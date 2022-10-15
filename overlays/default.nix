self: super:

let
	cp = super.python3.pkgs.callPackage;

in rec {
	my-py-addons = rec {
		copier =  cp ./copier.nix {
			inherit iteration-utilities
			        jinja2-ansible-filters
			        pydantic
			        pyyaml-include
			;
		};
		datadog-api-client = cp ./datadog-api-client.nix {};
		iteration-utilities = cp ./iteration-utilities.nix {};
		jinja2-ansible-filters = cp ./jinja2-ansible-filters.nix {};
		pydantic = cp ./pydantic.nix {};
		pyyaml-include = cp ./pyyaml-include.nix {};
		xonsh-direnv = cp ./xonsh-direnv.nix {};
	};

	hms = super.callPackage ./hms.nix {
		pkgs = self.pkgs;
	};

	xonsh = super.xonsh.overridePythonAttrs (old: rec{
		propagatedBuildInputs = old.propagatedBuildInputs ++ [ my-py-addons.xonsh-direnv ];
	});

}
