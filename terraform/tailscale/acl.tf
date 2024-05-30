resource "tailscale_acl" "default" {
  acl = jsonencode({
    acls : [
      {
			action: "accept",
			src: ["group:jegyrendszer"],
			dst: [
				"10.10.10.0/24:*",
				"100.114.216.4:8006",
				"100.93.205.85:8006",
				"10.10.20.0/24:*",
			],
		},
		{
			action: "accept",
			src: ["autogroup:owner"],
			dst: ["*:*"],
		},
    ],
  })
}