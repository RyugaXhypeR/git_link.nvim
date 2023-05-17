local key_set = vim.keymap.set

key_set(
  'x',
  '<leader>gl',
  '<cmd>lua require("git_link.api").copy_url("v")<cr>',
  { desc = 'Linewise highlighting in github urls.', silent = false }
)

key_set(
  'x',
  '<leader>go',
  '<cmd>lua require("git_link.api").open_url("v")<cr>',
  { desc = 'Opens the url in the default browser.', silent = true }
)

-- -- TODO
-- key_set(
--   'n',
--   '<leader>gl',
--   '<cmd>lua require("git_link.api").copy_url("n")<cr>',
--   { desc = 'Permalink!', }
-- )
