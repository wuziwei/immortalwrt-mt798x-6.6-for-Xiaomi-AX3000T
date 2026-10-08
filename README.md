# 小米 AX3000T ImmortalWrt 固件云编译 (Linux 6.6)

基于 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6) 源码的 GitHub Actions 自动化编译工作流。专为**已刷入大分区 U-Boot** 的小米路由器 AX3000T 定制打造。

---

## 固件特性

* **源码基底**：`padavanonly/immortalwrt-mt798x-6.6` (基于 Linux 6.6 LTS 内核)
* **网络与防火墙**：全面适配 **Firewall4 (`nftables`)**
* **硬件加速**：集成 MTK Filogic 原生 **WED (Wireless Ethernet Dispatch)** 硬件流量分发加速与 Turbo ACC (BBR / PPE / Shortcut-FE)
* **无缝初始化**：开机**默认开启 2.4G / 5G Wi-Fi**（免插网线即可初始化无线入网）
* **现代化主题**：默认预置并启用 **Argon** 响应式主题
* **科学代理**：集成现代化轻量 sing-box 客户端 **[OpenWrt-momo](https://github.com/nikkinikki-org/OpenWrt-momo)**（支持在 LuCI 界面一键在线下载/升级官方最新核心）
* **动态域名解析**：内置 **DDNS (动态 DNS)**，支持 Cloudflare、阿里云、DNSPod 等服务商
* **便捷终端**：内置 **TTYD 网页终端**（局域网访问已预设免密直登）
* **实用组件**：`UPnP`、`定时重启`、`htop`、`nano`、`openssh-sftp-server`

---

## 默认参数与凭据

| 项目 | 默认值 | 备注 |
| :--- | :--- | :--- |
| **管理后台 IP** | `192.168.6.1` | 已避开运营商光猫 (`192.168.1.1`) 与小米原厂 (`192.168.31.1`) 冲突 |
| **后台用户名** | `root` | 首次登录无需密码，建议进入系统后第一时间修改 |
| **后台密码** | `无密码` (留空直接登录) | |
| **默认 Wi-Fi 状态** | **已启用** | 开机自启，免插网线直接连 Wi-Fi 进后台 |
| **Wi-Fi 密码** | `无密码` | 请进入后台 `网络` -> `无线` 设置加密密码 |

---

## 刷机指南

> ⚠️ **重要前提**：本固件编译目标为 `ubootmod`，**仅适用于已刷入第三方大分区 U-Boot (如 110MB 分区) 的小米 AX3000T**。请勿在官方原厂小分区 U-Boot 下刷入。

### 通过 U-Boot Web 恢复页面刷入（推荐）

1. 路由器拔掉电源断电。
2. 用卡针长按路由器机身背后的 **Reset 键**，同时插上电源开机。
3. 持续按住 Reset 键约 **5~8 秒**，直到指示灯变为橙灯/蓝灯快闪后松开。
4. 使用网线将电脑连接至路由器的 **LAN 口**。
5. 将电脑有线网卡配置为静态 IP：
   * **IP 地址**：`192.168.31.2`（或 `192.168.1.2`，取决于你刷入的 U-Boot 版本）
   * **子网掩码**：`255.255.255.0`
   * **网关**：`192.168.31.1`（或 `192.168.1.1`）
6. 浏览器打开 `http://192.168.31.1`（打不开则尝试 `http://192.168.1.1`）进入 U-Boot Web 恢复控制台。
7. 选择本仓库 Releases 中发布的固件文件：
   * 文件名特征：**`*ax3000t-ubootmod-squashfs-sysupgrade.bin`**
8. 点击上传刷入，等待进度条走完（约 2~3 分钟），路由器会自动重启。
9. 刷机完成后，将电脑网卡改回**自动获取 IP (DHCP)**，浏览器访问 `http://192.168.6.1` 即可进入管理后台。

---

## momo (sing-box) 核心配置指引

为了保持极速编译（跳过繁重的 Go 语言工具链与核心编译），本固件采用**界面一键在线下载核心**的设计：

1. 确保路由器 WAN 口连通互联网。
2. 登录后台，前往 **服务 (Services)** -> **momo** -> **核心设置 (Core Settings)**。
3. 架构通常自动识别为 `linux-arm64`。
4. 在 **GitHub 镜像 / 代理 URL** 输入框填入一个可用的 GitHub 加速镜像（国内网络环境必备）：
   * `https://ghfast.top/`
   * `https://ghproxy.net/`
5. 点击 **“更新核心 / 下载核心”** 按钮。
6. 下载完成后，核心状态将点亮为正常可用，即可开始导入节点并开启透明代理。

---

## 云编译配置说明

* **`.github/workflows/build-ax3000t.yml`**：GitHub Actions 工作流，包含自动清理 runner 磁盘、依赖安装、多核并发编译及自动发布 Release。
* **`ax3000t.config`**：精简版设备与软件包配置文件（基于 MT7981 ubootmod 架构）。
* **`diy-part1.sh`**：拉取第三方软件源（包含 `OpenWrt-momo`）。
* **`diy-part2.sh`**：系统预设调优（设置 `192.168.6.1`、默认开启无线 Wi-Fi、TTYD 免密等）。

---

## 致谢与上游项目

* [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6)
* [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt)
* [nikkinikki-org/OpenWrt-momo](https://github.com/nikkinikki-org/OpenWrt-momo)
* [jerrykuku/luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon)
