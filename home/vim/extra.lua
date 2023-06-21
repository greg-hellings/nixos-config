-- ======================================================================
--
-- automatic commands
--
-- ======================================================================
local api = vim.api
local all = {"n", "v", "i"}

-- Highlights bad whitespace
--api.nvim_create_autocmd("ColorScheme", { command = "highlight ExtraWhitespace ctermbg=red guibg=red" })
--api.nvim_create_autocmd("BufWinEnter", { command = "match ExtraWhitespace /\s\+$/" })
--api.nvim_create_autocmd("InsertEnter", { command = "match ExtraWhitespace /\s\+\%#\@<!$/" })
--api.nvim_create_autocmd("InsertLeave", { command = "match ExtraWhitespace /\s\+$/" })
vim.fn.matchadd('errorMsg', [[\s\+$]])
api.nvim_create_autocmd("BufWinLeave", { command = "call clearmatches()" })
-- Automatically source .vimrc when we write that file
-- This is probably no longer valid since we're writing init.lua, but we'll keep it for the sake
-- of posterity at the moment
api.nvim_create_autocmd("BufWritePost", {
	pattern = ".vimrc",
	command = "source $MYVIMRC"
})
-- Toggles absolute line numbers on/off when a window has focus or not
numbertoggle = api.nvim_create_augroup("numbertoggle", { clear = true })
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
	command = "set relativenumber",
	group = numbertoggle
})
api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, {
	command = "set norelativenumber",
	group = numbertoggle
})
-- Set file highlighting to Ruby for Vagrantfiles
api.nvim_create_autocmd({ "BufRead", "BufNewFile"}, {
	pattern = "Vagrantfile*",
	command = "set filetype=ruby"
})

if api.nvim_command_output("!git rev-parse --is-inside-work-tree") == true then
	vim.keymap.set(all, "<C-p>", ":GFiles --cached --others --exclude-standard<CR>")
	vim.keymap.set(all, "<C-o>", ":GFiles?<CR>")
else
	vim.keymap.set(all, "<C-p>", ":Files<CR>")
end
