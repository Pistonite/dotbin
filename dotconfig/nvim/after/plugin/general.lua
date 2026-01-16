require('telescope').setup({
    defaults = {
        mappings = {
            i = {
                ["<A-j>"] = "move_selection_next",
                ["<A-k>"] = "move_selection_previous",
            }
        }
    },
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown { }
        }
    }
})
require("telescope").load_extension("ui-select")
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
require("claudecode").setup {
    log_level = "error",
    terminal = {
        provider = "native",
        split_width_percentage = 0.4,
        cwd_provider = function(ctx)
            return ctx.cwd
        end,
    },
}
