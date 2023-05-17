-- Module to run various git commands in a seperate process and return the output.

local Job = require('plenary.job')
local M = {}

-- Run git commands in a new process and return the output.
--
-- Parameters
-- ==========
-- args: list
--   The arguments to pass to git.
--
-- cwd: str | nil
--   The working directory in which the command is to be executed.
--   Defaults to working directory of the buffer if not specified.
M.git_cmd = function(args, cwd)
  return Job:new({
    command = 'git',
    args = args,
    cwd = cwd or vim.fn.expand('%:p:h'),
    on_exit = function(j_self, _, _)
      return table.concat(j_self:result(), '')
    end,
  }):sync()
end

-- Get the current branch name, this will be used to generate the blob for that branch.
M.get_git_branch = function(cwd)
  return M.git_cmd({ 'branch', '--show-current' }, cwd)[1]
end

-- Get the current git remote url.
M.get_repo_url = function(cwd)
  local remote = M.git_cmd({ 'remote' })[1]
  if remote == nil then
    return nil
  end

  return M.git_cmd({ 'config', '--get', ('remote.%s.url'):format(remote) }, cwd)[1]
end

-- Get the root directory of the git repo.
M.get_git_root = function(cwd)
  return M.git_cmd({ 'rev-parse', '--show-toplevel' }, cwd)[1]
end

-- Get the relative path of the file from the git root.
--
-- Parameters
-- ==========
-- file_path: str
--  The path of the file relative to the working directory.
--
-- cwd: str | nil
-- The working directory in which the command is to be executed.
M.get_relative_path = function(file_path, cwd)
  return M.git_cmd({ 'ls-files', '--full-name', '--', file_path or vim.fn.expand('%:p') }, cwd)[1]
end

return M
