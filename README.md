# git_link.nvim
A neovim plugin to generate permalink from the editor.

## Requirements
[git](https://git-scm.com)
[plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
[xdg-utils](https://www.freedesktop.org/wiki/Software/xdg-utils/)

## Installation
Using [plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'nvim-lua/plenary.vim'
Plug 'RyugaXhypeR/git_link.nvim'
```

Using [packer](https://github.com/wbthomason/packer.nvim):
```lua
use { 'RyugaXhypeR/git_link.nvim', requires = 'nvim-lua/plenary.nvim' }
```

## Quick start
### Default keybinds
- `<leader>gl`:
    Copies the permalink to clipboard.
- `<leader>go`
    Opens the permalink in the default browser.
