{
  bashInteractive,
  dockerTools,
  git,
  lib,
  nix,
  pkgs,
  podman,
  top,
  writeShellApplication,
  ...
}:
let
  policy = (
    pkgs.writeTextFile {
      name = "policy.json";
      text = ''
        {
          "default": [{"type": "insecureAcceptAnything"}]
        }
      '';
      destination = "/etc/containers/policy.json";
    }
  );
  activate = writeShellApplication {
    name = "activate";
    runtimeInputs = [ bashInteractive ];
    text = ''
      mkdir -p /etc/containers
      cp ${policy}/etc/containers/policy.json /etc/containers/policy.json;
      bash "$@"
    '';
  };
in
(import "${nix.src.outPath}/docker.nix" {
  inherit pkgs;
  name = "registry.thehellings.com/greg/nixos-config/img-builder";
  tag = "latest";

  bundleNixpkgs = false;
  Cmd = [
    (lib.getExe activate)
  ];
  extraPkgs = [
    dockerTools.caCertificates
    podman
    policy
  ];
  flake-registry = (pkgs.formats.json { }).generate "flake-registry.json" ({
    version = 2;
    flakes.nixpkgs = {
      exact = true;
      from = {
        id = "nixpkgs";
        type = "indirect";
      };
      to = "${top.nixunstable}";
    };
  });
  gitMinimal = git; # We want the full version in this
  maxLayers = 111;
  nixConf = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
})
