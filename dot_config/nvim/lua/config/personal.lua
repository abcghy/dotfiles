vim.opt.clipboard = "unnamedplus"

-- use spaces instead of tabs
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.ignorecase = true

-- have to have number, or it will only show 0 for current line
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

-- easy to read and navigate within text files, can add in the future
local text_file_types = { "markdown", "org" }
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = text_file_types,
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.keymap.set("n", "j", "gj", { buffer = true })
        vim.keymap.set("n", "k", "gk", { buffer = true })
    end
})

vim.keymap.set("n", "<space>ot", function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 15)
end, { desc = "[o]pen [t]erminal", })

vim.keymap.set("n", "<M-J>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-K>", "<cmd>cprev<CR>")

--- lsp configs
vim.lsp.enable({ 'lua_ls' })

vim.o.winborder = 'rounded'

vim.cmd("set completeopt+=noselect")
vim.diagnostic.config({
    virtual_text = true,
    virtual_lines = {
        current_line = true,
    }
})

-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     if client:supports_method('textDocument/completion') then
--       vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--     end
--   end,
-- })

