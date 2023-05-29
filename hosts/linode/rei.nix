{ ... }:
{
	services = {
		odoo = {
			enable = true;
			domain = "doublel.thehellings.com";
			settings.options = {
				db_host = "localhost";
				db_port = "5432";
				db_user = "odoo";
				dbfilter = "^doublel.*$";
			};
		};
	};
}
