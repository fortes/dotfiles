-- vim:et ft=lua sts=2 sw=2 ts=2
-- Load all base / legacy options from ~/.vimrc
vim.cmd('source ~/.vimrc')

require('packer').startup(function(use)
  -- Let packer manage itself
  use {
    'wbthomason/packer.nvim',
    config = function()
      -- Automatically reload options and update plugins after changing config
      vim.cmd([[
        augroup packer_reload_config
          autocmd!
          autocmd BufWritePost $MYVIMRC source <afile> | PackerCompile
        augroup end
      ]])
    end
  }

  -- GitHub Co-Pilot is paid, so only load if #ENABLE_GITHUB_COPILOT is set
  -- locally
  use {
    'github/copilot.vim',
    cond = function()
      return os.getenv('ENABLE_GITHUB_COPILOT') == '1'
    end
  }

  -- Language Server for all sorts of goodness
  use {
    'neovim/nvim-lspconfig',
    -- Use telescope in keybindings
    after = {'telescope.nvim'},
    config = function()
      local nvim_lsp = require('lspconfig')

      -- Only map keys after language server has attached to buffer
      local lsp_on_attach = function(client, bufnr)
        local function map(...)
          opts = {
            buffer=bufnr,
            noremap=true,
            silent=true
          }
          vim.keymap.set(...)
        end

        -- Never use tsserver formatting, it's not very good
        if client.name == 'tsserver' then
          client.server_capabilities.documentFormattingProvider = false
        end

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
          map('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({async = true})<cr>')

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

      local lsp_servers = {
        'bashls',
        'cssls',
        'dockerls',
        'eslint',
        'html',
        'jsonls',
        'pyright',
        'tsserver',
        'vimls',
        'yamlls'
      }
      for _, lsp in ipairs(lsp_servers) do
        nvim_lsp[lsp].setup {
          on_attach = lsp_on_attach,
          flags = {
            debounce_text_changes = 150
          }
        }
      end
    end
  }

  -- Show LSP progress in lower right
  use {
    'j-hui/fidget.nvim',
    after = {'nvim-lspconfig'},
    config = function()
      require('fidget').setup({})
    end
  }

  -- Treesitter for better highlighting, indent, etc
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
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
        rainbow = {
          enable = true,
          extended_mode = true,
        }
      }

      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
    end
  }

  -- Create text objects using Treesitter queries
  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = {'nvim-treesitter'},
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
  }

  -- Use Treesitter to autoclose / rename tags
  use {
    'windwp/nvim-ts-autotag',
    after = {'nvim-treesitter'},
  }

  -- Use Treesitter to add `end` in Lua, Bash, etc
  use {
    'RRethy/nvim-treesitter-endwise',
    after = {'nvim-treesitter'},
    config = function()
      require('nvim-treesitter.configs').setup {
        endwise = {
          enable = true
        }
      }
    end,
  }

  -- Use Treesitter to do LSP-like things:
  use {
    'nvim-treesitter/nvim-treesitter-refactor',
    after = {'nvim-treesitter'},
    config = function()
      require('nvim-treesitter.configs').setup {
        refactor = {
          highlight_definitions = {enable = true},
        },
      }
    end
  }

  -- Use Treesitter to infer correct `commentstring`
  use {
    'joosepalviste/nvim-ts-context-commentstring',
    after = {'nvim-treesitter'}
  }

  -- Rainbow parens, etc
  use {
    'p00f/nvim-ts-rainbow',
    after = {'nvim-treesitter'}
  }

  -- Enable spellchecking in buffers that use Treesitter
  use {
    'lewis6991/spellsitter.nvim',
    after = {'nvim-treesitter'},
    config = function()
      -- Can also be a list of filetypes
      require('spellsitter').setup({enable = true})
    end
  }

  -- Indentation guides
  use {
    'lukas-reineke/indent-blankline.nvim',
    -- Used for context highlighting
    after = {'nvim-treesitter'},
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
  }

  -- Fuzzy finder for all the things
  use {
    {
      'nvim-telescope/telescope.nvim',
      requires = {
        -- Helper functions
        'nvim-lua/plenary.nvim',
        -- Support FZF syntax
        'telescope-fzf-native.nvim'
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
      run = 'make'
    }
  }

  use {
    'AckslD/nvim-neoclip.lua',
    requires = {
      -- Uses telescope for selection
      {'nvim-telescope/telescope.nvim'},
    },
    config = function()
      require('neoclip').setup({})

      vim.keymap.set('n', '<leader>cl',
        ':lua require("telescope").extensions.neoclip.default()<cr>',
        {noremap=true, silent=true})
    end
  }

  -- Highlight ranges in timeline
  use {
    'winston0410/range-highlight.nvim',
    requires = {
      'winston0410/cmd-parser.nvim',
    },
    cond = function()
      return vim.fn.has('nvim-0.5') == 1
    end,
    config = function()
      require('range-highlight').setup({})
    end
  }

  -- Very simple tab completion
  use { 'ackyshake/VimCompletesMe'}

  -- Honor `.editorconfig`
  use {'editorconfig/editorconfig-vim'}

  -- Copy to system via OSC52 via <leader>c
  use {
    'ojroques/nvim-osc52',
    config = function()
      vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr=true})
      vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap=true})
      vim.keymap.set('x', '<leader>c', require('osc52').copy_visual)
    end
  }

  -- Autoformatting
  use {'prettier/vim-prettier'}

  -- Display available key bindings, marks, registers, etc
  use {
    'folke/which-key.nvim',
    config = function()
      require("which-key").setup()
    end
  }

  -- Preview line number via `:XXX` before moving
  use {
    'nacro90/numb.nvim',
    config = function()
      require('numb').setup()
    end
  }

  -- Shows git diff in signs column
  -- `[c` / `]c` to jump between hunks
  -- <leader>hs to stage hunk
  -- <leader>hp to preview hunk
  use {
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
  }

  -- Better text objects, will seek to nearest match on line
  use {'wellle/targets.vim'}

  -- Extend normal mode `ga` with more info like digraphs and emoji code
  use {'tpope/vim-characterize'}

  -- Adds helpers for UNIX shell commands
  -- * :Remove Delete buffer and file at same time
  -- * :Unlink Delete file, keep buffer
  -- * :Move Rename buffer and file
  use {'tpope/vim-eunuch'}

  -- Run git commands in editor, also used by other packages
  use {'tpope/vim-fugitive'}

  -- netrw, but better
  use {
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
  }

  -- git status for dirvish
  use {
    'kristijanhusak/vim-dirvish-git',
    after = {'vim-dirvish'},
  }

  -- Comment / uncomment things quickly
  use {'tpope/vim-commentary'}

  -- Edit surrounding quotes / parents / etc
  use {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup({
        -- Use defaults
      })
    end
  }

  -- Movement and option switches via `[` and `]` (toggle with `y`)
  use {'tpope/vim-unimpaired'}

  -- Add `.` repeat functionality to plugins that support it
  use {'tpope/vim-repeat'}

  -- Readline-like bindings in insert/command mode
  use {'tpope/vim-rsi'}

  -- Automatically insert closing parens, etc
  use {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup({
        -- Use Treesitter to check for pair
        check_ts = true,
      })
    end
  }

  -- Better Markdown handling
  use {
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
  }

  -- Mostly for Hugo template syntax
  use {
    'fatih/vim-go',
    cond = function()
      return vim.fn.has('nvim-0.4') == 1
    end,
    -- Since only using for syntax for now, don't do full setup
    -- run = ':GoUpdateBinaries'
  }

  -- Show colors in actual color
  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
      if vim.o.termguicolors then
        require('colorizer').setup()
      end
    end
  }

  -- Reasonable colors
  use {
    'EdenEast/nightfox.nvim',
    config = function()
      if vim.o.termguicolors then
        vim.cmd('silent! colorscheme nightfox')
      end
    end
  }
end)

-- Load local config, if present
vim.cmd([[
if filereadable(expand('~/.nvimrc.local'))
  source ~/.nvimrc.local
endif
]])
