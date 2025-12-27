-- only required if packer is `opt`
vim.cmd [[packadd packer.nvim ]]

return require("packer").startup(function(use)
    use "wbthomason/packer.nvim"
    -- U: Upstream appears to be unmaintained. No need to check for updates
    -- L: Lock to this version because of an issue, put the issue link like L#123

    -- ## UI AND EDITOR FUNCTION
    use { 'nvim-tree/nvim-tree.lua',                 tag = "v1.14.0" }
    use { 'nvim-tree/nvim-web-devicons',             commit = "6788013bb9cb784e606ada44206b0e755e4323d7" }
    use { 'nvim-lualine/lualine.nvim',               commit = "47f91c416daef12db467145e16bed5bbfe00add8" }
    use { 'lukas-reineke/indent-blankline.nvim',     tag = "v3.9.0" }
    use { 'nvim-telescope/telescope.nvim',           commit = "4d0f5e0e7f69071e315515c385fab2a4eff07b3d" }
    use { 'nvim-telescope/telescope-ui-select.nvim', commit = "6e51d7da30bd139a6950adf2a47fda6df9fa06d2" }
    use { 'nvim-lua/plenary.nvim',                   commit = "b9fd5226c2f76c951fc8ed5923d85e4de065e509" }
    use { 'mbbill/undotree',                         commit = "0f1c9816975b5d7f87d5003a19c53c6fd2ff6f7f" }
    use { 'voldikss/vim-floaterm',                   commit = "a11b930f55324e9b05e2ef16511fe713f1b456a7" }
    use { 'terrortylor/nvim-comment',                commit = "e9ac16ab056695cad6461173693069ec070d2b23" } -- U

    -- ## THEME AND COLORS
    use { "catppuccin/nvim", as = "catppuccin",      tag = "v1.11.0" }
    use { 'nvim-treesitter/nvim-treesitter',         branch = 'master', run = ':TSUpdate' }
    use { 'nvim-treesitter/nvim-treesitter-context', commit = '64dd4cf3f6fd0ab17622c5ce15c91fc539c3f24a' }

    -- ## LANGUAGE SERVICE
    use { 'neovim/nvim-lspconfig',                   commit = "d696e36d5792daf828f8c8e8d4b9aa90c1a10c2a" }
    use { 'felpafel/inlay-hint.nvim',                commit = "ee8aa9806d1e160a2bc08b78ae60568fb6d9dbce" }
    use { 'mason-org/mason.nvim',                    commit = "57e5a8addb8c71fb063ee4acda466c7cf6ad2800", run = ":MasonUpdate" }
    use { 'williamboman/mason-lspconfig.nvim',       commit = "9f9c67795d0795a6e8612f5a899ca64a074a1076" }
    use { 'github/copilot.vim',                      tag = "v1.58.0" }
    use { 'CopilotC-Nvim/CopilotChat.nvim',          tag = "v4.7.4" }
    -- completion
    use { 'hrsh7th/nvim-cmp',                        commit = "d97d85e01339f01b842e6ec1502f639b080cb0fc" }
    use { 'hrsh7th/cmp-nvim-lsp',                    commit = "cbc7b02bb99fae35cb42f514762b89b5126651ef" }
    use { 'hrsh7th/cmp-path',                        commit = "c642487086dbd9a93160e1679a1327be111cbc25" }
    use { 'hrsh7th/cmp-buffer',                      commit = "b74fab3656eea9de20a9b8116afa3cfc4ec09657" }
    use { 'hrsh7th/cmp-nvim-lsp-signature-help',     commit = "fd3e882e56956675c620898bf1ffcf4fcbe7ec84" }
    use { 'hrsh7th/cmp-nvim-lua',                    commit = "e3a22cb071eb9d6508a156306b102c45cd2d573d" }
    -- language: java (jdtls)
    use { 'mfussenegger/nvim-jdtls',                 commit = "ece818f909c6414cbad4e1fb240d87e003e10fda",
        ft = { 'java' },
        config = function () require('lsp-wrapper.jdtls') end
    }
end)
