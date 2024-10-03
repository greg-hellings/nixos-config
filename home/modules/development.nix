{ config, pkgs, lib, ... }:
let
  packages = with pkgs; [
    bruno # but let's not talk about it
    cargo
    gh-copilot
    mariadb
    nix-eval-jobs
    nix-fast-build
    nix-output-monitor
    nix-update
    nixfmt-rfc-style
    nixpkgs-review
    nodejs
    process-compose
    zed-editor
  ];
in
with lib; {
  options.greg.development = mkEnableOption "Setup necessary development packages";

  config = mkIf config.greg.development {
    home.packages = packages;
  };
}
