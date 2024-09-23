return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<leader>fd", "<cmd>FzfLua files<cr>", desc = "Find files" },
		{ "<leader>fn", "<cmd>FzfLua complete_path<cr>", desc = "Get filename with path" },
		{ "<leader>rg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
		{ "<leader>b", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		{ "<leader>m", "<cmd>FzfLua marks<cr>", desc = "Marks" },
		{ "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git status" },
		{ "<leader>cc", "<cmd>FzfLua lsp_code_actions<cr>", desc = "Lsp Code Actions" },
		{ "<leader>cd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },
	},
	config = function()
		-- calling `setup` is optional for customization
		local actions = require("fzf-lua.actions")
		require("fzf-lua").setup({
			"fzf-tmux",
			files = {
				actions = { ["alt-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" } },
			},
		})
	end,
}
