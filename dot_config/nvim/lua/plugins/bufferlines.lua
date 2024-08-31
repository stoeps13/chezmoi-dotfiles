return {
  "akinsho/bufferline.nvim",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require("bufferline").setup {
      options = {
        mode = 'tabs',
        seperator_style = 'slant',
        show_close_icon = false,
        show_buffer_close_icon = false,
        diagnostics = 'nvim_lsp',
        always_show_bufferline = true,
        numbers = "none",
        close_command = function(n)
          LazyVim.ui.bufremove(n)
        end,
        right_mouse_command = function(n)
          LazyVim.ui.bufremove(n)
        end,
        hover = {
          enabled = true,
          delay = 150,
          reveal = { 'close' }
        },
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left"
          }
        },
      }
    }
    vim.keymap.set("n", "H", ":bp<CR>", {})
    vim.keymap.set("n", "L", ":bn<CR>", {})
  end,
}
