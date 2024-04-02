let
	linode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv9Zud3kZOl86gtmkn+uj3D4kiXWDPtyUL02VVLNR4Q";
	jude = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOos0zQePsa+T6Z2dsKbPOvEdrBQ8a6mx3s7pN6ysCI0 root@jude";
	myself = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHleYKtfV4W1Z63Ysu9w5Rbglqlz4F92YcZoMkucoTNf";
	genesis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEI9jbTPmEWQ0F2bLYmnIOLmBnag1fkKxHRjz3X8lB/k root@genesis";
	hosea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLIwkTTXA56sUlUjEulXXZRvZy5H4a5ZwgKWLlpkQDz";
	systems = [ genesis linode jude myself hosea ];


	user1 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQDLQRq55JKqLifX+31kEXyuoB8gfM+5thAlgR7XLPvvdu6g2a5cCWyozQ1I2oGbPRfJtzcJ5ifM7Ii2PuqAj3MdYFLHBEDOhIpBBWme9Ts2YB9HJ4NorBvB4zEfJd0Q7k2MmylyeBOwdwGz3bVqPRDcJbxWFMDHqr33FEs6SXdfyAQ5SvhWGARI84qz8zUUdOp6M4e3aIGO3cx1gA+YzYQ4FbUtL8+m1NFO8VoNFMZBMf5q0iF/SgEu5bmGWUCePia6DvfeBFQ2/y4Y7WmOj980WE+JmFTkIvmGruMYeGI8FuDQ2JIIIcehddy9bQbPF4VlGnTFsHqJYVRUUWc+vH1cPNMn01oB8s27ogf9e1lyhIN+cZOgp/jDt4eXcO4Wr04uwj7CI6m+d8iMQOa5Jv0hmNgqqiwOMVBlKeo0FCxlovzwvn/Lia9WZ74JqM6JwLCD8SZ0oFgiSIHOTHrQhr7iaCmj7X/0ey7VR8FnCrpeAJpG+ELTfWGshF1d9QR2zW7u4EsXTDLiuOmdJ+/KxwMvjMcWdlg2+Qch6SwulTQRxWaED2IWJo+YiAql8eaiVXu/eZJGLoiskGFZnONoLrzIT4pSjakPlrSpn/M/GkP1pDpaMkr24OhJsGpJNEU3F1ZcOMqy2iJzIxlPmU8Xg0I/OrnbJplpaXeRCqnmouJUJhWkaPzawaVyW7dtvprLWcpQtUgTRet18WLyOrLKlq1jwvNRMTPKUJ2IFJMpk2pNEP6bdiUxyMa4vrRIEU2p1zsYSUJpCRLtccZ/i/+yAqwnTA2L5TdAORi9nD2uCdM/Ljz52V3A14QapS6oqcoWx2soWKgnsbVXoG8DxmUTpll77Ze9t7Y5216SMInWuOu0vstP8ZcgFmWsiBgIYIuLA58abWHMxgD251phYidua6R3Gtkf8J/kYqTR1P6eJF1bt5efEg7FD2aL1QQZsYJo3CRNz7yVe1XqMdPbfe2mFXQVF9TDX5x6r9Ir3d0KiEmTlBdByz8nSyPJ8IQxC58NT4LNVQs3p2XH2Zcf6B4JOBSmV4NNBnLseFobsxniWjkWwZigED/D2iu3OXuuhmskCbw0hKy2rBcKffaSNMioVqYIiYNfKlMlSvAacQKqc/1HCpqgX8PwAcSgNSLy4K7/gIrTHmjY+g+CH7onzatWzkLo+0vsZRa/D/qwhhK2CU2FeU07mhnWxWuzqpJuqVaAwDTaEforK7nQUtAOFAZZP6qGhIoqsynYt4THb+QORb3QYfaP0PVgQwXfVU5Q8eUQFZ8A+siPtOASFjDumsIbseB5VzkF+UhvdseJwkX2+4pVFu8eHFDyvArYsHeGK6fBcQGJFQc2jSs6doIP9HD9IO2R ghelling@unknown38BAF87CD102";
	user4 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQCoGGV3eD1oF0O62JZfCWNxmViRjRGQsfOhRkQfzQROkwDlFZ7S1+02fudD9t7mPtZE6dQ4yS2+6Q3NIfGW8NBbZAlWwsQ6PnrpuAhWpWc+ng/IDQd9CH/rBCt5bWSLL8AGHa4c+qde7iyoFGK0l9jXVD9wATBFQ274WTmPacVQVHmIAmJS6ISmR6vlq9eaDj1fX8wixao6WvzfwAUvXIs8nhPEfmtyu4T/1Eev9rVIxOw3ODQjk/E0VWV4Koeptsyc+V+j+XMyA91v8f20T4Uwe5LGnJHSQS0WavHnCMWHb1tzkmiKdaNCymoDUcUF2rywMYry7JN0kZo2mp2d7OzE/RP3bz/IsAI33+DwRlDYDNzgeLsLVmOJij61AtqBZque6WDcyCF8HN0ZaY0KJPOtNlN92+GUBRF/Faei0MXZ7wW2BZL5Bc7qnXc9USyhPNsm2vQ7LLhh/NtBGqB88+C+AidTTZ/xiIHKWZJXPkWLPRcK5cfaFqHFqcVMk4U+b0FYB95vYPKmjURlAZ6WrU6dNaNaMH9hJSE6/03is4hb4t8RCRiNaR41pEACDZbATjY0DInFn1LxxpUV66xfpOVg5hKm5ScIks3KxWJ8i3v4/cX7WvbDC/UzWb2UygpsqR7/1n5LV1SNPl+/qxFfdaOyZ8WVvx7DKGxkKfkPBgGwdpSthdv7BY+SC4sT9WXQAPGnvOIk6HwKhHjJYX7AIKK64ACfGZbjBC2gg7Ocl4HkgwpYYlUWLRJdJUhHOCi3VhPZDspYhw/UxPnUhYa8lxq5l7kgkks/tFe1qHOvPe3QRW6brg3EdJNkwtMrlrstW4/nph/KFqSshzNVDlEqTAnhE1cjbBZNmlHt1Un4ixcW1b8b86mE+472pSsIEfO8vxP26brQhxepJFZGOFv2vs3XDrrtn6IMJok4e+AQSCCY0kCcgfG5nMYXUoWpGyTpN/JLG0joJuhPWt58OaOzzKNPq2+rCVAbS7/UmDCqkwxjCywxOZRwluBsEWbZaLEdOwQOfIZQGwSDBM0hfHJJxMSaLN3rCe6VZb+c/5mFXUZ46L5mOGkRlO1TOEAe4jqawAQnuGaHN8mMWSw1gKM+UBXTKa0tBR6Aj/OSfPW0jU+mz/YzzJkzNnlRFiSrLxWvL4eXaBsMZvgKdpA41+E4JG8Vu+9D9KNGRnLASOCxRknV18MubZlEEyKby9A6TaKoPrz7GVQZP+36V9DtAJAza74nHSDNAQG/4w2BLOw9+VrDNdXwjMbgG+SN4f1K+e554OirtSMVB73VXjdwoH/FyX+7+dcUZRQ7V2n37jIVOE6CcuEPjzdnkvKSqBsdTO3Bt66+QtS9BwGHu5c01+Q7jvIl greg@nixos";
	user5 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQDR4vmc5TiymSjMB7E+oYsiTxOg+2xwnLAILYjQKPA7dIvz/A/HW31R1aVVxNEgkHm8qeqmgE1bUysMMl128zvdKmwkMmq2uagx9hboyfCwOYRaQOtpS0dlgSllhM654vL9553t94sTuMIfNUiXBD3EV2Z5JJ1RteCkBTJjzmXQnV9he0xozBYOdGv35UGneQzAr7Pps9iK81mR4yW+vLcW3pAaPmDBbN7C6WFxqcEBWsaJZK0rLCTrQo+6B130XgH6gPgh4GyDaRmtRJl63yANiP/RfkDFTPKOh87slLLZaHJUe94P2CTZw0e9xSzWuzx71nBp9JhkoZkI9XD+AnbHIZ9X3twIADUf+D0fivzOH+Yzne0gNRFa+O4x8xd/xj8QeM+Rr1ATikBf/FRfyx+RzHgHS1ZyOKfIpQbrm44E8Smv7FzS5RcCfAScSn0npOqP0cilYjtDCEoeMVsx4XQy4+iYLOA/EaMICSz2PwQFG/KXe7NK30Cc5flq5qUiz8TX1Mzlxuro4qTktYSXZBs5YyEg3Za/hcqMV52kVn0W8S1DatHOL4TlRKYeKsg1hWNvtm2MRqJvWkqK9vNNL86Ew5D5hgXdCk+AiRzOhQxfprPYMea2Vx1Mkaq3VYHWmJBWc/m4aOKUSajhFu8KG7l8bc4IkgC+qQCYzr6pCUDlCaCEF1iQ3lItSkbJJmRBHKEOb85lsIJ/SZ0bhsMl8bc9z33zY+bwv2NezG/aKVGrny4ZTAI1BKkZN/60L0yzJihyKamEa442jjnvG1jzC2wEtd/0gCGWScfZsQWqDu97spbeq8jrc67U9xqlGTrWyyNsCW2lpu26cQWWRC8ufl5zBNRDFDSYKceBaJ2+sx1GPj3YYdJSlTt5JvxNyBg0BGfGqCTd0w4IXF3KP9IZRWWAKPaOZcil2MRZwYhWEd7p+CtKVAL93uW0sE+0C13+iFMnBUkFBJ2dZH+tWpywCRYcrVNvrBlsHe2XniwBwvQHUFgKaQAB8upFTK1xBWTh2S+CVyNed/fckAUrPDj4sI2NERGcyPC5Oi6r0fUPtcWvKRfA/yXx5A0iNWc6acTqd5wwSO3s8rOCjIwdczZmkmnjAf3UKhmtDnwRd9rbO5Hanom80re9Dk0W+z9E2+70b9iYvZ60pbw+cG4WqEQnr02RS8hKvU0CsYFoDMTzV4snqTKNrl0IeD+Fmjl7oDkcC4YQbZd2902qVL3WHHvW+p0WQ1B/rk8BPVRYVmrUQbqwPFCQlmTe3Zy+LpqbWYemhQJGVSiEiioVNCc7pHO6RyWLCoEQKwKHAoNleKtkG94hT/d0z+1RYpB/nbJ51BPihK5EMlXbw/Hu1SVaaDLOSL6p greg@mm";

	user_genesis_virt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWPSFQT0AH77wrwRhiskcBS0w4ZakBRdJywYYBsnm3S greg@genesis";
	user_ivr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYzms+KIe5/bYF3uCyFjA5e1AgMPLIA3c4k417coqBe gregory.hellings@ls23003";
	user_jude = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnRc/kBhxcjpUtiRQY+BXnSObdp0jFL1395wAQxJip7 greg@jude";
	user_linode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAX6pNx5mbwIa8X+GzktyNijfYmJUpgROFpRxSW9js0 greg@linode";
	user_myself = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl6DJVrPSujvJSAEA5Q8tRrzfJs/c6DMwqwQEUFffIR greg@myself";
	user_hosea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrqJQvDspLi1vXQRJ/Z5kN/F8jCBHvaXjo+5zLuIYjR greg@hosea";

	users = [
		user_genesis_virt
		user_ivr
		user_jude
		user_linode
		user_myself
		user_hosea
	];

	everyone = systems ++ users;
in
{
	# Demo of how to create it
	"matrix.age".publicKeys = everyone;
	# At the point where you want to use it, put
	# age.secrets.matrix.file = ../../secrets/matrix.age;
	# Then you can reference the file at /run/agenix/matrix
	"nextcloudadmin.age".publicKeys = everyone;

	"3proxy.age".publicKeys = everyone;

	"linode-forgejo-runner.age".publicKeys = everyone;
	"jude-forgejo-runner.age".publicKeys = everyone;


	"dendrite.age".publicKeys = everyone;
	"dendrite_key.age".publicKeys = everyone;
	"gitlab/secret.age".publicKeys = everyone;
	"gitlab/otp.age".publicKeys = everyone;
	"gitlab/db.age".publicKeys = everyone;
	"gitlab/jws.age".publicKeys = everyone;
	# openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.crt -days 365 -nodes -subj '/CN=issuer'
	# Then pipe the resulting files to agenix -e <foo>
	"gitlab/key.age".publicKeys = everyone;
	"gitlab/cert.age".publicKeys = everyone;
	"gitlab/myself-qemu-runner-reg.age".publicKeys = everyone;
	"gitlab/myself-vbox-runner-reg.age".publicKeys = everyone;
	"gitlab/myself-podman-runner-reg.age".publicKeys = everyone;
	"gitlab/myself-shell-runner-reg.age".publicKeys = everyone;
	"gitlab/docker-auth.age".publicKeys = everyone;

	"acme_password.age".publicKeys = everyone;
	"ca/intermediate_key.age".publicKeys = everyone;
	"ca/root_key.age".publicKeys = everyone;
}
