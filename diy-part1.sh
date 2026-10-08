#!/bin/bash
# 1. 拉取 nikkinikki 的 OpenWrt-momo 源码
git clone --depth 1 https://github.com/nikkinikki-org/OpenWrt-momo package/luci-app-momo

# 2. 拉取在线升级插件
git clone --depth 1 -b master https://github.com/Hyy2001X/AutoBuild-Packages.git package/autobuild
