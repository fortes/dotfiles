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

  -- Language Server for all sorts of goodness
  use {
    'neovim/nvim-lspconfig',
    -- Use telescope in keybindings
    after = {'telescope.nvim'},
    config = function()
      local nvim_lsp = require('lspconfig')

      -- Only map keys after language server has attached to buffer
      local lsp_on_attach = function(client, bufnr)
        local function buf_set_keymap(...)
          vim.api.nvim_buf_set_keymap(bufnr, ...)
        end
        local function buf_set_option(...)
          vim.api.nvim_buf_set_option(bufnr, ...)
        end

        -- Take over omnicompletion via <c-x><c-o>
        if client.server_capabilities.completionProvider then
          buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
        end

        -- Never use tsserver formatting, it's not very good
        if client.name == 'tsserver' then
          client.server_capabilities.documentFormattingProvider = false
        end

        local opts = {
          noremap=true,
          silent=true
        }

        if client.server_capabilities.definitionProvider then
          buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          buf_set_keymap('n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        end
        if client.server_capabilities.referencesProvider then
          buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          buf_set_keymap('n', 'gR', '<cmd>Telescope lsp_references<cr>', opts)
        end
        if client.server_capabilities.renameProvider then
          buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        end
        if client.server_capabilities.hoverProvider then
          buf_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        end
        if client.server_capabilities.implementationProvider then
          buf_set_keymap('n', 'gI', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        end
        if client.server_capabilities.typeDefinitionProvider then
          buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        end
        if client.server_capabilities.signatureHelpProvider then
          buf_set_keymap('n', 'g?', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        end
        if client.server_capabilities.codeActionProvider then
          buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        end
        if client.server_capabilities.documentFormattingProvider then
          buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<cr>', opts)

          -- Format on save, where supported
          vim.cmd([[
            augroup lsp_format_on_save
              autocmd!
              autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
            augroup end
          ]])
        end
        if client.server_capabilities.documentRangeFormattingProvider then
          buf_set_keymap('v', '<leader>f', '<cmd>lua vim.lsp.buf.range_formatting()<cr>', opts)
        end
        if client.server_capabilities.documentSymbolProvider then
          buf_set_keymap('n', '<leader>ds', '<cmd>Telescope lsp_document_symbols<cr>', opts)
        else
          buf_set_keymap('n', '<leader>ds', '<cmd>Telescope treesitter<cr>', opts)
        end
        if client.server_capabilities.workspaceSymbolProvider then
          buf_set_keymap('n', '<leader>ws', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', opts)
        end

        buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
        buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
        buf_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<cr>', opts)
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
          local ok = pcall(require"telescope.builtin".git_files, opts)
          if not ok then require"telescope.builtin".find_files(opts) end
        end

        local opts = {
          noremap=true,
          silent=true
        }

        -- Key mappings
        vim.api.nvim_set_keymap('n', '<leader>t', '<cmd>Telescope<cr>', opts)
        vim.api.nvim_set_keymap('n', 'z=', '<cmd>Telescope spell_suggest<cr>', opts)
        vim.api.nvim_set_keymap('n', '<c-p>', ':lua project_files()<cr>', opts)
        vim.api.nvim_set_keymap('n', '<m-p>',
          [[<cmd>Telescope oldfiles<cr>]],
          opts)
        vim.api.nvim_set_keymap('n', '<m-b>',
          [[<cmd>Telescope buffers show_all_buffers=true<cr>]],
          opts)
        vim.api.nvim_set_keymap('n', 'Q',
          [[<cmd>Telescope live_grep<cr>]],
          opts)
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

      vim.api.nvim_set_keymap('n', '<leader>cl',
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

  -- Copy to system via OSC52
  use {
    'ojroques/vim-oscyank',
    config = function()
      vim.api.nvim_set_keymap('v', '<leader>y', ':OSCYank<cr>',
        {noremap=true, silent=true})
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
      })
    end
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
    after = {'vim-dirvish-git'},
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
