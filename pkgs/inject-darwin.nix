{
  writeShellApplication,
  coreutils,
  curl,
  gnutar,
  inetutils,
  nix,
  ...
}:
writeShellApplication {
  name = "inject-darwin";
  runtimeInputs = [
    coreutils
    curl
    gnutar
    inetutils
    nix
  ];
  text = ''
    # Get my configuration
    cd /etc/nix-darwin

    # Build NixOS for this system
    nix --extra-experimental-features "nix-command flakes" build ".#darwinConfigurations.$(hostname -s).system"
    sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
    sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
    sudo ./result/sw/bin/darwin-rebuild switch --flake .
  '';
}
