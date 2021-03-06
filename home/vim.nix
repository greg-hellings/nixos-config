{ pkgs, ... }:

let
	vim-stabs = pkgs.vimUtils.buildVimPlugin {
		name = "vim-stabs";
		src = pkgs.fetchFromGitHub {
			owner = "Thyrum";
			repo = "vim-stabs";
			rev = "4654d4e000680e1f608b40f155af08873446ed63";
			sha256 = "0hi1c5zv38hwxbyrf11fz97r728jgbppz4is7fwzwhfrzhwbw0ga";
		};
	};
in
{
	programs.vim = {
		enable = true;
		plugins = with pkgs.vimPlugins; [
			ansible-vim
			bufexplorer
			ctrlp
			direnv-vim
			nerdtree
			vim-gitgutter
			vim-flake8
			vim-fugitive
			vim-indent-guides
			vim-packer
			gruvbox
			syntastic
		];
		settings = {
			background = "dark";
			copyindent = true;
			expandtab = false;
			hidden = true;
			ignorecase = true;
			mouse = "a";
			number = true;
			relativenumber = true;
			shiftwidth = 4;
			smartcase = true;
			tabstop = 4;
		};
		extraConfig = ''
syntax enable
set preserveindent
set softtabstop=0
set nowrap
set showcmd
set cursorline
set lazyredraw
set showmatch
set hlsearch
" Shows non-printing characters
set listchars=tab:→\ ,extends:→,precedes:←,trail:·,eol:¬
set list

" Set filetype to the way I want it
let g:nix_recommended_style = 0

" Highlights bad whitespace
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Settings for CtrlP
set wildignore+=*.swp,*.pyc,*.class,.tox
" Base of search is ordered as
" r - searching up from here to the nearest  marker (.git, .hg, .svn, etc)
" a - dir of current file, unless that's a subdirectory of CWD
" c - dir of current file
let g:ctrlp_working_path_mode = 'arc'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_show_hidden = 1
"let g:ctrlp_user_command = {
"	\'types': {
"		\1: ['.git', '${pkgs.git}/bin/git ls-files --cached --exclude-standard --others' ],
"	\},
"	\'fallback': '${pkgs.findutils}/bin/find . -type f | ${pkgs.gnugrep}/bin/grep -v -e "\.tox/" -e "\.git/"'
"\}
" let g:ctrpl_match_func = { 'match': 'pymatcher#PyMatch' }

" Settings for NerdTree
let NERDTreeIgnore = ['\.pyc$', '\.o$', '\.class$']
" indent guides
let g:indent_guides_enable_on_vim_startup = 1
autocmd! BufWritePost .vimrc source $MYVIMRC
" Tell syntastic to use yamllint
let g:syntastic_yaml_checkers = ['yamllint']
let g:syntastic_yaml_yamllint_args = []
let g:syntastic_shell = "${pkgs.bash}/bin/bash"
" Shortcuts for resolving git diff conflicts
let g:diffget_local_map = 'gl'
let g:diffget_upstream_map = 'gu'

" Key mappings
map <F2> <Esc>\be
map <F4> <Esc>:NERDTreeToggle<Cr>
map <F6> <Esc>:CtrlP<Cr>
" Allows navigating splits
map <C-j> <C-w>j<C-w><Cr>
map <C-k> <C-w>k<C-w><Cr>
map <C-h> <C-w>h<C-w><Cr>
map <C-l> <C-w>l<C-w><Cr>

colorscheme gruvbox

" ============================================================================
" User functions to just make life easier
" ============================================================================
" Toggle absolute line numbers when we don't have focus, and hybrid when
" we do have it
augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
	autocmd BufLeave,FocusLost,InsertEnter	 * set norelativenumber
augroup END
" syntax highlighting for Vagrantfiles
augroup vagrant
	au!
	au BufRead,BufNewFile Vagrantfile set filetype=ruby
augroup END
" Creates the directory for a file if it doesn't already exist.
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

" Return indent (all whitespace at start of a line), converted from
" tabs to spaces if what = 1, or from spaces to tabs otherwise.
" When converting to tabs, result has no redundant spaces.
function! Indenting(indent, what, cols)
	let spccol = repeat(' ', a:cols)
	let result = substitute(a:indent, spccol, '\t', 'g')
	let result = substitute(result, ' \+\ze\t', ''', 'g')
	if a:what == 1
		let result = substitute(result, '\t', spccol, 'g')
	endif
	return result
endfunction

" Convert whitespace used for indenting (before first non-whitespace).
" what = 0 (convert spaces to tabs), or 1 (convert tabs to spaces).
" cols = string with number of columns per tab, or empty to use 'tabstop'.
" The cursor position is restored, but the cursor will be in a different
" column when the number of characters in the indent of the line is changed.
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
'';
	};
}
