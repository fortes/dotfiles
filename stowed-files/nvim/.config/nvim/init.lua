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

-- Fold options are window-local, so apply them to every window showing the
-- buffer. A buffer can also be loaded while outside any window (nvim-bqf
-- `bufload`s quickfix entries to preview them), in which case this is a no-op
-- rather than clobbering whichever window happens to be current.
local function set_foldexpr(bufnr, expr)
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    vim.wo[win][0].foldmethod = 'expr'
    vim.wo[win][0].foldexpr = expr
  end
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
  group = vim.api.nvim_create_augroup('lsp_attach', { clear = true }),
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
      set_foldexpr(bufnr, 'v:lua.vim.lsp.foldexpr()')
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

-- ============================================================================
-- `yo` option toggles, in the style of vim-unimpaired (whose [/] motions are
-- all built in as of Neovim 0.11, so the plugin isn't worth carrying). `yon`
-- and `yos` live in ~/.vimrc, since plain option toggles work in Vim too.
-- ============================================================================

-- Hides every diagnostic display at once: inline text, the current-line
-- virtual lines, and the E/W/H gutter signs (which with `signcolumn=auto:1-3`
-- from ~/.vimrc can claim three columns on a busy line). Diagnostics keep being
-- collected either way, so `<leader>e` floats and `<leader>q` still work while
-- everything is hidden.
-- `signs` is captured rather than hardcoded to `true` so a future
-- `signs = { ... }` table (custom text, severity filters) survives a round trip.
local diagnostic_signs = vim.diagnostic.config().signs
map('n', 'yoe', function()
  local on = not vim.diagnostic.config().virtual_text
  vim.diagnostic.config({
    virtual_text = on,
    virtual_lines = on and { current_line = true } or false,
    signs = on and diagnostic_signs or false,
  })
end, { desc = 'Toggle diagnostic (error) display' })

-- Harper is the grammar checker, and reports everything through its own
-- diagnostic namespace (`nvim.lsp.harper_ls.<client id>`), so disabling those
-- silences grammar hints without touching diagnostics from any other server.
map('n', 'yog', function()
  local found = false
  for ns, info in pairs(vim.diagnostic.get_namespaces()) do
    if vim.startswith(info.name, 'nvim.lsp.harper_ls.') then
      found = true
      vim.diagnostic.enable(not vim.diagnostic.is_enabled({ bufnr = 0, ns_id = ns }), {
        bufnr = 0,
        ns_id = ns,
      })
    end
  end
  if not found then
    vim.notify('harper-ls is not attached to this buffer', vim.log.levels.WARN)
  end
end, { desc = 'Toggle grammar (harper) hints' })

-- Plugin manager: vim.pack (built-in, nvim 0.12+).
-- Run `:lua vim.pack.update()` to install/update plugins.

-- Treesitter parsers to keep installed. Parser names aren't filetypes (`.tsx`
-- is filetype `typescriptreact` but parser `tsx`, `.sh` is `sh` but parser
-- `bash`); `vim.treesitter.language.get_lang()` does that mapping at runtime.
local treesitter_parsers = {
  'bash', 'css', 'diff', 'gotmpl', 'html', 'javascript',
  'json', 'lua', 'markdown', 'markdown_inline', 'python',
  'tsx', 'typescript', 'vim', 'yaml',
}

-- Build hooks must be registered before vim.pack.add() so that PackChanged
-- fires for the initial install. The augroup matters here beyond tidiness: a
-- duplicate hook (from re-sourcing this file) would run two parser builds at
-- once, racing each other over the same download cache.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pack_build', { clear = true }),
  desc = 'Build native plugin components after install/update',
  callback = function(ev)
    local spec = ev.data.spec
    local kind = ev.data.kind
    if kind == 'delete' then return end

    local path = ev.data.path

    if spec.name == 'nvim-treesitter' then
      -- On a fresh install PackChanged fires before the plugin is on
      -- 'runtimepath', so load it before calling into its Lua API
      if not ev.data.active then vim.cmd.packadd(spec.name) end
      -- `force` on update because a parser's ABI and generated queries have to
      -- match the plugin version, so existing parsers need rebuilding too --
      -- plain `install` is a no-op for anything already on disk. `summary`
      -- reports how many actually built: a compile failure is otherwise silent
      -- and leaves the language with queries but no parser.
      local task = require('nvim-treesitter').install(treesitter_parsers, {
        force = kind == 'update',
        summary = true,
      })
      -- Installing is async. Block on a fresh install, where highlighting,
      -- folding and indentation stay broken until the parsers exist and quitting
      -- mid-build leaves a language with queries but no parser. Updates can
      -- finish in the background, since the old parsers still work meanwhile.
      if kind == 'install' then
        -- Wrapped in a closure so the pcall also covers the method lookup, and
        -- a throw can't escape into vim.pack.add() and abort the plugin setups
        local ok, built = pcall(function() return task:wait(300000) end)
        if not ok or built == false then
          vim.notify(
            'nvim-treesitter: not all parsers built, see :TSLog',
            vim.log.levels.ERROR
          )
        end
      end
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
  -- Pin every server to one position encoding. Neovim advertises
  -- { 'utf-8', 'utf-16', 'utf-32' } and each server picks its favourite, so a
  -- TypeScript buffer ends up with tsc on utf-8 and harper/oxfmt/oxlint on
  -- utf-16 — column offsets that disagree on any line with multibyte
  -- characters, which `:checkhealth vim.lsp` flags. utf-16 is the one encoding
  -- the LSP spec requires every server to implement, so it's the safe common
  -- denominator. `'*'` is the lowest-priority config, so per-server settings
  -- below still win.
  vim.lsp.config('*', {
    capabilities = {
      general = { positionEncodings = { 'utf-16' } },
    },
  })

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

  -- root_dir returning nil prevents attachment, so oxfmt/oxlint
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
    -- Same as yamlls below: `markdown.mdx` is a filetype Neovim never sets
    -- (an .mdx file is detected as `conf`), so it only serves to make
    -- `:checkhealth vim.lsp` report an unknown filetype
    vim.lsp.config('marksman', { filetypes = { 'markdown' } })
    vim.lsp.enable('marksman')
  end

  if vim.fn.executable('pyright-langserver') == 1 then
    vim.lsp.enable('pyright')
  end

  -- TypeScript 7 ships the native compiler as plain `tsc`, which serves
  -- `tsc --lsp`; the `tsgo` preview binary and lspconfig's `tsgo` config are
  -- both deprecated in favour of it. No root_dir override here: lspconfig's
  -- `tsc` config already does its own (more thorough) Deno detection, keyed on
  -- package-manager lockfiles and deno.lock rather than just deno.json.
  if vim.fn.executable('tsc') == 1 then
    vim.lsp.enable('tsc')
  end

  if vim.fn.executable('vim-language-server') == 1 then
    vim.lsp.enable('vimls')
  end

  if vim.fn.executable('yaml-language-server') == 1 then
    -- lspconfig also lists `yaml.docker-compose`, `yaml.gitlab` and
    -- `yaml.helm-values`, which Neovim's filetype detection never produces --
    -- they only exist if you `:set filetype=` them by hand, so they just make
    -- `:checkhealth vim.lsp` complain about unknown filetypes. Dropping them
    -- costs nothing: compose files are plain `yaml`, and yaml-language-server
    -- picks their schema from SchemaStore by filename, not by filetype.
    vim.lsp.config('yamlls', { filetypes = { 'yaml' } })
    vim.lsp.enable('yamlls')
  end
end)

-- Treesitter. The `main` branch only ships parsers and queries: highlighting
-- and folding come from Neovim itself, indentation from the plugin. (`master`
-- is frozen and doesn't support nvim 0.12.) Parsers are installed by the
-- PackChanged hook above, which needs tree-sitter-cli on PATH.
use({ src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' }, function()
  -- A buffer's parser, or nil when there isn't a usable one. `get_parser`
  -- resolves the filetype to a parser name itself, and returns nil rather than
  -- throwing when the parser is missing or fails to load — notably on an ABI
  -- mismatch after a Neovim upgrade, until `:TSUpdate` runs.
  local function buf_parser(bufnr)
    -- When the filetype no longer maps to a language, `get_parser` falls back to
    -- whatever parser the buffer already holds, so clearing `filetype` would
    -- otherwise keep reporting the previous language
    if vim.bo[bufnr].filetype == '' then return nil end
    -- Second return value is an error message, deliberately dropped: "no parser
    -- for X" is the normal case for most filetypes, and `vim.notify` doesn't
    -- filter by level, so reporting it would fire on every plain-text buffer.
    -- `:checkhealth nvim-treesitter` is where to look when a parser is missing.
    local parser = vim.treesitter.get_parser(bufnr)
    return parser
  end

  -- Created once and shared: a second `clear = true` call would wipe the
  -- autocmd registered by the first
  local group = vim.api.nvim_create_augroup('treesitter', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    desc = 'Enable treesitter highlighting and indentation',
    callback = function(ev)
      local parser = buf_parser(ev.buf)
      if not parser then return end

      -- Loading the parser isn't enough: `start` also compiles the `highlights`
      -- query, which throws when query and parser disagree on node types — e.g.
      -- mid-`:TSUpdate`, when the new queries are already on the runtimepath but
      -- the old parser is still on disk. Unprotected, that error aborts every
      -- later FileType handler for the buffer (autopairs, autotag, obsidian,
      -- dirvish, fugitive).
      local ok, err = pcall(vim.treesitter.start, ev.buf, parser:lang())
      if not ok then
        vim.notify_once(('treesitter: %s\nRun :TSUpdate'):format(err), vim.log.levels.WARN)
        return
      end

      -- Without an `indents` query treesitter indents nothing at all, so leave
      -- those languages (diff, markdown_inline, vim, ...) to Neovim's own
      -- indent plugins
      if vim.treesitter.query.get(parser:lang(), 'indents') then
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })

  -- Folding is window-local, so buffers with neither an LSP folding provider
  -- nor a parser keep `foldmethod=marker` from ~/.vimrc. BufWinEnter as well as
  -- FileType, to catch buffers that only get a window later: LspAttach can only
  -- reach windows that exist when the server attaches, and nvim-bqf `bufload`s
  -- quickfix entries to preview them, so an LSP often attaches while the buffer
  -- has no window at all. This has to re-apply the LSP choice rather than bail
  -- out on seeing a capable client, or such a buffer ends up with no folding.
  vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
    group = group,
    desc = 'Enable LSP or treesitter folding',
    callback = function(ev)
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
        if client:supports_method('textDocument/foldingRange') then
          set_foldexpr(ev.buf, 'v:lua.vim.lsp.foldexpr()')
          return
        end
      end
      if buf_parser(ev.buf) then
        set_foldexpr(ev.buf, 'v:lua.vim.treesitter.foldexpr()')
      end
    end,
  })
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
  map('n', '<leader>*', function()
    builtin.live_grep({ default_text = vim.fn.expand('<cword>') })
  end, { desc = 'Live grep current word' })
  map('v', '<leader>*', function()
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

  -- Honor the vault's Obsidian.app daily-notes config so `:Obsidian today`
  -- and the Obsidian app stay in sync. Each field falls back independently to
  -- a canonical default if the file is missing or that field is unset. Read
  -- once at setup; restart nvim to pick up changes. The template is applied
  -- only on creation; editing it won't retro-fit existing notes.
  local function obsidian_sync()
    local synced = {
      templates_folder = '_templates',
      daily_notes = {
        folder = 'journal',
        date_format = 'YYYY-MM/YYYY-MM-DD',
        template = 'daily-journal.md',
      },
    }
    local path = vim.fn.expand('~/notes/.obsidian/daily-notes.json')
    if vim.fn.filereadable(path) == 0 then return synced end
    local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), '\n'))
    if not ok or type(decoded) ~= 'table' then return synced end
    if type(decoded.folder) == 'string' and decoded.folder ~= '' then
      synced.daily_notes.folder = decoded.folder
    end
    if type(decoded.format) == 'string' and decoded.format ~= '' then
      synced.daily_notes.date_format = decoded.format
    end
    if type(decoded.template) == 'string' and decoded.template ~= '' then
      -- Obsidian stores a vault-relative path (often without .md), e.g.
      -- "_templates/daily-journal". Split into the templates folder and the
      -- filename obsidian.nvim expects relative to it. A bare filename
      -- (fnamemodify ':h' returns '.') leaves the folder default in place.
      local dir = vim.fn.fnamemodify(decoded.template, ':h')
      local name = vim.fn.fnamemodify(decoded.template, ':t')
      if dir ~= '' and dir ~= '.' then
        synced.templates_folder = dir
      end
      synced.daily_notes.template = name:match('%.md$') and name or name .. '.md'
    end
    return synced
  end

  local synced = obsidian_sync()

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
      folder = synced.templates_folder,
    },
    daily_notes = vim.tbl_extend('force', synced.daily_notes, {
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
    group = vim.api.nvim_create_augroup('obsidian_notes', { clear = true }),
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

-- Highlight :XXX command ranges in cmdline
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
