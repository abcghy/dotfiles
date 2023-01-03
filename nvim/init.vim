lua require('plugins')
lua require('config')

augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end

" customize lualine
lua << END
require('lualine').setup {
    options = {
        -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
        theme = 'onedark',
        -- theme = 'onelight',
        disabled_filetypes = {
            statusline = {'NvimTree'},
        },
    },
    sections = {
        lualine_c = {
            {
                'filename',
                path = 1
            }
        }
    }
    -- inactive_sections = {
    --     lualine_c = {
    --         {
    --             'filename',
    --             path = 1
    --         }
    --     }
    -- }
}

require('nvim-tree').setup({
    hijack_cursor = true,
    view = {
        width = 50,
        mappings = {
            list = {
                { key = { "<CR>", "l", }, action = "edit" },
                { key = { "<BS>", "h", }, action = "close_node"},
            },
        },
    },
    renderer = {
        indent_markers = {
            enable = true,
        },
        icons = {
            show = {
                folder = false,
            },
            padding = " "
        },
        highlight_opened_files = "all",
    },
})

require('gitsigns').setup({
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        map('n', '<leader>gbl', gs.toggle_current_line_blame)
    end
})

require('telescope').setup {
    defaults = {
        path_display = {'truncate'}
    },
    pickers = {
        find_files = {
            theme = "dropdown",
        },
        live_grep = {
            theme = "dropdown",
        },
    }
}
END

:set tabstop=4
:set shiftwidth=4
:set expandtab

set clipboard+=unnamedplus

set nu rnu
set cursorline
" set cursorcolumn

nnoremap <SPACE> <Nop>
let mapleader = " " " map leader to Space

nnoremap <Leader>w <C-w>
nnoremap <Leader>wd :close<cr>
nnoremap R :source $MYVIMRC<cr>
nnoremap tt :NvimTreeToggle<cr>
nnoremap tf :NvimTreeFocus<cr>

nnoremap J 10j
nnoremap K 10k
vnoremap J 10j
vnoremap K 10k

""" telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

""" lazygit
nnoremap <silent> <leader>gg :LazyGit<CR>

""" wilder.nvim
" call wilder#setup({'modes': [':', '/', '?']})

""" hlslens
" remove highlight
nnoremap <leader>l <cmd>noh<cr>

set t_Co=256   " This is may or may not needed.

set background=dark
colorscheme PaperColor

" set termguicolors
" hi Normal guibg=NONE ctermbg=NONE

