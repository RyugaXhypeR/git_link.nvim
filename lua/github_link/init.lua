local key_set = vim.keymap.set
local api = require("github_link.api")

key_set(
    "x",
    "<leader>gl",
    api.selected_link,
    { desc = "Linewise highlighting in github urls." }
)
