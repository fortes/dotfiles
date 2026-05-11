-- vim:et ft=lua sts=2 sw=2 ts=2
-- Load all base / legacy options from ~/.vimrc
vim.cmd('source ~/.vimrc')

-- Helper for keymaps
local function map(mode, lhs, rhs, opts_or_bufnr)
  local opts = { noremap = true, silent = true }
  if type(opts_or_bufnr) == 'number' then
    opts.buffer = opts_or_bufnr
  elseif type(opts_or_bufnr) == 'table' then
    opts = vim.tbl_extend('force', opts, opts_or_bufnr)
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Set up diagnostic configuration
vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = {
    -- Only show multiple lines for current cursor line
    current_line = true,
  },
})

-- Set up LspAttach autocmd for keymaps and completion
-- Quite a few are now default as of v0.11:
-- `grn` to rename symbol
-- `grr` to find references
-- `gri` to find implementation
-- `gO` for document symbol
-- `gra` for code actions
-- `<C-S>` for signature help
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local bufnr = event.buf

    if not client then return end

    -- OXlint-specific keymaps
    if client.name == 'oxlint' then
      map('n', '<leader>x', function()
        vim.lsp.buf.code_action({
          context = { only = { 'source.fixAll' } },
          apply = true,
        })
      end, { buffer = bufnr, desc = 'Fix all OXlint issues' })
    end

    map('n', '<leader>e', vim.diagnostic.open_float, {
      buffer = bufnr,
      desc = 'Show diagnostics under the cursor',
    })
    map('n', '<leader>q', vim.diagnostic.setloclist, {
      buffer = bufnr,
      desc = 'Add buffer diagnostics to the location list',
    })
    -- `yod` already used by unimpaired for `diff`, use `yoe` (error). Toggles
    -- inline display only — diagnostics keep being collected so signs, the
    -- location list, and `<leader>e` floats still work.
    map('n', 'yoe', function()
      local cfg = vim.diagnostic.config()
      local on = not cfg.virtual_text
      vim.diagnostic.config({
        virtual_text = on,
        virtual_lines = on and { current_line = true } or false,
      })
    end, { buffer = bufnr, desc = 'Toggle diagnostic display' })

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    if client:supports_method('textDocument/definition') then
      -- Match VSCode mapping
      map('n', '<f12>', vim.lsp.buf.definition, {
        buffer = bufnr,
        desc = 'Go to definition',
      })
    end

    if client:supports_method('textDocument/hover') then
      -- `K` mapped by default, add `gh` to match VSCode vim mappings
      map('n', 'gh', vim.lsp.buf.hover, {
        buffer = bufnr,
        desc = 'Show LSP hover information',
      })
    end

    if client:supports_method('textDocument/foldingRange') then
      -- Enable LSP folding when available (overrides treesitter folding)
      vim.api.nvim_set_option_value('foldmethod', 'expr', { win = 0 })
      vim.api.nvim_set_option_value('foldexpr', 'v:lua.vim.lsp.foldexpr()', { win = 0 })
    end

    if client:supports_method('textDocument/references') then
      -- grr default in Neovim 0.11, use upper case to use Telescope
      map('n', 'gRR', function()
        require('telescope.builtin').lsp_references({ include_declaration = false })
      end, { buffer = bufnr, desc = 'Telescope LSP references' })
      -- Match VSCode mapping
      map('n', '<s-f12>', vim.lsp.buf.references, {
        buffer = bufnr,
        desc = 'Show references',
      })
    end

    if client:supports_method('textDocument/rename') then
      -- Match VSCode mapping
      map('n', '<f2>', vim.lsp.buf.rename, {
        buffer = bufnr,
        desc = 'Rename symbol',
      })
    end
  end,
})

-- Plugin manager: vim.pack (built-in, nvim 0.12+).
-- Run `:lua vim.pack.update()` to install/update plugins.

-- Build hooks must be registered before vim.pack.add() so that PackChanged
-- fires for the initial install
vim.api.nvim_create_autocmd('PackChanged', {
  desc = 'Build native plugin components after install/update',
  callback = function(ev)
    local spec = ev.data.spec
    local kind = ev.data.kind
    if kind == 'delete' then return end

    local path = ev.data.path

    if spec.name == 'nvim-treesitter' then
      -- PackChanged fires before pack_add adds the plugin to rtp, so prepend
      -- manually to make `require('nvim-treesitter')` resolve
      vim.schedule(function()
        vim.opt.rtp:prepend(path)
        require('nvim-treesitter').install({
          'bash', 'css', 'diff', 'gotmpl', 'html', 'javascript',
          'json', 'lua', 'markdown', 'markdown_inline', 'python',
          'tsx', 'typescript', 'vim', 'yaml',
        })
      end)
    end

    if spec.name == 'telescope-fzf-native.nvim' then
      vim.notify('Building telescope-fzf-native...', vim.log.levels.INFO)
      vim.system({ 'make', '-C', path }, { text = true }, function(result)
        if result.code ~= 0 then
          -- vim.notify can't be called in a libuv callback
          vim.schedule(function()
            vim.notify(
              'telescope-fzf-native build failed:\n' .. (result.stderr or ''),
              vim.log.levels.ERROR
            )
          end)
        end
      end)
    end
  end,
})

-- All specs are passed to vim.pack.add() at once; setups run in declaration
-- order after.
local _specs = {}
local _setups = {}
local function use(spec, setup_fn)
  table.insert(_specs, spec)
  if setup_fn then table.insert(_setups, setup_fn) end
end

-- Variables shared across multiple plugin setups
local copilot_enabled = os.getenv('ENABLE_GITHUB_COPILOT') == '1'

-- Per-buffer Deno detection so opening a Deno file from a non-Deno cwd
-- still routes to the right LSP/formatter
local function in_deno_project(bufnr)
  if os.getenv('ENABLE_DENO') == '1' then return true end
  return vim.fs.root(bufnr or 0, { 'deno.json', 'deno.jsonc' }) ~= nil
end

-- ============================================================================
-- Plugin declarations
-- ============================================================================

-- Utilities used by many plugins
use('https://github.com/nvim-lua/plenary.nvim')

-- Icons (used by which-key, telescope, etc)
use('https://github.com/nvim-tree/nvim-web-devicons', function()
  require('nvim-web-devicons').setup({})
end)

-- LSP server configurations
use('https://github.com/neovim/nvim-lspconfig', function()
  if vim.fn.executable('bash-language-server') == 1 then
    vim.lsp.enable('bashls')
  end

  if vim.fn.executable('vscode-css-language-server') == 1 then
    vim.lsp.enable('cssls')
  end

  -- Deno: root_markers gate attachment to buffers actually inside a Deno
  -- project (so this is safe to enable unconditionally)
  if vim.fn.executable('deno') == 1 then
    vim.lsp.config('denols', {
      root_markers = { 'deno.json', 'deno.jsonc' },
      single_file_support = false,
    })
    vim.lsp.enable('denols')
  end

  if vim.fn.executable('docker-langserver') == 1 then
    vim.lsp.enable('dockerls')
  end

  -- root_dir returning nil prevents attachment, so oxfmt/oxlint/tsgo
  -- skip Deno-managed buffers per-buffer (not just at startup)
  local function not_in_deno(extra_markers)
    return function(bufnr, on_dir)
      if in_deno_project(bufnr) then return end
      on_dir(vim.fs.root(bufnr, extra_markers) or vim.fn.getcwd())
    end
  end

  if vim.fn.executable('oxfmt') == 1 then
    vim.lsp.config('oxfmt', { root_dir = not_in_deno({ 'package.json' }) })
    vim.lsp.enable('oxfmt')
  end

  if vim.fn.executable('oxlint') == 1 then
    vim.lsp.config('oxlint', { root_dir = not_in_deno({ 'package.json', '.oxlintrc.json' }) })
    vim.lsp.enable('oxlint')
  end

  -- Harper (grammar/spell checker)
  if vim.fn.executable('harper-ls') == 1 then
    vim.lsp.config('harper_ls', {
      settings = {
        ['harper-ls'] = {
          linters = {
            SpellCheck = false,
          },
          -- Default on MacOS goes in ~/Library/Application Support/ which
          -- isn't stowed
          userDictPath = vim.fn.expand('~/.config/harper-ls/dictionary.txt'),
        },
      },
    })
    vim.lsp.enable('harper_ls')
  end

  if vim.fn.executable('vscode-html-language-server') == 1 then
    vim.lsp.enable('html')
  end

  if vim.fn.executable('vscode-json-language-server') == 1 then
    vim.lsp.enable('jsonls')
  end

  if vim.fn.executable('lua-language-server') == 1 then
    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = {
            -- Recognize the `vim` global
            globals = { 'vim' },
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file('', true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.enable('lua_ls')
  end

  if vim.fn.executable('marksman') == 1 then
    vim.lsp.enable('marksman')
  end

  if vim.fn.executable('pyright-langserver') == 1 then
    vim.lsp.enable('pyright')
  end

  if vim.fn.executable('tsgo') == 1 then
    vim.lsp.config('tsgo', { root_dir = not_in_deno({ 'tsconfig.json', 'package.json' }) })
    vim.lsp.enable('tsgo')
  end

  if vim.fn.executable('vim-language-server') == 1 then
    vim.lsp.enable('vimls')
  end

  if vim.fn.executable('yaml-language-server') == 1 then
    vim.lsp.enable('yamlls')
  end
end)

-- GitHub Copilot inline suggestions + NES (requires subscription + ENABLE_GITHUB_COPILOT=1)
if copilot_enabled then
  -- NES (next-edit suggestion) support; copilot.lua delegates NES to this plugin
  use('https://github.com/copilotlsp-nvim/copilot-lsp')
  use('https://github.com/zbirenbaum/copilot.lua', function()
    require('copilot').setup({
      -- Disable panel (we use inline suggestions only); clear its default
      -- open = '<M-CR>' keymap to avoid conflict with NES accept_and_goto
      panel = { enabled = false, keymap = { open = false } },
      filetypes = {
        markdown = true,
        -- Disable in UI/picker buffers
        TelescopePrompt = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          -- Tab is handled manually below to integrate with popup-menu navigation
          accept = false,
          accept_word = '<M-w>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
      },
      -- Next-edit suggestion: predicts and jumps to the next edit location
      -- NES keymaps are normal mode (valid fields: accept_and_goto, accept, dismiss)
      nes = {
        enabled = true,
        keymap = {
          accept_and_goto = '<M-CR>',
        },
      },
    })
  end)
end

-- Tab / S-Tab: override the vimrc pumvisible mappings (last definition wins,
-- since init.lua sources .vimrc at the top). Adds copilot accept at the front
-- of the priority chain when the plugin is loaded; otherwise identical to the
-- vimrc behaviour.
map('i', '<Tab>', function()
  if package.loaded['copilot.suggestion'] and require('copilot.suggestion').is_visible() then
    -- Undo point so `u` reverts just the accepted suggestion
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-g>u', true, false, true), 'n', false)
    require('copilot.suggestion').accept()
  elseif vim.fn.pumvisible() == 1 then
    return '<C-n>'
  else
    return '<Tab>'
  end
end, { expr = true, desc = 'Copilot accept / completion next / tab' })
map('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true, desc = 'Completion prev / S-Tab' })

-- Normal-mode Tab: accept NES when visible, else fall through. In terminals
-- that don't distinguish <Tab> from <C-i>, the fallthrough preserves the
-- default jumplist-forward behaviour; in terminals that do (kitty protocol),
-- <Tab> stays unmapped.
if copilot_enabled then
  map('n', '<Tab>', function()
    if vim.b.nes_state then
      local nes_api = require('copilot.nes.api')
      if nes_api.nes_apply_pending_nes() then
        nes_api.nes_walk_cursor_end_edit()
        return ''
      end
    end
    return '<Tab>'
  end, { expr = true, desc = 'Copilot accept NES / Tab' })
end

-- Treesitter: highlighting, indent, folding (use main branch for nvim 0.12 API)
-- Parsers are installed automatically via the PackChanged hook above
-- (requires tree-sitter-cli on PATH).
use({ src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' }, function()
  vim.api.nvim_create_autocmd('FileType', {
    desc = 'Enable treesitter highlighting and indentation',
    pattern = {
      'bash', 'css', 'diff', 'gotmpl', 'html', 'javascript', 'json',
      'lua', 'markdown', 'markdown_inline', 'python', 'tsx',
      'typescript', 'vim', 'yaml',
    },
    callback = function()
      local ok = pcall(vim.treesitter.start)
      if ok then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })
  -- Treesitter folding (LSP overrides per-buffer in LspAttach above)
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
end)

-- Autoclose / rename HTML/JSX/TSX tags
use('https://github.com/windwp/nvim-ts-autotag', function()
  require('nvim-ts-autotag').setup({
    opts = {
      enable_close_on_slash = true,
    },
  })
end)

-- Add `end` in Lua, Bash, Ruby, etc (auto-activates via treesitter)
use('https://github.com/RRethy/nvim-treesitter-endwise')

-- Split or join code blocks (<leader>m to toggle)
use('https://github.com/Wansmer/treesj', function()
  require('treesj').setup({
    use_default_keymaps = false,
    -- Node with syntax error will not be formatted
    check_syntax_error = true,
    -- If line after join will be longer than max value, node will not be formatted
    max_join_length = 120,
    -- Cursor stays on the node being formatted
    cursor_behavior = 'hold',
    notify = true,
    dot_repeat = true,
  })
  map('n', '<leader>m', require('treesj').toggle, { desc = 'Toggle node join' })
end)

-- Fuzzy finder for files, grep, buffers, etc
use('https://github.com/nvim-telescope/telescope.nvim', function()
  local telescope = require('telescope')
  local actions = require('telescope.actions')
  local action_layout = require('telescope.actions.layout')

  telescope.setup({
    defaults = {
      -- Conflicts with `winborder`; remove once
      -- https://github.com/nvim-lua/plenary.nvim/pull/649 lands
      border = false,
      -- Show all mappings via <C-/>
      mappings = {
        i = {
          ['<Esc>'] = actions.close,
          ['<M-p>'] = action_layout.toggle_preview,
        },
        n = {
          ['<M-p>'] = action_layout.toggle_preview,
        },
      },
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--trim', -- Remove leading indentation
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = 'smart_case',
      },
    },
    pickers = {
      find_files = { hidden = true },
      git_files = { show_untracked = true },
      live_grep = {
        additional_args = function() return { '--hidden' } end,
      },
    },
  })

  -- fzf-native requires a compiled library; silently skip until first build
  -- (run :lua vim.pack.update() to trigger the PackChanged build hook)
  pcall(telescope.load_extension, 'fzf')
  telescope.load_extension('ui-select')

  -- Fallback to file search if not in a git repo. git_files is async so
  -- pcall around it doesn't catch "not a git repo" — check up front.
  local function project_files()
    if vim.fs.root(0, '.git') then
      require('telescope.builtin').git_files({
        use_git_root = true,
        show_untracked = true,
      })
    else
      require('telescope.builtin').find_files({ hidden = true })
    end
  end

  local builtin = require('telescope.builtin')
  map('n', '<leader>t', builtin.builtin, { desc = 'Telescope pickers' })
  map('n', 'z=', builtin.spell_suggest, { desc = 'Spelling suggestions' })
  map('n', '<c-p>', project_files, { desc = 'Project files' })
  map('n', '<m-b>', builtin.buffers, { desc = 'Buffers' })
  map('n', '<m-g>', builtin.git_status, { desc = 'Git status' })
  map('n', '<m-m>', builtin.marks, { desc = 'Marks' })
  map('n', '<m-p>', builtin.oldfiles, { desc = 'Old files' })
  map('n', '<m-r>', builtin.registers, { desc = 'Registers' })
  -- Replace lgrep bindings from ~/.vimrc with live grepping and selection
  map('n', 'Q', function()
    builtin.live_grep({ default_text = vim.fn.expand('<cword>') })
  end, { desc = 'Live grep current word' })
  map('v', 'Q', function()
    -- Save current `s` register before overwriting
    local old_reg = vim.fn.getreg('s')
    local old_regtype = vim.fn.getregtype('s')
    vim.cmd('normal! "sy')
    local selection = vim.fn.getreg('s')
    vim.fn.setreg('s', old_reg, old_regtype)
    builtin.live_grep({ default_text = selection })
  end, { desc = 'Live grep selection' })
end)

-- Native FZF sorting for telescope (built via PackChanged after :lua vim.pack.update())
use('https://github.com/nvim-telescope/telescope-fzf-native.nvim')

-- Use telescope for vim.ui.select prompts
use('https://github.com/nvim-telescope/telescope-ui-select.nvim')

-- Clipboard history via telescope (<leader>cl)
use('https://github.com/AckslD/nvim-neoclip.lua', function()
  require('neoclip').setup({})
  -- Must load after telescope is set up
  require('telescope').load_extension('neoclip')
  map('n', '<leader>cl', function()
    require('telescope').extensions.neoclip.default()
  end, { desc = 'Clipboard history' })
end)

-- Formatting (<leader>f for buffer, gq for selection)
use('https://github.com/stevearc/conform.nvim', function()
  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

  -- Use `deno` for formatting when in a deno project, oxfmt otherwise
  local function deno_or_oxfmt(bufnr)
    if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' }) ~= nil then
      return { 'deno_fmt', lsp_format = 'prefer' }
    end
    return { 'oxfmt' }
  end

  require('conform').setup({
    default_format_opts = {
      lsp_format = 'fallback',
    },
    format_after_save = function(bufnr)
      -- Skip ~/notes — obsidian.nvim sets tabs there, but oxfmt would
      -- reformat with spaces and undo the per-buffer setting.
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      if vim.startswith(file_path, vim.fn.expand('~/notes/')) then
        return nil
      end
      return {}
    end,
    formatters = {
      oxfmt = {
        command = 'oxfmt',
        args = { '--stdin-filepath', '$FILENAME' },
        stdin = true,
      },
      shfmt = {
        prepend_args = { '-i', '2', '-ci', '-bn' },
      },
    },
    formatters_by_ft = {
      bash = { 'shfmt' },
      css = { 'oxfmt' },
      html = { 'oxfmt' },
      javascript = deno_or_oxfmt,
      javascriptreact = deno_or_oxfmt,
      json = deno_or_oxfmt,
      jsonc = deno_or_oxfmt,
      markdown = deno_or_oxfmt,
      python = { 'ruff' },
      typescript = deno_or_oxfmt,
      typescriptreact = deno_or_oxfmt,
      yaml = { 'oxfmt' },
    },
  })

  map('', '<leader>f', function()
    require('conform').format({ async = true })
  end, { desc = 'Format buffer' })
end)

-- Obsidian notes integration (active only in ~/notes directory)
-- No version pin: vim.pack doesn't support wildcard releases, tracks main branch
use('https://github.com/obsidian-nvim/obsidian.nvim', function()
  -- obsidian.nvim hard-errors if no configured workspace path exists
  if vim.fn.isdirectory(vim.fn.expand('~/notes')) == 0 then
    return
  end

  -- Honor the vault's Obsidian.app daily-notes config (folder, format,
  -- template) so `:Obsidian today` and the Obsidian app stay in sync. Each
  -- field falls back to a canonical default if the file is missing or that
  -- field is unset. Read once at setup; restart nvim to pick up changes. The
  -- template is applied only on creation; editing it won't retro-fit existing
  -- notes.
  local function daily_notes_config()
    local config = {
      folder = 'journal',
      date_format = 'YYYY/MM/YYYY-MM-DD',
      template = 'daily-journal.md',
    }
    local path = vim.fn.expand('~/notes/.obsidian/daily-notes.json')
    if vim.fn.filereadable(path) == 0 then return config end
    local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), '\n'))
    if not ok or type(decoded) ~= 'table' then return config end
    if type(decoded.folder) == 'string' and decoded.folder ~= '' then
      config.folder = decoded.folder
    end
    if type(decoded.format) == 'string' and decoded.format ~= '' then
      config.date_format = decoded.format
    end
    if type(decoded.template) == 'string' and decoded.template ~= '' then
      -- Obsidian stores a vault-relative path (often without .md);
      -- obsidian.nvim wants a filename relative to templates.folder.
      local name = vim.fn.fnamemodify(decoded.template, ':t')
      config.template = name:match('%.md$') and name or name .. '.md'
    end
    return config
  end

  require('obsidian').setup({
    legacy_commands = false,
    workspaces = {
      {
        name = 'notes',
        path = '~/notes',
      },
    },
    -- Vault convention is TitleCase filenames (e.g. "My Note Title" →
    -- MyNoteTitle.md). builtin.title_id slugifies to lowercase-with-hyphens,
    -- and zettel_id produces random short IDs - neither matches.
    note_id_func = function(title)
      local id = title and (title:gsub('%s+', '')) or ''
      if id == '' then
        return require('obsidian.builtin').zettel_id()
      end
      return id
    end,
    -- Notes use rich custom frontmatter (location, journal flags, etc) that
    -- the built-in func would normalize away. Leave it alone.
    frontmatter = { enabled = false },
    templates = {
      folder = '_templates',
    },
    daily_notes = vim.tbl_extend('force', daily_notes_config(), {
      -- Existing journal entries don't carry this tag
      default_tags = {},
      -- `:Obsidian today` should land on today, not skip back to Friday
      workdays_only = false,
    }),
    -- Colocate pasted images with the note: `./` resolves relative to the
    -- current file, so people/Foo.md pastes into people/attachments/.
    attachments = { folder = './attachments' },
    picker = { name = 'telescope.nvim' },
    -- Use [[wikilinks]] with the shortest unambiguous path; auto_update
    -- rewrites existing references when renaming via :Obsidian rename
    link = { style = 'wiki', format = 'shortest', auto_update = true },
    -- conceallevel is set per-buffer in the BufEnter autocmd below
    ui = { ignore_conceal_warn = true },
  })

  map('n', '<leader>os', '<cmd>Obsidian quick_switch<cr>', { desc = 'Obsidian quick switch' })
  map('n', '<leader>of', '<cmd>Obsidian search<cr>', { desc = 'Obsidian search' })
  map('n', '<leader>ob', '<cmd>Obsidian backlinks<cr>', { desc = 'Obsidian backlinks' })
  map('n', '<leader>ot', '<cmd>Obsidian today<cr>', { desc = 'Obsidian today' })
  map('n', '<leader>oT', '<cmd>Obsidian template<cr>', { desc = 'Obsidian insert template' })
  map('n', '<leader>on', '<cmd>Obsidian new<cr>', { desc = 'Obsidian new note' })
  map('n', '<leader>or', '<cmd>Obsidian rename<cr>', { desc = 'Obsidian rename' })
  map('n', '<leader>oc', '<cmd>Obsidian toc<cr>', { desc = 'Obsidian table of contents' })
  map('v', '<leader>ol', '<cmd>Obsidian link<cr>', { desc = 'Obsidian link selection' })

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*.md',
    desc = 'Notes-specific buffer settings',
    callback = function()
      local file_path = vim.fn.expand('%:p')
      local notes_path = vim.fn.expand('~/notes/')
      if vim.startswith(file_path, notes_path) then
        -- Tabs instead of spaces
        vim.opt_local.expandtab = false
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        -- Required by obsidian.nvim for [[wikilink]] / link rendering
        vim.opt_local.conceallevel = 2

        -- <CR>, ]o, [o are bound by obsidian.nvim's own autocmd (api.smart_action,
        -- api.nav_link) for any buffer in the workspace; don't override them.
        -- `:Obsidian smart_action` and `:Obsidian nav_link` aren't registered
        -- as subcommands, so the cmdline form would error. <CR> follows
        -- wikilinks; built-in gf keeps working for raw paths and URLs.
      end
    end,
  })
end)

-- Highlight :XXX command ranges in cmdline (cmd-parser is required by range-highlight)
use('https://github.com/winston0410/cmd-parser.nvim')
use('https://github.com/winston0410/range-highlight.nvim', function()
  require('range-highlight').setup({})
end)

-- Show available keybindings, marks, registers (<leader>?)
use('https://github.com/folke/which-key.nvim', function()
  require('which-key').setup({})
  map('n', '<leader>?', function()
    require('which-key').show({ global = false })
  end, { desc = 'Buffer Local Keymaps (which-key)' })
end)

-- Preview line number before jumping with :NNN
use('https://github.com/nacro90/numb.nvim', function()
  require('numb').setup()
end)

-- Git signs in gutter, blame, hunk navigation
-- `[c` / `]c` to jump between hunks
-- <leader>hs to stage hunk, <leader>hp to preview hunk
use('https://github.com/lewis6991/gitsigns.nvim', function()
  require('gitsigns').setup({
    current_line_blame = true,
    on_attach = function(bufnr)
      local gitsigns = require('gitsigns')

      -- ]c next hunk
      map('n', ']c', function()
        if vim.wo.diff then vim.cmd.normal({ ']c', bang = true })
        else gitsigns.nav_hunk('next') end
      end, { buffer = bufnr, desc = 'Next hunk' })
      -- [c previous hunk
      map('n', '[c', function()
        if vim.wo.diff then vim.cmd.normal({ '[c', bang = true })
        else gitsigns.nav_hunk('prev') end
      end, { buffer = bufnr, desc = 'Previous hunk' })

      map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>', { buffer = bufnr, desc = 'Stage hunk' })
      map('v', '<leader>hs', function()
        gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, { buffer = bufnr, desc = 'Stage hunk' })
      map('n', '<leader>hS', ':Gitsigns undo_stage_hunk<CR>', { buffer = bufnr, desc = 'Unstage hunk' })
      map('n', '<leader>hp', ':Gitsigns preview_hunk<CR>', { buffer = bufnr, desc = 'Preview hunk' })
      map('n', '<leader>hi', ':Gitsigns preview_hunk_inline<CR>', { buffer = bufnr, desc = 'Preview hunk inline' })
      map('n', '<leader>hr', ':Gitsigns reset_hunk<CR>', { buffer = bufnr, desc = 'Reset hunk' })
      map('v', '<leader>hr', function()
        gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, { buffer = bufnr, desc = 'Reset hunk' })

      map('n', '<leader>gB', ':Gitsigns blame_line<CR>', { buffer = bufnr, desc = 'Show blame for current line' })
      map('n', '<leader>gbl', ':Gitsigns toggle_current_line_blame<CR>', { buffer = bufnr, desc = 'Toggle current line blame' })
      map('n', '<leader>gd', ':Gitsigns toggle_deleted<CR>', { buffer = bufnr, desc = 'Toggle deleted markers' })
      map('n', '<leader>gs', ':Gitsigns toggle_signs<CR>', { buffer = bufnr, desc = 'Toggle git signs' })
      map('n', '<leader>gw', ':Gitsigns toggle_word_diff<CR>', { buffer = bufnr, desc = 'Toggle word diff' })
    end,
  })
end)

-- Extend `ga` with more character info (digraphs, emoji, etc)
use('https://github.com/tpope/vim-characterize')

-- UNIX shell commands (:Remove, :Move, :Rename, etc)
use('https://github.com/tpope/vim-eunuch')

-- Git integration (:Git, :Gblame, etc)
use('https://github.com/tpope/vim-fugitive')

-- Better file browser (replaces netrw)
-- `-` to open parent dir, `x` to add to arglist, visual <Enter> to open all
use('https://github.com/justinmk/vim-dirvish', function()
  vim.o.autochdir = false
  vim.g['loaded_netrwPlugin'] = 1
  vim.api.nvim_create_user_command('Explore', 'Dirvish <args>', { nargs = '?', complete = 'dir' })
  vim.api.nvim_create_user_command('Sexplore', 'belowright split | silent Dirvish <args>', { nargs = '?', complete = 'dir' })
  vim.api.nvim_create_user_command('Vexplore', 'leftabove vsplit | silent Dirvish <args>', { nargs = '?', complete = 'dir' })
  vim.api.nvim_create_user_command('Lexplore', 'topleft vsplit | silent Dirvish <args>', { nargs = '?', complete = 'dir' })
  vim.api.nvim_create_user_command('Texplore', 'tabnew | silent Dirvish <args>', { nargs = '?', complete = 'dir' })
  vim.api.nvim_create_augroup('dirvish_bindings', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = 'dirvish_bindings',
    pattern = 'dirvish',
    callback = function()
      map('n', '<cr>', function()
        vim.cmd('call dirvish#open("edit", 0)')
      end, { buffer = 0, desc = 'Open file' })
      map('n', '<leader>T', function()
        vim.cmd('call dirvish#open("tabedit", 0)')
      end, { buffer = 0, desc = 'Open file in new tab' })
      map('n', '<leader>s', function()
        vim.cmd('call dirvish#open("split", 0)')
      end, { buffer = 0, desc = 'Open file in split' })
      map('n', '<leader>v', function()
        vim.cmd('call dirvish#open("vsplit", 0)')
      end, { buffer = 0, desc = 'Open file in vsplit' })
    end,
  })
end)

-- Git status decorations in dirvish ([f/]f to jump between git files)
use('https://github.com/kristijanhusak/vim-dirvish-git')

-- Surround text with quotes/parens/tags
use('https://github.com/kylechui/nvim-surround', function()
  require('nvim-surround').setup({})
end)

-- [/] movements + `y` option toggles
use('https://github.com/tpope/vim-unimpaired')

-- Repeat plugin actions with `.`
use('https://github.com/tpope/vim-repeat')

-- Readline-like bindings in insert/command mode
use('https://github.com/tpope/vim-rsi')

-- Auto-close parens, brackets, quotes
use('https://github.com/windwp/nvim-autopairs', function()
  require('nvim-autopairs').setup({
    -- Use treesitter to check for pairs
    check_ts = true,
    disable_filetype = { 'TelescopePrompt' },
  })
end)

-- Quickfix improvements: preview, filter, history navigation
-- `p`/`P` toggle preview, <tab>/<s-tab> filter, `<`/`>` quickfix history
use('https://github.com/kevinhwang91/nvim-bqf', function()
  require('bqf').setup({
    auto_enable = true,
    preview = {
      auto_preview = true,
      win_height = 12,
      win_vheight = 12,
      delay_syntax = 80,
      border_chars = { '┃', '┃', '━', '━', '┏', '┓', '┗', '┛', '█' },
    },
    func_map = {
      -- Disable default fzf mapping (we use telescope)
      fzffilter = '',
    },
  })
end)

-- Color scheme
use('https://github.com/RRethy/base16-nvim', function()
  if vim.o.termguicolors then
    if os.getenv('COLOR_THEME') == 'light' then
      vim.opt.background = 'light'
      vim.cmd.colorscheme('base16-default-light')
    else
      vim.opt.background = 'dark'
      vim.cmd.colorscheme('base16-default-dark')
    end
  end
end)

-- ============================================================================
-- Install plugins and run setup functions
-- ============================================================================

vim.pack.add(_specs)

for _, setup_fn in ipairs(_setups) do
  setup_fn()
end

-- Load local config, if present
local local_config_path = vim.fn.expand('~/.nvimrc.local')
if vim.fn.filereadable(local_config_path) == 1 then
  vim.cmd('source ' .. local_config_path)
end
