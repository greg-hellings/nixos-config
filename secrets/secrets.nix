let
	linode = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBFQOgRYNWsmG8SUV6T8oEFw+581hNLCexCmdzFY2YwH9tgKiE3+doxrKqAmBnxsg80zzzRmIqs+4i+PKCK5waqI+/70Qozf/SSJDzepjQRhrIvZBlhXF9N7ZfAlrOySjjvHgvkaQmS96eOxGy5jNpGR8uSMDu32bwY9urnJ3lskPajaHeu6/abrcFc9rEMkVgC55Itr6kbR9Lv6oRWc+faue6LAEhND1RTflPloUyueWSxuZF7jvOCgEWkuynWHXiy1rr+5PlEp7pVDV+Xz0EXRt/kCDPh6VDdQdJPx98FX6zdz4u2HvIxo9dXao75k4xelFsLPb1t7+meMDkOtYLRiVkPzl6/0F23nFvLRWvnSl6nduO9RwCsVgI4zgUvYWm1aabw9YG0+JcaqU62GFwediFiyU4F7h9ALNnZwhvL3UWvbRJaOxuZl4TJk9tKUIIZsn1nGElw60wbSzknm0AD3fR5NnXEd0zJ3NE8dAS3Yy2TolkrTAeZrVd+7x00roPM4lcXgccWHl8e/SDyDULxMObwVlYOf+CcYisQGdzqJ9GC5Y39X0NeIpgcInpkxW8FYfQUADZ5msHrXNp7FGPrVJe3q7JBdLL4fDjiByHlH/qBziCHjbrhoSWzYZMDSYO1w+Rl0J8A4dSRm16+YwQ+hca3iEwcoKFJcrOeGTGGQ==";
	jude = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOos0zQePsa+T6Z2dsKbPOvEdrBQ8a6mx3s7pN6ysCI0 root@jude";
	systems = [ linode jude ];


	user1 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQDLQRq55JKqLifX+31kEXyuoB8gfM+5thAlgR7XLPvvdu6g2a5cCWyozQ1I2oGbPRfJtzcJ5ifM7Ii2PuqAj3MdYFLHBEDOhIpBBWme9Ts2YB9HJ4NorBvB4zEfJd0Q7k2MmylyeBOwdwGz3bVqPRDcJbxWFMDHqr33FEs6SXdfyAQ5SvhWGARI84qz8zUUdOp6M4e3aIGO3cx1gA+YzYQ4FbUtL8+m1NFO8VoNFMZBMf5q0iF/SgEu5bmGWUCePia6DvfeBFQ2/y4Y7WmOj980WE+JmFTkIvmGruMYeGI8FuDQ2JIIIcehddy9bQbPF4VlGnTFsHqJYVRUUWc+vH1cPNMn01oB8s27ogf9e1lyhIN+cZOgp/jDt4eXcO4Wr04uwj7CI6m+d8iMQOa5Jv0hmNgqqiwOMVBlKeo0FCxlovzwvn/Lia9WZ74JqM6JwLCD8SZ0oFgiSIHOTHrQhr7iaCmj7X/0ey7VR8FnCrpeAJpG+ELTfWGshF1d9QR2zW7u4EsXTDLiuOmdJ+/KxwMvjMcWdlg2+Qch6SwulTQRxWaED2IWJo+YiAql8eaiVXu/eZJGLoiskGFZnONoLrzIT4pSjakPlrSpn/M/GkP1pDpaMkr24OhJsGpJNEU3F1ZcOMqy2iJzIxlPmU8Xg0I/OrnbJplpaXeRCqnmouJUJhWkaPzawaVyW7dtvprLWcpQtUgTRet18WLyOrLKlq1jwvNRMTPKUJ2IFJMpk2pNEP6bdiUxyMa4vrRIEU2p1zsYSUJpCRLtccZ/i/+yAqwnTA2L5TdAORi9nD2uCdM/Ljz52V3A14QapS6oqcoWx2soWKgnsbVXoG8DxmUTpll77Ze9t7Y5216SMInWuOu0vstP8ZcgFmWsiBgIYIuLA58abWHMxgD251phYidua6R3Gtkf8J/kYqTR1P6eJF1bt5efEg7FD2aL1QQZsYJo3CRNz7yVe1XqMdPbfe2mFXQVF9TDX5x6r9Ir3d0KiEmTlBdByz8nSyPJ8IQxC58NT4LNVQs3p2XH2Zcf6B4JOBSmV4NNBnLseFobsxniWjkWwZigED/D2iu3OXuuhmskCbw0hKy2rBcKffaSNMioVqYIiYNfKlMlSvAacQKqc/1HCpqgX8PwAcSgNSLy4K7/gIrTHmjY+g+CH7onzatWzkLo+0vsZRa/D/qwhhK2CU2FeU07mhnWxWuzqpJuqVaAwDTaEforK7nQUtAOFAZZP6qGhIoqsynYt4THb+QORb3QYfaP0PVgQwXfVU5Q8eUQFZ8A+siPtOASFjDumsIbseB5VzkF+UhvdseJwkX2+4pVFu8eHFDyvArYsHeGK6fBcQGJFQc2jSs6doIP9HD9IO2R ghelling@unknown38BAF87CD102";
	user3 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQDUd5LQVl/spIfJ3mh/MERlCfSIHCh3jXnaNVnyHY2AVD2dFVgFX+Q+1adA64plXqXHEQVb3q2EMzVW14QAMP9VJspnODgpyMHwpxp6ZNUsZIH83RN8kauVHgW2LRDCZ4DLRzbqaeDm92rntapoUB74Vjto00AE3gWyGQp/v6BeAUhqE0J2p6T6xDgsuyJ+Tzm2YEUozFW8w8LSGDgaoTKzjq0WVkAo9rNaxGLr/ez8P3SUHgb2VSUrL1qrHE99KL8rravOjP0aQmGGWu/MOjgvh7icQuqYlBF6MHfxeSd7/FZApVNKzEXD9TKBg5IaCOjHH2GHnxthSC0mcjKmF2EVAXuWYDARqxmtIfV/9YdeECEFxzB6X+t6b3RYxA0/oa5Zt70WH2LILmc3U5EfiRf88x4WcsdmbcsKQ74/julgg7vYlTlndBxvl8Nd1IKd6ZD3nJBMMMKrDOYbME5r6x2VTzm/RQkpp+SHarCMXxjukhguYY3Iz9CTO2hdGaQ/41ftlOhpb3I1Gai9GymTPFDt9n3JCEVyQ1+a97ELVr+Ky1L3hMewE8nqZFIoXUB2RFMu2pD9GggDO2e6bXdN3SIHLL/8amoDK62iYgVEp1XBkzHJ7U6hhIYbkFji0KK8A7Cwg8+gOKdovycJIAWndHjaDcLmWDlBktqHIRQvLMTzE9f935faTcrSTpnrCLK/pR3f7ir7HGpD8lUug8m7DfxhH3am1Fz7uY9iNI1GLctexC7espXq/xEA/+j7JRVVKbpIubXcmJjNlKs6jOx849SpdWvLlnJpqo1PIjxE9ZDa7zlPSLMTKGTuY0ekKvvbuaOhcOBuYg1RfbdN1QIX5ba86U7giFMZb7wGh7Pbsy0PhFgO7ANgNZy81RKp45G8ozHLnXCj/qhstqjcEgUICDkT/CGnNkreu023kqOaix0nELBLwWBVM/5iWmKQZnpiBhHHDNJ3Q6DsCkIUdfOWZNCIRwGDPuV8uMOEHJIemg25Z282QqWUIfWzGOO1f0ylVmhTQooZIfjhyGXxKa6AV+/tAXQtkF5B1Z8rB5A3pYYLDmnY1E007sWpvm2L/HKV7cWUX7bkuS+qBXZyHxEn+cc6YvalJbDi5/bE5kFQudZFgKInwFiMLhX/8BpbgBUv+6MvvCn79o9qnoOnkI36A9bEOdQKpjwPdg9tkVWr0RotXfP62tIAQsxS05J7yxprC5Uitf+Bhp+Hph0tS/hyxTbN1h30vfdABouvQpcqbgUlp6psyTT17efeNbGcs9l4gkg4HOGpmF60alA1+PBZ1l7ba6bglp+CZoeA5qsCTmMxT5yLaWcEck/8WR3NHQqkER5ZyH1204Kci35kNon69y1/ greg@linode";
	user4 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQCoGGV3eD1oF0O62JZfCWNxmViRjRGQsfOhRkQfzQROkwDlFZ7S1+02fudD9t7mPtZE6dQ4yS2+6Q3NIfGW8NBbZAlWwsQ6PnrpuAhWpWc+ng/IDQd9CH/rBCt5bWSLL8AGHa4c+qde7iyoFGK0l9jXVD9wATBFQ274WTmPacVQVHmIAmJS6ISmR6vlq9eaDj1fX8wixao6WvzfwAUvXIs8nhPEfmtyu4T/1Eev9rVIxOw3ODQjk/E0VWV4Koeptsyc+V+j+XMyA91v8f20T4Uwe5LGnJHSQS0WavHnCMWHb1tzkmiKdaNCymoDUcUF2rywMYry7JN0kZo2mp2d7OzE/RP3bz/IsAI33+DwRlDYDNzgeLsLVmOJij61AtqBZque6WDcyCF8HN0ZaY0KJPOtNlN92+GUBRF/Faei0MXZ7wW2BZL5Bc7qnXc9USyhPNsm2vQ7LLhh/NtBGqB88+C+AidTTZ/xiIHKWZJXPkWLPRcK5cfaFqHFqcVMk4U+b0FYB95vYPKmjURlAZ6WrU6dNaNaMH9hJSE6/03is4hb4t8RCRiNaR41pEACDZbATjY0DInFn1LxxpUV66xfpOVg5hKm5ScIks3KxWJ8i3v4/cX7WvbDC/UzWb2UygpsqR7/1n5LV1SNPl+/qxFfdaOyZ8WVvx7DKGxkKfkPBgGwdpSthdv7BY+SC4sT9WXQAPGnvOIk6HwKhHjJYX7AIKK64ACfGZbjBC2gg7Ocl4HkgwpYYlUWLRJdJUhHOCi3VhPZDspYhw/UxPnUhYa8lxq5l7kgkks/tFe1qHOvPe3QRW6brg3EdJNkwtMrlrstW4/nph/KFqSshzNVDlEqTAnhE1cjbBZNmlHt1Un4ixcW1b8b86mE+472pSsIEfO8vxP26brQhxepJFZGOFv2vs3XDrrtn6IMJok4e+AQSCCY0kCcgfG5nMYXUoWpGyTpN/JLG0joJuhPWt58OaOzzKNPq2+rCVAbS7/UmDCqkwxjCywxOZRwluBsEWbZaLEdOwQOfIZQGwSDBM0hfHJJxMSaLN3rCe6VZb+c/5mFXUZ46L5mOGkRlO1TOEAe4jqawAQnuGaHN8mMWSw1gKM+UBXTKa0tBR6Aj/OSfPW0jU+mz/YzzJkzNnlRFiSrLxWvL4eXaBsMZvgKdpA41+E4JG8Vu+9D9KNGRnLASOCxRknV18MubZlEEyKby9A6TaKoPrz7GVQZP+36V9DtAJAza74nHSDNAQG/4w2BLOw9+VrDNdXwjMbgG+SN4f1K+e554OirtSMVB73VXjdwoH/FyX+7+dcUZRQ7V2n37jIVOE6CcuEPjzdnkvKSqBsdTO3Bt66+QtS9BwGHu5c01+Q7jvIl greg@nixos";
	user5 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQDR4vmc5TiymSjMB7E+oYsiTxOg+2xwnLAILYjQKPA7dIvz/A/HW31R1aVVxNEgkHm8qeqmgE1bUysMMl128zvdKmwkMmq2uagx9hboyfCwOYRaQOtpS0dlgSllhM654vL9553t94sTuMIfNUiXBD3EV2Z5JJ1RteCkBTJjzmXQnV9he0xozBYOdGv35UGneQzAr7Pps9iK81mR4yW+vLcW3pAaPmDBbN7C6WFxqcEBWsaJZK0rLCTrQo+6B130XgH6gPgh4GyDaRmtRJl63yANiP/RfkDFTPKOh87slLLZaHJUe94P2CTZw0e9xSzWuzx71nBp9JhkoZkI9XD+AnbHIZ9X3twIADUf+D0fivzOH+Yzne0gNRFa+O4x8xd/xj8QeM+Rr1ATikBf/FRfyx+RzHgHS1ZyOKfIpQbrm44E8Smv7FzS5RcCfAScSn0npOqP0cilYjtDCEoeMVsx4XQy4+iYLOA/EaMICSz2PwQFG/KXe7NK30Cc5flq5qUiz8TX1Mzlxuro4qTktYSXZBs5YyEg3Za/hcqMV52kVn0W8S1DatHOL4TlRKYeKsg1hWNvtm2MRqJvWkqK9vNNL86Ew5D5hgXdCk+AiRzOhQxfprPYMea2Vx1Mkaq3VYHWmJBWc/m4aOKUSajhFu8KG7l8bc4IkgC+qQCYzr6pCUDlCaCEF1iQ3lItSkbJJmRBHKEOb85lsIJ/SZ0bhsMl8bc9z33zY+bwv2NezG/aKVGrny4ZTAI1BKkZN/60L0yzJihyKamEa442jjnvG1jzC2wEtd/0gCGWScfZsQWqDu97spbeq8jrc67U9xqlGTrWyyNsCW2lpu26cQWWRC8ufl5zBNRDFDSYKceBaJ2+sx1GPj3YYdJSlTt5JvxNyBg0BGfGqCTd0w4IXF3KP9IZRWWAKPaOZcil2MRZwYhWEd7p+CtKVAL93uW0sE+0C13+iFMnBUkFBJ2dZH+tWpywCRYcrVNvrBlsHe2XniwBwvQHUFgKaQAB8upFTK1xBWTh2S+CVyNed/fckAUrPDj4sI2NERGcyPC5Oi6r0fUPtcWvKRfA/yXx5A0iNWc6acTqd5wwSO3s8rOCjIwdczZmkmnjAf3UKhmtDnwRd9rbO5Hanom80re9Dk0W+z9E2+70b9iYvZ60pbw+cG4WqEQnr02RS8hKvU0CsYFoDMTzV4snqTKNrl0IeD+Fmjl7oDkcC4YQbZd2902qVL3WHHvW+p0WQ1B/rk8BPVRYVmrUQbqwPFCQlmTe3Zy+LpqbWYemhQJGVSiEiioVNCc7pHO6RyWLCoEQKwKHAoNleKtkG94hT/d0z+1RYpB/nbJ51BPihK5EMlXbw/Hu1SVaaDLOSL6p greg@mm";

	user_genesis_virt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWPSFQT0AH77wrwRhiskcBS0w4ZakBRdJywYYBsnm3S greg@genesis";
	user_jude = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQCgg6FGmtWPjw5iYTlxJLz1WBCE7zhYhXgmfPvFRt6cd+sPdBdD3axkYPwuUxIa1dxwLEHn8BY9ZajFNrbD+Y0C82stxbBGLRhScj9phGP6LPJhNJsqeuU1rXcnUS127GlFayBb92UajpgMBVlQVJVgOikdK0GZWS4LMsTafkldS5leYr4o8pJ94ZQUk04m9Y2AhkLOMWDdLqqbVS7rFDKsfNDm6YUIrc4fCFvMwo2IhKb3VMv/CqPBFWx9YWFnLoNRAUhVTbcpDWBprvgAirf1rI9jXihX78gBLYqaI0shZg3mldIfQPaPudxXAYXZBFxZkcdnlEwOIL3jvR1bQKfRroAsLs4Nz66RDMIEC6cYm6QEIppFzx5pAXmjBHk8RPYPV0Z7gHxlp2yL0C3K6E1XN/A6cvK719VxEI8Sqmzl7Dd9/wikuyZhA/ZJfShpGTFX7M4wWKd9ZB6F01ATqAqACs4BHIIakl01C+lad2WQwxCXZo3dxGTMGoUrWTlTcAIKYHA0uun0k3oU0KRcSojpGMFCedR/HfLXZ/3TxeUHAZzSFKAQqZPE+6AZMoDSqVgWW6gPvRqVbtgG17qf6kPXM7XQRw/mNnjUWYrqSzDU4eEyN0AcfWhAN7defp+ERNlDyIdvYSiTniONuBMR5nz5xhLctKosJ1DaQcyNxYok9kGhG92pShRW11JmU/AmM3K6svD2tMRNRg2sJUNYHVzr/P65vZ43jXFV9hn5VTvhNofiDmAgTiPP+4Xo25FHtzu2CDwd7ve1zZZ8WyunmHx5kevdCQBcscKnpHO5MK1EBG2acThWD3HbfzncLkP6w5ZkLngGieIB1C3UjpzbbcBTeQ2NJnra59ZpouZ/ivqoxr/xqCakKlRmi201PV4DzB3HEYhODnmieykZcpSU77EuQb5H5w4k/YY0I9ZVrwyBuMfEducUPV8ghV6HRuZYUNWhOOr+rSmPSvi24kH8kkuoG7D+6aZbLpezyl6u6RvFuwGC784nr1nLXFSMOQpjND23SuGWn6iAcSCqxJ5eBIh50U2ZylsavBjaMDp94esBEG/YyWKcFO5b3xPr75/cwaeLGttdrnMfyWFG6Iz1yFxiMvTNqLKRlGNduK6OPTet89ymu1Gau+l5kfn9YE22gvwCRWU2GuCyTk/PigFyrAKmKduglUecW+Wgylh2OQ6YLJkE3nnJ2u+ujEJsqNdoQBJRFYm4efPFp0WK6DrAmOT/fAD6TyLitWwH+1XFgDR3IKynHgTVaG5SVhjBrT9NA59b90FDmQJmKiVMItDFTn6Ir2+qMw3mvl/xHoXJ6QRuNEOTWtqh8QeJIU5+tjr0pfW+Dz4/fydmOYX3khVZADR9 greg@jude";
	user_linode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAX6pNx5mbwIa8X+GzktyNijfYmJUpgROFpRxSW9js0 greg@linode";
	user_ivr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYzms+KIe5/bYF3uCyFjA5e1AgMPLIA3c4k417coqBe gregory.hellings@ls23003";

	users = [
		user_genesis_virt
		user_jude
		user_linode
		user_ivr
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

	"drone.age".publicKeys = everyone;

	"3proxy.age".publicKeys = everyone;

	"monica.age".publicKeys = everyone;

	"linode-forgejo-runner.age".publicKeys = everyone;
}
