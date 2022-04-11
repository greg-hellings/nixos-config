# Virtual hosts that don't seem to have any better place to live should go in here.
# There are others that are specific to their own purposese scattered about in the
# configuration in places where they more naturally live. This is more of a catchall
# for ones that do not have a better place to live
{ ... }:

{
	services.nginx = {
		enable = true;
		# A proxy front-end for Syncthing
		virtualHosts."dns.thehellings.lan" = {
			locations."/sync/".proxyPass = "http://127.0.0.1:8384/";
			serverAliases = [ "dns" ];
		};
	};
}
