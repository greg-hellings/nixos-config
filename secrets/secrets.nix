let
	linode = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBFQOgRYNWsmG8SUV6T8oEFw+581hNLCexCmdzFY2YwH9tgKiE3+doxrKqAmBnxsg80zzzRmIqs+4i+PKCK5waqI+/70Qozf/SSJDzepjQRhrIvZBlhXF9N7ZfAlrOySjjvHgvkaQmS96eOxGy5jNpGR8uSMDu32bwY9urnJ3lskPajaHeu6/abrcFc9rEMkVgC55Itr6kbR9Lv6oRWc+faue6LAEhND1RTflPloUyueWSxuZF7jvOCgEWkuynWHXiy1rr+5PlEp7pVDV+Xz0EXRt/kCDPh6VDdQdJPx98FX6zdz4u2HvIxo9dXao75k4xelFsLPb1t7+meMDkOtYLRiVkPzl6/0F23nFvLRWvnSl6nduO9RwCsVgI4zgUvYWm1aabw9YG0+JcaqU62GFwediFiyU4F7h9ALNnZwhvL3UWvbRJaOxuZl4TJk9tKUIIZsn1nGElw60wbSzknm0AD3fR5NnXEd0zJ3NE8dAS3Yy2TolkrTAeZrVd+7x00roPM4lcXgccWHl8e/SDyDULxMObwVlYOf+CcYisQGdzqJ9GC5Y39X0NeIpgcInpkxW8FYfQUADZ5msHrXNp7FGPrVJe3q7JBdLL4fDjiByHlH/qBziCHjbrhoSWzYZMDSYO1w+Rl0J8A4dSRm16+YwQ+hca3iEwcoKFJcrOeGTGGQ==";
	systems = [ linode ];

	user = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQDLQRq55JKqLifX+31kEXyuoB8gfM+5thAlgR7XLPvvdu6g2a5cCWyozQ1I2oGbPRfJtzcJ5ifM7Ii2PuqAj3MdYFLHBEDOhIpBBWme9Ts2YB9HJ4NorBvB4zEfJd0Q7k2MmylyeBOwdwGz3bVqPRDcJbxWFMDHqr33FEs6SXdfyAQ5SvhWGARI84qz8zUUdOp6M4e3aIGO3cx1gA+YzYQ4FbUtL8+m1NFO8VoNFMZBMf5q0iF/SgEu5bmGWUCePia6DvfeBFQ2/y4Y7WmOj980WE+JmFTkIvmGruMYeGI8FuDQ2JIIIcehddy9bQbPF4VlGnTFsHqJYVRUUWc+vH1cPNMn01oB8s27ogf9e1lyhIN+cZOgp/jDt4eXcO4Wr04uwj7CI6m+d8iMQOa5Jv0hmNgqqiwOMVBlKeo0FCxlovzwvn/Lia9WZ74JqM6JwLCD8SZ0oFgiSIHOTHrQhr7iaCmj7X/0ey7VR8FnCrpeAJpG+ELTfWGshF1d9QR2zW7u4EsXTDLiuOmdJ+/KxwMvjMcWdlg2+Qch6SwulTQRxWaED2IWJo+YiAql8eaiVXu/eZJGLoiskGFZnONoLrzIT4pSjakPlrSpn/M/GkP1pDpaMkr24OhJsGpJNEU3F1ZcOMqy2iJzIxlPmU8Xg0I/OrnbJplpaXeRCqnmouJUJhWkaPzawaVyW7dtvprLWcpQtUgTRet18WLyOrLKlq1jwvNRMTPKUJ2IFJMpk2pNEP6bdiUxyMa4vrRIEU2p1zsYSUJpCRLtccZ/i/+yAqwnTA2L5TdAORi9nD2uCdM/Ljz52V3A14QapS6oqcoWx2soWKgnsbVXoG8DxmUTpll77Ze9t7Y5216SMInWuOu0vstP8ZcgFmWsiBgIYIuLA58abWHMxgD251phYidua6R3Gtkf8J/kYqTR1P6eJF1bt5efEg7FD2aL1QQZsYJo3CRNz7yVe1XqMdPbfe2mFXQVF9TDX5x6r9Ir3d0KiEmTlBdByz8nSyPJ8IQxC58NT4LNVQs3p2XH2Zcf6B4JOBSmV4NNBnLseFobsxniWjkWwZigED/D2iu3OXuuhmskCbw0hKy2rBcKffaSNMioVqYIiYNfKlMlSvAacQKqc/1HCpqgX8PwAcSgNSLy4K7/gIrTHmjY+g+CH7onzatWzkLo+0vsZRa/D/qwhhK2CU2FeU07mhnWxWuzqpJuqVaAwDTaEforK7nQUtAOFAZZP6qGhIoqsynYt4THb+QORb3QYfaP0PVgQwXfVU5Q8eUQFZ8A+siPtOASFjDumsIbseB5VzkF+UhvdseJwkX2+4pVFu8eHFDyvArYsHeGK6fBcQGJFQc2jSs6doIP9HD9IO2R ghelling@unknown38BAF87CD102";
in
{
	# Demo of how to create it
	#"matrix.age".publicKeys = [ linode user ];
	# At the point where you want to use it, put
	# age.secrets.matrix.file = ../../secrets/matrix.age;
	# Then you can reference the file at /run/agenix/matrix
}
