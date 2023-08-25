#!/usr/bin/env bash
set -ex

curl -s https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | sed '1,33d' > /etc/adblock_hosts

# Custom domains that I need to preserve for some reason
for f in "segment.com" "segment.io" "branch.io" "dev.visualwebsiteoptimizer.com"; do
	sed -i -e "/${f}/d" /etc/adblock_hosts  # Blocks Trelly content for house investors
done

systemctl restart dnsmasq
