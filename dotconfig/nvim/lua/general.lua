-- # General Configuration

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
vim.opt.foldmethod = 'expr'  -- treesitter folding
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
-- search
vim.opt.hlsearch = true
vim.opt.incsearch = true -- should be the default
-- scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

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
    local jump_half_word = function(action, flag)
        -- Save current position
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        -- Search pattern: _ or [A-Z] or word boundary (\<)
        local pattern = [[\(_\w\|\u\|\<\)]]
        -- Search forward, no [W]rap and go to [e]nd
        local found = vim.fn.search(pattern, 'We')
        if found == 0 then
            -- Not found, restore cursor
            vim.api.nvim_win_set_cursor(0, {row, col})
            return
        end
        if action == nil then
            return
        end
        if action == 'd' or action == 'c' then
            local new_row, new_col = unpack(vim.api.nvim_win_get_cursor(0))
            vim.api.nvim_win_set_cursor(0, {row, col})
            -- enter visual mode
            vim.cmd('normal! v')
            if flag == 't' then
                vim.api.nvim_win_set_cursor(0, {new_row, new_col - 1})
            else
                vim.api.nvim_win_set_cursor(0, {new_row, new_col})
            end
            vim.cmd('normal! d')
            if action == 'c' then
                vim.cmd('startinsert')
            end
            return
        end
    end
    noremap('n', '<S-l>', function() jump_half_word(nil) end)
    noremap('n', 'df<S-l>', function() jump_half_word("d", "f") end)
    noremap('n', 'dt<S-l>', function() jump_half_word("d" ,"t") end)
    noremap('n', 'cf<S-l>', function() jump_half_word("c", "f") end)
    noremap('n', 'ct<S-l>', function() jump_half_word("c" ,"t") end)

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
    noremap('n', '<leader>w', '<cmd>NvimTreeClose<cr><C-w>r<cmd>NvimTreeOpen<cr><C-W>l')
    -- duplicate split view to other side
    noremap('n', '<leader>dl', '<C-w>l<cmd>q<cr><C-w>v') --left to right
    noremap('n', '<leader>dh', '<C-w>h<cmd>q<cr><C-w>v') --right to left
    -- convert between Rust /// doc and JS /** doc */
    noremap('n', '<leader>J', '0f/wBR/**<esc>A */<esc>')
    noremap('v', '<leader>J', '<esc>\'<lt>O<esc>0C/**<esc>\'>o<esc>0C */<esc><cmd>\'<lt>,\'>s/\\/\\/\\// */<cr>gv`<lt>koj=<cmd>nohl<cr>')
    noremap('n', '<leader>R', '0f*wBR///<esc>A<esc>xxx')
    noremap('v', '<leader>R', '<esc>\'<lt>dd\'>ddgv<esc><cmd>\'<lt>,\'>s/\\*/\\/\\/\\//<cr>gv`<lt>koj=<cmd>nohl<cr>')
    -- copilot
    noremap('i', '<A-Tab>', '<Plug>(copilot-accept-line)')
    -- toggle floaterm
    noremap('n', [[<C-\>]], function() vim.cmd.FloatermToggle() end)
    noremap('t', [[<C-\>]], vim.cmd.FloatermToggle)
    -- new floaterm terminal
    noremap('n', [[<leader><C-\>]], vim.cmd.FloatermNew)
    noremap('t', [[<leader><C-\>]], [[<C-\><C-n><cmd>FloatermNew<CR>]])
    -- back to normal mode with Ctrl-w
    noremap('t', '<C-w>', [[<C-\><C-n>]])
    -- cycle through terminals
    noremap('n', '<C-n>', vim.cmd.FloatermNext)
    noremap('t', '<C-n>', vim.cmd.FloatermNext)
    -- jumping to diagnostics
    local show_diag_float = function()
        vim.defer_fn(function()
            vim.diagnostic.open_float({ scope = 'cursor' })
        end, 50)
    end
    noremap('n', '[d', function()
        vim.diagnostic.jump({ count = -1})
        show_diag_float()
    end)
    noremap('n', ']d', function()
        vim.diagnostic.jump({ count = 1})
        show_diag_float()
    end)
    noremap('n', '[D', function()
        vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
        show_diag_float()
    end)
    noremap('n', ']D', function()
        vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
        show_diag_float()
    end)
    -- toggle comment
    noremap('n', '<leader>c', vim.cmd.CommentToggle)
    noremap('v', '<leader>c', "V<cmd>'<,'>CommentToggle<cr>gv")
    -- toggle undotree
    noremap('n', '<leader>u', vim.cmd.UndotreeToggle)

    -- Other key mappings, see
    -- telescope.lua
    -- lsp-config.lua
    -- nvim-tree.lua
end)()
