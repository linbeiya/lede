#!/bin/bash
#
# 磁盘空间监控脚本
# 用于在编译过程中监控磁盘使用情况
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取磁盘使用情况
get_disk_usage() {
    df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# 获取可用空间（GB）
get_available_space() {
    df -BG / | awk 'NR==2 {print $4}' | sed 's/G//'
}

# 清理函数
cleanup_space() {
    echo -e "${YELLOW}🧹 开始清理磁盘空间...${NC}"
    
    # 清理 APT 缓存
    sudo apt-get clean
    
    # 清理临时文件
    sudo rm -rf /tmp/*
    sudo rm -rf /var/tmp/*
    
    # 清理日志文件
    sudo journalctl --vacuum-time=1d
    
    # 清理 Docker（如果存在）
    if command -v docker &> /dev/null; then
        sudo docker system prune -af
    fi
    
    # 清理编译临时文件
    if [ -d "build_dir" ]; then
        echo "清理编译临时文件..."
        rm -rf build_dir/host
        rm -rf build_dir/toolchain-*
        find build_dir -name "*.tmp" -delete
    fi
    
    if [ -d "staging_dir" ]; then
        echo "清理 staging 目录..."
        rm -rf staging_dir/host
    fi
    
    if [ -d "tmp" ]; then
        echo "清理 tmp 目录..."
        rm -rf tmp/*
    fi
    
    echo -e "${GREEN}✅ 清理完成${NC}"
}

# 主监控循环
monitor_disk_space() {
    local threshold=${1:-85}  # 默认阈值 85%
    local usage=$(get_disk_usage)
    local available=$(get_available_space)
    
    echo -e "${BLUE}📊 磁盘使用情况监控${NC}"
    echo -e "当前使用率: ${usage}%"
    echo -e "可用空间: ${available}GB"
    
    if [ "$usage" -gt "$threshold" ]; then
        echo -e "${RED}⚠️  磁盘使用率超过 ${threshold}%！${NC}"
        cleanup_space
        
        # 重新检查
        usage=$(get_disk_usage)
        available=$(get_available_space)
        echo -e "${BLUE}清理后使用率: ${usage}%${NC}"
        echo -e "${BLUE}清理后可用空间: ${available}GB${NC}"
        
        if [ "$usage" -gt 90 ]; then
            echo -e "${RED}❌ 磁盘空间严重不足，建议停止编译${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}✅ 磁盘空间充足${NC}"
    fi
    
    return 0
}

# 显示大文件和目录
show_large_files() {
    echo -e "${BLUE}📁 最大的目录（前10个）：${NC}"
    du -sh * 2>/dev/null | sort -hr | head -10
    
    echo -e "${BLUE}📄 最大的文件（前10个）：${NC}"
    find . -type f -exec du -h {} + 2>/dev/null | sort -hr | head -10
}

# 主函数
main() {
    case "${1:-monitor}" in
        "monitor")
            monitor_disk_space ${2:-85}
            ;;
        "cleanup")
            cleanup_space
            ;;
        "large")
            show_large_files
            ;;
        "help")
            echo "用法: $0 [monitor|cleanup|large|help] [threshold]"
            echo "  monitor [threshold] - 监控磁盘使用率（默认阈值85%）"
            echo "  cleanup            - 清理磁盘空间"
            echo "  large              - 显示大文件和目录"
            echo "  help               - 显示帮助信息"
            ;;
        *)
            echo "未知命令: $1"
            echo "使用 '$0 help' 查看帮助"
            exit 1
            ;;
    esac
}

main "$@"
