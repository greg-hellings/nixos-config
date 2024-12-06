{ pkgs, ... }:

{
  services.mongodb = {
    enable = false;
  };
  environment.systemPackages = with pkgs; [
    mongodb-compass
    pipenv-ivr
    python311
    stdenv.cc
  ];
}
