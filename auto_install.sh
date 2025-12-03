#!/bin/bash
#
# 自动化安装配置脚本
# 功能：自动检测系统、安装依赖、配置定时任务
#

set -e  # 遇到错误立即退出

# 获取脚本所在目录（绝对路径）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 显示标题
show_banner() {
    echo "=================================================="
    echo "    Linux 系统监控自动化部署脚本"
    echo "    - 时间同步 (每2小时)"
    echo "    - 网络检测 (每2小时)"
    echo "=================================================="
    echo ""
}

# 检测操作系统
detect_os() {
    log_step "检测操作系统..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        log_info "操作系统: $NAME $VERSION"
    elif [ -f /etc/redhat-release ]; then
        OS="centos"
        log_info "操作系统: CentOS/RHEL"
    else
        log_error "无法识别操作系统"
        exit 1
    fi

    # 检测包管理器
    if command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        log_info "包管理器: yum"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        log_info "包管理器: dnf"
    elif command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt-get"
        log_info "包管理器: apt-get"
    else
        log_error "未找到支持的包管理器"
        exit 1
    fi

    echo ""
}

# 检查并安装依赖
install_dependencies() {
    log_step "检查系统依赖..."

    local packages_to_install=()

    # 检查必需的命令
    local required_commands=("curl" "chrony" "ping" "systemctl" "crontab")

    for cmd in "${required_commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            case $cmd in
                chrony)
                    if [ "$PKG_MANAGER" = "apt-get" ]; then
                        packages_to_install+=("chrony")
                    else
                        packages_to_install+=("chrony")
                    fi
                    ;;
                curl)
                    packages_to_install+=("curl")
                    ;;
                ping)
                    if [ "$PKG_MANAGER" = "apt-get" ]; then
                        packages_to_install+=("iputils-ping")
                    else
                        packages_to_install+=("iputils")
                    fi
                    ;;
            esac
        fi
    done

    # 安装缺失的包
    if [ ${#packages_to_install[@]} -gt 0 ]; then
        log_info "需要安装以下软件包: ${packages_to_install[*]}"

        if [ "$PKG_MANAGER" = "apt-get" ]; then
            log_info "更新软件包列表..."
            apt-get update -qq
        fi

        for package in "${packages_to_install[@]}"; do
            log_info "安装 $package..."
            if [ "$PKG_MANAGER" = "apt-get" ]; then
                DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $package
            else
                $PKG_MANAGER install -y -q $package
            fi

            if [ $? -eq 0 ]; then
                log_info "✓ $package 安装成功"
            else
                log_error "✗ $package 安装失败"
                exit 1
            fi
        done
    else
        log_info "✓ 所有依赖已满足"
    fi

    echo ""
}

# 配置chrony服务
configure_chrony() {
    log_step "配置chrony服务..."

    # 启用chrony服务
    if systemctl is-enabled chrony &> /dev/null; then
        log_info "✓ chrony服务已设置为开机启动"
    else
        log_info "设置chrony服务开机启动..."
        systemctl enable chrony
        log_info "✓ 已启用chrony开机启动"
    fi

    # 启动chrony服务
    if systemctl is-active chrony &> /dev/null; then
        log_info "✓ chrony服务运行中"
    else
        log_info "启动chrony服务..."
        systemctl start chrony
        log_info "✓ chrony服务已启动"
    fi

    echo ""
}

# 设置脚本权限
setup_scripts() {
    log_step "设置脚本权限..."

    # 设置执行权限
    chmod +x "$SCRIPT_DIR/monitor.sh"
    chmod +x "$SCRIPT_DIR/sync_time.sh"
    chmod +x "$SCRIPT_DIR/check_network.sh"

    log_info "✓ 脚本权限设置完成"
    log_info "  脚本目录: $SCRIPT_DIR"
    echo ""
}

# 创建日志目录
create_log_dirs() {
    log_step "创建日志目录..."

    mkdir -p /var/log/monitor
    mkdir -p /var/log/sync_time
    mkdir -p /var/log/check_network

    log_info "✓ 日志目录创建完成"
    log_info "  - /var/log/monitor/"
    log_info "  - /var/log/sync_time/"
    log_info "  - /var/log/check_network/"
    echo ""
}

# 配置定时任务
configure_crontab() {
    log_step "配置定时任务..."

    # 备份现有crontab
    local backup_file="/root/crontab_backup_$(date +%Y%m%d_%H%M%S).txt"
    if crontab -l &> /dev/null; then
        crontab -l > "$backup_file" 2>/dev/null || true
        log_info "已备份现有crontab到: $backup_file"
    fi

    # 获取当前crontab
    local current_crontab=$(crontab -l 2>/dev/null || true)

    # 定义新的定时任务
    local new_cron_monitor="0 */2 * * * $SCRIPT_DIR/monitor.sh"

    # 检查是否已存在监控任务
    if echo "$current_crontab" | grep -q "monitor.sh"; then
        log_warn "监控任务已存在，跳过添加"
    else
        log_info "添加监控定时任务（每2小时执行）..."
        (crontab -l 2>/dev/null || true; echo "$new_cron_monitor") | crontab -
        log_info "✓ 定时任务已添加: $new_cron_monitor"
    fi

    echo ""
    log_info "当前定时任务列表:"
    crontab -l | grep -v "^#" | grep -v "^$" || echo "  (空)"
    echo ""
}

# 测试脚本
test_scripts() {
    log_step "测试监控脚本..."

    log_info "运行网络检测..."
    if ping -c 2 -W 3 223.5.5.5 > /dev/null 2>&1; then
        log_info "✓ 网络连接正常 (223.5.5.5)"
    else
        log_warn "✗ 网络连接失败，请检查网络配置"
    fi

    log_info "测试时间源..."
    if curl -sI http://www.aliyun.com --connect-timeout 5 --max-time 10 | grep -q "Date:"; then
        log_info "✓ 阿里云时间源可访问"
    else
        log_warn "✗ 阿里云时间源不可访问"
    fi

    echo ""
}

# 显示完成信息
show_completion() {
    echo "=================================================="
    echo "           安装配置完成！"
    echo "=================================================="
    echo ""
    echo "📋 配置信息："
    echo "   安装目录: $SCRIPT_DIR"
    echo "   监控脚本: $SCRIPT_DIR/monitor.sh"
    echo "   执行频率: 每2小时一次"
    echo "   日志目录: /var/log/monitor/"
    echo ""
    echo "🔧 常用命令："
    echo "   查看定时任务: crontab -l"
    echo "   编辑定时任务: crontab -e"
    echo "   查看日志: tail -f /var/log/monitor/monitor.log"
    echo "   手动执行: $SCRIPT_DIR/monitor.sh"
    echo ""
    echo "📊 监控任务："
    echo "   ✓ 时间同步（阿里云）"
    echo "   ✓ 网络检测（223.5.5.5）"
    echo "   ✓ 自动重启（网络失败3次）"
    echo ""
    echo "⏰ 下次执行时间："

    # 计算下次执行时间（整点）
    local current_hour=$(date +%H)
    local current_min=$(date +%M)
    local next_hour=$(( (current_hour / 2 * 2 + 2) % 24 ))
    echo "   $(date -d "$next_hour:00" '+%Y-%m-%d %H:%M')"
    echo ""
    echo "💡 提示："
    echo "   - 监控任务将在每天的 0:00, 2:00, 4:00, ... 22:00 执行"
    echo "   - 首次执行可能需要等待到下个整点"
    echo "   - 可以手动执行测试: $SCRIPT_DIR/monitor.sh"
    echo ""
    echo "=================================================="
}

# 主函数
main() {
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root权限运行此脚本"
        exit 1
    fi

    show_banner
    detect_os
    install_dependencies
    configure_chrony
    setup_scripts
    create_log_dirs
    configure_crontab
    test_scripts
    show_completion
}

# 运行主函数
main

exit 0
