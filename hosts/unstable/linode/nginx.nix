{ ... }:
let
  homepage = "127.0.0.1:30080";
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "greg.hellings@gmail.com";
  };

  services.nginx = {
    enable = true;

    clientMaxBodySize = "25000m"; # To help with uploading container images
    # If there are recommended settings, let's use them!
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  # Actually serve the content from here
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers."homepage" = {
      # needs explicit port to match what gitlab-runner sees when pulling
      image = "registry.thehellings.com:443/greg/homepage/gregs-homepage:latest";
      ports = [ "${homepage}:80" ];
    };
  };
  greg.proxies = {
    "thehellings.com" = {
      target = "http://${homepage}/";
      ssl = true;
      genAliases = false;
    };
    "doubles.thehellings.com" = {
      target = "http://localhost:8081";
      ssl = true;
      genAliases = false;
    };
  };
}
