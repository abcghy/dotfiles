return {
    "folke/snacks.nvim",
    lazy = false,
    ---@type snacks.Config
    opts = {
        lazygit = {
        },
        dashboard = {
            sections = {
                { section = "header" },
                { section = "keys",   gap = 1, padding = 1 },
                { section = "startup" },
            },
        },
        picker = {
        },
    },
    keys = {
        { "<leader>gg", function() Snacks.lazygit() end,                                        desc = "Lazygit" },
        { "<leader>ff", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
        { "<leader>fr", function() Snacks.picker.recent() end,                                  desc = "Recent Files" },
        { "<leader>sf", function() Snacks.picker.grep() end,                                    desc = "Grep" },
        { "<leader>fp", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
        { "<leader>bb", function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
        { "<leader>hh", function() Snacks.picker.help() end,                                    desc = "Help Pages" },
    }
}
