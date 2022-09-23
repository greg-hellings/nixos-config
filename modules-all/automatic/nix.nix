{ pkgs, ... }:

{
	# Enable flakes
	nix = {
		package = pkgs.nixFlakes;

		settings = {
			substituters = [
				"https://cache.garnix.io"
			];
			trusted-public-keys = [
				"cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
			];
		};
		# Keep freespace available, at a minimum, and enable Flakes
		extraOptions = ''
experimental-features = nix-command flakes
min-free = ${toString (1024 * 1024 * 1024) }
max-free = ${toString (5 * 1024 * 1024 * 1024) }

# Used by direnv
keep-outputs = true
keep-derivations = true
'';
	};
	nixpkgs.config.allowUnfree = true;
}
