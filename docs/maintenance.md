# n8n Docker 维护指南

## 日常维护操作

### 服务重启

使用维护脚本安全重启服务：

```bash
./restart-n8n.sh
```

### 健康检查

#### PostgreSQL 健康检查
```bash
docker-compose exec postgres pg_isready -U n8n_admin -d n8n
```

#### Redis 健康检查
```bash
docker-compose exec redis redis-cli ping
```

#### n8n 健康检查
```bash
curl http://localhost:5678/healthz
```

### 查看服务状态

```bash
# 查看所有服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f postgres
docker-compose logs -f n8n
docker-compose logs -f redis
```

## 定期维护任务

### 每周维护

1. **检查服务日志错误**
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

### 每月维护

1. **清理 Docker 资源**
   ```bash
   # 清理未使用的镜像和容器
   docker system prune -f

   # 清理未使用的数据卷 (谨慎操作!)
   docker volume prune -f
   ```

2. **更新镜像**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

3. **验证备份**
   - 测试从最新备份恢复数据

## 自动化配置

### 自动健康检查

创建健康检查脚本并配置定时任务：

```bash
# 创建健康检查脚本
cp /path/to/health-check.sh ~/bin/n8n-health-check.sh
chmod +x ~/bin/n8n-health-check.sh

# 配置 crontab - 每 5 分钟检查一次
*/5 * * * * ~/bin/n8n-health-check.sh >> /var/log/n8n-health.log 2>&1
```

### 自动备份

配置每日自动备份：

```bash
# 创建备份脚本
cp /path/to/backup-n8n.sh ~/bin/n8n-backup.sh
chmod +x ~/bin/n8n-backup.sh

# 每天凌晨 2 点自动备份
0 2 * * * ~/bin/n8n-backup.sh >> /var/log/n8n-backup.log 2>&1
```

## 资源配置

### Docker Desktop 资源分配

打开 Docker Desktop → Settings → Resources，建议配置：

- **内存**: 至少 4GB (推荐 8GB)
- **CPU**: 至少 2 核 (推荐 4 核)
- **磁盘**: 至少 60GB

### PostgreSQL 配置

在 `docker-compose.yml` 中的关键配置：

```yaml
postgres:
  shm_size: 256mb
  command: >
    postgres
    -c shared_buffers=256MB
    -c max_connections=200
    -c fsync=on
    -c synchronous_commit=on
    -c full_page_writes=on
    -c wal_level=replica
  healthcheck:
    interval: 10s
    timeout: 10s
    retries: 5
    start_period: 30s
```

### n8n 数据库连接配置

关键环境变量：

```yaml
environment:
  - DB_POSTGRESDB_POOL_SIZE=10
  - DB_LOGGING_ENABLED=false
  - DB_LOGGING_MAX_EXECUTION_TIME=0
```

## 性能优化

### Worker 数量调整

根据负载调整 worker 数量：

- **轻量负载** (< 100 执行/小时): 1 worker
- **中等负载** (100-500 执行/小时): 2-3 workers
- **高负载** (> 500 执行/小时): 4+ workers

### 数据库连接池优化

- 监控连接数使用情况
- 根据需要调整 `DB_POSTGRESDB_POOL_SIZE`

### 日志轮转配置

- 避免日志文件占满磁盘
- 使用 logrotate 或 Docker 日志驱动

## 监控指标

建议监控以下指标：

| 指标 | 阈值 | 操作 |
|------|------|------|
| CPU 使用率 | > 80% | 增加 CPU 核心数 |
| 内存使用率 | > 85% | 增加内存或优化配置 |
| 磁盘使用率 | > 80% | 清理或扩容 |
| PostgreSQL 连接数 | > 150 | 增加 max_connections |
| Redis 队列长度 | > 1000 | 增加 worker 数量 |

## 相关资源

- [问题处理指南](./troubleshooting.md) - 常见问题诊断和解决方案
- [DOCKER_COMPOSE_README.md](./DOCKER_COMPOSE_README.md) - 完整部署指南
- [n8n 官方文档](https://docs.n8n.io)

## 技术支持

- n8n 社区: https://community.n8n.io
- GitHub Issues: https://github.com/n8n-io/n8n/issues
