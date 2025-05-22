{
  pkgs,
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
  # This is a dumb hack to pass the value into the import below, but it's how we have to do it,
  # since that's how the module system works
  _module.args.cache = true;
  imports = [
    ./nix-conf.nix
  ];

  programs.ssh = {
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
    bmon
    diffutils
    git
    gnupatch
    gregpy
    findutils
    file
    hms # My own home manager switcher
    btop
    iperf
    killall
    nano
    pciutils
    pwgen
    unzip
    wget
  ];
}
