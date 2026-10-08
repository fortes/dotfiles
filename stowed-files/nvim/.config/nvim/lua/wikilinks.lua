-- Obsidian-style [[wikilink]] autocomplete. Candidates are every note
-- filename plus every link target already used somewhere in the vault, even
-- when no note exists yet (Obsidian's "unresolved" links). Ranked by fuzzy
-- match plus how often each target is linked, so frequent people float up.
--
-- obsidian.nvim's LSP completes links too, but only to existing notes and
-- without ranking by usage; init.lua turns LSP completion off in the vault.

local M = {}

local root

-- Links to these are attachments, not notes, so they aren't candidates
local ATTACHMENT_EXTS = {
  base = true, canvas = true, csv = true, gif = true, jpeg = true, jpg = true,
  m4a = true, mov = true, mp3 = true, mp4 = true, pdf = true, png = true,
  svg = true, webm = true, webp = true,
}

-- name -> { path = 'people/Foo.md' | nil, count = <times linked> }
local index = {}

local function build_index()
  local next_index = {}
  local function entry(name)
    next_index[name] = next_index[name] or { count = 0 }
    return next_index[name]
  end
  local pending = 2
  local function done()
    pending = pending - 1
    if pending == 0 then
      index = next_index
    end
  end

  -- Hidden dirs (.obsidian, .scripts, ...) are skipped by rg by default
  vim.system({ 'rg', '--files', '-g', '*.md' }, { cwd = root, text = true }, function(res)
    for path in (res.stdout or ''):gmatch('[^\n]+') do
      entry(vim.fn.fnamemodify(path, ':t:r')).path = path
    end
    done()
  end)

  -- Link targets, without |alias, #heading, or ^block suffixes
  vim.system(
    { 'rg', '-o', '--no-filename', '--no-line-number', '-g', '*.md', [[\[\[[^\]|#^\n]+]] },
    { cwd = root, text = true },
    function(res)
      for target in (res.stdout or ''):gmatch('%[%[([^\n]+)') do
        target = vim.trim(target)
        -- Path-style links ([[people/Foo]]) collapse to the note name
        target = vim.fn.fnamemodify(target, ':t'):gsub('%.md$', '')
        local ext = target:match('%.(%w+)$')
        if target ~= '' and not (ext and ATTACHMENT_EXTS[ext:lower()]) then
          local e = entry(target)
          e.count = e.count + 1
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
    table.insert(items, {
      word = name .. close,
      abbr = name,
      menu = e.path and vim.fn.fnamemodify(e.path, ':h') or '(no note)',
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
      -- <C-n>/<C-p> change the text too; refreshing would drop the selection
      if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
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
      if vim.api.nvim_get_current_line():sub(col + 1, col + 2) == ']]' then
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
