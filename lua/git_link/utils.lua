M = {}

-- TODO: capture, normal-mode motion range
function M.get_mark_region(op_mode)
  vim.cmd[[execute "normal! \<esc>"]]
  local ln_start = vim.api.nvim_buf_get_mark(0, '<')
  local ln_stop = vim.api.nvim_buf_get_mark(0, '>')

  return ln_start[1], ln_stop[1]
end

return M
