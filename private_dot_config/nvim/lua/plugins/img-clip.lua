return {
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	opts = {
		-- add options here
		default = {
			dir_path = "assets", ---@type string | fun(): string
			extension = "png", ---@type string | fun(): string
			file_name = "%Y%m%d-%H%M%S", ---@type string | fun(): string
			use_absolute_path = false, ---@type boolean | fun(): boolean
			prompt_for_file_name = false,
			relative_to_current_file = true,
		},
		filetypes = {
			markdown = {
				url_encode_path = true, ---@type boolean | fun(): boolean
				template = "![$FILE_NAME]($FILE_PATH)", ---@type string | fun(context: table): string
				download_images = false, ---@type boolean | fun(): boolean
			},

			html = {
				template = '<img src="$FILE_PATH" alt="$FILE_NAME">', ---@type string | fun(context: table): string
			},

			asciidoc = {
			  dir_path = "images", ---@type string | fun(): string
				template = 'image::$FILE_NAME[width=80%, alt="$FILE_NAME"]', ---@type string | fun(context: table): string
			},
		},
		-- or leave it empty to use the default settings
	},
	keys = {
		-- suggested keymap
		{ "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
	},
}
