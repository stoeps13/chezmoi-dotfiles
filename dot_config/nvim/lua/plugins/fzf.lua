return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>fd", "<cmd>FzfLua files<cr>",    desc = "Find files" },
    { "<leader>rg", "<cmd>FzfLua grep<cr><cr>", desc = "Grep files" },
    { "<leader>cc", "<cmd>FzfLua grep_quickfix<cr>", desc = "Grep files" },
    { "<leader>b",  "<cmd>FzfLua buffers<cr>",  desc = "Find buffers" },
  },
  config = function()
    -- calling `setup` is optional for customization
    require("fzf-lua").setup({ "fzf-tmux" })
  end,
}
