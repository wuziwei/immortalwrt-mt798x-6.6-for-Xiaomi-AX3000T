# 小米 AX3000T ImmortalWrt 固件 (Linux 6.6)

基于 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6)（`openwrt-24.10-6.6` 分支）的 GitHub Actions 自动化编译工程。专为**已刷入第三方大分区 U-Boot（110MB+ 布局）**的小米路由器 AX3000T 定制打造。

配备 **上游代码变动自动侦测编译 (`update-checker`)** 与 **路由器后台在线一键无感升级 (`AutoUpdate`)**。

---

## 🌟 固件核心特性

* **源码基底**：同步自 237 的 `openwrt-24.10-6.6` 分支，采用 **Linux 6.6 LTS** 长期支持内核。
* **下一代防火墙**：全面适配 **Firewall4 (`nftables`)**，包转发性能大幅提升。
* **硬件级网络加速**：集成 MTK Filogic 专属 **WED (Wireless Ethernet Dispatch)** 硬件无线包分发卸载与 **Turbo ACC**（Flow Offloading / BBR / Shortcut-FE），满血千兆跑满且 CPU 占用低至个位数。
* **现代科学分流**：预装基于 sing-box 核心的轻量现代化客户端 **[OpenWrt-momo](https://github.com/nikkinikki-org/OpenWrt-momo)**（不预编臃肿核心，支持在 LuCI 界面一键在线下载/切换官方最新 ARM64 核心）。
* **动态域名解析**：内置 **DDNS (动态 DNS)**，原生集成 Cloudflare、阿里云、腾讯云 DNSPod、DuckDNS 等服务脚本，完整支持 IPv4 / IPv6 双栈解析。
* **开箱即用设计**：
  * **开机默认开启 Wi-Fi**：刷机后无需连网线插电脑，通电即自动发射 2.4G & 5G 无线信号。
  * **规避 IP 冲突**：默认后台 IP 设为 **`192.168.6.1`**，彻底避开光猫 (`192.168.1.1`) 与小米原厂 (`192.168.31.1`) 网段冲突。
  * **免密终端调试**：内置 **TTYD 终端**，局域网在网页后台点击即可免密码直接登入命令行。
* **外观与实用工具**：默认集成 **Argon** 现代化自适应主题，内置 `UPnP`、`定时重启`、`htop`、`nano`、`openssh-sftp-server`。

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

## ⚡ momo (sing-box) 核心激活指引

为保证极速编译，固件未在包内打包过时的预编译核心，改为刷机后在界面一键下载官方最新版：

1. 确保路由器 WAN 口接入光猫并已连通互联网。
2. 登录后台，进入 **服务 (Services) -> momo -> 核心管理 (Core Settings)**。
3. 界面会自动识别架构为 `linux-arm64`。
4. 在 **GitHub 镜像 / 代理 URL** 输入框中填入加速源（国内网络推荐）：
   * `https://ghfast.top/` 或 `https://ghproxy.net/`
5. 点击 **下载核心 / 检查更新**。
6. 状态变为正常可用后，即可导入订阅/节点并启动透明代理。

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
