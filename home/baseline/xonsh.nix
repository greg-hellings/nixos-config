{ pkgs, config, ... }:

{
  # Programs that are used in the settings file
  home.packages = with pkgs; [
    copier
    git
    gnused
    nix-output-monitor
    nvd
  ];

  programs = {
    carapace = {
      enable = true;
    };

    xonsh = {
      enable = true;

      sessionVariables = {
        # This is for pushing builds to my local S3 cache
        CARAPACE_BRIDGES = "zsh,bash";
        COMPLETIONS_CONFIRM = "True";
        CLICOLOR = 1;
        # vte_new_tab_cwd causes new Terminal tabs to open in the
        # same CWD as the current tab
        LESS_TERMCAP_mb = "\\033[01;31m"; # begin blinking
        LESS_TERMCAP_md = "\\033[01;31m"; # begin bold
        LESS_TERMCAP_me = "\\033[0m"; # end mode
        LESS_TERMCAP_so = "\\033[01;44;36m"; # begin standout-mode (bottom of screen)
        LESS_TERMCAP_se = "\\033[0m"; # end standout-mode
        LESS_TERMCAP_us = "\\033[00;36m"; # begin underline
        LESS_TERMCAP_ue = "\\033[0m"; # end underline
        LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN = "1";
        LSCOLORS = "ExGxBxDxCxEgEdxbxgxcxd";
        OS_CLOUD = "default";
        PROMPT = "{vte_new_tab_cwd}{env_name}{BOLD_GREEN}{user}@{hostname}{BOLD_BLUE} {short_cwd}{branch_color}{curr_branch: {}}{RESET} {BOLD_BLUE}{prompt_end}{RESET} ";
        #TIMEFORMAT = "%3Uu %3Ss %3lR %P%%";
        # Tells vox where to find virtualenvs
        VIRTUALENV_HOME = "${config.home.homeDirectory}/venv/";
        XONSH_COLOR_STYLE = "default";

        GOPATH = "${config.home.homeDirectory}/src/go";
        GOBIN = "${config.home.homeDirectory}/src/bin";
      };

      aliases = {
        # Python related ones
        ac = "vox activate";
        d = "vox deactivate";

        gh-personal = "$GH_CONFIG_DIR=\"${config.home.homeDirectory}/.config/gh/personal\" gh";
        ls = "ls --color";
        ll = "ls -l --color";
      };

      configHeader = builtins.readFile ./xonsh_header.xsh;
      configFooter =
        (builtins.readFile ./xonsh_footer.xsh)
        + (builtins.concatStringsSep "\n" [
          "with open('${pkgs.stdenv.cc}/nix-support/dynamic-linker', 'r') as fp:"
          "    $NIX_LD = fp.read().strip()"
        ]);
    };
  };
}
