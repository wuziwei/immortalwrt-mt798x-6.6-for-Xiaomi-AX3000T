#!/bin/sh
# 彻底杜绝 IPv4 组播泛洪打爆 Wi-Fi 空口，同时放行 IPv6 NDP 与单播流量
nft add table bridge filter 2>/dev/null || true
nft add chain bridge filter forward "{ type filter hook forward priority 0; policy accept; }" 2>/dev/null || true
if ! nft list chain bridge filter forward 2>/dev/null | grep -q "ip daddr 224.0.0.0/4"; then
    nft add rule bridge filter forward oifname "{ \"ra0\", \"rax0\" }" ip daddr 224.0.0.0/4 counter drop 2>/dev/null || true
fi
