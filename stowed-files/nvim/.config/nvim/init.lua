-- vim:et ft=lua sts=2 sw=2 ts=2
-- Load all base / legacy options from ~/.vimrc
vim.cmd('source ~/.vimrc')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Helper for keymaps
local function map(mode, lhs, rhs, opts_or_bufnr)
  local opts = {
    noremap = true,
    silent = true
  }
  if (type(opts_or_bufnr) == 'number') then
    opts.buffer = opts_or_bufnr
  elseif (type(opts_or_bufnr) == 'table') then
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
  }
})

-- Set up LspAttach autocmd for keymaps and completion
-- Quite a few are now default as of v0.11
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

    if not client then
      return
    end

    -- OXlint-specific keymaps
    if client.name == 'oxlint' then
      -- <leader>x to apply source.fixAll from OXlint
      map('n', '<leader>x', function()
        vim.lsp.buf.code_action({
          context = { only = { "source.fixAll" } },
          apply = true,
        })
      end, {
        buffer = bufnr,
        desc = "Fix all OXlint issues"
      })
    end

    map('n', '<leader>e', vim.diagnostic.open_float, {
      buffer = bufnr,
      desc = "Show diagnostics under the cursor"
    })
    map('n', '<leader>q', vim.diagnostic.setloclist, {
      buffer = bufnr,
      desc = "Add buffer diagnostics to the location list"
    })
    -- `yod` already used by unimpaired for `diff`, use `yoe` (error)
    map(
      'n',
      'yoe',
      function()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled())
      end,
      {
        buffer = bufnr,
        desc = "Toggle diagnostic display"
      }
    )

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true
      })
    end

    if client:supports_method('textDocument/definition') then
      -- Match VSCode mapping
      map('n', '<f12>', vim.lsp.buf.definition, {
        buffer = bufnr,
        desc = "Go to definition"
      })
    end

    if client:supports_method('textDocument/hover') then
      -- `K` mapped by default, add `gh` to match VSCode vim mappings
      map('n', 'gh', vim.lsp.buf.hover, {
        buffer = bufnr,
        desc = "Show LSP hover information"
      })
    end

    if client:supports_method('textDocument/foldingRange') then
      -- Enable LSP folding, when available
      vim.api.nvim_set_option_value('foldmethod', 'expr', { win = 0 })
      vim.api.nvim_set_option_value('foldexpr', 'v:lua.vim.lsp.foldexpr()', { win = 0 })
    end

    if client:supports_method('textDocument/references') then
      -- grr default in Neovim 0.11, use upper case to use Telescope
      map('n', 'gRR', function()
        require('telescope.builtin').lsp_references({
          include_declaration = false,
        })
      end, {
        buffer = bufnr,
        desc = "Telescope LSP references"
      })
      -- Match VSCode mapping
      map('n', '<s-f12>', vim.lsp.buf.references, {
        buffer = bufnr,
        desc = "Show references"
      })
    end

    if client:supports_method('textDocument/rename') then
      -- Match VSCode mapping
      map('n', '<f2>', vim.lsp.buf.rename, {
        buffer = bufnr,
        desc = "Rename symbol"
      })
    end
  end,
})

require("lazy").setup({
  -- LSP configuration plugin providing defaults for all servers
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Bash
      if vim.fn.executable('bash-language-server') == 1 then
        vim.lsp.enable('bashls')
      end

      if vim.fn.executable('copilot-language-server') == 1 then
        -- Enable built-in Copilot LSP (requires Neovim 0.11.2+)
        vim.lsp.enable("copilot")
      end

      -- Check if cwd is in a Deno project (or forced via env var)
      local in_deno_project = os.getenv('ENABLE_DENO') == '1' or
          vim.fs.root(vim.fn.getcwd(), { 'deno.json', 'deno.jsonc' }) ~= nil

      -- CSS
      if vim.fn.executable('vscode-css-language-server') == 1 then
        vim.lsp.enable('cssls')
      end

      -- Deno (only enable if cwd is a deno project)
      if vim.fn.executable('deno') == 1 and in_deno_project then
        vim.lsp.config('denols', {
          root_markers = { "deno.json", "deno.jsonc" },
          single_file_support = false,
        })
        vim.lsp.enable('denols')
      end

      -- Docker
      if vim.fn.executable('docker-langserver') == 1 then
        vim.lsp.enable('dockerls')
      end

      -- OXfmt (only enable if not in a deno project)
      if vim.fn.executable('oxfmt') == 1 and not in_deno_project then
        vim.lsp.enable('oxfmt')
      end

      -- OXlint (only enable if not in a deno project)
      if vim.fn.executable('oxlint') == 1 and not in_deno_project then
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
            }
          }
        })
        vim.lsp.enable('harper_ls')
      end

      -- HTML
      if vim.fn.executable('vscode-html-language-server') == 1 then
        vim.lsp.enable('html')
      end

      -- JSON
      if vim.fn.executable('vscode-json-language-server') == 1 then
        vim.lsp.enable('jsonls')
      end

      -- Lua (with custom settings)
      if vim.fn.executable('lua-language-server') == 1 then
        vim.lsp.config('lua_ls', {
          settings = {
            Lua = {
              runtime = {
                version = 'LuaJIT',
              },
              diagnostics = {
                -- Recognize the `vim` global
                globals = { 'vim' },
              },
              workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        })
        vim.lsp.enable('lua_ls')
      end

      -- Markdown
      if vim.fn.executable('marksman') == 1 then
        vim.lsp.enable('marksman')
      end

      -- Python
      if vim.fn.executable('pyright-langserver') == 1 then
        vim.lsp.enable('pyright')
      end

      -- TypeScript (only enable if not in a deno project)
      if vim.fn.executable('tsgo') == 1 and not in_deno_project then
        vim.lsp.enable('tsgo')
      end

      -- Vim
      if vim.fn.executable('vim-language-server') == 1 then
        vim.lsp.enable('vimls')
      end

      -- YAML
      if vim.fn.executable('yaml-language-server') == 1 then
        vim.lsp.enable('yamlls')
      end
    end,
  },

  -- GitHub Co-Pilot is paid, so only load if #ENABLE_GITHUB_COPILOT is set
  -- Use <leader><tab> to accept and go to next edit suggestion
  {
    "github/copilot.vim",
    cmd = "Copilot",
    cond = function()
      return os.getenv("ENABLE_GITHUB_COPILOT") == "1"
    end,
    config = function()
      -- Enable for markdown
      vim.g.copilot_filetypes = {
        markdown = true,
        DressingInput = false,
        Telescope = false,
        ['copilot-chat'] = false,
      }
    end,
    event = "InsertEnter",
  },

  -- Sidekick for AI CLI integration (e.g., ChatGPT, Claude, etc)
  -- Also supports next-edit suggestions from GitHub Copilot, via <tab>
  -- TODO: Should be able to rely on native LSP support in v0.12+ once released
  {
    "folke/sidekick.nvim",
    opts = {
      -- add any options here
      cli = {
        mux = {
          backend = "tmux",
          enabled = true,
        },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Sidekick Toggle Claude",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },

  -- GitHub Copilot chat, which isn't in copilot.vim yet
  --
  -- <leader>cc to toggle chat
  -- <C-l> to reset chat
  -- <leader>cc in visual to chat using selection
  -- :CopilotChatModels to view/select models
  -- :CopilotChatPrompts for predefined prompts like Explain/Review/Tests
  --
  -- <C-s> in insert mode to submit chat (<CR> in normal mode)
  -- <C-y> to accept nearest diff
  -- gh for help
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cond = function()
      return os.getenv("ENABLE_GITHUB_COPILOT") == "1"
    end,
    dependencies = {
      { "github/copilot.vim" },
      -- for curl, log and async functions
      { "nvim-lua/plenary.nvim" },
    },
    -- Note: Only on MacOS or Linux
    build = "make tiktoken",
    config = function()
      local chat = require('CopilotChat')
      local select = require('CopilotChat.select')

      chat.setup({})

      map('n', '<leader>cc', chat.toggle, {
        desc = "Toggle Copilot chat",
      })
      map(
        'v',
        '<leader>cc',
        function()
          local input = vim.fn.input("Ask Copilot: ", "Fix this code")
          if input ~= "" then
            chat.ask(input, {
              selection = select.visual
            })
          end
        end,
        { desc = "Copilot Chat with selection" }
      )
    end,
  },

  -- Show LSP progress in lower right
  {
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup({})
    end
  },

  -- Treesitter for better highlighting, indent, etc
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        auto_install = true,
        ensure_installed = {
          'bash',
          'css',
          'diff',
          'gotmpl',
          'html',
          'javascript',
          'json',
          'lua',
          'python',
          'tsx',
          'typescript',
          'vim',
          'yaml'
        },
        highlight = {
          enable = true
        },
        ignore_install = {},
        -- Enable `=` for indentation based on Treesitter (experimental)
        indent = {
          enable = true
        },
        modules = {},
        sync_install = false,
      }

      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end,
    lazy = false,
  },

  -- Create text objects using Treesitter queries
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
            }
          }
        }
      }
    end
  },

  -- Use Treesitter to autoclose / rename tags
  {
    'windwp/nvim-ts-autotag',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close_on_slash = true,
        }
      })
    end
  },

  -- Use Treesitter to add `end` in Lua, Bash, etc
  {
    'RRethy/nvim-treesitter-endwise',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
  },

  -- Use Treesitter to do LSP-like things:
  {
    'nvim-treesitter/nvim-treesitter-refactor',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        refactor = {
          highlight_definitions = { enable = true },
        },
      }
    end
  },

  -- Use Treesitter to infer correct `commentstring`
  {
    'joosepalviste/nvim-ts-context-commentstring',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
  },

  -- Split or Join blocks of code
  {
    'Wansmer/treesj',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('treesj').setup({
        use_default_keymaps = false,

        -- Node with syntax error will not be formatted
        check_syntax_error = true,

        -- If line after join will be longer than max value,
        -- node will not be formatted
        max_join_length = 120,

        -- hold|start|end:
        -- hold - cursor follows the node/place on which it was called
        -- start - cursor jumps to the first symbol of the node being formatted
        -- end - cursor jumps to the last symbol of the node being formatted
        cursor_behavior = 'hold',

        -- Notify about possible problems or not
        notify = true,
        -- Use `dot` for repeat action
        dot_repeat = true,
      })

      -- Key mappings: <space>m - toggle
      map('n', '<leader>m', require('treesj').toggle, {
        desc = 'Toggle node join',
      })
    end,
  },

  -- Fuzzy finder for all the things
  {
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        -- Helper functions
        'nvim-lua/plenary.nvim',
        -- Support FZF syntax
        'nvim-telescope/telescope-fzf-native.nvim',
        -- Use telescope for `vim.ui.select`
        'nvim-telescope/telescope-ui-select.nvim'
      },
      config = function()
        local telescope = require('telescope')
        local actions = require('telescope.actions')
        local action_layout = require('telescope.actions.layout')

        telescope.setup {
          defaults = {
            -- Conflicts with `winborder`, remove once
            -- https://github.com/nvim-lua/plenary.nvim/pull/649 lands
            border = false,
            -- Show all mappings via <C-/>
            mappings = {
              i = {
                ["<Esc>"] = actions.close,
                ["<M-p>"] = action_layout.toggle_preview,
              },
              n = {
                ["<M-p>"] = action_layout.toggle_preview,
              },
            },
            vimgrep_arguments = {
              "rg",
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
              "--smart-case",
              "--trim" -- Remove indentation
            }
          },
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = 'smart_case'
            }
          },
          pickers = {
            find_files = {
              hidden = true,
            },
            git_files = {
              show_untracked = true,
            },
            live_grep = {
              additional_args = function(opts)
                return { "--hidden" }
              end,
              hidden = true,
            },
          }
        }

        telescope.load_extension('fzf')
        telescope.load_extension('ui-select')

        -- Fallback to file search if not in git repo
        local project_files = function()
          local ok = pcall(require "telescope.builtin".git_files, {
            use_git_root = true,
            show_untracked = true
          })
          if not ok then
            require "telescope.builtin".find_files({
              hidden = true
            })
          end
        end

        local builtin = require('telescope.builtin')

        -- Key mappings
        map('n', '<leader>t', builtin.builtin, { desc = "Telescope pickers" })
        map('n', 'z=', builtin.spell_suggest, { desc = "Spelling suggestions" })
        map('n', '<c-p>', project_files, { desc = "Project files" })
        map('n', '<m-b>', builtin.buffers, { desc = "Buffers" })
        map('n', '<m-g>', builtin.git_status, { desc = "Git status" })
        map('n', '<m-m>', builtin.marks, { desc = "Marks" })
        map('n', '<m-p>', builtin.oldfiles, { desc = "Old files" })
        map('n', '<m-r>', builtin.registers, { desc = "Git status" })
        -- Replace lgrep bindings from ~/.vimrc with live grepping and selection
        map(
          'n',
          'Q',
          function()
            builtin.live_grep({
              default_text = vim.fn.expand("<cword>")
            })
          end,
          { desc = "Live grep current word" }
        )
        map(
          'v',
          'Q',
          function()
            -- Save current `s` register before overwriting
            local old_reg = vim.fn.getreg('s')
            local old_regtype = vim.fn.getregtype('s')

            -- Copy & save selection
            vim.cmd('normal! "sy')
            local selection = vim.fn.getreg('s')

            -- Restore previous
            vim.fn.setreg('s', old_reg, old_regtype)

            builtin.live_grep({
              default_text = selection
            })
          end,
          { desc = "Live grep selection" }
        )
      end
    },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make'
    }
  },

  {
    'AckslD/nvim-neoclip.lua',
    dependencies = {
      -- Uses telescope for selection
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('neoclip').setup({})

      map(
        'n',
        '<leader>cl',
        ':lua require("telescope").extensions.neoclip.default()<cr>',
        { desc = 'Clipboard history' }
      )
    end
  },

  -- Formatting, use <leader>f to format buffer / `gq` for selection
  {
    'stevearc/conform.nvim',
    cmd = { "ConformInfo" },
    event = "BufWritePre",
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      -- Use `deno` for formatting when in a deno project, oxfmt otherwise
      local deno_or_oxfmt = function(bufnr)
        -- Let `deno` LSP format when in a deno project, fall back to oxfmt
        if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' }) ~= nil then
          return { 'deno_fmt', lsp_format = 'prefer' }
        end
        return { 'oxfmt' }
      end

      require("conform").setup({
        default_format_opts = {
          lsp_format = "fallback",
        },
        format_after_save = {
          -- Options will be passed to conform.format()
          async = true,
          timeout_ms = 500,
        },
        formatters = {
          oxfmt = {
            command = 'oxfmt',
            args = { '--stdin-filename', '$FILENAME' },
            stdin = true,
          },
          shfmt = {
            prepend_args = { "-i", "2", "-ci", "-bn" },
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
    end,
  },

  {
    "obsidian-nvim/obsidian.nvim",
    -- Latest release instead of latest commit
    version = "*",
    ft = "markdown",
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "notes",
          path = "~/notes",
        },
      },
    },
    init = function()
      -- Set `conceallevel` for markdown files in ~/notes before obsidian loads
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.md",
        callback = function()
          local file_path = vim.fn.expand('%:p')
          local notes_path = vim.fn.expand('~/notes/')
          if vim.startswith(file_path, notes_path) then
            vim.opt_local.conceallevel = 2
            -- Use tabs instead of spaces
            vim.opt_local.expandtab = false
            vim.opt_local.shiftwidth = 4
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 4
          end
        end,
        desc = "Set conceallevel and tab settings for obsidian notes"
      })
    end,
  },

  -- Highlight ranges in timeline
  {
    'winston0410/range-highlight.nvim',
    event = "CmdlineEnter",
    opts = {},
  },

  -- Display available key bindings, marks, registers, etc
  {
    'folke/which-key.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    event = "VeryLazy",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  -- Preview line number via `:XXX` before moving
  {
    'nacro90/numb.nvim',
    event = "CmdlineEnter",
    config = function()
      require('numb').setup()
    end
  },

  -- Shows git diff in signs column
  -- `[c` / `]c` to jump between hunks
  -- <leader>hs to stage hunk
  -- <leader>hp to preview hunk
  -- <leader>hi to preview hunk (inline)
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        current_line_blame = true,
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          -- [c previous hunk
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end, {
            buffer = bufnr,
            desc = "Next hunk"
          })
          -- ]c next hunk
          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end, {
            buffer = bufnr,
            desc = "Previous hunk"
          })
          -- <leader>hs Stage current hunk
          map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>', {
            buffer = bufnr,
            desc = "Stage hunk"
          })
          map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, {
            buffer = bufnr,
            desc = "Stage hunk"
          })
          -- <leader>hS Unstage current hunk
          map('n', '<leader>hS', ':Gitsigns undo_stage_hunk<CR>', {
            buffer = bufnr,
            desc = "Unstage hunk"
          })
          -- <leader>hp Preview current hunk
          map('n', '<leader>hp', ':Gitsigns preview_hunk<CR>', {
            buffer = bufnr,
            desc = "Preview hunk"
          })
          -- <leader>hP Preview current hunk inline
          map('n', '<leader>hi', ':Gitsigns preview_hunk_inline<CR>', {
            buffer = bufnr,
            desc = "Preview hunk"
          })
          -- <leader>hr Restore current hunk
          map('n', '<leader>hr', ':Gitsigns reset_hunk<CR>', {
            buffer = bufnr,
            desc = "Reset hunk"
          })
          map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, {
            buffer = bufnr,
            desc = "Reset hunk"
          })

          -- Toggle options
          -- <leader>gB show blame for current line
          map('n', '<leader>gB', ':Gitsigns blame_line<CR>', {
            buffer = bufnr,
            desc = "Show blame for current line"
          })
          -- <leader>gbl toggle current line blame
          map('n', '<leader>gbl', ':Gitsigns toggle_current_line_blame<CR>', {
            buffer = bufnr,
            desc = "Toggle current line blame display"
          })
          -- <leader>gd toggle deleted
          map('n', '<leader>gd', ':Gitsigns toggle_deleted<CR>', {
            buffer = bufnr,
            desc = "Toggle deleted markers"
          })
          -- <leader>gs toggle signs
          map('n', '<leader>gs', ':Gitsigns toggle_signs<CR>', {
            buffer = bufnr,
            desc = "Toggle git signs"
          })
          -- <leader>gw toggle word diff
          map('n', '<leader>gw', ':Gitsigns toggle_word_diff<CR>', {
            buffer = bufnr,
            desc = "Toggle word diff"
          })
        end
      })
    end,
  },

  -- Extend normal mode `ga` with more info like digraphs and emoji code
  {
    'tpope/vim-characterize',
    event = "VeryLazy",
  },

  -- Adds helpers for UNIX shell commands
  -- * :Remove Delete buffer and file at same time
  -- * :Unlink Delete file, keep buffer
  -- * :Move Rename buffer and file
  {
    'tpope/vim-eunuch',
    event = "VeryLazy",
  },

  -- Run git commands in editor, also used by other packages
  {
    'tpope/vim-fugitive',
    event = "VeryLazy",
  },

  -- netrw, but better
  -- `-` to go up a directory
  -- `x` to add files to arglist, then can nav via `[a` and `]a`
  -- Visually select files and hit <Enter> to open all
  -- `<leader>s` open in split
  -- `<leader>v` open in vsplit
  -- `<leader>t` open in new tab
  {
    'justinmk/vim-dirvish',
    config = function()
      -- Unsupported with dirvish
      vim.o.autochdir = false

      -- Override `:Explore` and friends
      vim.g['loaded_netrwPlugin'] = 1
      vim.api.nvim_create_user_command('Explore', 'Dirvish <args>', {
        nargs = '?',
        complete = 'dir'
      })
      vim.api.nvim_create_user_command(
        'Sexplore',
        'belowright split | silent Dirvish <args>',
        { nargs = '?', complete = 'dir' }
      )
      vim.api.nvim_create_user_command(
        'Vexplore',
        'leftabove vsplit | silent Dirvish <args>',
        { nargs = '?', complete = 'dir' }
      )
      vim.api.nvim_create_user_command(
        'Lexplore',
        'topleft vsplit | silent Dirvish <args>',
        { nargs = '?', complete = 'dir' }
      )
      vim.api.nvim_create_user_command(
        'Texplore',
        'tabnew | silent Dirvish <args>',
        { nargs = '?', complete = 'dir' }
      )

      vim.api.nvim_create_augroup("dirvish_bindings", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "dirvish_bindings",
        pattern = "dirvish",
        callback = function()
          -- `Enter` already mapped in visual mode, but add to normal mode
          map(
            "n",
            "<cr>",
            function()
              vim.cmd('call dirvish#open("edit", 0)')
            end,
            {
              buffer = 0,
              desc = "Open file",
              noremap = true,
              silent = true,
            }
          )
          map(
            "n",
            "<leader>t",
            function()
              vim.cmd('call dirvish#open("tabedit", 0)')
            end,
            {
              buffer = 0,
              desc = "Open file in new tab",
              noremap = true,
              silent = true,
            }
          )
          map(
            "n",
            "<leader>s",
            function()
              vim.cmd('call dirvish#open("split", 0)')
            end,
            {
              buffer = 0,
              desc = "Open file in split",
              noremap = true,
              silent = true,
            }
          )
          map(
            "n",
            "<leader>v",
            function()
              vim.cmd('call dirvish#open("vsplit", 0)')
            end,
            {
              buffer = 0,
              desc = "Open file in vsplit",
              noremap = true,
              silent = true,
            }
          )
        end,
      })
    end
  },

  -- git status for dirvish
  -- [f Go to next git file
  -- ]f Go to prev git file
  {
    'kristijanhusak/vim-dirvish-git',
    dependencies = {
      'justinmk/vim-dirvish'
    },
  },

  -- Edit surrounding quotes / parents / etc
  {
    'kylechui/nvim-surround',
    event = "VeryLazy",
    config = function()
      require('nvim-surround').setup({
        -- Use defaults
      })
    end
  },

  -- Movement and option switches via `[` and `]` (toggle with `y`)
  {
    'tpope/vim-unimpaired'
  },

  -- Add `.` repeat functionality to plugins that support it
  {
    'tpope/vim-repeat'
  },

  -- Readline-like bindings in insert/command mode
  {
    'tpope/vim-rsi'
  },

  -- Automatically insert closing parens, etc
  {
    'windwp/nvim-autopairs',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    event = "InsertEnter",
    config = true,
    opts = {
      -- Use Treesitter to check for pair
      check_ts = true,
      disable_filetype = { "TelescopePrompt" },
    }
  },

  -- Quickfix improvements
  -- Shows some context of match in preview window (toggle with `p` / toggle
  -- auto-preview with `P`)
  -- <tab>/<s-tab> to toggle sign on item, `zn` or `zN` (inverse) to filter
  -- z<tab> to clear all signs in quickfix
  -- <C-x> to open in horizontal split, <C-v> for vertical
  -- `<`/`>` to move through quickfix history (basically `colder`/`cnewer`)
  -- Check out stevearc/quicker.nvim at some point
  {
    'kevinhwang91/nvim-bqf',
    dependencies = {
      -- Used for highlighting preview windows
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
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
          -- Disable default fzf mapping, since we use telescope
          fzffilter = '',
        },
      })
    end
  },

  -- Icons
  {
    'nvim-tree/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup({
      })
    end
  },

  -- Reasonable colors
  {
    'RRethy/base16-nvim',
    lazy = false,
    config = function()
      if vim.o.termguicolors then
        if os.getenv('COLOR_THEME') == 'light' then
          vim.opt.background = 'light'
          vim.cmd.colorscheme('base16-default-light')
        else
          vim.opt.background = 'dark'
          vim.cmd.colorscheme('base16-default-dark')
        end
      end
    end
  },
})

-- Load local config, if present
local local_config_path = vim.fn.expand('~/.nvimrc.local')
if vim.fn.filereadable(local_config_path) == 1 then
  vim.cmd('source ' .. local_config_path)
end
