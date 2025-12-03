#!/bin/bash
#
# 综合监控脚本 - 时间同步 + 网络检测
# 每2小时自动执行
# 日志目录: /var/log/monitor/
#

LOG_DIR="/var/log/monitor"
LOG_FILE="$LOG_DIR/monitor.log"
PING_TARGET="223.5.5.5"
PING_COUNT=3
MAX_RETRY=3

# 创建日志目录
mkdir -p "$LOG_DIR"

# 记录日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# ============================================================
# 1. 网络连通性检测
# ============================================================
check_network() {
    log "=================================================="
    log "开始网络连通性检测"
    log "=================================================="
    log "检测目标: $PING_TARGET"

    local retry=0
    local max_retries=$MAX_RETRY

    while [ $retry -lt $max_retries ]; do
        retry=$((retry + 1))
        log "第${retry}次检测..."

        if ping -c "$PING_COUNT" -W 5 "$PING_TARGET" > /dev/null 2>&1; then
            log "✓ 网络正常 - Ping $PING_TARGET 成功"
            return 0
        else
            log "✗ 第${retry}次ping失败"

            if [ $retry -lt $max_retries ]; then
                log "等待10秒后重试..."
                sleep 10
            fi
        fi
    done

    # 所有检测都失败
    log "=================================================="
    log "!!! 严重: 网络检测失败 ${max_retries} 次 !!!"
    log "=================================================="

    # 记录网络状态
    log "记录当前网络状态信息..."
    log "--- 网络接口状态 ---"
    ip addr | tee -a "$LOG_FILE"
    log "--- 路由表 ---"
    ip route | tee -a "$LOG_FILE"
    log "--- DNS配置 ---"
    cat /etc/resolv.conf 2>/dev/null | tee -a "$LOG_FILE"

    # 发送系统日志
    logger -t monitor "网络检测失败，系统即将重启"

    log "=================================================="
    log "系统将在30秒后自动重启"
    log "=================================================="

    # 给管理员更多反应时间
    sleep 30

    log "执行重启命令..."
    sync
    /sbin/reboot

    return 1
}

# ============================================================
# 2. 时间同步
# ============================================================
sync_time() {
    log "=================================================="
    log "开始时间同步"
    log "=================================================="

    # 记录同步前的时间
    local old_time=$(date '+%Y-%m-%d %H:%M:%S')
    log "同步前系统时间: $old_time"

    # 检查chrony服务
    if ! systemctl is-active --quiet chrony; then
        log "⚠ chrony服务未运行，尝试启动..."
        systemctl start chrony
        sleep 2
    fi

    # 停止chrony服务
    log "停止chrony服务..."
    systemctl stop chrony
    if [ $? -ne 0 ]; then
        log "ERROR: 停止chrony服务失败"
        return 1
    fi

    # 从阿里云获取时间
    log "从阿里云获取时间..."
    local aliyun_date=$(curl -sI http://www.aliyun.com --connect-timeout 10 --max-time 15 | grep -i "^Date:" | sed 's/Date: //i')

    if [ -z "$aliyun_date" ]; then
        log "⚠ 无法从阿里云获取时间，尝试备用源（百度）..."
        aliyun_date=$(curl -sI http://www.baidu.com --connect-timeout 10 --max-time 15 | grep -i "^Date:" | sed 's/Date: //i')

        if [ -z "$aliyun_date" ]; then
            log "ERROR: 所有时间源均失败"
            systemctl start chrony
            return 1
        fi
    fi

    log "获取到的时间: $aliyun_date"

    # 设置系统时间
    local new_time=$(date -d "$aliyun_date" +"%Y-%m-%d %H:%M:%S" 2>/dev/null)
    if [ -z "$new_time" ]; then
        log "ERROR: 时间格式转换失败"
        systemctl start chrony
        return 1
    fi

    date -s "$new_time" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log "✓ 系统时间已更新为: $new_time"
    else
        log "ERROR: 设置系统时间失败"
        systemctl start chrony
        return 1
    fi

    # 同步到硬件时钟
    log "同步到硬件时钟..."
    hwclock -w 2>/dev/null
    if [ $? -eq 0 ]; then
        log "✓ 硬件时钟已同步"
    else
        log "⚠ 硬件时钟同步失败（可能不影响使用）"
    fi

    # 启动chrony服务
    log "启动chrony服务..."
    systemctl start chrony
    if [ $? -eq 0 ]; then
        log "✓ chrony服务已启动"
    else
        log "ERROR: 启动chrony服务失败"
    fi

    # 强制同步
    sleep 2
    log "执行chrony强制同步..."
    chronyc -a makestep > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log "✓ chrony强制同步完成"
    fi

    # 记录同步后的时间
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    log "同步后系统时间: $current_time"

    # 计算时间差
    local old_timestamp=$(date -d "$old_time" +%s 2>/dev/null)
    local new_timestamp=$(date -d "$current_time" +%s 2>/dev/null)
    if [ -n "$old_timestamp" ] && [ -n "$new_timestamp" ]; then
        local time_diff=$((new_timestamp - old_timestamp))
        log "时间调整: ${time_diff} 秒"
    fi

    log "✓ 时间同步完成"
    return 0
}

# ============================================================
# 主程序
# ============================================================
main() {
    log "=================================================="
    log "综合监控任务开始执行"
    log "=================================================="

    # 1. 先检测网络
    check_network
    network_status=$?

    if [ $network_status -ne 0 ]; then
        log "网络检测失败，跳过时间同步"
        return 1
    fi

    log ""

    # 2. 网络正常，执行时间同步
    sync_time
    time_status=$?

    log ""
    log "=================================================="
    log "监控任务执行完成"
    log "网络检测: $([ $network_status -eq 0 ] && echo '✓ 正常' || echo '✗ 失败')"
    log "时间同步: $([ $time_status -eq 0 ] && echo '✓ 成功' || echo '✗ 失败')"
    log "=================================================="
    echo ""

    return 0
}

# 执行主程序
main

exit 0
