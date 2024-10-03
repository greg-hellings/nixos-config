{ stdenv, jinja2-cli }:

name: vars: template:
(stdenv.mkDerivation {
  inherit name;

  passAsFile = [ "varsData" ];
  varsData = builtins.toJSON vars;

  nativeBuildInputs = [ jinja2-cli ];
  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''${jinja2-cli}/bin/jinja2 --format=json ${template} $varsDataPath > result'';
  installPhase = "cp result $out";
})
