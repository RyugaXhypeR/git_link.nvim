local lfs = require("lfs")
local API = {}

-- Mutable globals to avoid multiply computations of shared objects.
-- TODO: Don't use globals.
local GIT_DIR = nil
local GIT_PREFIX = nil
local MAX_PARENTS = 15  -- const

local function contains_git_dir(dir)
  for attr in lfs.dir(dir) do
    if attr == '.git' and lfs.attributes(attr).mode == 'directory' then
      return attr
    end
  end
  return nil
end

local function get_local_git_dir(dir)
  if dir == nil then
    dir = vim.fn.expand("%:p:h")
  end

  local attr = contains_git_dir(dir)
  local i = 0

  -- Look through `MAX_PARENTS` directories to find a git directory.
  while attr == nil and i < MAX_PARENTS do
    dir = dir .. "/.."
    attr = contains_git_dir(dir)
    i = i + 1
  end

  if attr == nil then
    return nil
  end

  return dir
end

local function get_git_prefix(dir)
  return "git -C " .. dir
end

-- Extract the github username and repo name from the git config.
local function get_user_and_repo()
  GIT_DIR = get_local_git_dir(nil)

  if GIT_DIR == nil then
    os.exit()
  end

  GIT_PREFIX = get_git_prefix(GIT_DIR)

  local github_url = vim.fn.systemlist(GIT_PREFIX .. " config --get remote.origin.url")[1]
  if github_url == "" or github_url == nil then
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

-- Construct the github url using file path and line numbers.
local function get_highlighted_link(file_path, ln_start, ln_end)
  local user, repo = get_user_and_repo()
  local branch = get_git_branch()
  local rel_path = vim.fn.systemlist(GIT_PREFIX .. " ls-files --full-name -- " .. file_path)[1]

  local url = string.format("https://github.com/%s/%s/blob/%s/%s#L%d",
    user, repo, branch, rel_path, ln_start)

  if ln_end ~= nil then
    url = url .. "-L" .. ln_end
  end

  return url
end

local function get_selected()
  local ln_start = vim.api.nvim_buf_get_mark(0, '<')
  local ln_stop = vim.api.nvim_buf_get_mark(0, '>')

  -- Only return the line number
  return ln_start[1], ln_stop[1]
end

API.selected_link = function()
  vim.cmd[[execute "normal! \<esc>"]]
  local file_path = vim.fn.expand("%:p")
  local ln_start, ln_stop = get_selected()
  local url = get_highlighted_link(file_path, ln_start, ln_stop)
  print(url)
  vim.fn.setreg("+", url)
end

return API
