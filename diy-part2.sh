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
if ! command -v go &>/dev/null || [[ "$(go version 2>&1)" != *"go1.25"* && "$(go version 2>&1)" != *"go1.26"* && "$(go version 2>&1)" != *"go1.27"* ]]; then
  echo "==> Setting up Go 1.25.5..."
  curl -fsSL https://dl.google.com/go/go1.25.5.linux-amd64.tar.gz -o /tmp/go1.25.tar.gz
  sudo tar -C /usr/local -xzf /tmp/go1.25.tar.gz
  rm -f /tmp/go1.25.tar.gz
  export PATH=/usr/local/go/bin:$PATH
fi
echo "==> Go environment: $(go version 2>&1 || echo 'Go not found')"

mkdir -p files/usr/bin
echo "==> Cloning sing-box v1.15.0-alpha.13..."
rm -rf /tmp/sing-box-src
git clone --depth 1 -b v1.15.0-alpha.13 https://github.com/SagerNet/sing-box.git /tmp/sing-box-src || \
git clone --depth 1 -b v1.15.0-alpha.13 https://ghfast.top/https://github.com/SagerNet/sing-box.git /tmp/sing-box-src

cd /tmp/sing-box-src
echo "==> Compiling stripped sing-box 1.15 for Linux ARM64 with Tailscale..."
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build \
  -tags "with_quic,with_wireguard,with_clash_api,with_tailscale" \
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

# 8. 为 momo 运行时配置健康的 Go 内存上限（90MiB 堆缓冲，彻底消除 60MiB 引起的 GC Thrashing 80% CPU 暴冲）
if [ -d "package" ]; then
    find package/ feeds/ -name "momo" -type f -path "*/etc/config/*" -exec sed -i "s/option env_go_mem_limit '.*'/option env_go_mem_limit '90MiB'/g" {} + 2>/dev/null || true
    # 移除原先硬编码注入的 GOMEMLIMIT=60MiB 和 GOGC=30，杜绝 Go 垃圾回收器死循环抢占 CPU
    find package/ feeds/ -name "momo" -type f -path "*/init.d/*" -exec sed -i '/export GOMEMLIMIT/d' {} + 2>/dev/null || true
    find package/ feeds/ -name "momo" -type f -path "*/init.d/*" -exec sed -i '/export GOGC/d' {} + 2>/dev/null || true
fi

# 9. 修复 30-ext-devices-rps-setting 热插拔脚本死循环重启（防范局域网设备前缀刷新引发 mtk_smp 重启风暴，消除 22% CPU 浪费）
find package/ target/ -name "30-ext-devices-rps-setting" 2>/dev/null | while read -r rps_file; do
    if [ -f "$rps_file" ] && ! grep -q '\[ "$ACTION" = ifup \]' "$rps_file"; then
        sed -i '2i[ "$ACTION" = ifup ] || exit 0' "$rps_file"
        echo "==> Patched $rps_file with ifup action guard"
    fi
done

# 10. 修复 odhcp6c dhcpv6.script 应对局域网异常 RA 泛洪的防抖机制（30s 防抖，消除每 3 秒一次的 CPU 暴冲，挽救 36% CPU）
find package/ feeds/ -name "dhcpv6.script" 2>/dev/null | while read -r dhcp_script; do
    if [ -f "$dhcp_script" ] && ! grep -q 'last_ra_update' "$dhcp_script"; then
        sed -i '/ra-updated)/{n;s/.*/\t\tnow=\$(awk '\''{print int(\$1)}'\'' \/proc\/uptime 2>\/dev\/null)\n\t\tlast_ra=\$(cat \/tmp\/last_ra_update 2>\/dev\/null || echo 0)\n\t\t[ -n \"\$now\" ] \&\& [ -n \"\$last_ra\" ] \&\& [ \$((now - last_ra)) -lt 30 ] \&\& exit 0\n\t\techo \"\$now\" > \/tmp\/last_ra_update\n\t\t[ -n \"\$ADDRESSES\$RA_ADDRESSES\$PREFIXES\$USERPREFIX\" ] \&\& setup_interface \"\$1\"/}' "$dhcp_script"
        echo "==> Patched $dhcp_script with 30s RA debounce"
    fi
done

# 11. 默认禁用系统自带的独立 sing-box 服务自启（确保开机仅由 momo 调度，防止端口与 TUN 网卡冲突）
find package/ feeds/ -name "sing-box" -path "*/files/*" -type f -name "sing-box.init" 2>/dev/null | while read -r s_init; do
    sed -i 's/^START=.*/START=99\nENABLED=0/g' "$s_init" 2>/dev/null || true
    echo "==> Disabled autostart in $s_init"
done
