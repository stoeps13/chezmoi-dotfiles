return {
	{
		"hrsh7th/cmp-nvim-lsp",
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			"rafamadriz/friendly-snippets",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local ls = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_lua").lazy_load({ paths = "./lua/snippets" })
			local s = ls.snippet
			local t = ls.text_node
			local i = ls.insert_node
			local f = ls.function_node
			local extras = require("luasnip.extras")
			local rep = extras.rep

			local getPath = function()
				local current_file_path = vim.fn.expand("%:p")

				local parent_path = vim.fn.fnamemodify(current_file_path, ":h:h")

				return parent_path
			end

			local makePath = function()
				local current_file_path = vim.fn.expand("%:p")

				local current_working_directory = vim.fn.getcwd()

				local relative_path = vim.fn.fnamemodify(current_file_path, ":p:h")
				relative_path = vim.fn.substitute(
					relative_path,
					"^" .. vim.fn.escape(current_working_directory, "/\\") .. "/",
					"",
					""
				)

				return relative_path
			end
			local date = function()
				return { os.date("%Y-%m-%d") }
			end
			local addDirect = function()
				local current_file_path = vim.fn.expand("%:p")

				local base_path_prefix = "/Users/<SET YOUR BASE PATH!!!>"

				if vim.fn.stridx(current_file_path, base_path_prefix) == 0 then
					local relative_path_without_base =
						vim.fn.substitute(current_file_path, "^" .. base_path_prefix, "", "")

					local directory_only = vim.fn.fnamemodify(relative_path_without_base, ":h")

					return "/" .. directory_only
				end

				return "ERROR"
			end

			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				end
			end, { silent = true })

			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end, { silent = true })

			ls.add_snippets("vimwiki", {
				s("meta", {
					t({ "---", "title: " }),
					i(1, "note_title"),
					t({ "", "author: " }),
					i(2, "author"),
					t({ "", "date: " }),
					f(date, {}),
					t({ "", "categories: [" }),
					i(3, ""),
					t({ "]", "lastmod: " }),
					f(date, {}),
					t({ "", "tags: [" }),
					i(4),
					t({ "]", "comments: true", "---", "" }),
					i(0),
				}),

				s("home", {
					t("[[/index|Home]]"),
				}),

				s("to_back)", {
					t("[["),
					t("//"),
					f(getPath),
					t("/"),
					i(1, "back directory"),
					t("|Back]]"),
				}),

				s("h1", {
					t("# "),
					i(1, "Name header"),
				}),

				s("h2", {
					t("## "),
					i(1, "Name header"),
				}),
				s("h3", {
					t("### "),
					i(1, "Name header"),
				}),
				s("h4", {
					t("#### "),
					i(1, "Name header"),
				}),

				s("link", {
					t("["),
					i(1, "Linktitle"),
					t("]("),
					i(2, "Location"),
					t(")"),
				}),

				s("todo_incomp", {
					t("- [ ] "),
					i(1, "reminder"),
				}),

				s("todo_done", {
					t("- [X] "),
					i(1, "reminder"),
				}),

				s("todo_notyet", {
					t("- [.] "),
					i(1, "reminder"),
				}),

				s("comingsoon", {
					t({ "[[/index|Home]]", "", "" }),
					t("Coming Soon..."),
				}),

        s("InterlocUpdate", {
          t({"## " }),
					f(date, {}),
					t({ " Interloc Call" }),
        }),
        s("todo_open", {
          t("## Open tasks | status:pending -VISIBLE")
        })
			})
			local keymap = vim.api.nvim_set_keymap
			local opts = { noremap = true, silent = true }
			keymap("i", "<c-j>", "<cmd>lua require'luasnip'.jump(1)<CR>", opts)
			keymap("s", "<c-j>", "<cmd>lua require'luasnip'.jump(1)<CR>", opts)
			keymap("i", "<c-k>", "<cmd>lua require'luasnip'.jump(-1)<CR>", opts)
			keymap("s", "<c-k>", "<cmd>lua require'luasnip'.jump(-1)<CR>", opts)
		end,
		keys = {
			{ "<leader>fd", "<cmd>FzfLua files<cr>", desc = "Find files" },
			--  { "<c-j>", "<cmd>lua require'luasnip'.jump(1)<cr>", desc = "Jump snips"},
		},
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "luasnip" }, -- For luasnip users.
					{ name = "nvim_lsp" },
					{ name = "nvim_lua" },
					{ name = "buffer", keyword_length = 3 },
					{ name = "path" },
				}),
			})
		end,
	},
}
