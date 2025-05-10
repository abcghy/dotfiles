return {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
        require('mini.pairs').setup()
        require('mini.statusline').setup()
        -- require('mini.starter').setup()
        require('mini.indentscope').setup()
        require('mini.comment').setup()
        -- require('mini.notify').setup()
        require('mini.splitjoin').setup()
    end,
}
