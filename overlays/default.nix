self: super:
{
	datadog-api-client = super.callPackage ./datadog-api-client.nix {
		buildPythonPackage = self.python3.pkgs.buildPythonPackage;
		fetchPypi = self.python.pkgs.fetchPypi;
	};

	hms = super.callPackage ./hms.nix {
		pkgs = self.pkgs;
	};

	xonsh = super.xonsh.overridePythonAttrs (old: rec{
		propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.xonsh-direnv ];
	});

	xonsh-direnv = super.callPackage ./xonsh-direnv.nix {
		buildPythonPackage = self.python3.pkgs.buildPythonPackage;
		fetchPypi = self.python.pkgs.fetchPypi;
	};
}
