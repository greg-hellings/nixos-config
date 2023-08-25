#!/usr/bin/env bash
set -ex


curl -s https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | sed '1,33d' > /etc/adblock_hosts

# Custom domains that I need to preserve for some reason
sed -i -e '/segment.com/d' /etc/adblock_hosts  # Blocks Trelly content for house investors
sed -i -e '/segment.io/d' /etc/adblock_hosts  # Blocks Trelly content for house investors

systemctl restart dnsmasq
