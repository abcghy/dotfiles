lua require('plugins')

augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end

" customize lualine
lua << END
require('lualine').setup {
    options = {
        theme = 'palenight'
    }
}
END

:set tabstop=4
:set shiftwidth=4
:set expandtab
