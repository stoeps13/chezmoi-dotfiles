return {
	"vimwiki/vimwiki",
	dependencies = {
		"mattn/calendar-vim",
		"WnP/vimwiki_markdown",
		"michal-h21/vim-zettel",
	},
	init = function()
		-- Default directory, syntax and file type,
		-- symbols for spaces, auto re-index tags db
		vim.g.vimwiki_list = {
			{
				path = "~/vimwiki",
				syntax = "markdown",
				ext = ".md",
				links_space_char = "_",
				path_html = "~/vimwiki/site_html/",
				custom_wiki2html = "vimwiki_markdown",
				auto_tags = 1,
				auto_diary_index = 1,
			},
		}
		vim.g.vimwiki_global_ext = 0
    vim.g.markdown_folding = 1
    vim.g.vimwiki_folding = 'syntax'
    vim.g.vimwiki_header_type = '#'
    vim.cmd([[
        autocmd FileType vimwiki setlocal foldlevel=4
    ]])
    vim.g.vimwiki_fold_blank_lines = 1

		-- Disable header levels keybindings so oil.nvim will work
		vim.g.vimwiki_key_mappings = {
			headers = 0,
		}
		-- Syntax highlighting for code blocks
		vim.g.vimwiki_syntax_plugins = {
			codeblock = {
				["```lua"] = { parser = "lua" },
				["```python"] = { parser = "python" },
				["```javascript"] = { parser = "javascript" },
				["```bash"] = { parser = "bash" },
				["```html"] = { parser = "html" },
				["```css"] = { parser = "css" },
				["```c"] = { parser = "c" },
				["```sql"] = { parser = "sql" },
			},
		}
		vim.g.nv_search_paths = { "/var/home/stoeps/vimwiki" }
		vim.g.zettel_format = "%y%m%d-%H%M%-title"

		vim.cmd([[
      autocmd BufNewFile ~/vimwiki/diary/*.md
      \ call append(0,[
      \ "# " . split(expand('%:r'),'/')[-1], "",
      \ "## Meetings", "",
      \ "## Logbook",  ""])
    ]])
	end,
}
