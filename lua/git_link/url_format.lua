local M = {}

-- Split the url into its components.
function M.url_split(url)
  local protocol, domain, user, repo = url:match('([^:@]+).*[/@]([%w_]+).com[:/]([^/]+)/([^/]+).git')

  if protocol and domain and user and repo then
    return {
      protocol = protocol,
      domain = domain,
      user = user,
      repo = repo,
    }
  end
end

-- Return the permalink.
function M.url_format(repo_url, branch, relative_path, ln_start, ln_stop)
  local split = M.url_split(repo_url)

  if not split then
    vim.notify("Couldn't parse url.")
  elseif not branch then
    vim.notify("Couldn't fetch current branch.")
  elseif not relative_path then
    vim.notify('File does not exist.')
  end

  local blob = ('https://%s.com/%s/%s/blob/%s/%s'):format(
    split.domain, split.user, split.repo, branch, relative_path
  )

  if ln_start ~= nil then
    blob = blob .. '#L' .. ln_start
  end
  if ln_stop ~= nil then
    blob = blob .. '-#L' .. ln_stop
  end

  return blob
end

return M
