#!/bin/bash
#
# H68K 编译后自定义脚本 (DIY Part 2)
# 在 make defconfig 之后执行
#

echo "=========================================="
echo "开始执行 DIY Part 2 脚本 (H68K 专用)"
echo "=========================================="

# 确保配置文件存在
if [ ! -f .config ]; then
    echo "错误：.config 文件不存在！"
    exit 1
fi

# 应用 defconfig 以确保配置正确
echo "应用 defconfig..."
make defconfig

# 针对 H68K 设备的特殊配置
echo "应用 H68K 设备特殊配置..."

# 确保正确的目标平台
echo "CONFIG_TARGET_armsr=y" >> .config
echo "CONFIG_TARGET_armsr_armv8=y" >> .config
echo "CONFIG_TARGET_armsr_armv8_DEVICE_generic=y" >> .config

# 移除可能冲突的配置
sed -i '/CONFIG_TARGET_armvirt/d' .config

# 启用必要的内核模块
echo "启用必要的内核模块..."
echo "CONFIG_PACKAGE_kmod-usb3=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-storage=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-net=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-net-rtl8152=y" >> .config
echo "CONFIG_PACKAGE_kmod-r8169=y" >> .config

# 启用 MT7921 WiFi 驱动（H68K 常用）
echo "启用 MT7921 WiFi 驱动..."
echo "CONFIG_PACKAGE_kmod-mt76=y" >> .config
echo "CONFIG_PACKAGE_kmod-mt76-core=y" >> .config
echo "CONFIG_PACKAGE_kmod-mt76-connac-lib=y" >> .config
echo "CONFIG_PACKAGE_kmod-mt7921-common=y" >> .config
echo "CONFIG_PACKAGE_kmod-mt7921e=y" >> .config

# 启用文件系统支持
echo "启用文件系统支持..."
echo "CONFIG_PACKAGE_kmod-fs-ext4=y" >> .config
echo "CONFIG_PACKAGE_kmod-fs-cifs=y" >> .config
echo "CONFIG_PACKAGE_kmod-fs-ntfs3=y" >> .config

# 启用 Docker 支持
echo "启用 Docker 支持..."
echo "CONFIG_PACKAGE_luci-app-docker=y" >> .config
echo "CONFIG_PACKAGE_docker-ce=y" >> .config

# 启用常用应用
echo "启用常用应用..."
echo "CONFIG_PACKAGE_luci-app-openclash=y" >> .config
echo "CONFIG_PACKAGE_luci-app-adguardhome=y" >> .config
echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> .config

# 启用主题
echo "启用主题..."
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
echo "CONFIG_PACKAGE_luci-theme-design=y" >> .config

# 移除重复配置并重新应用 defconfig
echo "清理配置文件..."
sort .config | uniq > .config.tmp && mv .config.tmp .config
make defconfig

# 显示最终配置摘要
echo "=========================================="
echo "最终配置摘要："
echo "目标平台: $(grep "CONFIG_TARGET_" .config | head -3)"
echo "内核版本: $(grep "CONFIG_LINUX_" .config | head -1)"
echo "文件系统: $(grep "CONFIG_TARGET_ROOTFS_" .config)"
echo "=========================================="

echo "DIY Part 2 脚本执行完成"
echo "=========================================="
