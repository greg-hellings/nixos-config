{
	inputs,
	overlays,
	...
}:

{
	"gregory.hellings" = 
	let
		system = "x86_64-linux";
		pkgs = (import inputs.nixunstable { inherit system overlays; });
	in inputs.hmunstable.lib.homeManagerConfiguration {
		inherit pkgs;
		modules = [ ./home.nix ];
		extraSpecialArgs = {
			inherit inputs;
			gui = false;
			gnome = false;
			host = "ivr";
			username = "gregory.hellings";
		};
	};
}
