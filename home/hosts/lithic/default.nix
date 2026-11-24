{
  config,
  pkgs,
  pkgs',
  lib,
  ...
}:
let
  python = pkgs.python312.withPackages (
    p: with p; [
      ipython
    ]
  );
in
{
  # Disables hitting local cache
  _module.args.cache = lib.mkForce false;

  greg = {
    development = true;
    gui = true;
    nix.cache = false;
    zed = true;
  };

  home = {
    # Nushell does not read the Nix shell profile that sets this for zsh. The
    # nixpkgs claude-code wrapper only trusts this bundle when it is set.
    sessionVariables.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    packages = with pkgs; [
      ansible
      awscli2
      cargo
      clippy
      direnv
      docker
      docker-compose
      docker-buildx
      go
      home-manager
      just
      mcp-grafana
      nil
      nixVersions.stable
      poetry
      pre-commit
      (pulumi.withPackages (
        p: with p; [
          pulumi-aws-native
          pulumi-command
          pulumi-go
          pulumi-nodejs
          pulumi-python
        ]
      ))
      python
      rustc
      rustfmt
      terraform
    ];
  };

  programs = {
    claude-code.enable = true;
    # The lithic-cli plugin (lithic MCP server + skills). `lithic setup claude`
    # writes its files into this directory; settings.json only registers it.
    claude-settings = {
      enabledPlugins = [ "lithic-cli@lithic-cli" ];
      extraKnownMarketplaces = {
        lithic-cli = {
          source = {
            source = "directory";
            path = "${config.home.homeDirectory}/.local/share/lithic-cli/claude-plugin";
          };
        };
      };
    };
    direnv = {
      enable = true;
      enableNushellIntegration = true;
    };
    nushell = {
      enable = true;
    };
    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        directory = {
          home_symbol = "~";
          truncate_to_repo = false;
          truncation_length = 0;
          use_os_path_sep = true;
        };
      };
    };
  };
}
