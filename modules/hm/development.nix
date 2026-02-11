{
  config,
  pkgs,
  lib,
  ...
}:
let
  packages = with pkgs; [
    bruno # but let's not talk about it
    bruno-cli
    cargo
    github-copilot-cli
    gnumake
    nix-eval-jobs
    nix-fast-build
    nix-output-monitor
    nix-update
    nixfmt
    nixpkgs-review
    nodejs
    process-compose
    subversion
  ];
in
with lib;
{
  options.greg.development = mkEnableOption "Setup necessary development packages";

  config = mkIf config.greg.development { home.packages = packages; };
}
