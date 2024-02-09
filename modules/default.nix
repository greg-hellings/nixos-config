let
	nixos = (import ./nixos);
	darwin = (import ./darwin);
in {
	nixosModule = nixos;
	darwinModule = darwin;
}