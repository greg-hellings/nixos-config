{ config, lib, ... }:

let
  cfg = config.greg.syncthing;
in
with lib; {
  options.greg.syncthing = {
    enable = mkEnableOption "Setup my personal minimal configuration for Syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      overrideFolders = true;
      overrideDevices = true;
      settings = {
        devices = {
          chronicles.id = "7FI6Y3M-C7YQEDI-IB345L6-RKLXMB6-AEIV57Y-3J2RCXQ-MK6QRNK-EINPXAE";
          genesis.id = "YDTH4SD-GUAC5AA-SSYWYPZ-YMJW5LK-LE7PZKJ-GV2UJFZ-CU7LZAD-GTYWCQK";
          gitlab.id = "VAG5GHP-L7TNY7O-CHR3CKU-GXXVCIL-OT3WHHU-E4VAIZC-JI4BKOM-PYZQOQS";
          linode.id = "IJMMXPR-WNALZBD-FMJH5W5-WV7XGJY-HLJTKGT-5TKHJIH-75LT56D-UUZCYQE";
          matrix.id = "K5IHM3I-TJFFEW5-GAYJMPS-CYSHW5C-XHMC462-MFRMOHJ-EJLKIKC-CZHGJQ2";
        };
        options = {
          urAccepted = -1;
        };
      };
    };
  };
}
