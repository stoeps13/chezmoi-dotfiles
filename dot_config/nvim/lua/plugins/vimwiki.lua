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
    vim.g.vimwiki_folding = "syntax"
    vim.g.vimwiki_header_type = "#"
    vim.cmd([[
        autocmd FileType vimwiki setlocal foldlevel=3
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
    vim.g.zettel_format = "%y%m%d-%H%M%S"

    vim.cmd([[
      autocmd BufNewFile ~/vimwiki/diary/*.md
      \ call append(0,[
      \ "# " . split(expand('%:r'),'/')[-1], "",
      \ "## Meetings", "",
      \ "## Logbook",  ""])
    ]])

    -- Autocommands to pull and push to git automatically.
    -- author: @aaron <https://aaron.com.es>

    -- This is better accompanied with a crontab similar to:
    -- # Disable emails
    -- MAILTO=""
    -- # Autocommit for vimwiki
    -- * * * * * (cd ~/vimwiki && git pull origin master; git add .; git commit -m "Autocommit (cron 1 min) @ $(hostname -s)"; git push origin master)

    local function git_async_handler(data, event)
      if event == "exit" then
        if data == 0 then
          vim.api.nvim_echo({ { "Git commit and push successful.", "None" } }, false, {})
        else
          vim.api.nvim_echo({ { "Git commit and push failed.", "ErrorMsg" } }, false, {})
        end
      end
    end

    local function git_commit_and_push()
      local cmd = 'git commit -am "Autocommit (on save) @ $(hostname -s)" && git push'
      vim.fn.jobstart(cmd, {
        on_exit = function(_, data, event)
          git_async_handler(data, event)
        end,
      })
    end

    local function git_pull()
      local output = vim.fn.system("git pull origin main")
      if vim.v.shell_error ~= 0 then
        vim.api.nvim_err_writeln("Git pull failed")
        vim.api.nvim_err_writeln(output)
      else
        vim.api.nvim_echo({ { "Git pull successful", "None" } }, false, {})
      end
    end

    -- Create autocommand group for vimwiki autocommit
    vim.api.nvim_create_augroup("vimwiki_autocommit", { clear = true })

    -- Run git pull before reading vimwiki files
    vim.api.nvim_create_autocmd("BufReadPre", {
      group = "vimwiki_autocommit",
      pattern = "/var/home/stoeps/vimwiki/**",
      callback = function()
        git_pull()
      end,
    })

    -- Run git commit and push after saving vimwiki files
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = "vimwiki_autocommit",
      pattern = "/var/home/stoeps/vimwiki/**",
      callback = function()
        git_commit_and_push()
      end,
    })
  end,
}
