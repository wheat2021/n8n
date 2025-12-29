# n8n 文档索引

本目录包含 n8n 部署和维护的相关文档。

## 📚 文档列表

### 核心文档

- **[架构说明](./architecture.md)** - n8n 项目的整体架构和技术栈
- **[组件说明](./components.md)** - Docker Compose 中各组件的关系和配置
- **[部署指南](./deployment.md)** - n8n 的部署流程和配置说明
- **[维护指南](./maintenance.md)** - 日常维护和更新操作

### 访问和安全

- **[IP 地址访问解决方案](./ip-access-solution.md)** ⭐ **重要**
  - 问题：通过 IP 地址访问 n8n 时的 `crypto.randomUUID()` 错误
  - 当前方案：SSH 隧道
  - 生产方案：域名 + HTTPS
  
- **[SSH 隧道使用指南](./ssh-tunnel-guide.md)** - 详细的 SSH 隧道配置和使用说明

- **[SSH GitHub 访问](./ssh-github-access.md)** - 配置 n8n 节点使用 SSH 访问 GitHub

### 故障排查

- **[故障排查指南](./troubleshooting.md)** - 常见问题和解决方案

## 🚀 快速开始

### 本地访问 n8n

**当前推荐方式：SSH 隧道**

```bash
# 在本地电脑运行
ssh -L 5678:localhost:5678 你的用户名@160.13.4.23

# 然后在浏览器访问
http://localhost:5678
```

详见：[SSH 隧道使用指南](./ssh-tunnel-guide.md)

### 为什么不能直接通过 IP 访问？

浏览器的安全策略要求 `crypto.randomUUID()` API 只能在安全上下文（HTTPS 或 localhost）下使用。通过 `http://160.13.4.23:5678` 访问会导致 n8n 前端初始化失败。

详见：[IP 地址访问解决方案](./ip-access-solution.md)

## 📖 文档使用指南

### 日常使用

1. **启动 n8n**：参考 [部署指南](./deployment.md)
2. **访问 n8n**：参考 [SSH 隧道使用指南](./ssh-tunnel-guide.md)
3. **维护更新**：参考 [维护指南](./maintenance.md)

### 遇到问题

1. 查看 [故障排查指南](./troubleshooting.md)
2. 查看 [IP 地址访问解决方案](./ip-access-solution.md)
3. 检查 Docker 日志：`docker-compose logs -f n8n`

### 生产部署

如果需要升级到生产环境（团队使用、多设备访问），参考：
- [IP 地址访问解决方案 - 生产环境部署方案](./ip-access-solution.md#生产环境部署方案)

## 🔧 配置文件

### 主要配置

- `docker-compose.yml` - Docker Compose 配置文件
- `.env` - 环境变量配置

### 当前配置状态

- **访问方式**：SSH 隧道
- **监听地址**：`127.0.0.1:5678`（仅本地）
- **协议**：HTTP
- **Webhook URL**：`http://localhost:5678/`

## 📝 维护记录

### 2024-12-24

- **问题**：通过 IP 地址访问时出现 `crypto.randomUUID()` 错误
- **解决方案**：采用 SSH 隧道方案
- **配置变更**：
  - 移除 Caddy 反向代理配置
  - 恢复 n8n 直接监听 localhost:5678
  - 更新环境变量为 HTTP 协议
- **文档更新**：
  - 创建 [IP 地址访问解决方案](./ip-access-solution.md)
  - 创建 [SSH 隧道使用指南](./ssh-tunnel-guide.md)
  - 删除临时故障排查文档

## 🔗 相关资源

### 官方文档

- [n8n 官方文档](https://docs.n8n.io/)
- [n8n GitHub](https://github.com/n8n-io/n8n)
- [n8n 社区论坛](https://community.n8n.io/)

### 官方配置示例

- [n8n Docker Caddy 示例](https://github.com/n8n-io/n8n-docker-caddy) - 生产环境 HTTPS 配置参考

## 💡 提示

- 📌 **重要**：当前使用 SSH 隧道方案，适合个人使用
- 🚀 **升级**：如需团队协作，考虑升级到域名 + HTTPS 方案
- 🔒 **安全**：定期更新 n8n 版本和依赖
- 📊 **监控**：定期检查 Docker 容器状态和日志

---

**最后更新**：2024-12-24  
**维护者**：Terry Chen
