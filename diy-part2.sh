#!/bin/bash

# 1. 修改默认管理后台 IP 为 192.168.6.1
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# 2. 修改默认主机名为 AX3000T
sed -i 's/ImmortalWrt/AX3000T/g' package/base-files/files/bin/config_generate

# 3. 设置默认主题为 Argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 4. TTYD 网页终端免密直登
sed -i 's/\/bin\/login/\/bin\/login -f root/g' feeds/packages/utils/ttyd/files/ttyd.config

# 5. 预置 sing-box 1.15 官方核心到固件 /usr/bin/sing-box（节省 overlay 空间并保证 auto_redirect 原生支持）
mkdir -p files/usr/bin
curl -sL https://ghfast.top/https://github.com/SagerNet/sing-box/releases/download/v1.15.0-alpha.12/sing-box-1.15.0-alpha.12-linux-arm64-musl.tar.gz -o /tmp/sb.tar.gz || curl -sL https://github.com/SagerNet/sing-box/releases/download/v1.15.0-alpha.12/sing-box-1.15.0-alpha.12-linux-arm64-musl.tar.gz -o /tmp/sb.tar.gz
tar -xzf /tmp/sb.tar.gz -C /tmp/
mv /tmp/sing-box-*/sing-box files/usr/bin/sing-box
chmod +x files/usr/bin/sing-box
rm -rf /tmp/sb.tar.gz /tmp/sing-box-*
