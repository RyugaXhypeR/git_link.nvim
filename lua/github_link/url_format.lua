local M = {}

-- Split the url into its components.
M.url_split = function(url)
  local protocol, domain, user, repo = url:match("([^:@]+).*[/@]([%w_]+).com[:/]([^/]+)/([^/]+).git")

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
M.url_format = function(repo_url, branch, relative_path, ln_start, ln_stop)
  local split = M.url_split(repo_url)
  if not (split and branch and relative_path) then
    return nil
  end

  local blob = ("https://%s.com/%s/%s/blob/%s/%s"):format(
    split.domain, split.user, split.repo, branch, relative_path
  )

  if ln_start ~= nil then
    blob = blob .. "#L" .. ln_start
  end
  if ln_stop ~= nil then
    blob = blob .. "-#L" .. ln_stop
  end

  return blob
end

return M
