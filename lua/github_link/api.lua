local lfs = require("lfs")
local API = {}

-- Mutable globals to avoid multiply computations of shared objects.
-- TODO: Don't use globals.
local GIT_DIR = nil
local GIT_PREFIX = nil

--[[
Checks if the directory contains a `.git` directory

Parameters
----------
dir: str
 The directory to check in

Returns
-------
bool
--]]
local function contains_git_dir(dir)
  for attr in lfs.dir(dir) do
    if attr == '.git' and lfs.attributes(attr).mode == 'directory' then
      return true
    end
  end
  return false
end

--[[
Return the parent directory which contains the `.git` folder.

Parameters
----------
  dir: str | nil
    The base directory to look into.
    If dir is nil, it will search in directory of the current buffer.

Returns
-------
  str:
    The directory which contains the git directory.
--]]
local function get_local_git_dir(dir)
  if dir == nil then
    dir = vim.fn.expand("%:p:h")
  end

  local attr = contains_git_dir(dir)
  local i = 0

  -- Walk back the directories to find any `.git` dirs.
  while not attr and dir ~= '/' do
    -- Look for `.git` in the parent directory.
    dir = dir:gsub("/(%w+)$", "")
    attr = contains_git_dir(dir)
    i = i + 1
  end

  if not attr then
    return nil
  end

  return dir
end

-- Prefix to run git commands for specific projects.
local function get_git_prefix(dir)
  return "git -C " .. dir
end

-- Extract the github username and repo name from the git config.
local function get_user_and_repo()
  GIT_DIR = get_local_git_dir(nil)

  if GIT_DIR == nil then
    print("No git directory found!")
    return nil
  end

  GIT_PREFIX = get_git_prefix(GIT_DIR)

  local github_url = vim.fn.systemlist(GIT_PREFIX .. " config --get remote.origin.url")[1]
  if github_url == "" or github_url == nil then
    print("Project is not hosted on github!")
    return nil
  end

  local gh_user, gh_repo = github_url:match("github.com[:/](.+)/(.+)")
  gh_repo = gh_repo:gsub("%.git$", "") -- strip `.git` from the end if it exists.
  return gh_user, gh_repo
end

-- Get the current git branch.
local function get_git_branch()
  local branch = vim.fn.systemlist(GIT_PREFIX .. " rev-parse --abbrev-ref HEAD")[1]
  if branch == "HEAD" then
    branch = vim.fn.systemlist(GIT_PREFIX .. " rev-parse HEAD")[1]
  end
  return branch
end

-- Does checks to see if the project is hosted on github and it has all prerequisites to generate a url.
local function can_generate_url()
  GIT_DIR = get_local_git_dir(nil)
  if GIT_DIR == nil then 
    return false 
  end

  GIT_PREFIX = get_git_prefix(GIT_DIR)

  local branch = get_git_branch()
  if branch == nil then 
    return false 
  end

  local user_repo = get_user_and_repo()
  if user_repo == nil then 
    return false
  end

  local file_path = vim.fn.expand("%:p")
  local relative_path = vim.fn.systemlist(GIT_PREFIX .. " ls-files --full-name -- " .. file_path)[1]
  if relative_path == nil then 
    return false
  end

  return { user_repo, branch, relative_path }
end


-- Construct the github url using file path and line numbers.
local function get_highlighted_link(ln_start, ln_end)
  local can_gen = can_generate_url()
  if not can_gen then
    return nil
  end

  local user, repo, branch, relative_path = unpack(can_gen)

  local url = string.format("https://github.com/%s/%s/blob/%s/%s#L%d",
    user, repo, branch, relative_path, ln_start)

  if ln_end ~= nil then
    url = url .. "-L" .. ln_end
  end

  return url
end

-- Return the line number of start and stop marks of the current buffer.
local function get_selected()
  local ln_start = vim.api.nvim_buf_get_mark(0, '<')
  local ln_stop = vim.api.nvim_buf_get_mark(0, '>')

  -- Only return the line number
  return ln_start[1], ln_stop[1]
end

-- 
API.selected_link = function()
  vim.cmd[[execute "normal! \<esc>"]]
  local ln_start, ln_stop = get_selected()
  local url = get_highlighted_link(ln_start, ln_stop)

  if url == nil then
    return nil
  end

  vim.fn.setreg("+", url)
end

return API
