-- Function to replace multiple consecutive empty lines with a single empty line
function replace_multiple_empty_lines()
  -- Save cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Get the current buffer
  local bufnr = vim.api.nvim_get_current_buf()

  -- Get all lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Track if we're in a sequence of empty lines
  local in_empty_sequence = false
  local new_lines = {}

  -- Process each line
  for _, line in ipairs(lines) do
    local is_empty = line:match("^%s*$") ~= nil

    if is_empty then
      if not in_empty_sequence then
        -- First empty line in a sequence, keep it
        table.insert(new_lines, line)
        in_empty_sequence = true
      end
      -- Skip other empty lines in the sequence
    else
      -- Non-empty line, add it and reset the flag
      table.insert(new_lines, line)
      in_empty_sequence = false
    end
  end

  -- Replace all lines in the buffer with our processed lines
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)

  -- Try to restore cursor position
  -- Ensure the line exists in the new buffer
  local new_line_count = #new_lines
  if cursor_pos[1] > new_line_count then
    cursor_pos[1] = new_line_count
  end
  vim.api.nvim_win_set_cursor(0, cursor_pos)

  -- Print a message with the number of lines removed
  local lines_removed = #lines - #new_lines
  print("Removed " .. lines_removed .. " empty lines")
end

-- Create a command to call this function
vim.api.nvim_create_user_command("RemoveEmptyLines", replace_multiple_empty_lines, {})

-- Optional: Map it to a key combination
vim.api.nvim_set_keymap(
  'n',                            -- normal mode
  '<localleader>se',                  -- key combination (replace with your preference)
  ':lua replace_multiple_empty_lines()<CR>',
  { desc = "remove multiple empty lines", noremap = true, silent = true }
)
