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
      package = pkgs.zed-editor-fhs;
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
          context = "Editor && (showing_completions || showing_code_actions)";
          bindings = {
            enter = "editor::Newline";
            escape = "editor::Cancel";
          };
        }
      ];
      userSettings = {
        agent = {
          default_model = {
            provider = "copilot_chat";
            model = "claude-4";
          };
          single_file_review = true;
        };
        baseKeymap = "VSCode";
        buffer_font_size = 16;
        edit_predictions = {
          copilot = {
            proxy = null;
            proxy_no_verify = null;
          };
          enable_in_text_threads = false;
          mode = "subtle";
        };
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
        vim = {
          toggle_relative_line_numbers = true;
        };
        vim_mode = true;
        ui_font_size = 20;
      };
    };
  };
}
