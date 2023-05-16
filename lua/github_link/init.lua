local key_set = vim.keymap.set
local api = require("github_link.api")

key_set(
  "x",
  "<leader>gl",
  api.selected_url,
  { desc = "Linewise highlighting in github urls.", silent = false }
)

key_set(
  "x",
  "<leader>go",
  api.open_url,
  { desc = "Opens the url in the default browser.", silent = true }
)
