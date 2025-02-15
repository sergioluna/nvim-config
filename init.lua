local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
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
            vim.cmd.colorscheme("nord")

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

    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },

    { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/nvim-cmp" },
    { "L3MON4D3/LuaSnip" },

    {
        "nvim-telescope/telescope.nvim", tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    { "tpope/vim-fugitive" },

    { "mbbill/undotree" },
})

-- lsp zero setup
local lsp_zero = require("lsp-zero")

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({buffer = bufnr})
end)

-- mason setup
require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "ts_ls",
        "denols",
        "html",
        "cssls",
        "dockerls"
    },
    handlers = {
        lsp_zero.default_setup,
    },
})

-- lsp config setups should be after mason-lspconfig setup
require("lspconfig")
require("lspconfig").denols.setup {
    root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
}

require("lspconfig").ts_ls.setup {
    root_dir = require("lspconfig").util.root_pattern("package.json"),
    single_file_support = false
}

require("sluna")
