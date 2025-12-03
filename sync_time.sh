#!/bin/bash
#
# 时间同步脚本 - 从阿里云服务器同步时间
# 日志目录: /var/log/sync_time/
#

LOG_DIR="/var/log/sync_time"
LOG_FILE="$LOG_DIR/sync_time.log"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 记录日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========== 开始时间同步 =========="

# 记录同步前的时间
OLD_TIME=$(date '+%Y-%m-%d %H:%M:%S')
log "同步前系统时间: $OLD_TIME"

# 停止chrony服务
log "停止chrony服务..."
systemctl stop chrony
if [ $? -eq 0 ]; then
    log "chrony服务已停止"
else
    log "ERROR: 停止chrony服务失败"
    exit 1
fi

# 从阿里云获取时间
log "从阿里云获取时间..."
ALIYUN_DATE=$(curl -sI http://www.aliyun.com --connect-timeout 10 --max-time 15 | grep -i "^Date:" | sed 's/Date: //i')

if [ -z "$ALIYUN_DATE" ]; then
    log "ERROR: 无法从阿里云获取时间，尝试备用源..."
    # 备用时间源
    ALIYUN_DATE=$(curl -sI http://www.baidu.com --connect-timeout 10 --max-time 15 | grep -i "^Date:" | sed 's/Date: //i')

    if [ -z "$ALIYUN_DATE" ]; then
        log "ERROR: 所有时间源均失败，启动chrony服务后退出"
        systemctl start chrony
        exit 1
    fi
fi

log "获取到的时间: $ALIYUN_DATE"

# 设置系统时间
NEW_TIME=$(date -d "$ALIYUN_DATE" +"%Y-%m-%d %H:%M:%S")
date -s "$NEW_TIME"
if [ $? -eq 0 ]; then
    log "系统时间已更新为: $NEW_TIME"
else
    log "ERROR: 设置系统时间失败"
    systemctl start chrony
    exit 1
fi

# 同步到硬件时钟
log "同步到硬件时钟..."
hwclock -w
if [ $? -eq 0 ]; then
    log "硬件时钟已同步"
else
    log "WARNING: 硬件时钟同步失败"
fi

# 启动chrony服务
log "启动chrony服务..."
systemctl start chrony
if [ $? -eq 0 ]; then
    log "chrony服务已启动"
else
    log "ERROR: 启动chrony服务失败"
fi

# 强制同步
log "执行chrony强制同步..."
chronyc -a makestep
if [ $? -eq 0 ]; then
    log "chrony强制同步完成"
else
    log "WARNING: chrony强制同步失败"
fi

# 记录同步后的时间
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
log "同步后系统时间: $CURRENT_TIME"
log "========== 时间同步完成 =========="
echo ""

exit 0
