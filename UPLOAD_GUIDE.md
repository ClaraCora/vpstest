# GitHub 上传指南

本指南帮助你将项目上传到 GitHub 仓库：https://github.com/ClaraCora/vpstest

## 📦 项目文件清单

以下是需要上传的所有文件：

### 核心脚本
- ✅ `auto_install.sh` - 自动化安装脚本（推荐使用）
- ✅ `monitor.sh` - 综合监控脚本
- ✅ `sync_time.sh` - 独立时间同步脚本
- ✅ `check_network.sh` - 独立网络检测脚本
- ✅ `install.sh` - 基础安装脚本

### 文档文件
- ✅ `README.md` - 项目主页说明（已优化）
- ✅ `QUICKSTART.md` - 快速使用指南
- ✅ `CHANGELOG.md` - 更新日志
- ✅ `CONTRIBUTING.md` - 贡献指南
- ✅ `crontab_config.txt` - Crontab配置说明

### 配置文件
- ✅ `LICENSE` - MIT许可证
- ✅ `.gitignore` - Git忽略配置

### 不需要上传的文件
- ❌ `README_OLD.md` - 旧版README（已废弃）
- ❌ `*.log` - 日志文件
- ❌ `crontab_backup_*.txt` - Crontab备份

## 🚀 方法一：通过 GitHub 网页上传（推荐新手）

### 步骤：

1. **访问仓库**
   - 打开 https://github.com/ClaraCora/vpstest

2. **上传文件**
   - 点击 "Add file" → "Upload files"
   - 将所有文件拖拽到上传区域（除了不需要上传的文件）

3. **提交更改**
   - 在底部填写提交信息：
     ```
     Initial commit: VPS监控工具 v1.0.0

     - 时间同步功能
     - 网络连通性检测
     - 自动化部署脚本
     - 完整文档
     ```
   - 点击 "Commit changes"

## 🔧 方法二：通过 Git 命令行上传（推荐有经验用户）

### 前提条件：
- 已安装 Git
- 已配置 GitHub 凭证

### 步骤：

```bash
# 1. 进入项目目录
cd /root/test

# 2. 初始化 Git 仓库
git init

# 3. 添加远程仓库
git remote add origin https://github.com/ClaraCora/vpstest.git

# 4. 创建 .gitignore（已完成）
# cat .gitignore  # 检查内容

# 5. 添加文件到暂存区
git add auto_install.sh
git add monitor.sh
git add sync_time.sh
git add check_network.sh
git add install.sh
git add README.md
git add QUICKSTART.md
git add CHANGELOG.md
git add CONTRIBUTING.md
git add crontab_config.txt
git add LICENSE
git add .gitignore

# 或者一次性添加所有文件（会自动排除.gitignore中的文件）
git add .

# 6. 查看状态
git status

# 7. 提交更改
git commit -m "Initial commit: VPS监控工具 v1.0.0

- 时间同步功能（阿里云+百度源）
- 网络连通性检测（自动重启）
- 自动化部署脚本
- 完整文档和使用指南"

# 8. 推送到 GitHub
git branch -M main
git push -u origin main
```

### 如果遇到认证问题：

```bash
# 使用 Personal Access Token
# 1. GitHub上生成 Token: Settings → Developer settings → Personal access tokens
# 2. 使用 Token 作为密码

# 或者使用 SSH
# 1. 生成 SSH 密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. 添加公钥到 GitHub
cat ~/.ssh/id_ed25519.pub
# 复制输出，添加到 GitHub: Settings → SSH and GPG keys

# 3. 修改远程仓库地址
git remote set-url origin git@github.com:ClaraCora/vpstest.git
```

## 📝 方法三：打包后本地上传

### 创建压缩包：

```bash
# 进入项目目录
cd /root/test

# 创建要上传的文件列表
cat > /tmp/upload_files.txt << 'EOF'
auto_install.sh
monitor.sh
sync_time.sh
check_network.sh
install.sh
README.md
QUICKSTART.md
CHANGELOG.md
CONTRIBUTING.md
crontab_config.txt
LICENSE
.gitignore
EOF

# 创建tar.gz压缩包
tar -czf /root/vpstest-v1.0.0.tar.gz \
  auto_install.sh \
  monitor.sh \
  sync_time.sh \
  check_network.sh \
  install.sh \
  README.md \
  QUICKSTART.md \
  CHANGELOG.md \
  CONTRIBUTING.md \
  crontab_config.txt \
  LICENSE \
  .gitignore

# 或创建zip压缩包
zip -r /root/vpstest-v1.0.0.zip \
  auto_install.sh \
  monitor.sh \
  sync_time.sh \
  check_network.sh \
  install.sh \
  README.md \
  QUICKSTART.md \
  CHANGELOG.md \
  CONTRIBUTING.md \
  crontab_config.txt \
  LICENSE \
  .gitignore

echo "压缩包已创建："
ls -lh /root/vpstest-v1.0.0.*
```

然后：
1. 下载压缩包到本地
2. 解压
3. 通过网页上传到 GitHub

## ✅ 上传后的检查清单

上传完成后，在 GitHub 页面检查：

- [ ] README.md 正确显示（带徽章和格式）
- [ ] 所有脚本文件都存在
- [ ] LICENSE 文件存在
- [ ] .gitignore 文件存在
- [ ] 文档文件都能正常查看
- [ ] 项目描述已填写
- [ ] Topics 标签已添加（建议：linux, monitoring, vps, bash, automation）

## 🏷️ 创建第一个 Release

上传完成后，建议创建 v1.0.0 release：

1. 访问 https://github.com/ClaraCora/vpstest/releases
2. 点击 "Create a new release"
3. 填写信息：
   - Tag: `v1.0.0`
   - Title: `VPS监控工具 v1.0.0`
   - Description: 复制 CHANGELOG.md 中 v1.0.0 的内容
4. 点击 "Publish release"

## 📌 推荐的仓库设置

### 1. 添加项目描述
在仓库页面点击"设置"图标，添加：
```
轻量级Linux VPS自动化监控工具 - 时间同步 + 网络检测
```

### 2. 添加 Topics
```
linux
monitoring
vps
bash
shell-script
automation
network-monitoring
time-sync
server-monitoring
```

### 3. 启用 GitHub Pages（可选）
如果想要项目主页：
- Settings → Pages
- Source: Deploy from a branch
- Branch: main, /root

## 🎯 下一步

上传完成后可以：

1. **编写更详细的文档**
2. **添加 GitHub Actions**（自动化测试）
3. **创建 Wiki 页面**
4. **设置 Issue 模板**
5. **添加徽章**（构建状态、下载量等）

## 💡 提示

- 首次上传建议使用网页方式，更直观
- 后续更新使用 Git 命令行更高效
- 记得在每次重大更新时创建新的 Release
- 保持 CHANGELOG.md 更新

## 📞 需要帮助？

如果遇到问题：
1. 查看 GitHub 官方文档
2. 搜索相关错误信息
3. 在项目 Issues 中提问

---

祝上传顺利！ 🎉
