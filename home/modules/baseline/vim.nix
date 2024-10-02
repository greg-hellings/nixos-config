{ pkgs, ... }:

let
	vim-xonsh = pkgs.vimUtils.buildVimPlugin {
		name = "vim-xonsh";
		src = pkgs.fetchFromGitHub {
			owner = "meatballs";
			repo = "vim-xonsh";
			rev = "929f35e";
			hash = "sha256-ugHLu2Z9bTtQsIp4FQPKxgjVe9oZNjfQYrP+aHu+/uU=";
		};
	};
in
{
	fonts.fontconfig.enable = true;
	home.packages = [ (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) ];
	programs.nixvim = {
		enable = true;
		colorschemes.gruvbox.enable = true;
		globals = {
			indent_guides_enable_on_vim_startup = 1;
			nix_recommended_style = 0;
		};
		opts = {
			background = "dark";
			backup = false;
			copyindent = true;
			cursorline = true;
			expandtab = false;
			hidden = true;
			hlsearch = true;
			ignorecase = true;
			lazyredraw = true;
			list = true;
			listchars = "tab:→ ,extends:→,precedes:←,trail:·,eol:¬";
			mouse = "a";
			number = true;
			preserveindent = true;
			relativenumber = true;
			shiftwidth = 4;
			showcmd = true;
			showmatch = true;
			signcolumn = "yes";
			smartcase = true;
			softtabstop = 4;
			tabstop = 4;
			# Setting for CtrlP
			wildignore = "*.swp,*.pyc,*.class,.tox";
			wrap = false;
			writebackup = false;
		};
		keymaps = let
			winMove = key: { mode = "n"; key = "<C-${key}>"; action = "<C-w>${key}<C-w><CR>"; };
		in [ {
			mode = "n";
			key = "<C-e>";
			action = "<Esc>:BufExplorer<CR>";
		} {
			mode = "n";
			key = "<C-t>";
			#action = "<Esc>:NERDTreeToggle<CR>";
			action = "<Esc>:Neotree toggle<CR>";
		} {
			mode = "n";
			key = "<C-g>";
			action = "<Esc>:Neotree float git_status toggle<CR>";
		}
			(winMove "h")
			(winMove "j")
			(winMove "k")
			(winMove "l")
		];
		plugins = {
			airline.enable = true;
			cmp = {
				enable = true;
				autoEnableSources = true;
				settings.sources = [
					{ name = "nvim_lsp"; }
					{ name = "buffer"; group_index = 2; }
					{ name = "path"; gruop_index = 3; }
				];
			};
			direnv.enable = true;
			gitgutter.enable = true;
			fugitive.enable = true;
			fzf-lua = {
				enable = true;
				keymaps = {
					"<C-o>" = {
						action = "files";
						settings = {
							previewers.cat.cmd = "${pkgs.coreutils}/bin/cat";
							winopts.height = 0.5;
						};
					};
					"<C-p>" = {
						action = "git_files";
						settings = {
							previewers.cat.cmd = "${pkgs.coreutils}/bin/cat";
							winopts.height = 0.5;
						};
					};
				};
				profile = "fzf-vim";
			};
			lsp = {
				enable = true;
				servers = {
					#ansibels.enable = true;
					cmake.enable = true;
					gopls.enable = true;
					html.enable = true;
					nixd.enable = true;
					#packer.enable = true;
					pylsp.enable = true;
					pyright.enable = true;
					rust-analyzer = {
						# No need to have these installed on every one of my systems
						installCargo = false;
						installRustc = false;
						enable = true;
					};
					terraformls.enable = true;
				};
			};
			neo-tree.enable = true;
			notify.enable = true;
			web-devicons.enable = true;
		};
		extraConfigLua = builtins.replaceStrings [ "@git@" ] [ "${pkgs.git}/bin/git" ] (builtins.readFile ./vim/extra.lua);
		extraConfigVim = builtins.readFile ./vim/extra.vimrc;
		extraPlugins = with pkgs.vimPlugins; [
			bufexplorer

			context-vim
			vim-indent-guides
			vim-xonsh
		];
		viAlias = true;
		vimAlias = true;
	};
}
