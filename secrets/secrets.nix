let
  linode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv9Zud3kZOl86gtmkn+uj3D4kiXWDPtyUL02VVLNR4Q";
  jude = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOos0zQePsa+T6Z2dsKbPOvEdrBQ8a6mx3s7pN6ysCI0 root@jude";
  isaiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHleYKtfV4W1Z63Ysu9w5Rbglqlz4F92YcZoMkucoTNf";
  genesis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEI9jbTPmEWQ0F2bLYmnIOLmBnag1fkKxHRjz3X8lB/k root@genesis";
  gitlab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7hesFWwlmSbWPJWUiF8fIppy5a83yXw84O0Ytz+Zyq";
  hosea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLIwkTTXA56sUlUjEulXXZRvZy5H4a5ZwgKWLlpkQDz";
  jeremiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjQjXq9WYU2Ki27BR9WwJ4ZruS/lJXbjC1b0Q42Adi0";
  matrix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIbvNNYrsT9sSBSwIL9c0LiHDaOiztlTJZAGgTDGUHq root@vm-matrix";
  exodus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxmnCj2E9DxcnefPW+n4yCuLShxqr0p024riogdeXA3";

  systems = [
    gitlab
    genesis
    linode
    jude
    isaiah
    hosea
    jeremiah
    matrix
    exodus
  ];

  user_gitlab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwX8DZRRbZ+Iwo90dROg/61lisazAAGK/W8aqWfWcJr greg@nixos";
  user_genesis_virt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWPSFQT0AH77wrwRhiskcBS0w4ZakBRdJywYYBsnm3S greg@genesis";
  user_ivr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYzms+KIe5/bYF3uCyFjA5e1AgMPLIA3c4k417coqBe gregory.hellings@ls23003";
  user_jude = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnRc/kBhxcjpUtiRQY+BXnSObdp0jFL1395wAQxJip7 greg@jude";
  user_linode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAX6pNx5mbwIa8X+GzktyNijfYmJUpgROFpRxSW9js0 greg@linode";
  user_isaiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl6DJVrPSujvJSAEA5Q8tRrzfJs/c6DMwqwQEUFffIR greg@isaiah";
  user_hosea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrqJQvDspLi1vXQRJ/Z5kN/F8jCBHvaXjo+5zLuIYjR greg@hosea";
  user_jeremiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYIiecdyM9c7tXgR96983K3wqiJeQRMbrzGIF8Wy6uO greg@jeremiah";
  user_exodus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC189EnvWjNUp3xSzPMAtw85oQEsvP1tQR1TK640nLx6 greg@exodus";

  users = [
    user_gitlab
    user_genesis_virt
    user_ivr
    user_jude
    user_linode
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
  # At the point where you want to use it, put
  # age.secrets.matrix.file = ../../secrets/matrix.age;
  # Then you can reference the file at /run/agenix/matrix
  "nextcloudadmin.age".publicKeys = everyone;

  "3proxy.age".publicKeys = everyone;

  "linode-forgejo-runner.age".publicKeys = everyone;
  "jude-forgejo-runner.age".publicKeys = everyone;
  "minio.age".publicKeys = everyone;

  "cache-private-key.age".publicKeys = [
    jeremiah
    isaiah
    jude
    user_jeremiah
    user_isaiah
    user_jude
    user_exodus
  ];
  "cache-credentials.age".publicKeys = [
    jeremiah
    isaiah
    jude
    user_jeremiah
    user_isaiah
    user_jude
    user_exodus
  ];

  "restic-env.age".publicKeys = everyone;
  "restic-pw.age".publicKeys = everyone;

  "dendrite.age".publicKeys = everyone;
  "dendrite_key.age".publicKeys = everyone;
  "gitlab/secret.age".publicKeys = everyone;
  "gitlab/otp.age".publicKeys = everyone;
  "gitlab/db.age".publicKeys = everyone;
  "gitlab/jws.age".publicKeys = everyone;
  # openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.crt -days 365 -nodes -subj '/CN=issuer'
  # Then pipe the resulting files to agenix -e <foo>
  "gitlab/key.age".publicKeys = everyone;
  "gitlab/cert.age".publicKeys = everyone;
  "gitlab/jeremiah-runner-reg.age".publicKeys = everyone;
  "gitlab/isaiah-qemu-runner-reg.age".publicKeys = everyone;
  "gitlab/isaiah-vbox-runner-reg.age".publicKeys = everyone;
  "gitlab/isaiah-podman-runner-reg.age".publicKeys = everyone;
  "gitlab/isaiah-shell-runner-reg.age".publicKeys = everyone;
  "gitlab/linode-deployer-runner-reg.age".publicKeys = everyone;
  "gitlab/docker-auth.age".publicKeys = everyone;

  "acme_password.age".publicKeys = everyone;
  "ca/intermediate_key.age".publicKeys = everyone;
  "ca/root_key.age".publicKeys = everyone;

  "minio_secret_access_key.age".publicKeys = everyone;
  "minio_access_key_id.age".publicKeys = everyone;

  "kubernetes/kubernetesToken.age".publicKeys = [
    isaiah
    user_isaiah
    user_jude
  ];
}
