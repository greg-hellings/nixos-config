{ ... }:

{
  imports = [
    ../../../modules/nix-conf.nix
    ./ansible.nix
    ./bash.nix
    ./direnv.nix
    ./git.nix
    ./ssh.nix
    ./vim.nix
    ./xonsh.nix
  ];
}
