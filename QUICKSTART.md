# 快速使用指南

## 一键安装部署

```bash
cd /root/test
./auto_install.sh
```

安装脚本会自动完成：
- ✓ 检测操作系统类型
- ✓ 安装chrony时间同步服务
- ✓ 安装curl等必要工具
- ✓ 配置定时任务（每2小时执行）
- ✓ 创建日志目录
- ✓ 测试网络连通性

## 已配置的定时任务

```cron
0 */2 * * * /root/test/monitor.sh
```

**执行时间**: 每天 0:00, 2:00, 4:00, 6:00, 8:00, 10:00, 12:00, 14:00, 16:00, 18:00, 20:00, 22:00

## 监控功能

### 1. 网络连通性检测
- 检测目标: 223.5.5.5 (阿里DNS)
- 重试机制: 失败后每10秒重试，最多3次
- 失败处理: 3次全部失败后等待30秒自动重启系统

### 2. 时间同步
- 时间源: 阿里云 (http://www.aliyun.com)
- 备用源: 百度 (http://www.baidu.com)
- 同步方式:
  1. 停止chrony服务
  2. 从网络获取时间
  3. 设置系统时间
  4. 同步硬件时钟
  5. 启动chrony服务
  6. 执行强制同步

## 常用命令

### 查看定时任务
```bash
crontab -l
```

### 手动执行监控
```bash
/root/test/monitor.sh
```

### 查看实时日志
```bash
tail -f /var/log/monitor/monitor.log
```

### 查看历史日志
```bash
cat /var/log/monitor/monitor.log
# 或查看最近50行
tail -50 /var/log/monitor/monitor.log
```

### 检查chrony服务状态
```bash
systemctl status chrony
```

### 查看chrony时间源
```bash
chronyc sources -v
```

### 测试网络连通性
```bash
ping -c 3 223.5.5.5
```

## 修改配置

### 修改执行频率

编辑crontab：
```bash
crontab -e
```

常用时间配置：
```cron
# 每小时执行
0 * * * * /root/test/monitor.sh

# 每2小时执行（当前配置）
0 */2 * * * /root/test/monitor.sh

# 每3小时执行
0 */3 * * * /root/test/monitor.sh

# 每天凌晨3点执行
0 3 * * * /root/test/monitor.sh

# 每30分钟执行
*/30 * * * * /root/test/monitor.sh
```

### 修改检测参数

编辑监控脚本：
```bash
vi /root/test/monitor.sh
```

可调整的参数：
```bash
PING_TARGET="223.5.5.5"    # 检测目标IP
PING_COUNT=3               # 每次ping的包数
MAX_RETRY=3                # 最大重试次数
```

### 修改重启前等待时间

在 `/root/test/monitor.sh` 中找到：
```bash
sleep 30  # 重启前等待30秒
```

可以改为更长时间，如60秒：
```bash
sleep 60  # 重启前等待60秒
```

## 文件说明

```
/root/test/
├── auto_install.sh       # 自动安装脚本（一键部署）
├── monitor.sh            # 综合监控脚本（时间+网络）
├── sync_time.sh          # 独立时间同步脚本
├── check_network.sh      # 独立网络检测脚本
├── install.sh            # 原始安装脚本
├── crontab_config.txt    # Crontab配置说明
├── README.md             # 完整文档
└── QUICKSTART.md         # 本快速指南

/var/log/
├── monitor/              # 综合监控日志
│   └── monitor.log
├── sync_time/            # 时间同步日志
│   └── sync_time.log
└── check_network/        # 网络检测日志
    └── check_network.log
```

## 日志示例

```
[2025-12-03 10:47:19] ==================================================
[2025-12-03 10:47:19] 综合监控任务开始执行
[2025-12-03 10:47:19] ==================================================
[2025-12-03 10:47:19] 开始网络连通性检测
[2025-12-03 10:47:19] 检测目标: 223.5.5.5
[2025-12-03 10:47:19] 第1次检测...
[2025-12-03 10:47:21] ✓ 网络正常 - Ping 223.5.5.5 成功
[2025-12-03 10:47:21] 开始时间同步
[2025-12-03 10:47:21] 同步前系统时间: 2025-12-03 10:47:21
[2025-12-03 10:47:21] ✓ 系统时间已更新为: 2025-12-03 10:47:21
[2025-12-03 10:47:23] ✓ 时间同步完成
[2025-12-03 10:47:23] 监控任务执行完成
[2025-12-03 10:47:23] 网络检测: ✓ 正常
[2025-12-03 10:47:23] 时间同步: ✓ 成功
```

## 故障排查

### 定时任务不执行

1. 检查cron服务状态
```bash
systemctl status cron      # Debian/Ubuntu
systemctl status crond     # CentOS/RHEL
```

2. 检查cron日志
```bash
tail -f /var/log/cron      # CentOS/RHEL
tail -f /var/log/syslog    # Debian/Ubuntu
```

3. 手动测试脚本
```bash
/root/test/monitor.sh
```

### 时间同步失败

1. 检查网络连接
```bash
curl -I http://www.aliyun.com
```

2. 检查chrony服务
```bash
systemctl status chrony
chronyc sources
```

3. 查看详细日志
```bash
tail -50 /var/log/monitor/monitor.log
```

### 网络检测误报

如果网络正常但经常触发重启：

1. 增加重试次数（编辑 `/root/test/monitor.sh`）
```bash
MAX_RETRY=5  # 从3改为5
```

2. 增加每次ping的包数
```bash
PING_COUNT=5  # 从3改为5
```

3. 更换检测目标
```bash
PING_TARGET="114.114.114.114"  # 使用其他DNS
```

## 卸载

### 删除定时任务
```bash
crontab -e
# 删除包含 /root/test/monitor.sh 的行
```

### 删除脚本和日志
```bash
rm -rf /root/test/
rm -rf /var/log/monitor/
rm -rf /var/log/sync_time/
rm -rf /var/log/check_network/
```

### 恢复crontab备份
```bash
# 查看备份文件
ls /root/crontab_backup_*.txt

# 恢复备份
crontab /root/crontab_backup_YYYYMMDD_HHMMSS.txt
```

## 安全提示

1. **重启风险**: 网络检测失败会自动重启系统，请确保这是你期望的行为
2. **日志管理**: 定期清理日志文件，避免占用过多磁盘空间
3. **权限控制**: 所有脚本使用root权限运行，请勿随意修改
4. **备份重要数据**: 重启前建议备份重要数据和配置

## 常见问题

**Q: 为什么选择每2小时执行？**
A: 平衡了时间准确性和系统资源占用，对大多数场景足够。可根据需求调整。

**Q: 网络检测为什么选择223.5.5.5？**
A: 这是阿里云的公共DNS服务器，稳定可靠，在中国大陆访问速度快。

**Q: 硬件时钟同步失败是否影响使用？**
A: 不影响。虚拟机环境可能不支持hwclock，但系统时间已正确同步。

**Q: 可以同时运行独立脚本和综合脚本吗？**
A: 可以，但不建议。建议只使用monitor.sh，避免重复执行。

**Q: 如何临时禁用监控任务？**
A: 编辑crontab，在任务行前加#注释符号即可。
