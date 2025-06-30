-- # Extra Snipets of functionality

-- ## Copy to system clipboard
--   NOTE: we are using register "a", so it doesn't conflict
--   with nvim's builtin functionality
--
-- Windows: uses set-clipboard
-- Wayland: wl-copy is used.
--
-- Otherwise, assume we are in SSH session, and use the HOST_MACHINE_IP
-- environment variable to send it to host using websocket
local _ = (function()
    if vim.fn.has("win32") ~= 0 then
        vim.cmd([[
set shell=pwsh
set shellcmdflag=-command
set shellquote="
set shellxquote=
]])
        vim.cmd([[
augroup YankToScript
  autocmd!
  autocmd TextYankPost * if v:register == 'a' | call writefile([getreg('a')], $LOCALAPPDATA .. '/.config/nvim/.yank') | silent! execute '!(Get-Content $env:LOCALAPPDATA/.config/nvim/.yank) -replace "`0","`n" | set-clipboard' | redraw! | endif
augroup END
        ]])
    elseif vim.fn.executable("wl-copy") ~= 0 then
        vim.cmd([[
augroup YankToScript
  autocmd!
  autocmd TextYankPost * if v:register == 'a' | call writefile([getreg('a')], '/tmp/yank') | silent! execute '!bash -c "cat /tmp/yank | tr ''\0'' ''\n'' | wl-copy -n"' | redraw! | endif
augroup END
        ]])
    else
        vim.cmd([[
augroup YankToScript
  autocmd!
  autocmd TextYankPost * if v:register == 'a' | call writefile([getreg('a')], '/tmp/yank') | silent! execute '!bash -c "source ~/.bashrc && cat /tmp/yank | websocat -1 -t -u ws://$HOST_MACHINE_IP:8881"' | redraw! | endif
augroup END
        ]])
    end
end)()


-- ## Bug in 0.11 that causes line number width change when diagnostics change, which causes the whole text to shift
local _ = (function()
    local NORMAL_WIDTH = 6
    local NARROW_WIDTH = NORMAL_WIDTH - 2 -- diagnostics are 2 chars in width
    local bufid_to_hasdiag = {}
    local update_bufid_to_hasdiag = function()
        for _, bufid in ipairs(vim.api.nvim_list_bufs()) do
            local diagnostics = vim.diagnostic.get(bufid)
            bufid_to_hasdiag[bufid] = #diagnostics > 0
        end
    end
    local update_numberwidth = function()
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
            local bufid = vim.api.nvim_win_get_buf(winid)
            if bufid_to_hasdiag[bufid] then
                vim.api.nvim_set_option_value('numberwidth', NARROW_WIDTH, { win = winid })
            else
                vim.api.nvim_set_option_value('numberwidth', NORMAL_WIDTH, { win = winid })
            end
        end
    end
    local refresh_numberwidth_for_all_wins = function()
        update_bufid_to_hasdiag()
        update_numberwidth()
    end
    refresh_numberwidth_for_all_wins()
    -- auto update when switching buffers
    vim.api.nvim_create_autocmd("BufEnter", {
        callback = refresh_numberwidth_for_all_wins
    })
    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
            vim.diagnostic.hide()
            for _, winid in ipairs(vim.api.nvim_list_wins()) do
                vim.api.nvim_set_option_value('numberwidth', NORMAL_WIDTH, { win = winid })
            end
        end
    })
    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            vim.diagnostic.show()
            refresh_numberwidth_for_all_wins()
        end
    })
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        callback = function()
            -- no need to update in insert mode sice diagnostics are not shown
            if vim.fn.mode() == 'i' then
                return
            end
            refresh_numberwidth_for_all_wins()
        end
    })
end)()

-- ## Extra filetypes to recognize
vim.cmd [[
  au BufRead,BufNewFile *.md.txtpp        set filetype=markdown
  au BufRead,BufNewFile *.html.txtpp      set filetype=html
  au BufRead,BufNewFile *.rs.txtpp        set filetype=rust
  au BufRead,BufNewFile *.ts.txtpp        set filetype=typescript
  au BufRead,BufNewFile *.tsx.txtpp       set filetype=typescriptreact
  au BufRead,BufNewFile *.js.txtpp        set filetype=javascript
  au BufRead,BufNewFile *.jsx.txtpp       set filetype=javascriptreact
  au BufRead,BufNewFile *.py.txtpp        set filetype=python
  au BufRead,BufNewFile *.css.txtpp       set filetype=css
  au BufRead,BufNewFile *.json.txtpp      set filetype=json
  au BufRead,BufNewFile *.yaml.txtpp      set filetype=yaml
  au BufRead,BufNewFile *.yml.txtpp       set filetype=yaml
  au BufRead,BufNewFile *.toml.txtpp      set filetype=toml
  au BufRead,BufNewFile *.bash.txtpp      set filetype=bash

  au BufRead,BufNewFile *.rasi            set filetype=css
]]
