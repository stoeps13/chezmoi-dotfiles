return {
	"nvim-telekasten/telekasten.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-telekasten/calendar-vim",
		"nvim-telescope/telescope-media-files.nvim",
	},
	config = function()
		require("telekasten").setup({
      auto_set_filetype = false,
      take_over_my_home = true,
			home = vim.fn.expand("~/zettelkasten"),
			dailies = "diary", -- path to daily notes
			weeklies = "weeklies", -- path to weekly notes
			templates = "templates", -- path to templates

			-- Specific note templates
			-- set to `nil` or do not specify if you do not want a template
			template_new_note = vim.fn.expand("~/zettelkasten/templates/new.md"), -- template for new notes
			template_new_daily = vim.fn.expand("~/zettelkasten/templates/daily.md"), -- template for new daily notes
			template_new_weekly = vim.fn.expand("~/zettelkasten/templates/weekly.md"), -- template for new weekly notes
      template_handling = "always_ask",

      -- Flags for creating non-existing notes
      follow_creates_nonexisting = true,    -- create non-existing on follow
      dailies_create_nonexisting = true,    -- create non-existing dailies
      weeklies_create_nonexisting = true,   -- create non-existing weeklies

			-- Image subdir for pasting
			-- subdir name
			-- or nil if pasted images shouldn't go into a special subdir
			image_subdir = "img",

			-- File extension for note files
			extension = ".md",

			-- Generate note filenames. One of:
			-- "title" (default) - Use title if supplied, uuid otherwise
			-- "uuid" - Use uuid
			-- "uuid-title" - Prefix title by uuid
			-- "title-uuid" - Suffix title with uuid
			new_note_filename = "title",
			-- file uuid type ("rand" or input for os.date such as "%Y%m%d%H%M")
			uuid_type = "%Y%m%d%H%M",
			-- UUID separator
			uuid_sep = "-",
			calendar_monday = 1,
		})
		-- Launch panel if nothing is typed after <leader>z
		vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>")

		-- Most used functions
		vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
		vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>")
		vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>")
		vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>")
		vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
		vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>")
		vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>")
		vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>")

		-- Call insert link automatically when we start typing a link
		vim.keymap.set("i", "[[", "<cmd>Telekasten insert_link<CR>")

	end,
}
