return {
  "akinsho/bufferline.nvim",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'moll/vim-bbye'
  },
  config = function()
    require("bufferline").setup {
      options = {
        always_show_bufferline = true,
        diagnostics = 'nvim_lsp',
        enforce_regular_tabs = true,
        numbers = "none",
        persist_buffer_sort = true,
        seperator_style = 'thin',
        show_buffer_close_icons = false,
        show_buffer_icons = true,
        show_close_icon = false,
        show_tab_indicators = true,
        indicator = {
          style = 'icon',
          icon = '|',
        },
        hover = {
          enabled = true,
          delay = 150,
          reveal = { 'close' }
        },
        offsets = {
          {
            filetype = "neo-tree",
            text = "",
            padding = 1
          }
        },
      }
    }
    vim.keymap.set("n", "H", ":bp<CR>", {})
    vim.keymap.set("n", "L", ":bn<CR>", {})
    vim.keymap.set('n', "<leader>q", ":Bdelete! %<CR>", {})
  end,
}
