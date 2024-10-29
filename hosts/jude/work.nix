{ pkgs, ... }:

{
  services.mongodb = {
    enable = false;
  };
  environment.systemPackages = with pkgs; [ mongodb-compass ];
}
