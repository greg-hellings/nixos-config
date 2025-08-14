{ config, pkgs, ... }:
{
  home = {
    sessionVariables = {
      AWS_SHARED_CREDENTIALS_FILE = "/run/agenix/cache-credentials";
      CARAPACE_BRIDGES = "zsh,bash";
      EDITOR = "nvim";
      GOPATH = "${config.home.homeDirectory}/src/go";
      GOBIN = "${config.home.homeDirectory}/src/bin";
      LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN = "1";
      MAVEN_OPTS = " -Dmaven.wagon.http.ssl.insecure=true";
      SWORD_PATH = "${config.home.homeDirectory}/.sword/";
      #TIMEFORMAT = "%3Uu %3Ss %3lR %P%%";
      VIRTUALENV_HOME = "${config.home.homeDirectory}/venv/";
    };
    shellAliases = {
      nb = "nix build -L";
      nixdu = "sudo nix-store --gc --print-roots | egrep -v \"^(/nix/var|/run/\\\\w+-system|\\\\{memory|/proc)\"";
      nixtest = "nixpkgs-review rev HEAD";
      nixup = "nix flake lock update";
      nixcopy = "nix copy --to \"s3://binary-cache/?profile=default&endpoint=nas.home%3A9000&scheme=http\"";
      s = "nix run \".#runserver\"";
      updateScript = "nix-shell maintainers/scripts/update.nix --argstr package";

      # General
      k = "kubectl";
      kn = "kubectl get nodes -o wide";
      kp = "kubectl get pods -o wide";
      win = "sudo virsh start win10";
      yaml2js = "python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)'";
      z = "zeditor .";

      # Tailscale related ones
      tsup = "sudo tailscale up";
      tspub = "sudo tailscale up --exit-node=linode";
      tshome = "sudo tailscale up --exit-node=2maccabees";
      tsclear = "sudo tailscale up --exit-node=''";

      # Vagrant related
      vdown = "vagrant destroy";
      vhalt = "vagrant halt";
      vos = "vagrant up --provision --provider openstack";
      vprov = "vagrant provision";
      vup = "vagrant up --provision --provider libvirt";
      vssh = "vagrant ssh";
    };
  };
  programs = {
    carapace = {
      enable = true;
    };
    direnv = {
      enable = true;
    };
    ghostty = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = {
        command = if pkgs.stdenv.hostPlatform.isDarwin then "~/.nix-profile/bin/xonsh" else "nu";
        font-family = "Hacker";
        theme = "Dracula";
        scrollback-limit = "1000000";
        window-save-state = "always";

        keybind = [
          "ctrl+n=new_window"

          "ctrl+shift+h=goto_split:left"
          "ctrl+shift+j=goto_split:down"
          "ctrl+shift+k=goto_split:up"
          "ctrl+shift+l=goto_split:right"

          "ctrl+b>h=new_split:left"
          "ctrl+b>j=new_split:down"
          "ctrl+b>k=new_split:up"
          "ctrl+b>l=new_split:right"

          "ctrl+b>t=new_tab"
          "ctrl+b>n=next_tab"
          "ctrl+b>p=previous_tab"
        ];
      };
    };
    starship = {
      enable = true;
    };
  };
}
