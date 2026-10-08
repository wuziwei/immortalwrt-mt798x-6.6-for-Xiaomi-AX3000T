# 小米 AX3000T ImmortalWrt 固件 (Linux 6.6)

基于 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6)（`openwrt-24.10-6.6` 分支）的 GitHub Actions 自动化编译工程。专为**已刷入第三方大分区 U-Boot（110MB+ 布局）**的小米路由器 AX3000T 定制打造。

支持 **每月自动定时云编译** 与 **路由器后台在线一键无感升级**。

---

## 🌟 固件核心特性

* **源码基底**：基于最新的 `openwrt-24.10-6.6` 分支，采用 **Linux 6.6 LTS** 长期支持内核。
* **下一代防火墙**：原生适配 **Firewall4 (`nftables`)**，转发与路由更高效。
* **硬件转发加速**：集成 MTK Filogic 专属 **WED (Wireless Ethernet Dispatch)** 硬件无线包分发卸载与 **Turbo ACC**（Flow Offloading / BBR / Shortcut-FE），千兆跑满 CPU 占用率极低。
* **科学代理生态**：预装基于 sing-box 的现代极简客户端 **[OpenWrt-momo](https://github.com/nikkinikki-org/OpenWrt-momo)**，支持在 LuCI 界面一键在线下载/切换官方最新 ARM64 核心。
* **动态域名解析**：内置 **DDNS (动态 DNS)**，开箱支持 Cloudflare、阿里云、腾讯云 DNSPod、DuckDNS 等，完整支持 IPv4 / IPv6 双栈动态解析。
* **开箱即用体验**：
  * **开机默认开启 Wi-Fi**：刷机首次开机自动发射无线信号，无需插网线即可通过 Wi-Fi 初始化配置。
  * **避开 IP 冲突**：默认管理地址设为 `192.168.6.1`，彻底规避运营商光猫 (`192.168.1.1`) 及小米原厂 (`192.168.31.1`) 的网段冲突。
  * **网页终端免密**：内置 **TTYD 终端**，局域网网页端点击直接免密登录命令行。
  * **在线升级闭环**：集成 **AutoUpdate 自动更新插件**，可直接在后台检测当前 GitHub 仓库的最新构建并一键升级，无需进入 U-Boot。
* **视觉与实用组件**：预装 **Argon** 现代化自适应主题，集成 `UPnP`、`定时重启`、`htop`、`nano`、`openssh-sftp-server`。

---

## 📋 默认参数与凭据

| 配置项 | 默认值 | 说明 |
| :--- | :--- | :--- |
| **管理后台 IP** | `192.168.6.1` | 首次开机连上 Wi-Fi 或插网线后访问 |
| **后台用户名** | `root` | 首次登录无密码（留空直接点登录） |
| **后台密码** | `无密码` | 建议进入系统后在【系统 -> 管理权】设置密码 |
| **默认 Wi-Fi 状态** | **已开启 (2.4G & 5G)** | 免插网线，搜索无线即可接入 |
| **默认 Wi-Fi 密码** | `无密码` | 请在【网络 -> 无线】中设置安全加密密码 |

---

## 🚀 首次刷机指引（通过 U-Boot）

> ⚠️ **重要提示**：本固件专为**已刷入大分区 U-Boot（如 110MB 分区）**的小米 AX3000T 编译。请勿在原厂未改分区的官方 U-Boot 下刷入。

1. **进入 U-Boot Web 恢复页面**：
   * 路由器拔掉电源线断电。
   * 用卡针顶住机身背部的 **Reset 键**，同时插上电源开机。
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

### 方式 1：后台一键在线升级（极力推荐）
进入路由器后台 **系统 (System) -> 在线更新 (AutoUpdate)**：
1. 点击 **检查更新**，插件会自动比对你 GitHub 仓库的最新 Release。
2. 发现新版本后点击 **一键升级**，路由器会自动在后台下载并刷入，全程自动保留原有配置。

### 方式 2：手动上传固件升级
1. 从本仓库 Releases 下载最新的 `*ax3000t-ubootmod-squashfs-sysupgrade.bin`。
2. 登录后台进入 **系统 -> 备份/升级 -> 刷写新的固件镜像**。
3. 上传文件并确认刷入即可。

---

## ⚡ momo (sing-box) 核心激活指引

固件为了极致的编译速度，未在固件内写死过时的预编译核心，改为刷机后在界面一键下载官方最新版：

1. 确保路由器 WAN 口接入光猫并已连通互联网。
2. 登录后台，进入 **服务 (Services) -> momo -> 核心管理 (Core Settings)**。
3. 界面会自动识别架构为 `linux-arm64`。
4. 在 **GitHub 镜像 / 代理 URL** 输入框中填入加速源（国内网络推荐）：
   * `https://ghfast.top/` 或 `https://ghproxy.net/`
5. 点击 **下载核心 / 检查更新**。
6. 状态变为正常可用后，即可导入订阅/节点并启动透明代理。

---

## ⏰ 自动云编译机制

本仓库配置了 GitHub Actions 自动化工作流：
* **定时自动运行**：每月 1 号北京时间凌晨 04:00 自动拉取上游最新源码构建并发布。
* **手动按需触发**：前往仓库的 **Actions** 标签页，点击 **Build Xiaomi AX3000T ImmortalWrt -> Run workflow** 随时触发全新编译。

---

## 💡 致谢与参考项目

* [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6)
* [nikkinikki-org/OpenWrt-momo](https://github.com/nikkinikki-org/OpenWrt-momo)
* [jerrykuku/luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon)
* [Hyy2001X/AutoBuild-Packages](https://github.com/Hyy2001X/AutoBuild-Packages)
