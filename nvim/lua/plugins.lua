-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- comment plugin
  use 'tpope/vim-commentary'

  -- status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  use 'frigoeu/psc-ide-vim'

  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    },
    tag = 'nightly' -- optional, updated every week. (see issue #1193)
  }

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
  -- or                            , branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  
  use {
    'kdheepak/lazygit.nvim'
  }

  use {'kevinhwang91/nvim-hlslens'}


  use {'rakr/vim-one'}

  use {'NLKNguyen/papercolor-theme'}

  use {
    'lewis6991/gitsigns.nvim',
    -- tag = 'release' -- To use the latest release (do not use this if you run Neovim nightly or dev builds!)
  }

  -- use {
  --   'gelguy/wilder.nvim',
  --   config = function()
  --     -- config goes here
  --   end,
  -- }
  
  -- use {
  --   "folke/which-key.nvim",
  --   config = function()
  --     require("which-key").setup {
  --       -- your configuration comes here
  --       -- or leave it empty to use the default settings
  --       -- refer to the configuration section below
  --     }
  --   end
  -- }

  -- use({
  -- 	"Pocco81/true-zen.nvim",
  -- 	config = function()
  -- 		 require("true-zen").setup {
  -- 			-- your config goes here
  -- 			-- or just leave it empty :)
  -- 		 }
  -- 	end,
  -- })
  
  -- use {'junegunn/goyo.vim'}

  -- auto add pair
  use {'Raimondi/delimitMate'}

  use {'machakann/vim-sandwich'}

  use {'udalov/kotlin-vim'}

end)
