return {
  'catppuccin/nvim',
  --'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.termguicolors = true
    vim.cmd.colorscheme "catppuccin-mocha" -- catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
    -- vim.o.background = 'dark'
  end
}
