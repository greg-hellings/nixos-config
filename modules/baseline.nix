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
  imports = [
    ./nix-conf.nix
  ];

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
