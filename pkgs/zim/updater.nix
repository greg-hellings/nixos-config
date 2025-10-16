{
  writeShellApplication,
  nix-prefetch,
  gcc,
  go,
  ...
}:
let
  goscript = ./updater.go;
in
writeShellApplication {
  name = "update-zims";
  runtimeInputs = [
    gcc
    go
    nix-prefetch
  ];
  text = ''
    go build -o updater ${goscript}
    ./updater "$@"
  '';
}
