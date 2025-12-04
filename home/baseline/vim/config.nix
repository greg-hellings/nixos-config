{ pkgs, ... }:
{
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
  keymaps =
    let
      winMove = key: dir: {
        mode = "n";
        key = "<C-${key}>";
        #action = "<C-w>${key}<C-w><CR>";
        action = ":ZellijNavigate${dir}<CR>";
      };
    in
    [
      {
        mode = "n";
        key = "<C-e>";
        action = "<Esc>:BufExplorer<CR>";
      }
      {
        mode = "n";
        key = "<C-t>";
        #action = "<Esc>:NERDTreeToggle<CR>";
        action = "<Esc>:Neotree toggle<CR>";
      }
      {
        mode = "n";
        key = "<C-g>";
        action = "<Esc>:Git<CR>";
      }
      (winMove "h" "Left")
      (winMove "j" "Down")
      (winMove "k" "Up")
      (winMove "l" "Right")
    ];
  plugins = {
    airline.enable = true;
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          {
            name = "buffer";
            group_index = 2;
          }
          {
            name = "path";
            gruop_index = 3;
          }
        ];
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-f>" = "cmp.mapping.select_next_item()";
          "<C-b>" = "cmp.mapping.select_prev_item()";
          "<C-c>" = "cmp.mapping.abort()";
        };
      };
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
        cmake.enable = true;
        gopls.enable = true;
        html.enable = true;
        nixd.enable = true;
        nushell.enable = true;
        pylsp.enable = true;
        pyright.enable = true;
        rust_analyzer = {
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
    remote-nvim.enable = true;
    web-devicons.enable = true;
    zellij-nav.enable = true;
  };
  userCommands = {
    Ggr = {
      command = "Ggrep! <q-args> | cw | redraw!";
      nargs = "+";
    };
  };
  extraConfigLua = builtins.replaceStrings [ "@git@" ] [ "${pkgs.git}/bin/git" ] (
    builtins.readFile ./extra.lua
  );
  extraConfigVim = builtins.readFile ./extra.vimrc;
  extraPlugins = with pkgs.vimPlugins; [
    bufexplorer
    context-vim
    vim-indent-guides
  ];
  viAlias = true;
  vimAlias = true;
}
