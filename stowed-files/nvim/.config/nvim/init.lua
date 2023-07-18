-- vim:et ft=lua sts=2 sw=2 ts=2
-- Load all base / legacy options from ~/.vimrc
vim.cmd('source ~/.vimrc')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

require("lazy").setup({
  -- GitHub Co-Pilot is paid, so only load if #ENABLE_GITHUB_COPILOT is set
  {
    'github/copilot.vim',
    cond = function()
      return os.getenv('ENABLE_GITHUB_COPILOT') == '1'
    end,
    config = function()
      vim.g.copilot_filetypes = {
        -- Override default, which disables markdown
        markdown = true,
        -- Disable in places where it doesn't make sense
        TelescopePrompt = false
      }
    end
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

      local function map(...)
        opts = {
          buffer=bufnr,
          noremap=true,
          silent=true
        }
        vim.keymap.set(...)
      end

      -- Only map keys after language server has attached to buffer
      local lsp_on_attach = function(client, bufnr)
        if client.server_capabilities.definitionProvider then
          map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
          -- <C-]> automapped via `tagfunc`
        end
        if client.server_capabilities.referencesProvider then
          map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
          map('n', 'gR', '<cmd>Telescope lsp_references<cr>')
        end
        if client.server_capabilities.renameProvider then
          map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>')
        end
        if client.server_capabilities.hoverProvider then
          map('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>')
        end
        if client.server_capabilities.implementationProvider then
          map('n', 'gI', '<cmd>lua vim.lsp.buf.implementation()<cr>')
        end
        if client.server_capabilities.typeDefinitionProvider then
          map('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
        end
        if client.server_capabilities.signatureHelpProvider then
          map('n', 'g?', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
        end
        if client.server_capabilities.codeActionProvider then
          map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>')
        end
        if client.server_capabilities.documentFormattingProvider then
          map('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({async = false})<cr>')

          -- Format on save, where supported
          vim.cmd([[
          augroup lsp_format_on_save
            autocmd!
            autocmd BufWritePre <buffer> lua vim.lsp.buf.format({async = true})
          augroup end
          ]])
        end
        if client.server_capabilities.documentRangeFormattingProvider then
          map('v', '<leader>f', '<cmd>lua vim.lsp.buf.range_formatting()<cr>')
        end
        if client.server_capabilities.documentSymbolProvider then
          map('n', '<leader>ds', '<cmd>Telescope lsp_document_symbols<cr>')
        else
          map('n', '<leader>ds', '<cmd>Telescope treesitter<cr>')
        end
        if client.server_capabilities.workspaceSymbolProvider then
          map('n', '<leader>ws', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>')
        end

        map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
        map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
        map('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<cr>')
        map('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<cr>')
      end

      local default_lsp_opts = {
        on_attach = lsp_on_attach,
        flags = {
          debounce_text_changes = 150
        }
      }

      local lsp_configs = {
        bashls = default_lsp_opts,
        cssls = default_lsp_opts,
        cssmodules_ls =  vim.tbl_deep_extend('force', default_lsp_opts, {
          on_attach = function(client, bufnr)
            -- Don't use `definitionProvider` since it conflicts with tsserver
            client.server_capabilities.definitionProvider = false

            lsp_on_attach(client, bufnr)
          end,
        }),
        denols = vim.tbl_deep_extend('force', default_lsp_opts, {
          root_dir = nvim_lsp.util.root_pattern('deno.json')
        }) ,
        dockerls = default_lsp_opts,
        eslint =  vim.tbl_deep_extend('force', default_lsp_opts, {
          on_attach = function(client, bufnr)
            -- <leader>x to autofix via eslint
            map('n', '<leader>x', '<cmd>EslintFixAll<cr>')
            lsp_on_attach(client, bufnr)
          end,
          root_dir = nvim_lsp.util.root_pattern('.git')
        }),
        html = default_lsp_opts,
        jsonls = default_lsp_opts,
        pyright = default_lsp_opts,
        tsserver = vim.tbl_deep_extend('force', default_lsp_opts, {
          -- Increase memory limit to 16GB, might need to adjust on weaker
          -- machines
          init_options = {
            maxTsServerMemory = 16384
          },
          on_attach = function(client, bufnr)
            -- Never use tsserver formatting, it's not very good
            client.server_capabilities.documentFormattingProvider = false
            lsp_on_attach(client, bufnr)
          end,
          root_dir = nvim_lsp.util.find_node_modules_ancestor
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
    -- Re-write in progress, stay on stable
    tag = 'legacy',
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
    cond = function()
      return vim.fn.has('nvim-0.6') == 1
    end,
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'css',
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
        -- Enable `=` for indentation based on treesitter (experimental)
        indent = {enable = true},
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
      require('nvim-treesitter.configs').setup {
        autotag = {
          enable = true
        },
        textobjects = {
          select = {
            enable = true,
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
  },

  -- Use Treesitter to add `end` in Lua, Bash, etc
  {
    'RRethy/nvim-treesitter-endwise',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        endwise = {
          enable = true
        }
      }
    end,
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
      require('nvim-treesitter.configs').setup {
        refactor = {
          highlight_definitions = {enable = true},
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

  -- Enable spellchecking in buffers that use Treesitter
  {
    'lewis6991/spellsitter.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      -- Can also be a list of filetypes
      require('spellsitter').setup({enable = true})
    end
  },

  -- Indentation guides
  {
    'lukas-reineke/indent-blankline.nvim',
    -- Used for context highlighting
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('indent_blankline').setup {
        filetype_exclude = {
          'help',
          'markdown',
          'packer',
          'txt'
        },
        show_current_context = true,
        show_current_context_start = true,
        show_first_indent_level = false,
        use_treesitter = true,
      }
    end
  },

  -- Generate code annotations, e.g. JSDoc
  {
    'danymat/neogen',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('neogen').setup {
        enabled = true
      }

      local opts = {noremap = true, silent = true}
      vim.api.nvim_set_keymap("n", "<Leader>nf", ":lua require('neogen').generate()<cr>", opts)
    end
  },

  -- Split or Join blocks of code
  {
    'Wansmer/treesj',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('treesj').setup({
        -- Use default keymaps
        -- (<space>m - toggle, <space>j - join, <space>s - split)
        use_default_keymaps = true,

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
        langs = langs,
        -- Use `dot` for repeat action
        dot_repeat = true,
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
      cond = function()
        return vim.fn.has('nvim-0.6') == 1
      end,
      config = function()
        local telescope = require('telescope')

        telescope.setup {
          defaults = {
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
          }
        }

        telescope.load_extension('fzf')

        -- Fallback to file search if not in git repo
        function _G.project_files()
          local ok = pcall(require"telescope.builtin".git_files, {
            use_git_root = true,
            show_untracked = true
          })
          if not ok then require"telescope.builtin".find_files({
            hidden = true
          }) end
        end

        local opts = {
          noremap=true,
          silent=true
        }

        -- Key mappings
        vim.keymap.set('n', '<leader>t', '<cmd>Telescope<cr>', opts)
        vim.keymap.set('n', 'z=', '<cmd>Telescope spell_suggest<cr>', opts)
        vim.keymap.set('n', '<c-p>', ':lua project_files()<cr>', opts)
        vim.keymap.set('n', '<m-p>', [[<cmd>Telescope oldfiles<cr>]], opts)
        vim.keymap.set('n', '<m-b>',
        [[<cmd>Telescope buffers show_all_buffers=true<cr>]],
        opts)
        vim.keymap.set('n', 'Q', [[<cmd>Telescope live_grep<cr>]], opts)
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

      vim.keymap.set('n', '<leader>cl',
      ':lua require("telescope").extensions.neoclip.default()<cr>',
      {noremap=true, silent=true})
    end
  },

  -- Highlight ranges in timeline
  {
    'winston0410/range-highlight.nvim',
    dependencies = {
      'winston0410/cmd-parser.nvim',
    },
    cond = function()
      return vim.fn.has('nvim-0.5') == 1
    end,
    config = function()
      require('range-highlight').setup({})
    end
  },

  -- Copy to system via OSC52 via <leader>c
  {
    'ojroques/nvim-osc52',
    config = function()
      vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr=true})
      vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap=true})
      vim.keymap.set('x', '<leader>c', require('osc52').copy_visual)
    end
  },

  -- Autoformatting
  {
    'prettier/vim-prettier',
    event = "VeryLazy",
    config = function()
      -- Don't use quickfix for syntax errors
      vim.g['prettier#quickfix_enabled'] = 0
    end
  },

  -- Display available key bindings, marks, registers, etc
  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end
  },

  -- Preview line number via `:XXX` before moving
  {
    'nacro90/numb.nvim',
    event = "VeryLazy",
    config = function()
      require('numb').setup()
    end
  },

  -- Shows git diff in signs column
  -- `[c` / `]c` to jump between hunks
  -- <leader>hs to stage hunk
  -- <leader>hp to preview hunk
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signcolumn = true,
        current_line_blame = true,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(...)
            opts = {
              buffer=bufnr,
              noremap=true,
              silent=true
            }
            vim.keymap.set(...)
          end

          -- Toggle staging
          -- <leader>hs Stage current hunk
          map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>')
          -- <leader>hS Unstage current hunk
          map('n', '<leader>hS', ':Gitsigns undo_stage_hunk<CR>')
          -- <leader>hP Preview current hunk
          map('n', '<leader>hP', ':Gitsigns preview_hunk<CR>')

          -- Toggle options
          -- <leader>gB show blame for current line
          map('n', '<leader>gB', ':Gitsigns blame_line<CR>')
          -- <leader>gbl toggle current line blame
          map('n', '<leader>gbl', ':Gitsigns toggle_current_line_blame<CR>')
          -- <leader>gd toggle deleted
          map('n', '<leader>gd', ':Gitsigns toggle_deleted<CR>')
          -- <leader>gs toggle signs
          map('n', '<leader>gs', ':Gitsigns toggle_signs<CR>')
          -- <leader>gw toggle word diff
          map('n', '<leader>gw', ':Gitsigns toggle_word_diff<CR>')
        end
      })
    end,
  },

  -- Better text objects, will seek to nearest match on line
  {
    'wellle/targets.vim',
    event = "VeryLazy",
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

  {
    'NeogitOrg/neogit',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('neogit').setup({})
    end
  },

  -- netrw, but better
  {
    'justinmk/vim-dirvish',
    config = function()
      -- Unsupported with dirvish
      vim.o.autochdir = false

      -- Override `:Explore` and friends
      vim.g['loaded_netrwPlugin'] = 1
      vim.cmd([[
        command! -nargs=? -complete=dir Explore Dirvish <args>
        command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
        command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>
        command! -nargs=? -complete=dir Lexplore topleft vsplit | silent Dirvish <args>
        command! -nargs=? -complete=dir Texplore tabnew | silent Dirvish <args>
      ]])

    end
  },

  -- git status for dirvish
  {
    'kristijanhusak/vim-dirvish-git',
    dependencies = {
      'justinmk/vim-dirvish'
    },
  },

  -- Comment / uncomment things quickly
  {
    'tpope/vim-commentary'
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
    config = function()
      require('nvim-autopairs').setup({
        -- Use Treesitter to check for pair
        check_ts = true,
      })
    end
  },

  -- Better Markdown handling
  {
    'plasticboy/vim-markdown',
    config = function()
      vim.g['vim_markdown_fenced_languages'] = {
        'css',
        'html',
        'javascript',
        'js=javascript',
        'jsx=javascriptreact',
        'typescript',
        'ts=typescript',
        'tsx=typescriptreact',
        'sh',
        'bash=sh',
      }
      vim.g['vim_markdown_frontmatter'] = 1
    end
  },

  -- Only for Hugo template syntax
  {
    'fatih/vim-go',
    ft = 'gohtmltmpl',
    cond = function()
      return vim.fn.has('nvim-0.4') == 1
    end,
    -- Since only using for syntax for now, don't do full setup
    -- build = ':GoUpdateBinaries'
  },

  -- Show colors in actual color
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      if vim.o.termguicolors then
        require('colorizer').setup()
      end
    end
  },

  -- Reasonable colors
  {
    'EdenEast/nightfox.nvim',
    lazy = false,
    config = function()
      if vim.o.termguicolors then
        if os.getenv('COLOR_THEME') == 'light' then
          vim.cmd('silent! colorscheme dayfox')
        else
          vim.cmd('silent! colorscheme carbonfox')
        end
      end
    end
  }
})

-- Load local config, if present
vim.cmd([[
  if filereadable(expand('~/.nvimrc.local'))
    source ~/.nvimrc.local
    endif
  ]]
)
