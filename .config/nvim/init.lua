vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.cursorline = true
vim.opt.culopt = "both"
-- Follow the OS light/dark appearance (catppuccin "auto" maps light->latte, dark->frappe).
-- Detection lives in the alacritty sync script so macOS and Linux share one implementation.
local theme_mode_cmd = { "sh", vim.fn.expand("~/.config/alacritty/sync-theme.sh"), "mode" }
local function to_bg(out) return (out or ""):match("dark") and "dark" or "light" end
vim.opt.background = to_bg(vim.fn.system(theme_mode_cmd))
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    vim.system(theme_mode_cmd, { text = true }, function(res)
      vim.schedule(function()
        local bg = to_bg(res.stdout)
        if vim.o.background ~= bg then vim.o.background = bg end
      end)
    end)
  end,
})
vim.wo.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.clipboard = "unnamedplus"

-- Line wrapping with indentation
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:2"

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank( { timeout = 50 } ) end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

require("config.lazy")
