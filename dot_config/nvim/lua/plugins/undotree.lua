return {
    "mbbill/undotree",
    config = function()
        -- "t"oggle "u"ndotree
        vim.keymap.set('n', '<leader>tu', vim.cmd.UndotreeToggle)
    end
}
