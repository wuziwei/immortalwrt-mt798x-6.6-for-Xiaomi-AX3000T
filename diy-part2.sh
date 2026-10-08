#!/bin/bash
# Description: OpenWrt DIY script part 2 (After Update feeds)

# 1. 修改默认管理后台 IP 为 192.168.6.1（避开光猫 192.168.1.1 冲突）
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# 2. 修改默认主机名为 AX3000T
sed -i 's/ImmortalWrt/AX3000T/g' package/base-files/files/bin/config_generate

# 3. 设置默认主题为 Argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 4. 开机默认开启 Wi-Fi（免插网线开箱即用）
sed -i 's/disabled=1/disabled=0/g' package/kernel/mac80211/files/lib/netifd/wireless/mac80211.sh

# 5. TTYD 网页终端免密直登
sed -i 's/\/bin\/login/\/bin\/login -f root/g' feeds/packages/utils/ttyd/files/ttyd.config
