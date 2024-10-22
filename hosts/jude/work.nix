{ pkgs, ... }:

{
  services.mongodb = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [ mongodb-compass ];
}
