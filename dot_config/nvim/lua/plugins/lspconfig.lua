local lsps = { "lua_ls", "pyright", "ruff" }
local tools = { 'isort', 'black', 'pylint', 'mypy' }
return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        requires = {
            'williamboman/mason.nvim',
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = lsps,
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        requires = {
            'williamboman/mason.nvim',
        },
        config = function()
            require('mason-tool-installer').setup {
                ensure_installed = tools,
            }
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require('lspconfig')

            local lspconfig_defaults = lspconfig.util.default_config
            lspconfig_defaults.capabilities = vim.tbl_deep_extend(
                'force',
                lspconfig_defaults.capabilities,
                require('cmp_nvim_lsp').default_capabilities()
            )

            vim.api.nvim_create_autocmd('LspAttach', {
                desc = 'LSP actions',
                callback = function(event)
                    local opts = { buffer = event.buf }
                    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)

                    vim.keymap.set('n', '<leader>vr', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                    -- set to <F3> for now, because it is not that often
                    vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                    vim.keymap.set({ 'n', }, '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                end,
            })


            -- local on_attach = lspconfig_defaults.on_attach
            -- local capabilities = lspconfig_defaults.capabilities
            lspconfig.lua_ls.setup {
                settings = {
                    Lua = {
                        diagnostics = {
                            -- looks like this will eliminate the error from personl.lua
                            globals = { "vim" },
                        },
                    },
                },
            }

            lspconfig.pyright.setup({
            })
            lspconfig.ruff.setup({})
        end,
    },
    {
        'hrsh7th/cmp-nvim-lsp',
    },
    {
        'hrsh7th/nvim-cmp',
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                sources = {
                    { name = 'nvim_lsp' },
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
                    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = 'select' }),

                    -- select = false, means press enter won't select if current select none
                    -- select = false, 意味着在没有选择任何建议的时候，按住 enter，不会有选中
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),

                    ['<C-k>'] = cmp.mapping.complete(),

                    -- scroll up and down for documentation
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                }),
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python = { "isort", "black" }
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_format = "fallback",
                },
            })
        end
    },
    {
        'mfussenegger/nvim-lint',
        config = function()
            local lint = require('lint')
            lint.linters_by_ft = {
                python = { 'pylint', 'mypy' },
            }
            -- lint.linters.pylint.cmd = 'python'
            -- lint.linters.pylint.args = {
            --     '-m',
            --     'pylint',
            --     '-f',
            --     'json',
            --     '--disable=C0111', -- Disable missing docstring warnings
            --     '--enable=W0612',  -- Enable unused variable warnings
            --     '--from-stdin',
            --     function()
            --         return vim.api.nvim_buf_get_name(0)
            --     end,
            -- }
            -- lint.linters = {
            --     pylint = {
            --         cmd = 'python',
            --         args = {
            --             '--disable=C0111',
            --         },
            --     },
            -- }
            vim.api.nvim_create_autocmd({
                "BufWritePost", "BufReadPost", "InsertLeave",
            }, {
                callback = function()
                    lint.try_lint()
                end
            })

            -- TODO may delete in the future
            vim.keymap.set("n", "<leader>l", function()
                lint.try_lint()
            end, { desc = "Trigger linting for current file" })

            -- Show linters for the current buffer's file type
            vim.api.nvim_create_user_command("LintInfo", function()
                local filetype = vim.bo.filetype
                local linters = require("lint").linters_by_ft[filetype]

                if linters then
                    print("Linters for " .. filetype .. ": " .. table.concat(linters, ", "))
                else
                    print("No linters configured for filetype: " .. filetype)
                end
            end, {})
        end
    },
}
