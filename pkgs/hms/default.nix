{
  writeShellApplication,
  coreutils-full,
  nix-output-monitor,
  ...
}:

writeShellApplication {
  name = "hms";
  runtimeInputs = [
    coreutils-full
    nix-output-monitor
  ];
  text = (builtins.readFile ./hms.sh);
}
