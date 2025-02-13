{ pkgs, ... }:

{
  services.mongodb = {
    enable = false;
  };
  environment.systemPackages = with pkgs; [
    mongodb-compass
    pipenv-ivr
    pre-commit
    python311
    stdenv.cc
  ];
}
