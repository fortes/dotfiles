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

require("lazy").setup({
  -- GitHub Co-Pilot is paid, so only load if #ENABLE_GITHUB_COPILOT is set
  {
    "github/copilot.vim",
    cond = function()
      return os.getenv("ENABLE_GITHUB_COPILOT") == "1"
    end,
    config = function()
      vim.g.copilot_filetypes = {
        -- Override default, which disables markdown
        markdown = true,
        -- Disable in places where it doesn't make sense
        TelescopePrompt = false,
        DressingInput = false,
        codecompanion = false,
        ["copilot-chat"] = false,
      }
    end
  },

  -- GitHub Copilot chat, which isn't in copilot.vim yet
  --
  -- :CopilotChatOpen to open chat
  -- :CopilotChatModels to view/select models
  -- :CopilotChatAgents to view/select agents
  -- :CopilotChatPrompts for predefined prompts like Explain/Review/Tests
  --
  -- <C-s> in insert mode to submit chat (<CR> in normal mode)
  -- <C-y> to accept nearest diff
  -- gh for help
  {
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
      opts = {
        -- See Configuration section for options
      },
    },
  },

  -- AI coding assistant
  {
    "olimorris/codecompanion.nvim",
    cond = function()
      return os.getenv('ANTHROPIC_API_KEY') ~= '' or os.getenv('OPENAI_API_KEY') ~= ''
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Optional: For working with files with slash commands
      "nvim-telescope/telescope.nvim",
      -- Improves the default Neovim UI
      "stevearc/dressing.nvim",
    },
    config = true
  },

  -- Language Server for all sorts of goodness
  {
    'neovim/nvim-lspconfig',
    -- Use telescope in keybindings
    dependencies = {
      'nvim-telescope/telescope.nvim'
    },
    config = function()
      local nvim_lsp = require('lspconfig')

      -- Only map keys after language server has attached to buffer
      -- Quite a few are now default as of v0.11
      -- `grn` to rename symbol
      -- `grr` to find references
      -- `gri` to find implementation
      -- `g0` for document symbol
      -- `gra` for code actions
      -- `<C-S>` for signature help
      local lsp_on_attach = function(client, bufnr)
        if client.server_capabilities.referencesProvider then
          -- grr default in Neovim 0.11, use upper case to use Telescope
          map('n', 'gRR', '<cmd>Telescope lsp_references<cr>', bufnr)
        end

        map('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<cr>', bufnr)
        map('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<cr>', bufnr)
      end

      local default_lsp_opts = {
        on_attach = lsp_on_attach,
        flags = {
          debounce_text_changes = 150
        }
      }

      local deno_root_pattern = nvim_lsp.util.root_pattern('deno.json', 'deno.jsonc')

      local lsp_configs = {
        bashls = default_lsp_opts,
        cssls = default_lsp_opts,
        cssmodules_ls = default_lsp_opts,
        denols = vim.tbl_deep_extend('force', default_lsp_opts, {
          root_dir = deno_root_pattern,
          single_file_support = false,
        }),
        dockerls = default_lsp_opts,
        eslint = vim.tbl_deep_extend('force', default_lsp_opts, {
          on_attach = function(client, bufnr)
            -- <leader>x to autofix via eslint
            map('n', '<leader>x', '<cmd>EslintFixAll<cr>', {
              desc = "Fix all ESLint issues"
            })
            lsp_on_attach(client, bufnr)
          end,
          root_dir = nvim_lsp.util.root_pattern('.git')
        }),
        html = default_lsp_opts,
        jsonls = default_lsp_opts,
        lua_ls = vim.tbl_deep_extend('force', default_lsp_opts, {
          settings = {
            Lua = {
              diagnostics = {
                -- Recognize the vim global
                globals = { 'vim' }
              },
              workspace = {
                -- Add Neovim runtime files
                library = {
                  vim.env.VIMRUNTIME,
                  "${3rd}/luv/library"
                },
              },
              -- Do not send telemetry data
              telemetry = {
                enable = false,
              },
            }
          }
        }),
        pyright = default_lsp_opts,
        ts_ls = vim.tbl_deep_extend('force', default_lsp_opts, {
          -- Increase memory limit to 16GB, might need to adjust on weaker
          -- machines via `MAX_TS_SERVER_MEMORY` env var
          init_options = {
            maxTsServerMemory = tonumber(os.getenv('MAX_TS_SERVER_MEMORY')) or 32768,
          },
          on_attach = function(client, bufnr)
            -- Don't run if in a deno project
            if (deno_root_pattern(vim.fn.getcwd())) then
              client.stop()
              return
            end

            lsp_on_attach(client, bufnr)
          end,
          root_dir = nvim_lsp.util.root_pattern('node_modules'),
        }),
        vimls = default_lsp_opts,
        yamlls = default_lsp_opts
      }

      for lsp, opts in pairs(lsp_configs) do
        nvim_lsp[lsp].setup(opts)
      end
    end
  },

  -- Show LSP progress in lower right
  {
    'j-hui/fidget.nvim',
    dependencies = {
      'neovim/nvim-lspconfig'
    },
    config = function()
      require('fidget').setup({})
    end
  },

  -- Treesitter for better highlighting, indent, etc
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup {
        auto_install = true,
        ensure_installed = {
          'bash',
          'css',
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
        -- Enable `=` for indentation based on treesitter (experimental)
        indent = {
          enable = true
        },
        sync_install = false,
      }

      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
  },

  -- Create text objects using Treesitter queries
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
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

  -- Use Treesitter for rainbow delimiters
  {
    'HiPhish/rainbow-delimiters.nvim',
    name = 'rainbow-delimiters',
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
      ---@diagnostic disable-next-line: missing-fields
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
        map('n', '<leader>t', '<cmd>Telescope<cr>', {
          desc = "Telescope pickers",
        })
        map('n', 'z=', builtin.spell_suggest, { desc = "Spelling suggestions" })
        map('n', '<c-p>', project_files, { desc = "Project files" })
        map('n', '<m-p>', builtin.oldfiles, { desc = "Old files" })
        map('n', '<m-b>', builtin.buffers, { desc = "Buffers" })
        map('n', '<m-m>', builtin.marks, { desc = "Marks" })
        -- Replace lgrep bindings from ~/.vimrc with live grepping and selection
        map(
          'n',
          'Q',
          '<cmd>lua require("telescope.builtin").live_grep{' ..
          'default_text=vim.fn.expand("<cword>")' ..
          '}<cr>',
          { desc = "Live grep current word" }
        )
        map(
          'v',
          'Q',
          ':<C-u>norm! gv"sy<cr>:lua require("telescope.builtin").live_grep{' ..
          'default_text=vim.fn.getreg("s")' ..
          '}<cr>',
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

      -- Use `deno` for formatting when in a deno project, prettier otherwise
      local deno_or_prettier = function(bufnr)
        -- Let `deno` LSP format when in a deno project, fall back to prettier
        if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' }) ~= nil then
          return { 'deno_fmt', lsp_format = 'prefer' }
        end
        return { 'prettier' }
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
        formatters_by_ft = {
          bash = { 'shfmt' },
          css = { 'prettier' },
          html = { 'prettier' },
          javascript = deno_or_prettier,
          json = deno_or_prettier,
          jsonc = deno_or_prettier,
          markdown = deno_or_prettier,
          python = { 'ruff' },
          typescript = deno_or_prettier,
          yaml = { 'prettier' },
        },
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
      vim.api.nvim_create_user_command('Sexplore', 'belowright split | silent Dirvish <args>', {
        nargs = '?',
        complete = 'dir'
      })
      vim.api.nvim_create_user_command('Vexplore', 'leftabove vsplit | silent Dirvish <args>', {
        nargs = '?',
        complete = 'dir'
      })
      vim.api.nvim_create_user_command('Lexplore', 'topleft vsplit | silent Dirvish <args>', {
        nargs = '?',
        complete = 'dir'
      })
      vim.api.nvim_create_user_command('Texplore', 'tabnew | silent Dirvish <args>', {
        nargs = '?',
        complete = 'dir'
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
  -- Better UX for built-in vim UI like input and select
  {
    'stevearc/dressing.nvim',
    opts = {},
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

  -- Show colors in actual color
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      if vim.o.termguicolors then
        require('colorizer').setup({
          'css',
          'less',
        })
      end
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
  }
})

-- Load local config, if present
local local_config_path = vim.fn.expand('~/.nvimrc.local')
if vim.fn.filereadable(local_config_path) == 1 then
  vim.cmd('source ' .. local_config_path)
end
