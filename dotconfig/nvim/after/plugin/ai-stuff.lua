local select = require("CopilotChat.select")
local chat = require("CopilotChat")
chat.setup({
    temperature = 0.0,
    selection = function(source)
        return select.visual(source) or select.buffer(source)
    end,
    -- default window options
    window = {
        layout = 'float', -- 'vertical', 'horizontal', 'float', 'replace', or a function that returns the layout
        width = 0.4, -- fractional width of parent, or absolute width in columns when > 1
        height = 0.7, -- fractional height of parent, or absolute height in rows when > 1
        -- Options below only apply to floating windows
        relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
        border = 'rounded', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
        row = 99999, -- row position of the window, default is centered
        col = 99999, -- column position of the window, default is centered
        title = '', -- title of chat window
        footer = nil, -- footer of chat window
        zindex = 1, -- determines if window is on top or below other floating windows
    },
    auto_insert_mode = true,
    mappings = {
        complete = {
            -- i have no idea how this works
            -- but if I set <Right> here, <Tab> will
            -- accept the completion, otherwise it doesn't work
            insert = '<Right>',
        },
        close = {
            insert = '<C-w>',
            normal = '<ESC>',
        },
        show_diff = {
            normal = 'vd',
            full_diff = false
        },
        accept_diff = {
            normal = '<C-a>',
            insert = '<C-a>',
        }
    },
})
vim.keymap.set({'n', 'v'}, '<leader>gc', function()
    chat.open()
end, { noremap = true })
vim.keymap.set({'n', 'v', 'i'}, '<C-b>', function()
    if not chat.chat:visible() then
        return
    end
    chat.close()
    vim.cmd('undo')
    chat.open()
    vim.cmd('stopinsert')
end, { noremap = true })

-- turn off copilot completion by default
vim.cmd('Copilot disable')
