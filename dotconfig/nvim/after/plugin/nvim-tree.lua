local api = require "nvim-tree.api"
vim.cmd([[
    augroup NvimTreeAutoFocus
        autocmd BufEnter * lua require'nvim-tree.api'.tree.find_file()
    augroup END
]])
local function on_attach_nvim_tree(bufnr)
    -- setup lualine only after nvim tree attach
    -- to avoid loading it too early onto the tree
    local lualine_theme = require("lualine.themes.catppuccin")
    lualine_theme.normal.a.gui = ""
    lualine_theme.insert.a.gui = ""
    lualine_theme.visual.a.gui = ""
    lualine_theme.replace.a.gui = ""
    lualine_theme.command.a.gui = ""
    lualine_theme.inactive.a.gui = ""
    require('lualine').setup({
        options = {
            theme = lualine_theme,
            disabled_filetypes = {
                'packer',
                'NvimTree',
                'undotree',
            },
        },
        sections = {
            lualine_b = {
                'branch',
                'diff',
                {
                    'diagnostics',
                    colored = true,
                    symbols = {
                        error = 'E',
                        warn = 'W',
                        hint = 'H',
                        info = 'I',
                    }
                }
            }
        }
    })
    -- only attack keys i need
    local function opts(desc)
        return {
            desc = 'nvim-tree: ' .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true
        }
    end
    vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts('Info'))
    vim.keymap.set('n', 'O', api.node.navigate.parent_close, opts('Close parent'))
    vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Go to parent'))
    vim.keymap.set('n', 'm', api.fs.rename_sub, opts('Move'))
    vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'v', function()
        require("editorapi").close_aicoder()
        api.node.open.vertical()
    end, opts('Open: vertical'))
    vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: split'))
    vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
    vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
    vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
    vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
    vim.keymap.set('n', 'D', api.fs.trash, opts('Trash'))
    vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
    vim.keymap.set('n', 'r', api.fs.rename_sub, opts('Rename'))
    vim.keymap.set('n', '-', api.marks.toggle, opts('Select'))
    vim.keymap.set('n', 'bd', api.marks.bulk.delete, opts('Delete: selected'))
    vim.keymap.set('n', 'bm', api.marks.bulk.move, opts('Move: selected'))
    vim.keymap.set('n', '[', api.node.navigate.diagnostics.prev, opts('Prev diagnostic'))
    vim.keymap.set('n', ']', api.node.navigate.diagnostics.next, opts('Next diagnostic'))
    vim.keymap.set('n', 'B', api.tree.toggle_no_buffer_filter, opts('Toggle opened'))
    vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle dotfiles'))
    vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle gitignore'))
    vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
    vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
    vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts('Copy absolute path'))
    vim.keymap.set('n', 'y', api.fs.copy.filename, opts('Copy name'))
    vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts('Copy relative path'))
    vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))

    -- add custom
end

local integration = require("integration")

require("nvim-tree").setup({
    on_attach = on_attach_nvim_tree,
    git = {
        enable = integration.git
    },
    renderer = {
        icons = {
            glyphs = {
                bookmark = "-",
                git = {
                    unstaged = "M",
                    staged = "✓",
                    unmerged = "",
                    renamed = "R",
                    untracked = "U",
                    deleted = "D",
                    ignored = "i",
                },
            }
        }
    },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
        icons = {
            hint = "H",
            info = "I",
            warning = "W",
            error = "E",
        }
    }
})
require("codediff").setup {
    keymaps = {
        view = {
            quit = "<esc>",                    -- Close diff tab
            toggle_explorer = "<leader>T",  -- Toggle explorer visibility (explorer mode only)
            next_hunk = "]c",   -- Jump to next change
            prev_hunk = "[c",   -- Jump to previous change
            next_file = "]f",   -- Next file in explorer mode
            prev_file = "[f",   -- Previous file in explorer mode
            -- diff_get = "do",    -- Get change from other buffer (like vimdiff)
            -- diff_put = "dp",    -- Put change to other buffer (like vimdiff)
        },
        explorer = {
            select = "o",    -- Open diff for selected file
            --     hover = "K",        -- Show file diff preview
            --     refresh = "R",      -- Refresh git status
            toggle_view_mode = "i",  -- Toggle between 'list' and 'tree' views
            toggle_stage = nil,--"s", -- Stage/unstage selected file
            stage_all = nil,--"S",    -- Stage all files
            unstage_all = nil,--"U",  -- Unstage all files
            restore = nil--"x",      -- Discard changes (restore file)
        },
        conflict = {
            accept_incoming = nil,--j"<leader>ct",  -- Accept incoming (theirs/left) change
            accept_current = nil,--"<leader>co",   -- Accept current (ours/right) change
            accept_both = nil,--"<leader>cb",      -- Accept both changes (incoming first)
            discard = nil,--"<leader>cx",          -- Discard both, keep base
            next_conflict = "]x",            -- Jump to next conflict
            prev_conflict = "[x",            -- Jump to previous conflict
            diffget_incoming = "2do",        -- Get hunk from incoming (left/theirs) buffer
            diffget_current = "3do",         -- Get hunk from current (right/ours) buffer
        },
    },
}
