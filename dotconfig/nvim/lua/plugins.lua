-- only required if packer is `opt`
vim.cmd [[packadd packer.nvim ]]

return require("packer").startup(function(use)
    use "wbthomason/packer.nvim"
    -- U: Upstream appears to be unmaintained. No need to check for updates
    -- L: Lock to this version because of an issue, put the issue link like L#123

    -- ## UI AND EDITOR FUNCTION
    use { 'nvim-tree/nvim-tree.lua',                 tag = "v1.13.0" }
    use { 'nvim-tree/nvim-web-devicons',             commit = "19d6211c78169e78bab372b585b6fb17ad974e82" }
    use { 'nvim-lualine/lualine.nvim',               commit = "a94fc68960665e54408fe37dcf573193c4ce82c9" }
    use { 'lukas-reineke/indent-blankline.nvim',     tag = "v3.9.0" }
    use { 'nvim-telescope/telescope.nvim',           commit = "b4da76be54691e854d3e0e02c36b0245f945c2c7" }
    use { 'nvim-telescope/telescope-ui-select.nvim', commit = "6e51d7da30bd139a6950adf2a47fda6df9fa06d2" }
    use { 'nvim-lua/plenary.nvim',                   commit = "857c5ac632080dba10aae49dba902ce3abf91b35" }
    use { 'mbbill/undotree',                         commit = "7a8b831e9bfb9f6fe05cc33294882648dd6801fb" }
    use { 'voldikss/vim-floaterm',                   commit = "fd4bdd66eca56c6cc59f2119e4447496d8cde2ea" }
    use { 'terrortylor/nvim-comment',                commit = "e9ac16ab056695cad6461173693069ec070d2b23" } -- U

    -- ## THEME AND COLORS
    use { "catppuccin/nvim", tag = "v1.9.0", as = "catppuccin" }
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'nvim-treesitter/nvim-treesitter-context'

    -- ## LANGUAGE SERVICE
    use { 'neovim/nvim-lspconfig' }
    use { 'felpafel/inlay-hint.nvim',                commit = "ee8aa9806d1e160a2bc08b78ae60568fb6d9dbce" }
    use { 'williamboman/mason.nvim', run = ":MasonUpdate" }
    use { 'williamboman/mason-lspconfig.nvim' }
    use { 'github/copilot.vim',                      tag = "v1.50.0" }
    use { 'CopilotC-Nvim/CopilotChat.nvim',          tag = "v3.12.1" }
    -- completion
    use { 'hrsh7th/nvim-cmp',
        requires = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help' },
            { 'hrsh7th/cmp-nvim-lua' }
        }
    }
    -- language: java (jdtls)
    use { 'mfussenegger/nvim-jdtls',                 commit = "ece818f909c6414cbad4e1fb240d87e003e10fda",
        ft = { 'java' },
        config = function () require('lsp-wrapper.jdtls') end
    }
end)
