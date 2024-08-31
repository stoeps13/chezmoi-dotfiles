return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    lazy = true,
    dependencies = { { "nvim-lua/plenary.nvim" } },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>fd", builtin.find_files, {})
      vim.keymap.set("n", "<leader>rg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>b", builtin.buffers, {})
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      -- This is your opts table
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}
