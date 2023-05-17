local key_set = vim.keymap.set

key_set(
  'x',
  '<leader>gl',
  '<cmd>lua require("git_link.api").copy_url("v")<cr>',
  { desc = 'Copy the permalink to clipboard', silent = false }
)

key_set(
  'x',
  '<leader>go',
  '<cmd>lua require("git_link.api").open_url("v")<cr>',
  { desc = 'Opens the permalink in the default browser.', silent = true }
)

-- -- TODO
-- key_set(
--   'n',
--   '<leader>gl',
--   '<cmd>lua require("git_link.api").copy_url("n")<cr>',
--   { desc = 'Permalink!', }
-- )
