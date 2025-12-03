# VPS 自动化监控工具

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Shell](https://img.shields.io/badge/shell-bash-green.svg)
![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)
![Maintenance](https://img.shields.io/badge/maintained-yes-brightgreen.svg)

一个轻量级的 Linux VPS 自动化监控解决方案，支持时间同步和网络连通性检测。

[功能特性](#功能特性) • [快速开始](#快速开始) • [文档](#文档) • [配置说明](#配置说明)

</div>

---

## 📖 项目简介

VPS 自动化监控工具是一个专为 Linux 服务器设计的轻量级监控解决方案。通过定时任务自动执行时间同步和网络连通性检测，确保服务器时间准确性和网络稳定性。

### 适用场景

- ✅ VPS 服务器自动化运维
- ✅ 时间敏感的应用服务器（数据库、日志系统等）
- ✅ 需要保持网络连通性的关键服务
- ✅ 无人值守的生产环境服务器

## ✨ 功能特性

### 🔄 时间同步
- **多源支持**: 阿里云（主）+ 百度（备用）
- **完整同步**: 系统时间 → 硬件时钟 → Chrony 服务
- **智能重试**: 自动切换备用时间源
- **详细日志**: 记录每次同步的时间差异

### 🌐 网络监控
- **主动检测**: 定时 Ping 检测网络连通性
- **智能重试**: 失败后自动重试，避免误报
- **自动恢复**: 网络持续故障时自动重启系统
- **状态记录**: 重启前记录完整网络状态信息

### 🚀 自动化部署
- **一键安装**: 全自动检测系统环境
- **依赖管理**: 自动安装缺失的软件包
- **智能配置**: 自动配置 Crontab 定时任务
- **多系统支持**: Debian/Ubuntu/CentOS/RHEL

## 🎯 快速开始

### 环境要求

- **操作系统**: Linux (Debian/Ubuntu/CentOS/RHEL)
- **权限**: Root 权限
- **网络**: 能访问公网

### 一键安装

**复制下面一条命令即可完成安装：**

```bash
git clone https://github.com/ClaraCora/vpstest.git && cd vpstest && chmod +x auto_install.sh && ./auto_install.sh
```

<details>
<summary>或者分步安装（点击展开）</summary>

```bash
# 1. 下载项目
git clone https://github.com/ClaraCora/vpstest.git
cd vpstest

# 2. 运行自动安装脚本
chmod +x auto_install.sh
./auto_install.sh
```
</details>

安装脚本会自动完成：
- ✅ 检测操作系统和包管理器
- ✅ 安装 Chrony 时间同步服务
- ✅ 安装 curl 等必需工具
- ✅ 配置定时任务（每2小时执行）
- ✅ 创建日志目录
- ✅ 测试网络连通性

### 手动安装

如果需要手动安装，请参考 [QUICKSTART.md](QUICKSTART.md)

## 📚 文档

- **[快速使用指南](QUICKSTART.md)** - 详细的使用说明和常见问题
- **[配置说明](crontab_config.txt)** - Crontab 定时任务配置参考
- **[更新日志](CHANGELOG.md)** - 版本更新记录

## 🛠️ 配置说明

### 定时任务配置

默认配置为每 2 小时执行一次：

```cron
0 */2 * * * /root/test/monitor.sh
```

**执行时间**: 0:00, 2:00, 4:00, 6:00, 8:00, 10:00, 12:00, 14:00, 16:00, 18:00, 20:00, 22:00

### 修改执行频率

编辑 crontab 修改频率：

```bash
crontab -e
```

常用配置示例：

```cron
# 每小时执行
0 * * * * /root/test/monitor.sh

# 每3小时执行
0 */3 * * * /root/test/monitor.sh

# 每天凌晨3点执行
0 3 * * * /root/test/monitor.sh

# 每30分钟执行
*/30 * * * * /root/test/monitor.sh
```

### 自定义监控参数

编辑 `monitor.sh` 修改监控参数：

```bash
vi monitor.sh
```

可调整参数：

```bash
PING_TARGET="223.5.5.5"    # 检测目标IP（阿里DNS）
PING_COUNT=3               # 每次ping的包数
MAX_RETRY=3                # 最大重试次数
```

## 📊 使用示例

### 查看监控日志

```bash
# 实时查看日志
tail -f /var/log/monitor/monitor.log

# 查看最近50行
tail -50 /var/log/monitor/monitor.log
```

### 手动执行监控

```bash
/root/test/monitor.sh
```

### 检查定时任务

```bash
# 查看当前定时任务
crontab -l

# 编辑定时任务
crontab -e
```

### 日志输出示例

```
[2025-12-03 10:47:19] ==================================================
[2025-12-03 10:47:19] 综合监控任务开始执行
[2025-12-03 10:47:19] ==================================================
[2025-12-03 10:47:19] 开始网络连通性检测
[2025-12-03 10:47:19] 检测目标: 223.5.5.5
[2025-12-03 10:47:21] ✓ 网络正常 - Ping 223.5.5.5 成功
[2025-12-03 10:47:21] 开始时间同步
[2025-12-03 10:47:21] 同步前系统时间: 2025-12-03 10:47:21
[2025-12-03 10:47:21] ✓ 系统时间已更新为: 2025-12-03 10:47:21
[2025-12-03 10:47:23] ✓ 时间同步完成
[2025-12-03 10:47:23] 监控任务执行完成
```

## 📁 项目结构

```
vpstest/
├── auto_install.sh          # 自动化安装脚本（推荐使用）
├── monitor.sh               # 综合监控脚本（时间+网络）
├── sync_time.sh             # 独立时间同步脚本
├── check_network.sh         # 独立网络检测脚本
├── install.sh               # 基础安装脚本
├── crontab_config.txt       # Crontab配置说明
├── README.md                # 项目说明（本文件）
├── QUICKSTART.md            # 快速使用指南
├── CHANGELOG.md             # 更新日志
├── LICENSE                  # 许可证
└── .gitignore               # Git忽略文件
```

## 🔧 故障排查

### 定时任务不执行

```bash
# 检查cron服务状态
systemctl status cron       # Debian/Ubuntu
systemctl status crond      # CentOS/RHEL

# 重启cron服务
systemctl restart cron      # Debian/Ubuntu
systemctl restart crond     # CentOS/RHEL
```

### 时间同步失败

```bash
# 检查网络连接
curl -I http://www.aliyun.com

# 检查chrony服务
systemctl status chrony
chronyc sources
```

### 网络检测误报

如果网络正常但经常触发重启，可以调整监控参数：

```bash
# 编辑monitor.sh
vi monitor.sh

# 增加重试次数
MAX_RETRY=5

# 增加ping包数
PING_COUNT=5
```

更多问题请查看 [QUICKSTART.md](QUICKSTART.md) 中的故障排查章节。

## ⚠️ 注意事项

1. **重启风险**: 网络检测失败会自动重启系统，请确保这是你期望的行为
2. **权限要求**: 所有脚本需要 root 权限运行
3. **日志管理**: 建议定期清理日志文件，避免占用过多磁盘空间
4. **备份数据**: 重启前建议备份重要数据和配置

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- 感谢阿里云提供稳定的时间源服务
- 感谢所有贡献者和使用者的支持

## 📮 联系方式

- 项目地址: [https://github.com/ClaraCora/vpstest](https://github.com/ClaraCora/vpstest)
- 问题反馈: [Issues](https://github.com/ClaraCora/vpstest/issues)

---

<div align="center">

**[⬆ 返回顶部](#vps-自动化监控工具)**

Made with ❤️ by ClaraCora

</div>
