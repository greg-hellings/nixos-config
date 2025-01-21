{
  pkgs,
  config,
  lib,
  self,
  ...
}:
let
  builderHosts =
    if self != null then
      (lib.attrNames (
        lib.filterAttrs (_: v: v.config.greg.remote-builder.enable) self.nixosConfigurations
      ))
    else
      [ ];
in
{
  # Enable flakes
  nix = {
    gc = {
      automatic = true;
      # Scheduling of them is different in nixos vs nix-darwin, so check for
      # the extra details there
      options = "--delete-older-than 30d";
    };

    settings = {
      experimental-features = "nix-command flakes";
      keep-outputs = true;
      keep-derivations = true;
      min-free = (toString (1024 * 1024 * 1024));
      max-free = (toString (5 * 1024 * 1024 * 1024));
      trusted-users = [
        "greg"
        "gregory.hellings"
      ]; # For home and for work machines
      substituters = [
        "http://nas.home:9000/binary-cache/"
        "https://cache.garnix.io"
        "https://ai.cachix.org"
        "https://nixpkgs-python.cachix.org"
        "https://greg-hellings.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix.home:0qWYHn3gGllXChhAaaxKlNZtRy6yG/XJs1RFSqV3nW8="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
        "greg-hellings.cachix.org-1:y01Jl/L5evlhxdnUW6n56AiI1k8g1wxWhTxJCe7XSco="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    buildMachines = (
      lib.map (host: {
        hostName = "${host}-builder";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 12;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }) (lib.filter (x: x != config.networking.hostName) builderHosts)
    );
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };

  programs.ssh = {
    knownHosts = {
      chronicles = {
        extraHostNames = [
          "chronicles.thehellings.lan"
          "chronicles.home"
          "nas"
          "nas.thehellings.lan"
          "nas.home"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBecZUva9OnZuXLaBun6/1ITo5f9p0YMLPD+q0egLRS";
      };
      dns = {
        extraHostNames = [
          "dns"
          "dns.me.ts"
          "dns.home"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRCXdhXWHEvw84V9JC5bAGovvj12DLVphcEnsTHDjxW";
      };
      "genesis" = {
        extraHostNames = [
          "genesis.shire-zebra.ts.net"
          "genesis.home"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEI9jbTPmEWQ0F2bLYmnIOLmBnag1fkKxHRjz3X8lB/k";
      };
      "git" = {
        extraHostNames = [
          "git.home"
          "git.thehellings.lan"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKCH6L3YT7W8regzG395UWfRVfjYyUMJtmM+3w579bsT";
      };
      hosea = {
        extraHostNames = [
          "hosea.home"
          "hosea.thehellings.lan"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLIwkTTXA56sUlUjEulXXZRvZy5H4a5ZwgKWLlpkQDz";
      };
      isaiah = {
        extraHostNames = [
          "isaiah.home"
          "isaiah.thehellings.lan"
          "isaiah-builder"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHleYKtfV4W1Z63Ysu9w5Rbglqlz4F92YcZoMkucoTNf";
      };
      jeremiah = {
        extraHostNames = [
          "jeremiah.home"
          "jeremiah.thehellings.lan"
          "jeremiah-builder"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjQjXq9WYU2Ki27BR9WwJ4ZruS/lJXbjC1b0Q42Adi0";
      };
      jude = {
        extraHostNames = [
          "jude.home"
          "jude.thehellings.lan"
          "jude-builder"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOos0zQePsa+T6Z2dsKbPOvEdrBQ8a6mx3s7pN6ysCI0";
      };
      linode = {
        extraHostNames = [
          "linode.home"
          "linode.thehellings.lan"
          "thehellings.com"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv9Zud3kZOl86gtmkn+uj3D4kiXWDPtyUL02VVLNR4Q";
      };
    };
    extraConfig = builtins.concatStringsSep "\n" (
      lib.map (x: ''
        Host ${x}-builder
          Hostname ${x}.home
          User remote-builder-user
      '') builderHosts
    );
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "jitsi-meet-1.0.8043" ];
  };

  # Base packages that need to be in all my hosts
  environment.systemPackages = with pkgs; [
    agenix
    bitwarden-cli
    bmon
    cachix
    diffutils
    git
    gnupatch
    gregpy
    findutils
    file
    hms # My own home manager switcher
    htop
    iperf
    killall
    nano
    pciutils
    pwgen
    unzip
    wget
  ];
}
