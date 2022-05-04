self: super:
{
	xonsh-direnv = super.callPackage ./xonsh-direnv.nix {
		#lib = self.lib;
		buildPythonPackage = self.python3.pkgs.buildPythonPackage;
		fetchPypi = self.python.pkgs.fetchPypi;
	};

	xonsh = super.xonsh.overridePythonAttrs (old: rec{
		propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.xonsh-direnv ];
	});
}
