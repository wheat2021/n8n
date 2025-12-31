# 操作指南

本部分包含 n8n 的各类操作指南，涵盖部署、配置和集成等主题。

## 📖 文档分类

### 🚀 [部署指南](./deployment/)

如何在不同环境中部署 n8n：

- **[Docker Compose 部署](./deployment/docker-compose.md)** - 使用 Docker Compose 部署完整的 n8n 环境
  - 架构说明（PostgreSQL + Redis + n8n + worker）
  - 快速开始
  - 环境变量配置
  - 常用命令
  - 故障排查
  - 运维最佳实践

**即将添加：**
- Kubernetes 部署指南
- 云平台部署（AWS、Azure、GCP）
- 单容器部署

### ⚙️ [配置指南](./configuration/)

如何配置 n8n 的各项功能：

- **[SSH 隧道配置](./configuration/ssh-tunnel.md)** - 通过 SSH 隧道安全访问远程 n8n
  - 命令行 SSH 隧道
  - SSH config 配置
  - 自动重连脚本
  - 常见问题

**即将添加：**
- 环境变量配置
- 认证配置（LDAP、SAML、OAuth）
- Webhook 配置
- 自定义域名和 HTTPS

### 🔌 [集成指南](./integration/)

如何将 n8n 与其他系统集成：

- **[GitHub SSH 集成](./integration/github-ssh.md)** - 配置 n8n 访问 GitHub 仓库
  - SSH 密钥挂载
  - Git 配置
  - 验证和测试
  - 安全注意事项

**即将添加：**
- Slack 集成
- 数据库集成
- 云存储集成
- 自定义节点开发

## 🎯 快速导航

### 我想...

**部署 n8n**
→ [Docker Compose 部署指南](./deployment/docker-compose.md)

**远程访问 n8n**
→ [SSH 隧道配置](./configuration/ssh-tunnel.md)

**在工作流中使用 Git**
→ [GitHub SSH 集成](./integration/github-ssh.md)

**解决部署问题**
→ [常见问题处理](../04-operations/troubleshooting/common-issues.md)

## 📝 贡献指南

如果你想添加新的操作指南：

1. 选择合适的子分类（deployment / configuration / integration）
2. 使用 [操作指南模板](../_templates/guide-template.md)
3. 遵循文档规范
4. 更新本索引文件

详见 [文档贡献指南](../CONTRIBUTING.md)。

---

[← 返回文档首页](../README.md)
