require('nvim_comment').setup({
    create_mappings = false
})
require('treesitter-context').setup({
    enable = true,
    separator = '>',
})
require('nvim-treesitter.configs').setup({
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    }
})
