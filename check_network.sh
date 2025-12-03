#!/bin/bash
#
# 网络检测脚本 - 检测223.5.5.5连通性，失败则重启系统
# 日志目录: /var/log/check_network/
#

LOG_DIR="/var/log/check_network"
LOG_FILE="$LOG_DIR/check_network.log"
PING_TARGET="223.5.5.5"
PING_COUNT=3
MAX_RETRY=2

# 创建日志目录
mkdir -p "$LOG_DIR"

# 记录日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# ping检测函数
check_ping() {
    ping -c "$PING_COUNT" -W 5 "$PING_TARGET" > /dev/null 2>&1
    return $?
}

log "========== 开始网络检测 =========="
log "检测目标: $PING_TARGET"

# 第一次检测
if check_ping; then
    log "网络正常 - Ping $PING_TARGET 成功"
    log "========== 网络检测完成 =========="
    echo ""
    exit 0
fi

# 第一次失败，记录并重试
log "WARNING: 第1次ping失败，等待10秒后重试..."
sleep 10

# 第二次检测
if check_ping; then
    log "网络正常 - 重试后Ping $PING_TARGET 成功"
    log "========== 网络检测完成 =========="
    echo ""
    exit 0
fi

# 第二次失败，再次重试
log "WARNING: 第2次ping失败，等待10秒后再次重试..."
sleep 10

# 第三次检测（最后一次）
if check_ping; then
    log "网络正常 - 最后重试Ping $PING_TARGET 成功"
    log "========== 网络检测完成 =========="
    echo ""
    exit 0
fi

# 所有检测都失败，准备重启
log "ERROR: 连续${MAX_RETRY}次ping失败，网络不通！"
log "记录系统状态信息..."

# 记录网络接口状态
log "网络接口状态:"
ip addr | tee -a "$LOG_FILE"

# 记录路由表
log "路由表:"
ip route | tee -a "$LOG_FILE"

# 记录DNS配置
log "DNS配置:"
cat /etc/resolv.conf | tee -a "$LOG_FILE"

# 重启前最后警告
log "========================================="
log "!!!!! 系统将在10秒后自动重启 !!!!!"
log "========================================="

# 发送系统日志
logger -t check_network "网络检测失败，系统即将重启"

# 等待10秒后重启
sleep 10

log "执行重启命令..."
sync
/sbin/reboot

exit 0
