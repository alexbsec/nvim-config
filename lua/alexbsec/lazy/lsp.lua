
return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local lspconfig = require("lspconfig")
        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")

        local configs = require("lspconfig.configs")

        if not configs.gdscript then
            configs.gdscript = {
                default_config = {
                    name = "gdscript",
                    cmd = { "dummy" },
                    filetypes = { "gd", "gdscript", "gdscript3" },
                    root_dir = require("lspconfig.util").root_pattern("project.godot", ".git"),
                }
            }
        end

        require("conform").setup({
            formatters_by_ft = {}
        })

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "elixirls",
                "clangd",
                "omnisharp",
            },
            handlers = {
                function(server_name)
                    lspconfig[server_name].setup {
                        capabilities = cmp_lsp.default_capabilities()
                    }
                end,

                ["zls"] = function()
                    lspconfig.zls.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0
                end,

                ["lua_ls"] = function()
                    lspconfig.lua_ls.setup {
                        capabilities = cmp_lsp.default_capabilities(),
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            }
        })

        -- ⬇️ Conecta manualmente o gdscript LSP após o Mason setup
        local port = tonumber(os.getenv("GDScript_Port") or "6005")
        local socket = vim.lsp.rpc.connect("127.0.0.1", port)

        lspconfig.gdscript.setup({
            name = "gdscript",
            cmd = socket,
            rpc = socket,
            root_dir = lspconfig.util.root_pattern("project.godot", ".git"),
            filetypes = { "gd", "gdscript", "gdscript3" },
            on_attach = function(client, bufnr)
                print("✅ GDScript LSP conectado manualmente")
            end,
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-l>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
