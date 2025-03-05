vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.mouse = ""
--vim.opt.conceallevel = 2

vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.cursorline = true
vim.opt.autoread = true

-- use spaces for tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

-- linenumbers
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.clipboard="unnamedplus"

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

vim.opt.ignorecase = true
