-- # General Configuration
local editorapi = require("editorapi")

-- line numbers
vim.opt.number = true    -- Enable line numbers
vim.opt.rnu = true       -- Relative line numbers by default
-- hidden characters (controlled by keymapping)
vim.opt.listchars = "tab:▸ ,trail:·,nbsp:␣,extends:»,precedes:«,eol:↲"
-- indent
vim.opt.expandtab = true -- Tab become spaces
vim.opt.shiftwidth = 4   -- Indent 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.fillchars:append { diff = "╱" }

vim.opt.termguicolors = true -- colors
-- undo dir
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
local home = os.getenv('HOME')
if home == nil then
    home = os.getenv('USERPROFILE')
end
if home ~= nil then
    vim.opt.undodir = home .. '/.vim/undodir'
end

-- folds
vim.opt.foldenable = false   -- no fold at startup
vim.opt.foldlevel = 99
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- search
vim.opt.hlsearch = true
vim.opt.incsearch = true -- should be the default
-- scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
-- diff
vim.cmd([[
:set diffopt+=internal,algorithm:patience,indent-heuristic
:set diffopt+=linematch:60
]])

-- Floaterm style
vim.g.floaterm_title = 'Terminal [$1/$2]'
-- Undotree style
vim.g.undotree_WindowLayout = 0
vim.g.undotree_SetFocusWhenToggle = 1

-- ## Diagnostics
vim.diagnostic.config({
    virtual_text = true,
    float = {
        border = 'rounded',
    }
})

-- ## Keys
local _ = (function()
    -- helper for remapping
    local function noremap(mode, lhs, rhs, opts)
        local options = { noremap = true }
        if opts then
            options = vim.tbl_extend('force', options, opts)
        end
        vim.keymap.set(mode, lhs, rhs, options)
    end
    -- toggle relative line number
    noremap('n', '<leader>0', function() vim.o.relativenumber = not vim.o.relativenumber end)
    -- toggle show hidden characters (like eol, tab, etc.)
    noremap('n', '<leader>$', function() vim.o.list = not vim.o.list end)
    -- turn off search highlight
    noremap('n', '<leader> ', vim.cmd.nohlsearch)
    -- cursor movement
    -- 15 lines is about where the text moves and I can still see what's going on
    noremap('n', '<C-d>', '15j')     -- bukl move down
    noremap('n', '<C-u>', '15k')     -- bulk move up
    noremap('n', 'n', 'nzz')         -- move to next match and center
    noremap('n', 'N', 'Nzz')         -- move to previous match and center
    -- Move to next '_', uppercase letter, or word boundary
    noremap('n', '<S-l>', function() editorapi.jump_half_word(nil) end)
    noremap('n', 'df<S-l>', function() editorapi.jump_half_word("d", "f") end)
    noremap('n', 'dt<S-l>', function() editorapi.jump_half_word("d" ,"t") end)
    noremap('n', 'cf<S-l>', function() editorapi.jump_half_word("c", "f") end)
    noremap('n', 'ct<S-l>', function() editorapi.jump_half_word("c" ,"t") end)

    -- line movement (note: the : cannot be replaced by <cmd>)
    noremap('v', '<A-j>', [[:m '>+1<cr>gv=gv]]) -- move selection down
    noremap('v', '<A-k>', [[:m '<-2<cr>gv=gv]]) -- move selection up
    -- turn off recording so I don't accidentally hit it
    noremap('n', 'q', '<nop>')
    noremap('n', 'Q', '<nop>')
    -- change window size
    noremap('n', '<C-w>>', '<C-w>20>')
    noremap('n', '<C-w><', '<C-w>20<')
    noremap('n', '<C-w>+', '<C-w>10+')
    noremap('n', '<C-w>-', '<C-w>10-')
    -- copy to system clipboard (see extra.lua)
    noremap('v', '<leader>y', '"ay')
    -- swap left and right buffers
    noremap('n', '<leader>w', editorapi.swap_editing_files)
    -- convert between Rust /// doc and JS /** doc */
    noremap('n', '<leader>J', '0f/wBR/**<esc>A */<esc>')
    noremap('v', '<leader>J', '<esc>\'<lt>O<esc>0C/**<esc>\'>o<esc>0C */<esc><cmd>\'<lt>,\'>s/\\/\\/\\// */<cr>gv`<lt>koj=<cmd>nohl<cr>')
    noremap('n', '<leader>R', '0f*wBR///<esc>A<esc>xxx')
    noremap('v', '<leader>R', '<esc>\'<lt>dd\'>ddgv<esc><cmd>\'<lt>,\'>s/\\*/\\/\\/\\//<cr>gv`<lt>koj=<cmd>nohl<cr>')
    -- jumping to diagnostics
    noremap('n', '[d', function() editorapi.jump_diagnostic(-1, false) end)
    noremap('n', ']d', function() editorapi.jump_diagnostic(1, false) end)
    noremap('n', '[D', function() editorapi.jump_diagnostic(-1, true) end)
    noremap('n', ']D', function() editorapi.jump_diagnostic(-1, true) end)
    -- toggle comment
    noremap('n', '<leader>c', vim.cmd.CommentToggle)
    noremap('v', '<leader>c', "V<cmd>'<,'>CommentToggle<cr>gv")
    -- toggle undotree
    noremap('n', '<leader>u', vim.cmd.UndotreeToggle)

    -- floaterm
    noremap({'n', 't'}, [[<C-\>]], editorapi.toggle_floaterm)
    noremap({'t', 'n'}, [[<leader><C-\>]], editorapi.new_floaterm)
    -- escape from terminal
    noremap('n', '<esc>', editorapi.close_fileterm)
    noremap('t', '<C-w>', editorapi.fileterm_ctrl_w)
    -- cycle through terminals when floaterm is open
    noremap('t', '<C-n>', editorapi.cycle_floaterm)
    noremap('n', '<C-n>', editorapi.cycle_floaterm)
    -- auto startinsert when entering non-floaterm
    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            local bt = editorapi.buftyp()
            if bt == editorapi.buft.FILETERM then
                vim.cmd("startinsert")
            elseif bt == editorapi.buft.AIDIFF then
                local current_buf = vim.api.nvim_get_current_buf()
                for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    local bufnr = vim.api.nvim_win_get_buf(winid)
                    if bufnr ~= current_buf then
                        local ft = vim.bo[bufnr].filetype
                        if ft and ft ~= "" then
                            vim.bo[current_buf].filetype = ft
                            break
                        end
                    end
                end
            end
        end
    })
    -- duplicate split view to other side
    noremap('n', '<leader>dl', function() editorapi.editview_duplicate(true) end)
    noremap('n', '<leader>dh', function() editorapi.editview_duplicate(false) end)

    -- telescopers
    noremap({'n', 't'}, '<leader>ff', editorapi.open_file_finder)
    noremap('n', '<leader>fr', editorapi.open_last_finder)
    noremap('t', '<C-f>r', editorapi.open_last_finder)
    noremap('n', '<leader>fg', editorapi.open_live_grep_finder)
    noremap('t', '<C-f>g', editorapi.open_live_grep_finder)
    noremap('n', '<leader>fb', editorapi.open_buffer_finder)
    noremap('t', '<C-f>b', editorapi.open_buffer_finder)
    noremap('n', '<leader>fs', editorapi.open_symbol_finder)
    noremap('t', '<C-f>s', editorapi.open_symbol_finder)
    noremap('n', 'gr', editorapi.open_reference_finder)
    noremap('n', 'gd', editorapi.open_definition_finder)
    noremap('n', 'gi', editorapi.open_implementation_finder)
    noremap('n', '<leader>vd', editorapi.open_diagnostic_finder)
    -- just switch to main edit view
    noremap('n', '<leader>e', function() editorapi.switch_to_editview_then(nil) end)
    -- ## AI Coder integration
    noremap('n', '<leader>bb', editorapi.open_aicoder)
    noremap('n', '<leader>bg', editorapi.close_aicoder)
    noremap({'n', 't'}, '<leader>bv', editorapi.open_or_accept_aidiff)
    noremap({'n', 't'}, '<leader>bd', editorapi.deny_aidiff)
    noremap('n', '<leader>bl', function() editorapi.send_to_aicoder(false) end)
    noremap('v', '<leader>bl', function() editorapi.send_to_aicoder(true) end)
    noremap('n', '<leader>gs', function() editorapi.open_git_diff('status') end)
    noremap('n', '<leader>gd', function()
        vim.ui.input({ prompt = 'Git diff: ' }, function(input)
            if input then
                editorapi.open_git_diff(input)
            end
        end)
    end)

    -- focus on tree (edit mode and diff mode)
    noremap('n', '<leader>t', editorapi.open_file_tree)


    -- Other key mappings that requires plugin to be loaded first
    -- telescope.lua
    -- lsp-config.lua
    -- nvim-tree.lua
end)()
