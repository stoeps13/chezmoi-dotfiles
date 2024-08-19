require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'lua', 'vim', 'markdown', 'yaml'},
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  },
}
