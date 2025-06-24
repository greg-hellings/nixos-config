{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.greg.zed;
in
{
  options.greg.zed = lib.mkEnableOption "Whether to install the Zed editor";

  config = lib.mkIf cfg {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "ansible"
        "cargo-tom"
        "dockerfile"
        "mcp-server-gitlab"
        "helm"
        "html"
        "ini"
        "jsonnet"
        "latex"
        "make"
        "markdown-oxide"
        "material-icon-theme"
        "nix"
        "nu"
        "postgres-context-server"
        "python-refactoring"
        "slint"
        "snippets"
        "toml"
      ];
      extraPackages = with pkgs; [
        cargo
        direnv
        nil
        nix
        python3
        rustc
      ];
      installRemoteServer = true;
      userKeymaps = [
        {
        }
      ];
      userSettings = {
        baseKeymap = "VSCode";
        buffer_font_size = 16;
        features = {
          copilot = true;
        };
        relative_line_numbers = true;
        telemetry = {
          metrics = true;
        };
        theme = {
          mode = "system";
          light = "Gruvbox Dark";
          dark = "One Dark";
        };
        vim_mode = true;
        ui_font_size = 20;
      };
    };
  };
}
