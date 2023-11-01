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
	in inputs.hm.lib.homeManagerConfiguration {
		inherit pkgs;
		modules = [ ./home.nix ];
		extraSpecialArgs = {
			inherit inputs;
			gui = false;
			gnome = true;
			host = "ivr";
			username = "gregory.hellings";
		};
	};
}
