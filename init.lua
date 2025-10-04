local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "gbprod/nord.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("nord").setup({})
            -- vim.cmd.colorscheme("nord")

            -- Override Fugitive diff colors to improve visibility
            vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#A3BE8C", bg = "#2E3440" })    -- Green text on dark background
            vim.api.nvim_set_hl(0, "DiffChange", { fg = "#EBCB8B", bg = "#2E3440" }) -- Yellow text on dark background
            vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#BF616A", bg = "#2E3440" }) -- Red text on dark background
            vim.api.nvim_set_hl(0, "DiffText", { fg = "#88C0D0", bg = "#434C5E" })   -- Blue text on slightly lighter background
            -- Fix Neovim Errors (Make them more readable)
            vim.api.nvim_set_hl(0, "ErrorMsg", { fg = "#BF616A", bg = "#2E3440", bold = true }) -- Red text on dark background
            vim.api.nvim_set_hl(0, "WarningMsg", { fg = "#EBCB8B", bg = "#2E3440", bold = true }) -- Yellow text on dark background
            -- Fix LSP Diagnostic Colors
            vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#BF616A", bg = "NONE", bold = true })  -- Red for LSP errors
            vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#EBCB8B", bg = "NONE", bold = true })  -- Yellow for warnings
            vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#88C0D0", bg = "NONE" })  -- Blue hints
            vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#5E81AC", bg = "NONE" })  -- Subtle info messages
        end,
    },
    {
        "projekt0n/github-nvim-theme",
        lazy = false,
        priority = 1000,
        config = function()
            require("github-theme").setup({
                options = { transparent = false }
            })
            vim.cmd("colorscheme github_dark")
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function ()
            local configs = require("nvim-treesitter.configs")

            configs.setup({
                ensure_installed = {
                    "c",
                    "lua",
                    "vim",
                    "vimdoc",
                    "query",
                    "javascript",
                    "html",
                    "rust"
                },
                sync_install = false,
                -- recommended false if no tree-sitter CLI
                auto_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/nvim-cmp" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },

    {
        "nvim-telescope/telescope.nvim", tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    { "tpope/vim-fugitive" },

    { "mbbill/undotree" },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
})

local lsp_zero = require("lsp-zero")
lsp_zero.on_attach(function(_, bufnr)
    -- see :help lsp-zero-keybindings
    lsp_zero.default_keymaps({buffer = bufnr})
end)

-- This should be executed before language server configurations
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    require('cmp_nvim_lsp').default_capabilities()
)

-- mason setup
require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "ts_ls",
        "html",
        "cssls",
        "dockerls"
    },
    handlers = {
        -- first function is default function
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
        ts_ls = function()
            local lspconfig = require('lspconfig')
            lspconfig.ts_ls.setup({
                root_dir = lspconfig.util.root_pattern("package.json"),
                single_file_support = false
            })
        end,
    },
})

local cmp = require('cmp')
cmp.setup({
    sources = {
        {name = 'nvim_lsp'},
    },
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({}),
})

local diagnostic_icons = {
    [vim.diagnostic.severity.ERROR] = "",
    [vim.diagnostic.severity.WARN]  = "",
    [vim.diagnostic.severity.HINT]  = "",
    [vim.diagnostic.severity.INFO]  = "",
}

-- Set diagnostic signs (left gutter)
for severity, icon in pairs(diagnostic_icons) do
    local hl = "DiagnosticSign" .. ({
        [vim.diagnostic.severity.ERROR] = "Error",
        [vim.diagnostic.severity.WARN]  = "Warn",
        [vim.diagnostic.severity.HINT]  = "Hint",
        [vim.diagnostic.severity.INFO]  = "Info",
    })[severity]
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Set diagnostic virtual text (right-side hints)
vim.diagnostic.config({
    virtual_text = {
        prefix = function(diagnostic)
            return diagnostic_icons[diagnostic.severity] .. " "
        end,
        spacing = 4,
    },
    update_in_insert = false,
    severity_sort = true,
    signs = true
})

require('lualine').setup()

require("sluna")
