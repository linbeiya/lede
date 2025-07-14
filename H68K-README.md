# H68K OpenWrt 编译指南

本项目为 Hinlink H68K 设备提供了优化的 OpenWrt/LEDE 编译配置。

## 设备信息

- **设备名称**: Hinlink H68K
- **架构**: ARM64 (aarch64)
- **目标平台**: armsr/armv8
- **内核版本**: 6.6.x

## 主要特性

### 硬件支持
- ✅ ARM64 处理器支持
- ✅ USB 3.0 支持
- ✅ 千兆以太网 (Realtek RTL8169)
- ✅ MT7921 WiFi 驱动
- ✅ SATA 存储支持
- ✅ 多种文件系统支持 (EXT4, CIFS, NTFS3)

### 预装软件
- 🌐 **网络工具**: OpenClash, AdGuard Home, Turbo ACC
- 🐳 **容器化**: Docker CE + LuCI 管理界面
- 🎨 **主题**: Argon 主题, Design 主题
- 📊 **监控**: htop, iotop, 系统监控工具
- 🔧 **实用工具**: SSH, 文件传输, 自动重启

## 使用方法

### 方法一：GitHub Actions 在线编译（推荐）

1. Fork 本仓库到你的 GitHub 账户
2. 在仓库的 Settings > Secrets and variables > Actions 中添加：
   - `ACCESS_TOKEN`: 你的 GitHub Personal Access Token
3. 进入 Actions 页面，手动触发 "Build lede Firmware for H68K" 工作流
4. 等待编译完成（约 2-3 小时）
5. 下载编译好的固件

### 方法二：本地编译

```bash
# 1. 克隆仓库
git clone https://github.com/linbeiya/lede.git
cd lede

# 2. 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 3. 执行自定义脚本
chmod +x diy-part1.sh diy-part2.sh
./diy-part1.sh
./diy-part2.sh

# 4. 编译
make download -j8
make -j$(nproc) V=s
```

## 配置说明

### 目标平台配置
```
CONFIG_TARGET_armsr=y
CONFIG_TARGET_armsr_armv8=y
CONFIG_TARGET_armsr_armv8_DEVICE_generic=y
```

### 关键驱动
- `kmod-mt76*`: MT7921 WiFi 驱动套件
- `kmod-r8169`: Realtek 千兆网卡驱动
- `kmod-usb3`: USB 3.0 支持
- `kmod-fs-*`: 多种文件系统支持

## 故障排除

### 常见问题

1. **编译失败 - 目标平台错误**
   - 确保使用 `armsr` 而不是 `armvirt`
   - 检查 `.config` 文件中的目标平台配置

2. **WiFi 不工作**
   - 确认 MT7921 驱动已启用
   - 检查固件是否包含 `mt7921e.ko` 模块

3. **网卡不识别**
   - 确认 RTL8169 驱动已启用
   - 检查 USB 网卡驱动是否加载

### 调试命令

```bash
# 检查网络接口
ip link show

# 检查已加载的内核模块
lsmod | grep -E "(mt76|r8169|usb)"

# 检查系统日志
dmesg | tail -50
```

## 自定义配置

如需修改配置，请编辑以下文件：
- `.config`: 主配置文件
- `diy-part1.sh`: 编译前自定义脚本
- `diy-part2.sh`: 编译后自定义脚本

## 更新日志

- **2024-12-XX**: 初始版本，支持 H68K 基本功能
- 修复了 armvirt -> armsr 目标平台迁移问题
- 添加了完整的 MT7921 WiFi 驱动支持
- 优化了 GitHub Actions 编译流程

## 技术支持

如遇到问题，请：
1. 检查本 README 的故障排除部分
2. 查看 GitHub Actions 的编译日志
3. 在 Issues 中提交问题报告

## 许可证

本项目遵循原 LEDE 项目的 GPL-2.0 许可证。
