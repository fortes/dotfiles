-- Obsidian-style [[wikilink]] autocomplete. Candidates are every note
-- filename plus every link target already used somewhere in the vault, even
-- when no note exists yet (Obsidian's "unresolved" links). Ranked by fuzzy
-- match plus how often each target is linked, so frequent people float up.
--
-- obsidian.nvim's LSP completes links too, but doesn't rank by usage and
-- needs the LSP running; init.lua turns LSP completion off in the vault.
-- Needs rg; without it the index stays empty.

local M = {}

local root

-- Links to these are attachments, not notes, so they aren't candidates
local ATTACHMENT_EXTS = {
  avif = true, base = true, bmp = true, canvas = true, csv = true,
  excalidraw = true, flac = true, gif = true, heic = true, jpeg = true,
  jpg = true, m4a = true, mkv = true, mov = true, mp3 = true, mp4 = true,
  ogg = true, pdf = true, png = true, svg = true, wav = true, webm = true,
  webp = true, zip = true,
}

-- link text -> { path = 'people/Foo.md' | nil, count = <times linked> }.
-- Link text is the note name, or its path when several notes share a name
-- (Obsidian's "shortest path when possible").
local index = {}

local function build_index()
  -- vim.system() throws if rg is missing, which would abort all of init.lua
  if vim.fn.executable('rg') == 0 then
    return
  end
  local files, targets = {}, {}
  local pending = 2
  local function done()
    pending = pending - 1
    if pending > 0 then
      return
    end
    local by_name = {}
    for _, path in ipairs(files) do
      local name = vim.fn.fnamemodify(path, ':t:r')
      by_name[name] = by_name[name] or {}
      table.insert(by_name[name], path)
    end
    local next_index = {}
    local function entry(key)
      next_index[key] = next_index[key] or { count = 0 }
      return next_index[key]
    end
    -- Obsidian matches link targets to note names ignoring case
    local by_lower = {}
    for name, paths in pairs(by_name) do
      for _, path in ipairs(paths) do
        entry(#paths == 1 and name or path:gsub('%.md$', '')).path = path
      end
      by_lower[name:lower()] = by_lower[name:lower()] or name
    end
    for _, target in ipairs(targets) do
      local name = vim.fn.fnamemodify(target, ':t')
      name = by_name[name] and name or by_lower[name:lower()] or name
      local key = name
      if by_name[name] and #by_name[name] > 1 then
        -- Shared name: only links spelling out the note's path count
        key = next_index[target] and target
      end
      -- `[[folder/]]` has no name
      if key and key ~= '' then
        local e = entry(key)
        e.count = e.count + 1
      end
    end
    index = next_index
  end

  -- --no-config ignores ~/.config/ripgrep/rc: its --hidden would index
  -- .obsidian, .trash, ..., and --max-columns would truncate long links
  vim.system({ 'rg', '--no-config', '--files', '-g', '*.md' }, { cwd = root, text = true }, function(res)
    for path in (res.stdout or ''):gmatch('[^\n]+') do
      table.insert(files, path)
    end
    done()
  end)

  -- Link targets, without |alias, #heading, or ^block suffixes. Excluding `\`
  -- drops the escape in table links (`[[Note\|alias]]`).
  vim.system(
    { 'rg', '--no-config', '-o', '--no-filename', '--no-line-number', '-g', '*.md', [[\[\[[^\]|#^\n\\]+]] },
    { cwd = root, text = true },
    function(res)
      for target in (res.stdout or ''):gmatch('%[%[([^\n]+)') do
        target = vim.trim(target):gsub('%.md$', '')
        local ext = target:match('%.(%w+)$')
        if target ~= '' and not (ext and ATTACHMENT_EXTS[ext:lower()]) then
          table.insert(targets, target)
        end
      end
      done()
    end
  )
end

-- Column (0-based) just after an unclosed `[[` before the cursor, or nil.
-- Stops at `|` and `#` so aliases and heading refs don't re-trigger.
local function link_start()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(1, col)
  local open = before:match('.*()%[%[')
  if not open then
    return nil
  end
  local typed = before:sub(open + 2)
  if typed:find('[%]|#]') then
    return nil
  end
  return open + 1, typed, line:sub(col + 1)
end

local function candidates(typed, after)
  -- Don't add closing brackets if the link is already closed, including when
  -- typing inside an existing [[link]]
  local close = after:match('^[^%[%]]*%]%]') and '' or ']]'
  local names = vim.tbl_keys(index)
  local score = {}
  if typed ~= '' then
    local res = vim.fn.matchfuzzypos(names, typed)
    names = res[1]
    for i, name in ipairs(names) do
      score[name] = res[3][i]
    end
  end
  -- Fuzzy score plus a bonus for often-linked names, so a one-off typo link
  -- doesn't outrank someone linked 100+ times
  table.sort(names, function(a, b)
    local sa = (score[a] or 0) + 30 * math.log(index[a].count + 1)
    local sb = (score[b] or 0) + 30 * math.log(index[b].count + 1)
    if sa ~= sb then
      return sa > sb
    end
    return a < b
  end)
  local items = {}
  for i, name in ipairs(names) do
    if i > 200 then
      break
    end
    local e = index[name]
    local dir = e.path and vim.fn.fnamemodify(e.path, ':h')
    table.insert(items, {
      word = name .. close,
      abbr = name,
      menu = dir == '.' and '' or dir or '(no note)',
      kind = e.count > 0 and tostring(e.count) or '',
      equal = 1, -- we already filtered; don't let Vim re-filter
      user_data = 'wikilinks',
    })
  end
  return items
end

-- False until setup(), so callers don't need to know if the vault exists
local function in_vault(buf)
  if not root then
    return false
  end
  local name = vim.fn.resolve(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':p'))
  return vim.startswith(name, root .. '/')
end

function M.setup(vault_root)
  root = vault_root
  local group = vim.api.nvim_create_augroup('wikilinks', { clear = true })

  -- Global rather than per-buffer (set on FileType), which would stack a
  -- duplicate on every :edit / checktime reload
  vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChangedP' }, {
    group = group,
    pattern = '*.md',
    desc = 'Open and re-rank the wikilink menu while typing after [[',
    callback = function(args)
      if not in_vault(args.buf) then
        return
      end
      -- <C-n>/<C-p> change the text too; refreshing would drop the selection.
      -- Leave other menus (<C-x><C-o>, <C-n>) alone. LSP's menu also comes
      -- from complete(), so tell them apart by item rather than mode.
      local info = vim.fn.complete_info({ 'selected', 'items' })
      local first = info.items[1]
      if info.selected ~= -1 or (first and first.user_data ~= 'wikilinks') then
        return
      end
      local start, typed, after = link_start()
      if start then
        vim.fn.complete(start + 1, candidates(typed, after))
      end
    end,
  })

  -- With autopairs the `]]` is already there, so hop over it like Obsidian
  -- does; otherwise the cursor stays inside the link and the menu reopens
  vim.api.nvim_create_autocmd('CompleteDone', {
    group = group,
    desc = 'Move past the closing ]] after accepting a wikilink',
    callback = function()
      if vim.v.completed_item.user_data ~= 'wikilinks' then
        return
      end
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = vim.api.nvim_get_current_line()
      -- Completing inside an existing [[link]] only replaced the text before
      -- the cursor, so drop the rest of the old target (keeping |alias etc.)
      local after = line:sub(col + 1)
      if vim.v.event.reason == 'accept' and after:match('^[^%[%]]*%]%]') then
        local rest = after:match('^[^%]|#%^]*')
        if rest ~= '' then
          vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col + #rest, {})
          line = vim.api.nvim_get_current_line()
        end
      end
      if line:sub(col + 1, col + 2) == ']]' then
        vim.api.nvim_win_set_cursor(0, { row, col + 2 })
      end
    end,
  })

  -- Pick up new notes and links as you write
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = '*.md',
    desc = 'Rebuild the wikilink index',
    callback = function(args)
      if in_vault(args.buf) then
        build_index()
      end
    end,
  })

  build_index()
end

M.in_vault = in_vault

return M
