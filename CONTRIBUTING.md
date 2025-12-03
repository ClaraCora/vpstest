# 贡献指南

感谢你考虑为 VPS 自动化监控工具做出贡献！

## 行为准则

本项目遵循贡献者公约。参与本项目即表示你同意遵守其条款。

## 如何贡献

### 报告 Bug

在提交 Bug 报告之前，请：

1. **检查现有 Issues** - 确保该问题尚未被报告
2. **使用最新版本** - 确认问题在最新版本中仍然存在
3. **提供详细信息** - 包含以下内容：
   - 操作系统版本
   - 相关日志输出
   - 复现步骤
   - 预期行为
   - 实际行为

### 提交 Issue 模板

```markdown
**环境信息**
- 操作系统: [如 Ubuntu 20.04]
- 脚本版本: [如 v1.0.0]
- 安装方式: [自动/手动]

**问题描述**
清晰简洁地描述问题

**复现步骤**
1. 执行 '...'
2. 查看 '...'
3. 发生错误 '...'

**预期行为**
描述你期望发生什么

**实际行为**
描述实际发生了什么

**日志输出**
```bash
# 粘贴相关日志
```

**截图**
如果适用，添加截图帮助解释问题

**额外信息**
其他任何相关信息
```

### 提交功能请求

功能请求同样欢迎！请提供：

1. **使用场景** - 为什么需要这个功能？
2. **建议方案** - 你认为应该如何实现？
3. **替代方案** - 是否考虑过其他方法？

## 开发流程

### 1. Fork 项目

点击 GitHub 页面右上角的 "Fork" 按钮

### 2. 克隆仓库

```bash
git clone https://github.com/your-username/vpstest.git
cd vpstest
```

### 3. 创建分支

```bash
git checkout -b feature/amazing-feature
# 或
git checkout -b fix/bug-description
```

分支命名规范：
- `feature/` - 新功能
- `fix/` - Bug 修复
- `docs/` - 文档更新
- `refactor/` - 代码重构
- `test/` - 测试相关

### 4. 进行更改

#### 代码规范

**Shell 脚本规范：**

```bash
# 文件头部注释
#!/bin/bash
#
# 脚本简短描述
# 作者: Your Name
# 日期: YYYY-MM-DD
#

# 使用严格模式（适用时）
set -euo pipefail

# 函数注释
# 函数描述
# 参数: $1 - 参数说明
# 返回: 返回值说明
function_name() {
    local param=$1
    # 函数实现
}

# 变量命名使用大写
CONSTANT_VALUE="value"
LOCAL_VAR="local_value"

# 使用有意义的变量名
log_dir="/var/log/monitor"  # 好
d="/var/log/monitor"        # 不好
```

**日志规范：**

```bash
# 使用统一的日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "INFO: 操作成功"
log "WARN: 警告信息"
log "ERROR: 错误信息"
```

#### 测试要求

在提交前请测试：

```bash
# 语法检查
bash -n script.sh

# 在测试环境运行
./script.sh

# 检查日志输出
tail -f /var/log/monitor/monitor.log
```

支持的测试环境：
- Debian 11/12
- Ubuntu 20.04/22.04
- CentOS 7/8
- RHEL 7/8

### 5. 提交更改

```bash
# 添加更改
git add .

# 提交（使用清晰的提交信息）
git commit -m "feat: 添加自定义时间源支持"
```

#### 提交信息规范

格式: `<type>: <subject>`

**Type 类型：**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构（既不是新功能也不是修复）
- `test`: 测试相关
- `chore`: 构建/工具链更新

**示例：**
```
feat: 添加邮件告警功能
fix: 修复网络检测误报问题
docs: 更新安装文档
style: 统一代码缩进格式
refactor: 优化日志记录函数
test: 添加单元测试
chore: 更新依赖版本
```

### 6. 推送到 GitHub

```bash
git push origin feature/amazing-feature
```

### 7. 创建 Pull Request

1. 访问你的 Fork 仓库
2. 点击 "New Pull Request"
3. 填写 PR 描述模板
4. 等待代码审查

#### Pull Request 模板

```markdown
## 更改说明

简要描述本 PR 的更改内容

## 更改类型

- [ ] 新功能
- [ ] Bug 修复
- [ ] 文档更新
- [ ] 代码重构
- [ ] 其他（请说明）

## 测试情况

- [ ] 已通过语法检查
- [ ] 已在测试环境运行
- [ ] 已测试主要功能
- [ ] 已查看日志输出

**测试环境：**
- 操作系统:
- 版本:

## 相关 Issue

关联 Issue: #issue_number

## 检查清单

- [ ] 代码遵循项目规范
- [ ] 已添加必要的注释
- [ ] 已更新相关文档
- [ ] 无语法错误
- [ ] 已测试所有更改
- [ ] 提交信息清晰明确

## 截图（如适用）

添加截图或日志输出
```

## 代码审查流程

提交 PR 后：

1. **自动检查** - GitHub Actions 将运行自动检查
2. **代码审查** - 维护者将审查你的代码
3. **讨论修改** - 根据反馈进行必要的修改
4. **合并** - 审查通过后将被合并到主分支

## 开发建议

### 调试技巧

```bash
# 启用调试模式
bash -x script.sh

# 检查特定行
set -x  # 开启调试
# 代码
set +x  # 关闭调试
```

### 日志管理

```bash
# 实时查看日志
tail -f /var/log/monitor/monitor.log

# 搜索错误
grep "ERROR" /var/log/monitor/monitor.log

# 查看最近的执行
tail -100 /var/log/monitor/monitor.log
```

### 测试 Crontab

```bash
# 不要等待定时任务，直接测试
/root/test/monitor.sh

# 检查crontab是否正确
crontab -l

# 查看cron日志
tail -f /var/log/syslog | grep CRON
```

## 文档贡献

文档改进同样重要！

- 修正拼写错误
- 改进说明清晰度
- 添加使用示例
- 翻译文档

## 问题讨论

有疑问？欢迎通过以下方式讨论：

- 提交 Issue
- 在 PR 中评论
- Discussions 板块

## 版本发布

项目维护者负责版本发布：

1. 更新 CHANGELOG.md
2. 更新版本号
3. 创建 Git Tag
4. 发布 GitHub Release

## 致谢

所有贡献者都将列在 README.md 的致谢部分。

## 许可

提交贡献即表示你同意按照项目的 MIT 许可证授权你的贡献。

---

再次感谢你的贡献！ 🎉
