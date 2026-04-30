let
  hosts = (builtins.fromJSON (builtins.readFile ../network.json)).hosts;
  filterAttrs =
    pred: set:
    builtins.removeAttrs set (builtins.filter (name: !pred name set.${name}) (builtins.attrNames set));

  # linode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv9Zud3kZOl86gtmkn+uj3D4kiXWDPtyUL02VVLNR4Q";
  # jude = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOos0zQePsa+T6Z2dsKbPOvEdrBQ8a6mx3s7pN6ysCI0 root@jude";
  # isaiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHleYKtfV4W1Z63Ysu9w5Rbglqlz4F92YcZoMkucoTNf";
  # genesis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEI9jbTPmEWQ0F2bLYmnIOLmBnag1fkKxHRjz3X8lB/k root@genesis";
  # hosea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLIwkTTXA56sUlUjEulXXZRvZy5H4a5ZwgKWLlpkQDz";
  # jeremiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjQjXq9WYU2Ki27BR9WwJ4ZruS/lJXbjC1b0Q42Adi0";
  # matrix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIbvNNYrsT9sSBSwIL9c0LiHDaOiztlTJZAGgTDGUHq root@vm-matrix";
  # exodus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxmnCj2E9DxcnefPW+n4yCuLShxqr0p024riogdeXA3";

  # systems = [
  #   genesis
  #   linode
  #   jude
  #   isaiah
  #   hosea
  #   jeremiah
  #   matrix
  #   exodus
  # ];

  systems = (
    builtins.attrValues (builtins.mapAttrs (_: v: v.pubkey) (filterAttrs (_: v: v ? "pubkey") hosts))
  );

  builders = (
    builtins.attrValues (
      builtins.mapAttrs (_: v: v.pubkey) (filterAttrs (_: v: v ? "builder" && v.builder) hosts)
    )
  );

  user_genesis_virt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWPSFQT0AH77wrwRhiskcBS0w4ZakBRdJywYYBsnm3S greg@genesis";
  user_ivr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYzms+KIe5/bYF3uCyFjA5e1AgMPLIA3c4k417coqBe gregory.hellings@ls23003";
  user_jude = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnRc/kBhxcjpUtiRQY+BXnSObdp0jFL1395wAQxJip7 greg@jude";
  user_linode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAX6pNx5mbwIa8X+GzktyNijfYmJUpgROFpRxSW9js0 greg@linode";
  user_lithic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPVlMoN2pkKRRwKNuMbMczki5ybR34wvjdgDNlgR74Wh greg@gregs-MacBook-Pro-16-inch-Nov-2024";
  user_isaiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl6DJVrPSujvJSAEA5Q8tRrzfJs/c6DMwqwQEUFffIR greg@isaiah";
  user_hosea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrqJQvDspLi1vXQRJ/Z5kN/F8jCBHvaXjo+5zLuIYjR greg@hosea";
  user_jeremiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYIiecdyM9c7tXgR96983K3wqiJeQRMbrzGIF8Wy6uO greg@jeremiah";
  user_exodus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC189EnvWjNUp3xSzPMAtw85oQEsvP1tQR1TK640nLx6 greg@exodus";

  users = [
    user_genesis_virt
    user_ivr
    user_jude
    user_linode
    user_lithic
    user_isaiah
    user_hosea
    user_jeremiah
    user_exodus
  ];

  everyone = systems ++ users;
in
{
  # Demo of how to create it
  "matrix.age".publicKeys = everyone;
  "tailscale.age".publicKeys = everyone;
  # At the point where you want to use it, put
  # age.secrets.matrix.file = ../../secrets/matrix.age;
  # Then you can reference the file at /run/agenix/matrix
  "nextcloudadmin.age".publicKeys = everyone;

  "linode-forgejo-runner.age".publicKeys = everyone;
  "jude-forgejo-runner.age".publicKeys = everyone;
  "minio.age".publicKeys = everyone;

  "attic.age".publicKeys = everyone;
  "cache-private-key.age".publicKeys = builders ++ [
    user_jeremiah
    user_isaiah
    user_jude
    user_exodus
  ];
  "cache-credentials.age".publicKeys = builders ++ [
    user_jeremiah
    user_isaiah
    user_jude
    user_exodus
  ];

  "restic-env.age".publicKeys = everyone;
  "restic-pw.age".publicKeys = everyone;

  "grafana-secret-key.age".publicKeys = everyone;

  "dendrite.age".publicKeys = everyone;
  "dendrite_key.age".publicKeys = everyone;

  "gitea/buildbotWorkersFile.age".publicKeys = everyone;
  "gitea/oauthSecret.age".publicKeys = everyone;
  "gitea/oauthToken.age".publicKeys = everyone;
  "gitea/webhookSecret.age".publicKeys = everyone;
  "gitea/workerPassword.age".publicKeys = everyone;
  "gitea/runner-isaiah-podman.age".publicKeys = everyone;

  "acme_password.age".publicKeys = everyone;
  "ca/intermediate_key.age".publicKeys = everyone;
  "ca/root_key.age".publicKeys = everyone;

  "minio_secret_access_key.age".publicKeys = everyone;
  "minio_access_key_id.age".publicKeys = everyone;

  "kubernetes/bw_secret.age".publicKeys = everyone;
  "kubernetes/kubernetesToken.age".publicKeys = builders ++ [
    user_isaiah
    user_exodus
    user_jeremiah
    user_jude
  ];

  "compose/attic.env.age".publicKeys = everyone;

  "grafana-api-token.age".publicKeys = everyone;

  # Nebula mesh network — one private key per host, encrypted to that host's
  # system key + all user keys so Greg can (re)encrypt them from any machine.
  "nebula/genesis.key.age".publicKeys = everyone;
  "nebula/hosea.key.age".publicKeys = everyone;
  "nebula/isaiah.key.age".publicKeys = everyone;
  "nebula/jeremiah.key.age".publicKeys = everyone;
  "nebula/linode.key.age".publicKeys = everyone;
  "nebula/zeke.key.age".publicKeys = everyone;
  "nebula/exodus.key.age".publicKeys = everyone;

  # Custom files
  "lithic/cargo-config.toml.age".publicKeys = everyone;
}
