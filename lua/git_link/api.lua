local M = {}
local Job = require('plenary.job')
local Git = require('git_link.git')
local UrlFormat = require('git_link.url_format')
local Utils = require('git_link.utils')

-- Return the blob url.
local function get_url(op_mode)
  local repo_url = Git.get_repo_url(nil)
  local branch = Git.get_git_branch(nil)
  local relative_path = Git.get_relative_path(nil, nil)
  local ln_start, ln_stop = Utils.get_mark_region(op_mode)

  return UrlFormat.url_format(repo_url, branch, relative_path, ln_start, ln_stop)
end

-- Copies the url to `+` register.
function M.copy_url(op_mode)
  local url = get_url(op_mode)
  print(url)
  if url then
    vim.fn.setreg('+', url)
  end
end

-- Opens the url in browser.
-- Requires `xdg-open` to work.
function M.open_url()
  local url = get_url()
  local open_cmd = 'open'
  local os_name = vim.loop.os_uname().sysname

  if os_name == 'Linux' then
    open_cmd = 'xdg-' .. open_cmd
  end

  if url then
    Job:new({
      command = open_cmd,
      args = { url },
    }):start()
  end
end

return M
