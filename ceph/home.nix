{
  fsid = "749bf0ea-acf5-4a5e-b33e-9a057455c06b";
  clusterName = "home";
  initialMonitors = [
    {
      hostname = "myself.thehellings.lan";
      ipAddress = "10.42.1.6";
    }
    {
      hostname = "jeremiah.thehellings.lan";
      ipAddress = "10.42.1.8";
    }
    {
      hostname = "hosea.thehellings.lan";
      ipAddress = "10.42.1.7";
    }
  ];
  mdsNodes = [
    {
      hostname = "jeremiah.thehellings.lan";
      ipAddress = "10.42.1.8";
    }
  ];
  publicNetworks = [ "10.42.0.0/16" ];
  clusterNetworks = [ "10.201.0.0/16" ];
  adminKeyring = ../secrets/home.client.admin.keyring;
}
