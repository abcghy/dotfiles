require("mason").setup()
require("mason-lspconfig").setup()

-- Native LSP Setup
-- Get Language Server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local capabilities = require('cmp_nvim_lsp').default_capabilities()

servers = {'ccls', 'pyright', 'tsserver',}

-- cpp
-- get ccls
for i, v in pairs(servers) do
    require('lspconfig')[v].setup {
        capabilities = capabilities,
        on_attach = function()
            --            mode, key, function reference, only for this buffer
            vim.keymap.set("n", "Q", vim.lsp.buf.hover, {buffer = 0})
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, {buffer = 0})
            vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, {buffer = 0})
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {buffer = 0})
            vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, {buffer = 0})

            -- find next error in current file
            vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, {buffer = 0})
            -- find previous
            vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, {buffer = 0})
            ---- telescope diagnostics
            vim.keymap.set("n", "<leader>gd", "<cmd>Telescope diagnostics<cr>", {buffer = 0})
        end
    }
end

-- set completeopt=menu,menuone,noselect
vim.opt.completeopt={"menu", "menuone", "noselect"}

-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
snippet = {
  expand = function(args)
    -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
    -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
  end,
},
window = {
  completion = cmp.config.window.bordered(),
  documentation = {
      max_height = 10,
  },
  -- documentation = cmp.config.window.bordered(),
},
mapping = cmp.mapping.preset.insert({
  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  ['<C-f>'] = cmp.mapping.scroll_docs(4),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
}),
sources = cmp.config.sources({
  { name = 'nvim_lsp' },
  -- { name = 'vsnip' }, -- For vsnip users.
  { name = 'luasnip' }, -- For luasnip users.
  -- { name = 'ultisnips' }, -- For ultisnips users.
  -- { name = 'snippy' }, -- For snippy users.
}, {
  { name = 'buffer' },
})
})

-- Set configuration for specific filetype.
-- cmp.setup.filetype('gitcommit', {
--   sources = cmp.config.sources({
--     { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
--   }, {
--     { name = 'buffer' },
--   })
-- })

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline({ '/', '?' }, {
-- mapping = cmp.mapping.preset.cmdline(),
-- sources = {
--   { name = 'buffer' }
-- }
-- })

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(':', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })
require('hlslens').setup {}

