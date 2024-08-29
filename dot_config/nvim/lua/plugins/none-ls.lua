return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.diagnostics.ansiblelint,
				null_ls.builtins.diagnostics.eslint_d,
				null_ls.builtins.diagnostics.markdownlint,
				null_ls.builtins.diagnostics.shellcheck,
				null_ls.builtins.diagnostics.shellharden,
				null_ls.builtins.diagnostics.yamllint,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.isort,
				null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.shellharden,
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.yamlfix,
			},
		})

		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
