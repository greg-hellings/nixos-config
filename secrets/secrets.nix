let
  hosts = (builtins.fromJSON (builtins.readFile ../network.json)).hosts;
  filterAttrs =
    pred: set:
    builtins.removeAttrs set (builtins.filter (name: !pred name set.${name}) (builtins.attrNames set));

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

  "acme.age".publicKeys = everyone;

  # At the point where you want to use it, put
  # age.secrets.matrix.file = ../../secrets/matrix.age;
  # Then you can reference the file at /run/agenix/matrix
  "nextcloudadmin.age".publicKeys = everyone;

  "linode-forgejo-runner.age".publicKeys = everyone;
  "jude-forgejo-runner.age".publicKeys = everyone;
  "minio.age".publicKeys = everyone;

  "attic.age".publicKeys = everyone;
  "cache-private-key.age".publicKeys = everyone;
  "cache-credentials.age".publicKeys = everyone;
  "niks3/access_key_id.age".publicKeys = everyone;
  "niks3/api_token.age".publicKeys = everyone;
  "niks3/secret_access_key.age".publicKeys = everyone;

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

  "wealthfolio-secret-key.age".publicKeys = everyone;
  "wealthfolio-auth-hash.age".publicKeys = everyone;

  # Nebula mesh network — one private key per host, encrypted to that host's
  # system key + all user keys so Greg can (re)encrypt them from any machine.
  "nebula/exodus.key.age".publicKeys = everyone;
  "nebula/genesis.key.age".publicKeys = everyone;
  "nebula/hermes.key.age".publicKeys = everyone;
  "nebula/hosea.key.age".publicKeys = everyone;
  "nebula/isaiah.key.age".publicKeys = everyone;
  "nebula/jeremiah.key.age".publicKeys = everyone;
  "nebula/kuma.key.age".publicKeys = everyone;
  "nebula/linode.key.age".publicKeys = everyone;
  "nebula/money.key.age".publicKeys = everyone;
  "nebula/pinchflat.key.age".publicKeys = users ++ [ hosts.pinchflat.pubkey ];
  "nebula/zeke.key.age".publicKeys = everyone;

  # Custom files
  "lithic/cargo-config.toml.age".publicKeys = everyone;

  "hermes.age".publicKeys = everyone;
}
