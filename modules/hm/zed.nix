{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.greg.zed;
  zedPy = pkgs.python3.withPackages (
    p: with p; [
      python-lsp-server
      python-lsp-ruff
      ruff
    ]
  );
in
{
  options.greg.zed = lib.mkEnableOption "Whether to install the Zed editor";

  config = lib.mkIf cfg {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "ansible"
        "cargo-toml"
        "dockerfile"
        "gitlab-ci-ls"
        "helm"
        "html"
        "ini"
        "jsonnet"
        "justfile"
        "latex"
        "make"
        "markdown-oxide"
        "material-icon-theme"
        "mcp-server-gitlab"
        "mcp-server-grafana"
        "nix"
        "nixd"
        "nu"
        "postgres-context-server"
        "python-refactoring"
        "rust-analyzer"
        "slint"
        "snippets"
        "toml"
      ];
      extraPackages = with pkgs; [
        cargo
        direnv
        nil
        nix
        nixd
        rust-analyzer
        rustc
        slint-lsp
        zedPy
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
            model = "claude-opus-5-5";
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
        lsp = {
          rust-analyzer.binary.path_lookup = true;
          nix.binary.path_lookup = true;
          python.binary.path_lookup = true;
          slint.binary.path_lookup = true;
        };
        node = {
          path = lib.getExe pkgs.nodejs;
          npm_path = lib.getExe' pkgs.nodejs "npm";
        };
        relative_line_numbers = "enabled";
        telemetry = {
          metrics = true;
        };
        terminal = {
          detect_venv = {
            on = {
              directories = [
                "venv"
                ".venv"
              ];
              activate_script = "default";
            };
          };
          env.TERM = "alacritty";
          shell = "system";
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
