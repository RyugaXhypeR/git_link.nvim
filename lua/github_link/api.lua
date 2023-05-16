local M = {}
local Job = require('plenary.job')
local Git = require('github_link.git')
local UrlFormat = require('github_link.url_format')

-- Return the line number of start and stop mark of current buffer.
local function get_marks()
  -- Turn off visual mode.
  vim.cmd[[execute "normal! \<Esc>"]]

  local ln_start = vim.api.nvim_buf_get_mark(0, '<')[1]
  local ln_stop = vim.api.nvim_buf_get_mark(0, '>')[1]

  return ln_start, ln_stop
end

local function get_url()
  local repo_url = Git.get_repo_url(nil)
  local branch = Git.get_git_branch(nil)
  local relative_path = Git.get_relative_path(nil, nil)
  local ln_start, ln_stop = get_marks()

  return UrlFormat.url_format(repo_url, branch, relative_path, ln_start, ln_stop)
end

M.copy_url = function()
  local url = get_url()
  if url then
    vim.fn.setreg('+', url)
  end
end

M.open_url = function()
  local url = get_url()
  if url then
    Job:new({
      command = "open",
      args = { url },
      cwd = vim.fn.expand("%:p")
    }):start()
  end

end

return M
