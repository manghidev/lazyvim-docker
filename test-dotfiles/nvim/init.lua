-- Example Neovim configuration for LazyVim Docker
-- This is a test configuration file

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Custom keymaps
vim.keymap.set('n', '<leader>td', ':echo "Test dotfiles loaded!"<CR>', { desc = 'Test dotfiles' })

-- Example plugin configuration (would work with LazyVim)
return {
  -- Example: customize colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
