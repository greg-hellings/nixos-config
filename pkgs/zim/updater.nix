{
  writeShellApplication,
  nix-prefetch,
  go,
  ...
}:
let
  goscript = ./updater.go;
in
writeShellApplication {
  name = "update-zims";
  runtimeInputs = [
    go
    nix-prefetch
  ];
  text = ''
    go run ${goscript}
  '';
}
