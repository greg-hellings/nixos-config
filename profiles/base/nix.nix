{ pkgs, ... }:

{
	# Enable flakes
	nix = {
		package = pkgs.nixFlakes;

		# Keep freespace available, at a minimum, and enable Flakes
		extraOptions = ''
experimental-features = nix-command flakes
min-free = ${toString (1024 * 1024 * 1024) }
max-free = ${toString (5 * 1024 * 1024 * 1024) }

# Used by direnv
keep-outputs = true
keep-derivations = true
'';

		# Use hardlinking instead of copying when possible
		autoOptimiseStore = true;
	};
	nixpkgs.config.allowUnfree = true;
}
