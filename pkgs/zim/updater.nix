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
    go run ${goscript} -- pkgs/zim/blobs.json
  '';
}
