local API = {}
-- Extract the github username and repo name from the git config.
-- This will make it so that repos cloned over ssh will work as well.
local function get_user_and_repo()
  local github_url = vim.fn.systemlist("git config --get remote.origin.url")[1]

  if github_url == "" then
    -- Project is not hosted on github.
    return nil
  end

  -- TODO: Add support for other git hosting services.
  local gh_user, gh_repo = string.match(github_url, "github.com[:/](.+)/(.+).git")
  return gh_user, gh_repo
end

-- Get the current git branch.
local function get_git_branch()
  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
  if branch == "HEAD" then
    branch = vim.fn.systemlist("git rev-parse HEAD")[1]
  end
  return branch
end

-- Construct the github url using file path and line numbers.
local function get_highlighted_link(file_path, ln_start, ln_end)
  local user, repo = get_user_and_repo()
  local branch = get_git_branch()
  local rel_path = vim.fn.systemlist("git ls-files --full-name -- " .. file_path)[1]

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
    local file_path = vim.fn.expand("%:p")
    local ln_start, ln_stop = get_selected()
    local url = get_highlighted_link(file_path, ln_start, ln_stop)
    print(url)
    vim.fn.setreg("+", url)
end

return API
