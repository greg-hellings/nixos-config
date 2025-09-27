{
  writeShellApplication,
  gcc,
  gnugrep,
}:

writeShellApplication {
  name = "gcc-tune";
  runtimeInputs = [
    gcc
    gnugrep
  ];
  text = ''
    gcc -march=native -Q --help=target | grep 'mtune='
  '';
}
