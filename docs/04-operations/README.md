# 运维手册

本部分文档包含 n8n 的运维相关内容，包括日常维护、监控、故障排查等。

## 📖 文档列表

### 🛠️ 维护

- **[日常维护指南](./maintenance.md)** - n8n Docker 部署的日常运维操作
  - 服务重启和健康检查
  - 定期维护任务
  - 自动化配置（健康检查、备份）
  - 资源配置优化
  - 性能优化
  - 监控指标

### 🔧 [故障排查](./troubleshooting/)

常见问题的诊断和解决方案：

- **[常见问题处理](./troubleshooting/common-issues.md)** - Docker 部署的常见问题
  - 数据库连接异常（503 错误）
  - 服务性能下降
  - 数据持久化问题
  - 服务无法启动
  - 故障恢复流程

- **[IP 访问问题](./troubleshooting/ip-access.md)** - Web Crypto API 安全上下文问题
  - 问题根本原因分析
  - SSH 隧道解决方案
  - HTTPS 部署方案
  - 问题排查历史

## 🎯 运维要点

### 日常运维

#### 健康检查

定期检查服务健康状态：

```bash
# PostgreSQL
docker-compose exec postgres pg_isready -U n8n_admin -d n8n

# Redis
docker-compose exec redis redis-cli ping

# n8n
curl http://localhost:5678/healthz
```

#### 备份策略

- **数据库备份**: 每天自动备份 PostgreSQL
- **配置备份**: 备份 n8n 数据卷
- **保留策略**: 保留最近 7 天的备份

#### 监控指标

关键指标监控：

- CPU 使用率（阈值: 80%）
- 内存使用率（阈值: 85%）
- 磁盘使用率（阈值: 80%）
- PostgreSQL 连接数（阈值: 150）
- Redis 队列长度（阈值: 1000）

### 性能优化

#### 数据库优化

- 调整 PostgreSQL 参数（shared_buffers、max_connections）
- 优化数据库连接池大小
- 定期清理执行历史数据

#### Worker 扩展

根据负载调整 worker 数量：

- 轻量负载 (< 100 执行/小时): 1 worker
- 中等负载 (100-500 执行/小时): 2-3 workers
- 高负载 (> 500 执行/小时): 4+ workers

## 🚨 故障处理流程

### 快速诊断流程

1. **检查服务状态**
   ```bash
   docker-compose ps
   ```

2. **查看日志**
   ```bash
   docker-compose logs --tail 50
   ```

3. **执行健康检查**
   ```bash
   ./health-check.sh
   ```

4. **尝试重启**
   ```bash
   ./restart-n8n.sh
   ```

### 常见问题快速链接

- [数据库 503 错误](./troubleshooting/common-issues.md#场景-1-数据库连接异常-503-错误) → 重启服务
- [IP 地址无法访问](./troubleshooting/ip-access.md) → 使用 SSH 隧道
- [性能下降](./troubleshooting/common-issues.md#场景-2-服务性能下降) → 检查资源使用
- [服务无法启动](./troubleshooting/common-issues.md#场景-4-服务无法启动) → 检查端口和配置

## 📊 运维最佳实践

### 1. 自动化

- 配置定时健康检查（每 5 分钟）
- 配置自动备份（每天凌晨 2 点）
- 配置日志轮转（保留 7 天）

### 2. 监控

- 使用 Prometheus + Grafana 监控
- 配置告警规则
- 设置告警通知（邮件/Slack）

### 3. 安全

- 使用强密码
- 网络隔离（仅暴露必要端口）
- 启用 HTTPS
- 定期更新镜像

### 4. 备份

- 定期备份数据库
- 异地存储备份文件
- 定期测试恢复流程

## 🔗 相关资源

- [部署指南](../03-guides/deployment/) - 了解如何部署
- [架构设计](../02-architecture/) - 了解系统架构
- [n8n 官方文档](https://docs.n8n.io/hosting/)

## 📝 贡献

如果你遇到新的问题或有改进建议：

1. 使用 [故障排查模板](../_templates/troubleshooting-template.md)
2. 记录问题和解决方案
3. 更新本索引文件

详见 [文档贡献指南](../CONTRIBUTING.md)。

---

[← 返回文档首页](../README.md)
