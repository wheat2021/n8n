# n8n Docker 维护摘要

## 问题诊断 (2025-12-08)

### 症状
- 前端访问返回 `{"code":503,"message":"Database is not ready!"}`
- 无法正常访问 n8n 服务

### 根本原因
通过日志分析发现:

1. **PostgreSQL 频繁崩溃**
   - 错误: `server process was terminated by signal 13: Broken pipe`
   - 数据库不断进入恢复模式
   - 非正常关机导致需要执行 WAL 恢复

2. **n8n 数据库连接超时**
   - 日志显示: `timeout exceeded when trying to connect`
   - 由于 PostgreSQL 不稳定,导致连接失败

3. **Docker Desktop 环境问题**
   - macOS 上 Docker 虚拟化可能导致文件系统性能问题
   - 资源限制可能不足

## 修复方案

### 1. 优化 PostgreSQL 配置

在 `docker-compose.yml` 中添加:

```yaml
postgres:
  shm_size: 256mb  # 增加共享内存
  command: >
    postgres
    -c shared_buffers=256MB      # 共享缓冲区
    -c max_connections=200       # 最大连接数
    -c fsync=on                  # 确保数据持久化
    -c synchronous_commit=on     # 同步提交
    -c full_page_writes=on       # 完整页写入
    -c wal_level=replica         # WAL 级别
  healthcheck:
    interval: 10s                # 增加健康检查间隔
    timeout: 10s
    retries: 5
    start_period: 30s            # 启动宽限期
```

### 2. 优化 n8n 数据库连接

添加环境变量:
```yaml
environment:
  - DB_POSTGRESDB_POOL_SIZE=10
  - DB_LOGGING_ENABLED=false
  - DB_LOGGING_MAX_EXECUTION_TIME=0
```

### 3. 创建维护脚本

- **restart-n8n.sh**: 安全重启服务的脚本
- 包含服务停止、等待、启动和健康检查

## 修复结果

✅ 服务成功重启
✅ PostgreSQL 健康检查通过
✅ n8n 前端可访问 (http://localhost:5678)
✅ 健康端点返回: `{"status":"ok"}`

## 后续运维建议

### 立即执行

1. **检查 Docker Desktop 资源分配**
   - 打开 Docker Desktop → Settings → Resources
   - 建议配置:
     - 内存: 至少 4GB (推荐 8GB)
     - CPU: 至少 2 核 (推荐 4 核)
     - 磁盘: 至少 60GB

2. **设置自动健康检查**
   ```bash
   # 创建健康检查脚本
   cp /path/to/health-check.sh ~/bin/n8n-health-check.sh
   chmod +x ~/bin/n8n-health-check.sh

   # 配置 crontab
   */5 * * * * ~/bin/n8n-health-check.sh >> /var/log/n8n-health.log 2>&1
   ```

3. **配置自动备份**
   ```bash
   # 创建备份脚本
   cp /path/to/backup-n8n.sh ~/bin/n8n-backup.sh
   chmod +x ~/bin/n8n-backup.sh

   # 每天凌晨 2 点自动备份
   0 2 * * * ~/bin/n8n-backup.sh >> /var/log/n8n-backup.log 2>&1
   ```

### 定期维护 (每周)

1. **检查服务日志**
   ```bash
   docker-compose logs --tail 100 postgres | grep -i error
   docker-compose logs --tail 100 n8n | grep -i error
   ```

2. **监控资源使用**
   ```bash
   docker stats --no-stream
   ```

3. **检查磁盘空间**
   ```bash
   docker system df
   ```

### 定期维护 (每月)

1. **清理 Docker 资源**
   ```bash
   # 清理未使用的镜像和容器
   docker system prune -f

   # 清理未使用的数据卷 (谨慎!)
   docker volume prune -f
   ```

2. **更新镜像**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

3. **验证备份**
   - 测试从最新备份恢复数据

### 监控指标

建议监控以下指标:

| 指标 | 阈值 | 操作 |
|------|------|------|
| CPU 使用率 | > 80% | 增加 CPU 核心数 |
| 内存使用率 | > 85% | 增加内存或优化配置 |
| 磁盘使用率 | > 80% | 清理或扩容 |
| PostgreSQL 连接数 | > 150 | 增加 max_connections |
| Redis 队列长度 | > 1000 | 增加 worker 数量 |

### 性能优化建议

1. **根据负载调整 worker 数量**
   - 轻量负载 (< 100 执行/小时): 1 worker
   - 中等负载 (100-500 执行/小时): 2-3 workers
   - 高负载 (> 500 执行/小时): 4+ workers

2. **优化数据库连接池**
   - 监控连接数使用情况
   - 根据需要调整 `DB_POSTGRESDB_POOL_SIZE`

3. **配置日志轮转**
   - 避免日志文件占满磁盘
   - 使用 logrotate 或 Docker 日志驱动

## 故障恢复流程

如果再次遇到 503 错误:

1. **第一步: 快速重启**
   ```bash
   ./restart-n8n.sh
   ```

2. **第二步: 检查日志**
   ```bash
   docker-compose logs postgres --tail 50
   docker-compose logs n8n --tail 50
   ```

3. **第三步: 验证健康状态**
   ```bash
   docker-compose exec postgres pg_isready -U n8n_admin -d n8n
   curl http://localhost:5678/healthz
   ```

4. **第四步: 如果问题持续**
   - 检查 Docker Desktop 资源
   - 考虑增加资源限制
   - 查看系统日志排查底层问题

## 文档资源

- [DOCKER_COMPOSE_README.md](./DOCKER_COMPOSE_README.md) - 完整部署和运维指南
- [restart-n8n.sh](./restart-n8n.sh) - 服务重启脚本
- [n8n 官方文档](https://docs.n8n.io)

## 联系信息

如需技术支持:
- n8n 社区: https://community.n8n.io
- GitHub Issues: https://github.com/n8n-io/n8n/issues
