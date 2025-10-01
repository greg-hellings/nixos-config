-- ======================================================================
--
-- nvim-cmp configuration
--
-- ======================================================================
local cmp = require'cmp'

cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lspconfig' },
		{ name = 'vsnip' },
	},{
		{ name = 'buffer' }
	})
})

cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
		{ name = 'git' }
	},{
		{ name = 'buffer' }
	})
})

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = { { name = 'buffer' } }
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	},{
		{ name = 'cmdline' }
	})
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')
-- Add each LSP that you have configured here
--require('lspconfig')['<LANGUAGE_SERVER_HERE>'].setup {
--	capabilities = capabilities
--}
--lspconfig.pyright.setup { capabilities = capabilities }
--lspconfig.ansiblels.setup { capabilities = capabilities }
--lspconfig.jedi_language_server.setup { capabilities }

-- ======================================================================
--
-- Plugin configurations
--
-- ======================================================================
-- Set filetype to the way I want it
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


-- ============================================================================
-- User functions to just make life easier
-- ============================================================================
