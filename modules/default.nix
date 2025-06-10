let
  nixos = (import ./nixos);
  hm = (import ./hm);
in
{
  homeManagerModule = hm;
  nixosModule = nixos;
}
