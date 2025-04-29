return {
  'nvim-lualine/lualine.nvim',
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = true,
        -- theme = nord,
      },
      sections = {
        lualine_a = {
          {
            'filename',
            path = 1,
          }
        }
      }
    })
  end,
}
