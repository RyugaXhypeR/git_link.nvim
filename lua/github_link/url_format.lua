local M = {}

M.url_split = function(url)
  local protocol, domain, user, repo = url:match("([^:@]+).*[/@]([%w_]+).com[:/]([^/]+)/([^/]+).git")

  return {
    protocol = protocol,
    domain = domain,
    user = user,
    repo = repo,
  }
end

M.url_format = function(repo_url, branch, relative_path, ln_start, ln_stop)
  local split = M.url_split(repo_url)
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
