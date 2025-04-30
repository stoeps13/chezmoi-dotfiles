vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.mouse = ""
--vim.opt.conceallevel = 2

vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.cursorline = true
vim.opt.autoread = true

-- use spaces for tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

-- linenumbers
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.clipboard="unnamedplus"

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

vim.opt.ignorecase = true

-- Add this to your Neovim Lua config (init.lua or another loaded config file)
vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = "asciidoc",
  callback = function()
    -- Set folding method to expr
    vim.opt_local.foldmethod = "expr"
    -- Define fold expression that uses AsciiDoc headers (==, ===, etc.) for folding
    -- vim.opt_local.foldexpr = "getline(v:lnum)=~'^=\\+\\s' ? '>'.matchend(getline(v:lnum), '^=\\+') : '='"
    vim.opt_local.foldexpr = "getline(v:lnum)=~'^==\\s' ? '>1' : getline(v:lnum)=~'^===\\s' ? '>2' : '='"
    -- Start with all folds open
    vim.opt_local.foldenable = true
    vim.opt_local.foldlevel = 20

    -- Define buffer-local fold keymappings that won't interfere with vim-zettel
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>fc', '<cmd>foldclose<CR>', {desc = 'Close fold', noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>fo', '<cmd>foldopen<CR>', {desc = 'Open fold', noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>fa', '<cmd>fold<CR>', {desc = 'Toggle fold', noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>fM', 'zM', {desc = 'Close all folds', noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>fR', 'zR', {desc = 'Open all folds', noremap = true, silent = true})
  end
})
vim.api.nvim_create_autocmd({"BufEnter"}, {
  pattern = {"*.*.*"},
  callback = function()
    local filename = vim.fn.expand("%:p")
    local extensions = {}

    -- Split the filename by dots to get extensions
    for ext in string.gmatch(filename, "[^.]+") do
      table.insert(extensions, ext)
    end

    -- If we have at least two extensions
    if #extensions >= 2 then
      local second_to_last_ext = extensions[#extensions-1]

      -- Map of extensions to filetypes
      local extension_map = {
        md = "markdown",
        sh = "shell",
        properties = "toml",
        ini = "toml",
        yaml = "yaml",
        yml = "yaml",
        toml = "toml",
        json = "json",
        py = "python",
        js = "javascript",
        html = "html",
        css = "css",
        -- Add more mappings as needed
      }

      -- Set filetype if we have a mapping for it
      if extension_map[second_to_last_ext] then
        vim.bo.filetype = extension_map[second_to_last_ext]
      end
    end
  end
})
-- Create the mapping
vim.api.nvim_set_keymap(
  'n',                               -- normal mode
  '<localleader>sf',                 -- the key combination
  ':r ! update_frontmatter.py %<CR>:e!<CR>', -- the command to execute
  { desc = 'Update frontmatter', noremap = true, silent = false } -- options
)
vim.api.nvim_set_keymap(
  'n',                               -- normal mode
  '<localleader>sc',                 -- the key combination
  ':r! sn_case_with_comments.py -n %:t:r -f ', -- the command to execute
  { desc = "Get new comments",noremap = true, silent = false } -- options
)

vim.api.nvim_set_keymap(
  'n',                               -- normal mode
  '<localleader>si',                 -- the key combination
  ':r! sn_interloc_overview.py<CR>', -- the command to execute
  { desc = "Get open case list",noremap = true, silent = false } -- options
)

