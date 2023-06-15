-- Core vim settings
vim.opt.background="dark"
vim.opt.copyindent=true
vim.opt.expandtab=false
vim.opt.hidden=true
vim.opt.ignorecase=true
vim.opt.mouse="a"
vim.opt.number=true
vim.opt.relativenumber=true
vim.opt.shiftwidth=4
vim.opt.smartcase=true
vim.opt.tabstop=4
vim.opt.preserveindent=true
vim.opt.softtabstop=0
vim.opt.wrap=false
vim.opt.showcmd=true
vim.opt.cursorline=true
vim.opt.lazyredraw=true
vim.opt.showmatch=true
vim.opt.hlsearch=true
vim.opt.backup=false
vim.opt.writebackup=false
vim.opt.signcolumn="yes"
vim.opt.listchars="tab:→ ,extends:→,precedes:←,trail:·,eol:¬"
vim.opt.list=true

-- dunno about these?
-- syntax enable -- on by default in neovim
vim.cmd [[colorscheme gruvbox]]

-- ======================================================================
--
-- nvim-cmp configuration
--
-- ======================================================================
--local cmp = require'cmp'

--cmp.setup({
	--snippet = {
		--expand = function(args)
			--vim.fn["vsnip#anonymous"](args.body)
		--end,
	--},
	--window = {
		---- completion = cmp.config.window.bordered(),
		---- documentation = cmp.config.window.bordered(),
	--},
	--mapping = cmp.mapping.preset.insert({
		--['<C-b>'] = cmp.mapping.scroll_docs(-4),
		--['<C-f>'] = cmp.mapping.scroll_docs(4),
		--['<C-space>'] = cmp.mapping.complete(),
		--['<C-e>'] = cmp.mapping.abort(),
		--['<CR>'] = cmp.mapping.confirm({ select = true }),
	--}),
	--sources = cmp.config.sources({
		--{ name = 'nvim_lspconfig' },
		--{ name = 'vsnip' },
	--},{
		--{ name = 'buffer' }
	--})
--})
--
--cmp.setup.filetype('gitcommit', {
	--sources = cmp.config.sources({
		--{ name = 'git' }
	--},{
		--{ name = 'buffer' }
	--})
--})
--
--cmp.setup.cmdline({ '/', '?' }, {
	--mapping = cmp.mapping.preset.cmdline(),
	--sources = { { name = 'buffer' } }
--})
--
--cmp.setup.cmdline(':', {
	--mapping = cmp.mapping.preset.cmdline(),
	--sources = cmp.config.sources({
		--{ name = 'path' }
	--},{
		--{ name = 'cmdline' }
	--})
--})
--
--local capabilities = require('cmp_nvim_lsp').default_capabilities()
--local lspconfig = require('lspconfig')
---- Add each LSP that you have configured here
----require('lspconfig')['<LANGUAGE_SERVER_HERE>'].setup {
----	capabilities = capabilities
----}
----lspconfig.pyright.setup { capabilities = capabilities }
--lspconfig.ansiblels.setup { capabilities = capabilities }
--lspconfig.jedi_language_server.setup { capabilities = capabilities }

-- ======================================================================
--
-- automatic commands
--
-- ======================================================================
local api = vim.api

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

-- ======================================================================
--
-- Plugin configurations
--
-- ======================================================================
-- Set filetype to the way I want it
vim.g.nix_recommended_style=0
-- Settings for CtrlP
vim.opt.wildignore="*.swp,*.pyc,*.class,.tox"
-- Settings for NerdTree
vim.g.NERDTreeIgnore = {'\\.pyc$', '\\.o$', '\\.class$'}
-- indent guides
vim.g.indent_guides_enable_on_vim_startup = 1
-- Tell syntastic to use yamllint
vim.g.syntastic_yaml_checkers = {'yamllint'}
vim.g.syntastic_yaml_yamllint_args = {}
vim.g.syntastic_shell = "${pkgs.bash}/bin/bash"
-- Shortcuts for resolving git diff conflicts
vim.g.diffget_local_map = "gl"
vim.g.diffget_upstream_map = "gu"

-- ======================================================================
--
-- Custom commands and key mappings
--
-- ======================================================================
local all = {"n", "v", "i"}
-- Key mappings
-- map <F2> <Esc>\be
-- imap <F2> <Esc>\be
vim.keymap.set(all, "<F2>", "<Esc>\\be")
-- map <F4> <Esc>:NERDTreeToggle<Cr>
vim.keymap.set(all, "<F4>", "<Esc>:NERDTreeToggle")
-- Which file list to pop up
-- silent !git rev-parse --is-inside-work-tree
-- if v:shell_error == 0
--	map <C-p> :GFiles --cached --others --exclude-standard<CR>
--	map <C-o> :GFiles?
--else
--	map <C-p> :Files<CR>
--endif
if api.nvim_command_output("!git rev-parse --is-inside-work-tree") == true then
	vim.keymap.set(all, "<C-p>", ":GFiles --cached --others --exclude-standard<CR>")
	vim.keymap.set(all, "<C-o>", ":GFiles?")
else
	vim.keymap.set(all, "<C-p>", ":Files")
end
-- map <F6> <Esc>:Files<Cr>
vim.keymap.set(all, "<F6>", "<Esc>:Files<CR>")

-- Allows navigating splits
-- map <C-j> <C-w>j<C-w><Cr>
-- map <C-k> <C-w>k<C-w><Cr>
-- map <C-h> <C-w>h<C-w><Cr>
-- map <C-l> <C-w>l<C-w><Cr>
vim.keymap.set(all, "<C-j>", "<C-w>j<C-w><Cr>")
vim.keymap.set(all, "<C-k>", "<C-w>k<C-w><Cr>")
vim.keymap.set(all, "<C-h>", "<C-w>h<C-w><Cr>")
vim.keymap.set(all, "<C-l>", "<C-w>l<C-w><Cr>")

-- ============================================================================
-- User functions to just make life easier
-- ============================================================================
-- Creates the directory for a file if it doesn't already exist.
bufWritePres = vim.cmd [[
	function! s:MkNonExDir(file, buf)
		if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
			let dir=fnamemodify(a:file, ':h')
			if !isdirectory(dir)
				call mkdir(dir, 'p')
			endif
		endif
	endfunction
	augroup BWCCreateDir
		autocmd!
		autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
	augroup END
]]

-- Return indent (all whitespace at start of a line), converted from
-- tabs to spaces if what = 1, or from spaces to tabs otherwise.
-- When converting to tabs, result has no redundant spaces.
vim.cmd [[
function! Indenting(indent, what, cols)
	let spccol = repeat(' ', a:cols)
	let result = substitute(a:indent, spccol, '\t', 'g')
	let result = substitute(result, ' \+\ze\t', ''', 'g')
	if a:what == 1
		let result = substitute(result, '\t', spccol, 'g')
	endif
	return result
endfunction
]]

--Convert whitespace used for indenting (before first non-whitespace).
--what = 0 (convert spaces to tabs), or 1 (convert tabs to spaces).
--cols = string with number of columns per tab, or empty to use 'tabstop'.
--The cursor position is restored, but the cursor will be in a different
--column when the number of characters in the indent of the line is changed.
vim.cmd [[
function! IndentConvert(line1, line2, what, cols)
	let savepos = getpos('.')
	let cols = empty(a:cols) ? &tabstop : a:cols
	execute a:line1 . ',' . a:line2 . 's/^\s\+/\=Indenting(submatch(0), a:what, cols)/e'
	call histdel('search', -1)
	call setpos('.', savepos)
endfunction
command! -nargs=? -range=% Space2Tab call IndentConvert(<line1>,<line2>,0,<q-args>)
command! -nargs=? -range=% Tab2Space call IndentConvert(<line1>,<line2>,1,<q-args>)
command! -nargs=? -range=% RetabIndent call IndentConvert(<line1>,<line2>,&et,<q-args>)
]]
