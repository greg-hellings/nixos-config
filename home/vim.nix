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
	programs.neovim = {
		enable = true;
		viAlias = true;
		vimAlias = true;
		vimdiffAlias = true;
		plugins = with pkgs.vimPlugins; [
			ansible-vim
			bufexplorer
			coc-cmake
			coc-css
			coc-go
			coc-highlight
			coc-html
			coc-java
			coc-json
			coc-lists
			coc-markdownlint
			coc-nvim
			coc-pyright
			coc-tslint
			coc-vimtex
			coc-yaml
			context-vim
			direnv-vim
			fzf-vim
			nerdtree
			vim-airline
			vim-gitgutter
			vim-flake8
			vim-fugitive
			vim-indent-guides
			vim-packer
			vim-rooter
			vim-xonsh
			gruvbox
		];
		extraConfig = builtins.readFile ./vimrc;
	};
}
