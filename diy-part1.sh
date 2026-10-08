#!/bin/bash
# Description: OpenWrt DIY script part 1 (Before Update feeds)

# 1. 拉取 nikkinikki 的 OpenWrt-momo 源码
git clone --depth 1 https://github.com/nikkinikki-org/OpenWrt-momo package/luci-app-momo

# 2. 修复 padavanonly 源码中 MTK_WIFI_CHIP_OFFLINE 编译报错
for file in $(find target/linux/mediatek/ -name "mtk_eth_soc.c" 2>/dev/null); do
    sed -i '1i #ifndef MTK_WIFI_CHIP_OFFLINE\n#define MTK_WIFI_CHIP_OFFLINE 0x10\n#endif' "$file"
done
for patch in $(find target/linux/mediatek/ -name "*.patch" 2>/dev/null); do
    sed -i 's/case MTK_WIFI_CHIP_OFFLINE:/default:/g' "$patch" 2>/dev/null || true
done
