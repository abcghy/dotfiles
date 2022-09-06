lua require('plugins')

augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end

" customize lualine
lua << END
require('lualine').setup {
    options = {
        -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
        theme = 'onedark'
    }
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
        },
        highlight_opened_files = "all",
    },
})
END

:set tabstop=4
:set shiftwidth=4
:set expandtab

set clipboard+=unnamedplus

set nu rnu
set cursorline
set cursorcolumn

nnoremap <SPACE> <Nop>
let mapleader = " " " map leader to Space

nnoremap <Leader>w <C-w>
nnoremap R :source $MYVIMRC<cr>
nnoremap tt :NvimTreeToggle<cr>

nnoremap J 10j
nnoremap K 10k

""" telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>

""" lazygit
nnoremap <silent> <leader>gg :LazyGit<CR>

colorscheme one
" set background=light
set background=dark
set termguicolors
" hi Normal guibg=NONE ctermbg=NONE

