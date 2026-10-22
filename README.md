# 小米 AX3000T ImmortalWrt 固件 (Linux 6.6)

基于 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6)（`openwrt-24.10-6.6` 分支）的 GitHub Actions 自动化编译工程。专为**已刷入第三方大分区 U-Boot（110MB+ 布局）**的小米路由器 AX3000T 定制打造。

配备 **上游代码变动自动侦测编译 (`update-checker`)** 与 **路由器后台在线一键无感升级 (`AutoUpdate`)**。

---

## 🌟 固件核心特性

* **源码基底**：同步自 237 的 `openwrt-24.10-6.6` 分支，采用 **Linux 6.6 LTS** 长期支持内核。
* **下一代防火墙**：全面适配 **Firewall4 (`nftables`)**，包转发性能大幅提升。
* **硬件级网络加速**：集成 MTK Filogic 专属 **WED (Wireless Ethernet Dispatch)** 硬件无线包分发卸载与 **Turbo ACC**（Flow Offloading / BBR / Shortcut-FE），满血千兆跑满且 CPU 占用低至个位数。
* **现代科学分流与防爆内存调优**：
  * 预装基于 sing-box 核心的轻量现代化客户端 **[OpenWrt-momo](https://github.com/nikkinikki-org/OpenWrt-momo)**，并在编译期编译专属轻量 sing-box 核心。
  * **开箱即用纯核心接管**：默认禁用系统自带独立 `sing-box` 服务的自启，彻底避免双服务启动冲突与端口争抢；默认开启 momo 纯核心模式（`core_only`），零篡改完整直通用户原生订阅。
  * **独家内存防暴冲补丁**：针对 15+ 庞大规则集常驻堆内存超过 60MB 的现状，科学预置 `90MiB` 堆缓冲并移除硬编码 GC 限制，预设日志自动循环清理，彻底根除 Go 垃圾回收器（GC Pacer）死循环抢占 CPU 导致的 80% 异常高负载。
* **4K IPTV 零丢包与空口保护优化**：
  * **极速缓冲 udpxy**：开箱预置 2MB 高速双向缓冲与 128 批处理（`-B 2097152 -R 128 -H 2`），彻底消灭 27+ Mbps 4K 50fps 超高清广播直播的偶发丢包与微卡顿。
  * **Wi-Fi 空口组播风暴隔离**：开机自动关闭无线网卡上的组播路由泛洪与组播转单播，彻底保护 5GHz/2.4GHz 无线射频芯片算力。
* **系统级防重载与 CPU 降温补丁**：
  * **修复 MTK SMP 热插拔死循环**：为 `30-ext-devices-rps-setting` 增加动作判断，根除局域网设备前缀变动时每 3 秒触发一次 `mtk_smp restart` 消耗 22% CPU 的顽疾。
  * **odhcp6c RA 30 秒防抖去重**：防御局域网异常三方设备（如部分运营商组网 AP/拓展器）高频广播 Router Solicitation/Advertisement 导致的脚本反复拉起（挽救 36% CPU）。
* **全链路网络性能调优**：
  * 提升核心网卡队列深度 `txqueuelen` 至 5000，消灭突发视频码流队列溢出丢包。
  * 核心套接字缓冲区扩充至 16MB，MTK 硬件加速下默认采用稳健的原生 `cubic` 拥塞控制。
* **IPv6 开机固化与热插拔自愈**：
  * **重启不丢 IPv6**：在 `rc.local` 与 `hotplug.d/iface` 中内置路由自愈守护，开机或接口重载时若未捕获到默认路由，自动固化恢复至 `fe80::1 dev br-lan`，彻底杜绝重启后丢失 IPv6 导致 sing-box IPv6 节点全断（`connect: network is unreachable`）及 IPv6 DDNS 失败的严重隐患。
* **动态域名解析**：内置 **DDNS (动态 DNS)**，原生集成 Cloudflare、阿里云、腾讯云 DNSPod、DuckDNS 等服务脚本，完整支持 IPv4 / IPv6 双栈解析。
* **开箱即用设计**：
  * **开机默认开启 Wi-Fi**：刷机后无需连网线插电脑，通电即自动发射 2.4G & 5G 无线信号。
  * **规避 IP 冲突**：默认后台 IP 设为 **`192.168.6.1`**，彻底避开光猫 (`192.168.1.1`) 与小米原厂 (`192.168.31.1`) 网段冲突。
  * **免密终端调试**：内置 **TTYD 终端**，局域网在网页后台点击即可免密码直接登入命令行。
* **外观与实用工具**：默认集成 **Argon** 现代化自适应主题，内置 `UPnP`、`定时重启`、`htop`、`nano`、`openssh-sftp-server`。

---

## 📦 内置专属定制 sing-box 1.15 编译内核详解

本固件彻底告别了传统固件“刷机后需手动配置网络再下载核心”的繁琐步骤与死锁风险，**在 GitHub Actions 云端编译阶段直接通过 Go 1.23 交叉编译并内置了专为 MT7981B（ARM64 架构）深度定制的超轻量 sing-box 核心（位于 `/usr/bin/sing-box`）**。

### 1. 编译环境与构建参数
* **内核基底**：`sing-box v1.15.0-alpha.12`
* **编译器环境**：`Go 1.23.2 linux/amd64 -> linux/arm64 交叉编译`
* **纯静态免依赖 (`CGO_ENABLED=0`)**：全静态二进制链接，不依赖系统任何外部 C 动态链接库（libc/musl 兼容性零顾虑），杜绝动态加载符号冲突。
* **极致体积与内存瘦身**：
  * `-trimpath`：完全抹除本地编译机文件绝对路径，增强代码安全性与确定性构建。
  * `-ldflags "-s -w -buildid="`：剔除全部调试符号、符号表与调试元数据，二进制体积缩减 60%+，显著节省 Flash 闪存占用与系统内存中的代码映射空间（RssFile）。

### 2. 编译标签特性（Build Tags）
| 编译标签 (Tags) | 特性与优势说明 |
| :--- | :--- |
| `with_quic` | **原生支持 Hysteria 2 (`hy2`)、QUIC 及 TUIC 协议**。充分挖掘联发科 MT7981B 双核 1.3GHz 的硬件性能，实现极速 UDP 握手、高吞吐拥塞控制与抗运营商弱网丢包。 |
| `with_tailscale` | **深度内置 Tailscale 虚拟组网终端**。在 sing-box 配置中可直接通过 `endpoints` 定义 Tailscale 节点并打通异地多设备互联，无需在系统外层额外安装笨重独立的第三方 Tailscale 客户端。 |
| `with_wireguard` | **轻量级 WireGuard 内核隧道**，提供高安全度、极简低开销的跨网对等加密互通。 |
| `with_clash_api` | **完整支持 Clash 外部控制面板 RESTful API**。可无缝对接 Yacd、MetaCubeXD 等现代化 Web Dashboard 进行图形化节点测速、分流策略组切换与实时流量监控。 |
| *剔除冗余组件* | 主动剔除了用不到的重型用户态协议栈与冷门协议，大幅减轻后台线程轮询开销，保障低 CPU 占用。 |

### 3. 系统级防护与稳定性调优
* **开箱即用内置化**：固件刷入即自带可执行核心，开机无需再走任何代理重复下载，彻底终结了“没有核心无法翻墙，无法翻墙又下载不了核心”的死锁怪圈。
* **双进程防冲突机制**：系统自带的原版 `sing-box.init` 原生服务已在构建阶段强制设为 `ENABLED=0`，开机由 **momo** 单一接管，杜绝双服务争抢 TUN 虚拟网卡与路由表冲突。
* **原生订阅无损直通 (`core_only=1`)**：默认开启纯核心直通模式，零侵入、零篡改用户原生订阅，完整继承高级自定义 DNS（Fake-IP）、分流规则集（SRS）、节点分组策略。
* **防 GC Thrashing 内存暴冲保护**：
  * 将 Go 堆内存软上限设定为健康的 **`90MiB`**，并移除了原版 momo 硬编码的 `GOMEMLIMIT=60MiB` 限制。针对现代 15+ 规则集常驻 68MB+ 堆内存的现状，彻底根除了 Go GC Pacer 频繁触发引发的 80% CPU 暴冲假死。
* **规避 10 秒无响应死循环**：
  * 在 `momo` 保留地址中默认规避 `192.0.0.0/24`，彻底阻断了系统或应用在 IPv6 环境下探测 RFC 7050 `ipv4only.arpa` 造成的 10 秒超时挂起恶性循环。
* **ZRAM zstd 5.4倍压缩保障**：
  * 配合固件自带的 192MB ZRAM（`zstd` 算法，实测 5.46 倍压缩比）与 `vm.page-cluster = 0`，即使加载数十万条规则集，整体系统物理内存依然充裕稳健。

---

## 📋 默认参数与凭据

| 配置项 | 默认值 | 说明 |
| :--- | :--- | :--- |
| **管理后台 IP** | `192.168.6.1` | 电脑/手机连上路由后浏览器访问此地址 |
| **后台用户名** | `root` | 首次登录无密码（留空直接点登录） |
| **后台密码** | `无密码` | 首次进入后建议在【系统 -> 管理权】设置密码 |
| **默认 Wi-Fi 状态** | **已启用 (双频 2.4G & 5G)** | 开机即发射，无需网线即可初始化无线入网 |
| **默认 Wi-Fi 密码** | `无密码` | 进入后台【网络 -> 无线】设置安全密码 |

---

## 🚀 首次刷机指引（通过 U-Boot Web 恢复页面）

> ⚠️ **重要提示**：本固件专为**已刷入第三方大分区 U-Boot（如 110MB 分区）**的小米 AX3000T 编译。请勿在未改分区的官方 U-Boot 下刷入。

1. **进入 U-Boot Web 恢复页面**：
   * 路由器拔掉电源线断电。
   * 用卡针顶住机身背后的 **Reset 键**，同时插上电源开机。
   * 持续按住 Reset 键约 **5~8 秒**，直到路由器指示灯变为**橙灯快闪**（部分版本为蓝灯快闪）后松开。
2. **连接电脑并配置网卡**：
   * 用网线将电脑连接至路由器的 **LAN 口**（不要插 WAN 口）。
   * 将电脑有线网卡配置为静态 IP：
     * **IP 地址**：`192.168.31.2`（若打不开尝试 `192.168.1.2`）
     * **子网掩码**：`255.255.255.0`
     * **默认网关**：`192.168.31.1`（或 `192.168.1.1`）
3. **上传并刷入固件**：
   * 浏览器访问 `http://192.168.31.1`（或 `http://192.168.1.1`）。
   * 点击选择文件，选中本仓库 Releases 页面下载的固件：
     👉 **`*ax3000t-ubootmod-squashfs-sysupgrade.bin`**
   * 点击更新按钮，等待进度条走完（约 2~3 分钟），路由器会自动重启。
4. **进入系统**：
   * 路由器重启完成后，将电脑网卡改回 **自动获取 IP (DHCP)**。
   * 浏览器打开 **`http://192.168.6.1`** 即可进入 ImmortalWrt 管理后台。

---

## 🔄 后续系统升级方法（两种方式）

### 方式 1：后台一键在线升级（极力推荐，最省心）
进入路由器后台 **系统 (System) -> 在线更新 (AutoUpdate)**：
1. 点击 **检查更新**，插件会自动比对你 GitHub 仓库的最新 Release。
2. 发现新版本后点击 **一键升级**，路由器会自动在后台下载并刷入，全程自动保留原有配置。

### 方式 2：后台手动上传固件升级
1. 从本仓库 Releases 下载最新的 `*ax3000t-ubootmod-squashfs-sysupgrade.bin`。
2. 登录后台进入 **系统 -> 备份/升级 -> 刷写新的固件镜像**。
3. 上传固件并确认刷入即可。

---

## ⚡ momo (sing-box) 使用与订阅导入指引

由于固件已内置编译好的专属定制 sing-box 1.15 核心，**刷机开机后核心已处于永久就绪状态，无需再手动下载或在线拉取核心**！

1. 确保路由器 WAN 口接入光猫并已连通互联网。
2. 登录后台，进入 **服务 (Services) -> momo -> 配置 (Config)**：
   * 固件已默认预置 **纯核心模式 (`core_only`)**，确保零篡改直接透传你的原生订阅配置。
   * 固件已默认启用日志滚动清理与每日凌晨 04:00 自动维护重启（保持长期内存持久轻盈）。
3. 前往 **配置文件 (Profiles)**：
   * 上传你的 sing-box 配置文件（如 `sb-linux.json`）或填入订阅链接拉取。
4. 在 **概览 (Overview)** 页面点击 **启动** 即可开启全局/规则透明分流。
5. 若需查看节点延迟与手动切换策略分组，点击界面上的 **打开面板 (Open Dashboard)** 即可直连轻量 Web 控制台。

---

## ⚙️ 自动化云编译与更新机制

* **智能变动检测 (`update-checker.yml`)**：
  每天定时侦测 `padavanonly/immortalwrt-mt798x-6.6` 上游源码。**仅当上游发布新提交或驱动修复时，才自动唤醒并触发编译**，杜绝无意义的空跑和额度浪费。
* **手动按需触发 (`build-ax3000t.yml`)**：
  随时前往仓库的 **Actions** 标签页，点击 **Build Xiaomi AX3000T ImmortalWrt -> Run workflow** 即可手动开启全新编译。

---

## 💡 致谢与参考项目

* [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6)
* [daboq11/ImmortalWrt-237-ax3000t](https://github.com/daboq11/ImmortalWrt-237-ax3000t)
* [nikkinikki-org/OpenWrt-momo](https://github.com/nikkinikki-org/OpenWrt-momo)
* [jerrykuku/luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon)
* [Hyy2001X/AutoBuild-Packages](https://github.com/Hyy2001X/AutoBuild-Packages)
