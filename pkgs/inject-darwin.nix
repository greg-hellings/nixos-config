{
  writeShellApplication,
  coreutils,
  curl,
  gnutar,
  nix,
  nix-output-monitor,
  ...
}:
writeShellApplication {
  name = "inject-darwin";
  runtimeInputs = [
    coreutils
    curl
    gnutar
    nix
    nix-output-monitor
  ];
  text = ''
    # Get my configuration
    cd /etc/nix-darwin

    # Build NixOS for this system
    nom build --extra-experimental-features "nix-command flakes" ".#darwinConfigurations.$(hostname -s).system"
    sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
    sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
    sudo ./result/sw/bin/darwin-rebuild switch --flake .
  '';
}
