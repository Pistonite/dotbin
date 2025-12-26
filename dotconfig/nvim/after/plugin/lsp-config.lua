-- reference: https://lsp-zero.netlify.app/blog/you-might-not-need-lsp-zero.html

require('inlay-hint').setup({
    virt_text_pos = 'eol',
    -- this is taken from https://github.com/felpafel/inlay-hint.nvim
    -- and modified to my liking
    display_callback = function(line_hints, options, bufnr)
        local param_hints = {}
        local type_hints = {}
        table.sort(line_hints, function(a, b)
            return a.position.character < b.position.character
        end)
        for _, hint in pairs(line_hints) do
            local label = hint.label
            local kind = hint.kind
            local text = ''
            if type(label) == 'string' then
                text = label
            else
                for _, part in ipairs(label) do
                    text = text .. part.value
                end
            end
            if kind == 1 then
                param_hints[#param_hints + 1] = text:gsub('^:%s*', '')
            else
                type_hints[#type_hints + 1] = text:gsub(':$', '')
            end
        end
        local text = ''
        if #type_hints > 0 then
            text = ' (' .. table.concat(type_hints, ',') .. ')'
        end
        if #text > 0 then
            text = text .. ' '
        end
        if #param_hints > 0 then
            text = text ..  table.concat(param_hints, ',')
        end
        return text
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local bufid = event.buf
        local key_opts = { buffer = bufid }
        -- keys that only work when LSP is attached (so they are buffer-local)
        vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, key_opts)
        vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, key_opts)
        vim.keymap.set('n', 'K', function() vim.lsp.buf.hover({ border = "rounded" }) end, key_opts)
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, key_opts)
        -- code action menu
        vim.keymap.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, key_opts)
        -- signature help in input mode
        vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, key_opts)
        -- enable inlay hints (currently disabled by default)
        vim.lsp.inlay_hint.enable(true, { bufid })
        vim.cmd("hi LspInlayHint guifg=#d8d8d8 guibg=#3a3a3a")
        vim.keymap.set({'n', 'v'}, 'I', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, key_opts)
    end
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config['lua_ls'] ={
    capabilities = lsp_capabilities,
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostic = { globals = { 'vim' } }, -- make diagnostic work when configuring nvim
            workspace = {
                library = { vim.env.VIMRUNTIME },
            }
        }
    }
}

-- connect mason the LSP server management tool
require("mason").setup({
    ui = {
        border = 'rounded',
    }
})
require("mason-lspconfig").setup({})

-- local string_to_list = function(str, delimiter)
--     local list = {}
--     for word in string.gmatch(str, '([^' .. delimiter .. ']+)') do
--         table.insert(list, word)
--     end
--     return list
-- end

-- -- Rust Analyzer Environment Variables
-- --   LSP_RUST_ANALYZER_FEATURES: comma separated list of features to enable
-- --   LSP_RUST_ANALYZER_NO_DEFAULT_FEATURES: set to anything to disable default features
-- --   LSP_RUST_ANALYZER_EXTRA_ARGS: extra arguments to pass to cargo
-- local lsp_rust_analyzer_features = (function()
--     local env_value = vim.env.LSP_RUST_ANALYZER_FEATURES
--     if env_value == nil then
--         return {}
--     end
--     return string_to_list(env_value, ',')
-- end)()
-- local lsp_rust_analyzer_extra_args = (function()
--     local env_value = vim.env.LSP_RUST_ANALYZER_EXTRA_ARGS
--     if env_value == nil then
--         return {}
--     end
--     return string_to_list(env_value, ' ')
-- end)()
-- local lsp_rust_analyzer_no_default_features = vim.env.LSP_RUST_ANALYZER_NO_DEFAULT_FEATURES ~= nil
-- lspconfig.rust_analyzer.setup({
--     settings = {
--         ["rust-analyzer"] = {
--             cargo = {
--                 extraArgs = lsp_rust_analyzer_extra_args,
--                 features = lsp_rust_analyzer_features,
--                 noDefaultFeatures = lsp_rust_analyzer_no_default_features,
--             }
--         }
--     }
-- })
--
-- lsp.setup()

-- auto complete setup (needs to be after lsp.setup())
local cmp = require('cmp')
cmp.setup({
    -- completion menu kep mapping
    mapping = {
        -- accept completion
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        -- trigger completion
        ['<C-n>'] = cmp.mapping.complete(),
        -- abort completion
        ['<C-e>'] = cmp.mapping.abort(),
        -- nagivate
        ['<A-k>'] = cmp.mapping.select_prev_item(),
        ['<A-j>'] = cmp.mapping.select_next_item(),
    },

    -- Installed sources:
    sources = {
        { name = 'buffer',                 keyword_length = 2 }, -- source current buffer
        { name = 'path' },                     -- file paths
        { name = 'nvim_lsp',               keyword_length = 2 }, -- from language server
        { name = 'nvim_lsp_signature_help' },  -- display function signatures with current parameter emphasized
        { name = 'nvim_lua',               keyword_length = 2 }, -- complete neovim's Lua runtime API such vim.lsp.*
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    formatting = {
        fields = { 'abbr', 'kind' },
    },
})
-- Set completeopt to have a better completion experience
--
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force to select one from the menu
-- shortmess: avoid showing extra messages when using completion
-- updatetime: set updatetime for CursorHold
vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_set_option_value('updatetime', 300, {})

-- Remove if no longer needed
-- https://github.com/neovim/neovim/issues/30985 workaround for LSP error from rust-analyzer
for _, method in ipairs({
    'textDocument/diagnostic',
    'textDocument/semanticTokens/full/delta',
    'textDocument/inlayHint',
    'workspace/diagnostic'
}) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil then
            if err.code == -32802 then
                return
            end
            if err.code == -32603 then
                return
            end
        end

        return default_diagnostic_handler(err, result, context, config)
    end
end
