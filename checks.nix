{ hooks, system, ... }:

{
	pre-commit-check = hooks.lib.${system}.run {
		src = ./.;
		hooks = {
		};
	};
}
