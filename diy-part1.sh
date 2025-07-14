#!/bin/bash
#
# H68K 编译前自定义脚本 (DIY Part 1)
# 在 feeds 更新和安装之前执行
#

echo "=========================================="
echo "开始执行 DIY Part 1 脚本 (H68K 专用)"
echo "=========================================="

# 添加额外的软件源
echo "添加额外的软件源..."

# 添加 OpenClash 源
echo "src-git openclash https://github.com/vernesong/OpenClash" >> feeds.conf.default

# 添加 passwall 源
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall" >> feeds.conf.default

# 添加 SSR Plus 源
echo "src-git helloworld https://github.com/fw876/helloworld" >> feeds.conf.default

# 添加 Argon 主题源
echo "src-git argon https://github.com/jerrykuku/luci-theme-argon" >> feeds.conf.default

# 添加 Design 主题源
echo "src-git design https://github.com/gngpp/luci-theme-design" >> feeds.conf.default

# 修改默认 IP 地址
echo "修改默认 IP 地址为 192.168.1.1..."
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate

# 修改默认主机名
echo "修改默认主机名为 H68K-OpenWrt..."
sed -i 's/OpenWrt/H68K-OpenWrt/g' package/base-files/files/bin/config_generate

# 修改默认时区
echo "设置默认时区为上海..."
sed -i "s/'UTC'/'CST-8'/g" package/base-files/files/bin/config_generate
sed -i "/system.@system\[0\].timezone/d" package/base-files/files/bin/config_generate
sed -i "/system.@system\[0\].zonename/d" package/base-files/files/bin/config_generate
sed -i "/system.@system\[0\]/a\\\\t\\t\\tset system.@system[0].timezone='CST-8'" package/base-files/files/bin/config_generate
sed -i "/system.@system\[0\]/a\\\\t\\t\\tset system.@system[0].zonename='Asia/Shanghai'" package/base-files/files/bin/config_generate

# 修改版本信息
echo "修改版本信息..."
echo "H68K-$(date +%Y%m%d)" > package/base-files/files/etc/openwrt_version

# 为 H68K 设备优化内核参数
echo "为 H68K 设备优化内核参数..."
echo "CONFIG_ARM64_64K_PAGES=n" >> target/linux/armsr/config-6.6
echo "CONFIG_ARM64_4K_PAGES=y" >> target/linux/armsr/config-6.6

echo "=========================================="
echo "DIY Part 1 脚本执行完成"
echo "=========================================="
