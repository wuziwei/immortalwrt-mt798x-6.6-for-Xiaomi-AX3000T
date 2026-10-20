#!/bin/bash

# 1. 修改默认管理后台 IP 为 192.168.6.1
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# 2. 修改默认主机名为 AX3000T
sed -i 's/ImmortalWrt/AX3000T/g' package/base-files/files/bin/config_generate

# 3. 设置默认主题为 Argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 4. TTYD 网页终端免密直登
sed -i 's/\/bin\/login/\/bin\/login -f root/g' feeds/packages/utils/ttyd/files/ttyd.config

# 5. 编译专属超轻量 sing-box 1.15 核心（纯 Go 系统协议栈，无 gVisor，专为 hy2 + tailscale 定制）
if ! command -v go &>/dev/null || [[ "$(go version 2>&1)" != *"go1.2"* ]]; then
  echo "==> Setting up Go 1.23..."
  curl -fsSL https://dl.google.com/go/go1.23.2.linux-amd64.tar.gz -o /tmp/go1.23.tar.gz
  sudo tar -C /usr/local -xzf /tmp/go1.23.tar.gz
  rm -f /tmp/go1.23.tar.gz
  export PATH=/usr/local/go/bin:$PATH
fi
echo "==> Go environment: $(go version 2>&1 || echo 'Go not found')"

mkdir -p files/usr/bin
echo "==> Cloning sing-box v1.15.0-alpha.12..."
rm -rf /tmp/sing-box-src
git clone --depth 1 -b v1.15.0-alpha.12 https://github.com/SagerNet/sing-box.git /tmp/sing-box-src || \
git clone --depth 1 -b v1.15.0-alpha.12 https://ghfast.top/https://github.com/SagerNet/sing-box.git /tmp/sing-box-src

cd /tmp/sing-box-src
echo "==> Compiling stripped sing-box 1.15 for Linux ARM64..."
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build \
  -tags "with_quic,with_wireguard,with_clash_api" \
  -trimpath \
  -ldflags "-s -w -buildid=" \
  -o /tmp/sing-box-bin \
  ./cmd/sing-box
cd -

mv /tmp/sing-box-bin files/usr/bin/sing-box
chmod +x files/usr/bin/sing-box
rm -rf /tmp/sing-box-src
echo "==> sing-box binary ready in files/usr/bin/sing-box"

# 6. 默认关闭 Argon 主题的必应壁纸拉取（消除首页加载白屏与卡顿）
find package/ feeds/ -name "argon" -type f -path "*/etc/config/*" -exec sed -i "s/option online_wallpaper 'bing'/option online_wallpaper 'none'/g" {} + 2>/dev/null || true

# 7. 提升 uhttpd 默认最大并发数为 20（解决后台并发请求排队卡顿）
find package/ feeds/ -name "uhttpd.config" -exec sed -i "s/max_requests '3'/max_requests '20'/g" {} + 2>/dev/null || true

# 8. 为 momo 服务脚本注入 Go 内存控制上限（40MB 内存上限，杜绝 Swap 颠簸）
if [ -d "package" ]; then
    find package/ feeds/ -name "momo" -type f -path "*/init.d/*" -exec sed -i '/procd_open_instance/i \	export GOMEMLIMIT=40MiB\n\texport GOGC=30' {} + 2>/dev/null || true
fi
