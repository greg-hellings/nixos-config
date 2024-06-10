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

	vim-xonsh = pkgs.vimUtils.buildVimPlugin {
		name = "vim-xonsh";
		src = pkgs.fetchFromGitHub {
			owner = "meatballs";
			repo = "vim-xonsh";
			rev = "2028aac";
			sha256 = "sha256-0+dqtlz8LeyOoSiS12rv8aLdzOMj31PuYAyDYWnpNzw=";
		};
	};
in
{
	home.packages = with pkgs; [
		ansible-language-server
		pyright
	];

	programs.nixvim = {
		enable = true;
		colorschemes.gruvbox.enable = true;
		globals = {
			indent_guides_enable_on_vim_startup = 1;
			nix_recommended_style = 0;
			NERDTreeIgnore = [
				"\\.pyc$"
				"\\.pyo$"
				"\\.o$"
				"\\.class$"
			];
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
			action = "<Esc><leader>BufExplorer<CR>";
		} {
			mode = "n";
			key = "<C-t>";
			action = "<Esc><leader>NERDTreeToggle<CR>";
		} {
			mode = "n";
			key = "<C-o>";
			action = "<leader>GFiles?<CR>";
		}
			(winMove "h")
			(winMove "j")
			(winMove "k")
			(winMove "l")
		];
		plugins = {
			airline = {
				enable = true;
				settings.theme = "gruvbox";
			};
			gitgutter.enable = true;
			fugitive.enable = true;
			notify.enable = true;
		};
		extraConfigLua = builtins.replaceStrings [ "@git@" ] [ "${pkgs.git}/bin/git" ] (builtins.readFile ./vim/extra.lua);
		extraConfigVim = builtins.readFile ./vim/extra.vimrc;
		extraPlugins = with pkgs.vimPlugins; [
			bufexplorer
			gruvbox
			nerdtree
			nvim-cmp
			packer-nvim

			context-vim
			direnv-vim
			fzf-vim
			vim-flake8
			vim-indent-guides
			vim-xonsh
		];
		viAlias = true;
		vimAlias = true;
	};
}
