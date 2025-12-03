#!/bin/bash
#
# 安装和配置脚本
#

echo "=========================================="
echo "定时任务安装配置脚本"
echo "=========================================="
echo ""

# 1. 设置脚本执行权限
echo "[1/4] 设置脚本执行权限..."
chmod +x /root/test/sync_time.sh
chmod +x /root/test/check_network.sh
echo "✓ 脚本权限设置完成"
echo ""

# 2. 创建日志目录
echo "[2/4] 创建日志目录..."
mkdir -p /var/log/sync_time
mkdir -p /var/log/check_network
echo "✓ 日志目录创建完成"
echo ""

# 3. 检测chrony是否安装
echo "[3/4] 检查chrony服务..."
if systemctl list-unit-files | grep -q chrony.service; then
    echo "✓ chrony服务已安装"
    systemctl is-active --quiet chrony && echo "✓ chrony服务运行中" || echo "⚠ chrony服务未运行"
else
    echo "⚠ 警告: chrony服务未安装"
    echo "  请执行: yum install chrony (CentOS/RHEL) 或 apt install chrony (Debian/Ubuntu)"
fi
echo ""

# 4. 测试脚本
echo "[4/4] 测试脚本..."
echo ""
echo "测试网络检测脚本..."
/root/test/check_network.sh
echo ""

echo "=========================================="
echo "安装完成！"
echo "=========================================="
echo ""
echo "下一步操作:"
echo "1. 查看crontab配置: cat /root/test/crontab_config.txt"
echo "2. 编辑crontab: crontab -e"
echo "3. 添加定时任务配置"
echo ""
echo "推荐配置:"
echo "  # 每天凌晨3点同步时间"
echo "  0 3 * * * /root/test/sync_time.sh"
echo ""
echo "  # 每5分钟检测网络"
echo "  */5 * * * * /root/test/check_network.sh"
echo ""
echo "查看日志:"
echo "  时间同步日志: tail -f /var/log/sync_time/sync_time.log"
echo "  网络检测日志: tail -f /var/log/check_network/check_network.log"
echo ""
