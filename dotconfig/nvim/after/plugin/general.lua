require('nvim_comment').setup({
    create_mappings = false
})
require('treesitter-context').setup({
    enable = true,
    separator = '>',
})
require('nvim-treesitter').setup({ })
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldmethod = 'expr'
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
