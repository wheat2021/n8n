# n8n Docker Compose 部署指南

使用 Docker Compose 部署 n8n，包含 PostgreSQL 数据库和 Redis 队列管理系统。

## 架构说明

此配置包含以下服务：

- **PostgreSQL 16**: 持久化数据存储
- **Redis 6**: 任务队列管理（支持分布式执行）
- **n8n 主实例**: Web UI 和 API 服务
- **n8n-worker**: 后台工作流执行器（可水平扩展）

## 快速开始

### 1. 配置环境变量

首次部署前，需要配置环境变量：

```bash
# 复制示例配置文件
cp .env.example .env

# 生成安全的加密密钥
openssl rand -hex 32
```

编辑 `.env` 文件，**必须修改**以下配置：

- `POSTGRES_PASSWORD`: PostgreSQL root 用户密码
- `POSTGRES_NON_ROOT_PASSWORD`: n8n 应用使用的数据库密码
- `ENCRYPTION_KEY`: n8n 加密密钥（用于加密存储的凭证，至少 32 字符）

### 2. 启动服务

```bash
# 启动所有服务（后台运行）
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 3. 访问 n8n

服务启动后，在浏览器中访问：

```
http://localhost:5678
```

首次访问时需要创建管理员账号。

## 常用命令

### 服务管理

```bash
# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose down

# 重启服务
docker-compose restart

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f n8n          # n8n 主实例日志
docker-compose logs -f n8n-worker   # worker 日志
docker-compose logs -f postgres     # PostgreSQL 日志
docker-compose logs -f redis        # Redis 日志
```

### 数据管理

```bash
# 查看数据卷
docker volume ls

# 备份 PostgreSQL 数据
docker-compose exec postgres pg_dump -U n8n_admin n8n > backup.sql

# 恢复 PostgreSQL 数据
docker-compose exec -T postgres psql -U n8n_admin n8n < backup.sql
```

### 健康检查

```bash
# 检查 PostgreSQL 健康状态
docker-compose exec postgres pg_isready -U n8n_admin -d n8n

# 检查 Redis 健康状态
docker-compose exec redis redis-cli ping

# 检查 n8n 健康状态
curl http://localhost:5678/healthz
```

### 扩展 Worker

如需增加工作流处理能力，可以添加更多 worker：

编辑 `docker-compose.yml`，添加：

```yaml
  n8n-worker-2:
    <<: *shared
    command: worker
    depends_on:
      - n8n
```

然后重启服务：

```bash
docker-compose up -d
```

## 环境变量说明

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `POSTGRES_USER` | PostgreSQL root 用户名 | n8n_admin |
| `POSTGRES_PASSWORD` | PostgreSQL root 密码 | **必须修改** |
| `POSTGRES_DB` | 数据库名称 | n8n |
| `POSTGRES_NON_ROOT_USER` | n8n 应用数据库用户 | n8n_user |
| `POSTGRES_NON_ROOT_PASSWORD` | n8n 应用数据库密码 | **必须修改** |
| `ENCRYPTION_KEY` | n8n 加密密钥 | **必须修改** |
| `GENERIC_TIMEZONE` | 时区设置 | Asia/Shanghai |
| `N8N_PORT` | n8n Web 端口 | 5678 |

## 故障排查

### 数据库 503 错误 - "Database is not ready!"

**症状**: n8n 前端返回 `{"code":503,"message":"Database is not ready!"}`

**常见原因**:
1. PostgreSQL 频繁崩溃重启
2. 数据库连接超时
3. macOS Docker Desktop 资源限制或虚拟化问题

**解决方案**:

#### 方法 1: 使用修复脚本（推荐）

```bash
# 使用提供的重启脚本
./restart-n8n.sh
```

#### 方法 2: 手动修复步骤

```bash
# 1. 停止所有服务
docker-compose down

# 2. 等待几秒确保服务完全停止
sleep 5

# 3. 重新启动服务
docker-compose up -d

# 4. 监控 PostgreSQL 启动日志
docker-compose logs -f postgres

# 5. 检查服务状态
docker-compose ps
```

#### 方法 3: 检查 Docker Desktop 资源

如果问题持续存在,检查 Docker Desktop 设置:

1. 打开 Docker Desktop → Settings → Resources
2. 增加以下资源:
   - **内存 (Memory)**: 至少 4GB (推荐 8GB)
   - **CPU**: 至少 2 核心 (推荐 4 核心)
   - **磁盘空间**: 至少 60GB
   - **Swap**: 至少 1GB
3. 点击 "Apply & Restart"

#### 方法 4: 清理并重建（数据会丢失）

**⚠️ 警告: 此方法会删除所有数据！仅在其他方法失败时使用**

```bash
# 停止并删除所有容器和卷
docker-compose down -v

# 重新启动
docker-compose up -d
```

### PostgreSQL 频繁重启问题

**症状**: 日志显示 "server process was terminated by signal 13: Broken pipe"

**解决方案**:
1. 配置已优化 PostgreSQL 参数以提高稳定性
2. 增加共享内存: `shm_size: 256mb`
3. 调整健康检查参数,增加 `start_period`
4. 确保 Docker Desktop 有足够资源

### 服务无法启动

1. 检查端口是否被占用：
   ```bash
   lsof -i :5678  # n8n
   lsof -i :5432  # PostgreSQL
   lsof -i :6379  # Redis
   ```

2. 查看服务日志：
   ```bash
   docker-compose logs
   ```

### 数据库连接失败

1. 确认 PostgreSQL 服务已启动并健康：
   ```bash
   docker-compose ps postgres
   ```

2. 检查环境变量配置是否正确（用户名、密码、数据库名）

3. 查看 PostgreSQL 日志：
   ```bash
   docker-compose logs postgres
   ```

### n8n 无法访问

1. 确认所有依赖服务（PostgreSQL、Redis）都已健康运行：
   ```bash
   docker-compose ps
   ```

2. 检查防火墙设置是否允许访问端口 5678

3. 查看 n8n 日志寻找错误信息：
   ```bash
   docker-compose logs n8n
   ```

### 加密密钥错误

如果看到加密相关的错误,说明 `ENCRYPTION_KEY` 未正确设置或已更改。

**警告**: 更改加密密钥后,之前保存的所有凭证将无法解密！

## 数据持久化

以下数据通过 Docker 数据卷持久化：

- `db_storage`: PostgreSQL 数据
- `redis_storage`: Redis 数据
- `n8n_storage`: n8n 配置和工作流数据

即使容器被删除，这些数据仍会保留。如需完全清理：

```bash
# 停止并删除容器和数据卷
docker-compose down -v
```

**警告**: 此操作会永久删除所有数据！

## 运维最佳实践

### 日常运维

#### 1. 健康检查脚本

创建定时任务检查服务健康状态:

```bash
#!/bin/bash
# 保存为 health-check.sh

# 检查 PostgreSQL
if ! docker-compose exec postgres pg_isready -U n8n_admin -d n8n > /dev/null 2>&1; then
    echo "❌ PostgreSQL 不健康，正在重启..."
    docker-compose restart postgres
fi

# 检查 Redis
if ! docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
    echo "❌ Redis 不健康，正在重启..."
    docker-compose restart redis
fi

# 检查 n8n
if ! curl -f http://localhost:5678/healthz > /dev/null 2>&1; then
    echo "❌ n8n 不健康，正在重启..."
    docker-compose restart n8n
fi

echo "✅ 所有服务健康"
```

配置 crontab 定时执行:
```bash
# 每 5 分钟检查一次
*/5 * * * * /path/to/health-check.sh >> /var/log/n8n-health.log 2>&1
```

#### 2. 自动备份

创建定时备份脚本:

```bash
#!/bin/bash
# 保存为 backup-n8n.sh

BACKUP_DIR="/path/to/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份 PostgreSQL
docker-compose exec -T postgres pg_dump -U n8n_admin n8n | gzip > "$BACKUP_DIR/n8n_db_$DATE.sql.gz"

# 备份 n8n 数据卷
docker run --rm -v n8n_n8n_storage:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/n8n_storage_$DATE.tar.gz -C /data .

# 删除 7 天前的备份
find "$BACKUP_DIR" -name "*.gz" -mtime +7 -delete

echo "✅ 备份完成: $DATE"
```

配置定时备份:
```bash
# 每天凌晨 2 点备份
0 2 * * * /path/to/backup-n8n.sh >> /var/log/n8n-backup.log 2>&1
```

#### 3. 日志管理

配置日志轮转,避免日志文件过大:

```bash
# /etc/logrotate.d/n8n
/var/log/n8n-*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
```

#### 4. 监控告警

使用 Prometheus + Grafana 监控:

```yaml
# 在 docker-compose.yml 中添加
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
```

### 性能优化

#### 1. PostgreSQL 调优

根据工作负载调整 PostgreSQL 参数:

```yaml
# docker-compose.yml 中的 postgres 服务
command: >
  postgres
  -c shared_buffers=256MB           # 共享缓冲区
  -c max_connections=200            # 最大连接数
  -c effective_cache_size=1GB       # 有效缓存大小
  -c work_mem=8MB                   # 工作内存
  -c maintenance_work_mem=64MB      # 维护工作内存
  -c checkpoint_completion_target=0.9
  -c wal_buffers=16MB
  -c random_page_cost=1.1
```

#### 2. Worker 扩展策略

根据工作流执行量动态调整 worker:

- **轻量负载** (< 100 执行/小时): 1 个 worker
- **中等负载** (100-500 执行/小时): 2-3 个 worker
- **高负载** (> 500 执行/小时): 4+ 个 worker

监控队列长度:
```bash
docker-compose exec redis redis-cli llen bull:workflow:waiting
```

#### 3. 数据库连接池

调整 n8n 数据库连接池大小:

```yaml
environment:
  - DB_POSTGRESDB_POOL_SIZE=10  # 默认
  # 高负载时增加:
  - DB_POSTGRESDB_POOL_SIZE=20
```

### 安全加固

#### 1. 网络隔离

创建专用网络,限制外部访问:

```yaml
# docker-compose.yml
networks:
  n8n_network:
    driver: bridge

services:
  postgres:
    networks:
      - n8n_network
    # 移除 ports，仅内部访问

  redis:
    networks:
      - n8n_network
    # 移除 ports，仅内部访问

  n8n:
    networks:
      - n8n_network
    ports:
      - "127.0.0.1:5678:5678"  # 仅本地访问
```

#### 2. HTTPS 配置

使用 Caddy 反向代理:

```yaml
# docker-compose.yml
  caddy:
    image: caddy:2
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - n8n_network
```

```
# Caddyfile
n8n.yourdomain.com {
    reverse_proxy n8n:5678
}
```

#### 3. 定期更新

保持镜像最新:

```bash
# 更新所有镜像
docker-compose pull

# 重新创建容器
docker-compose up -d
```

### 故障恢复

#### 快速恢复流程

1. **从备份恢复数据库**:
```bash
# 停止服务
docker-compose down

# 恢复数据库
gunzip < backup.sql.gz | docker-compose exec -T postgres psql -U n8n_admin n8n

# 重启服务
docker-compose up -d
```

2. **恢复 n8n 数据**:
```bash
# 恢复数据卷
docker run --rm -v n8n_n8n_storage:/data -v /path/to/backup:/backup alpine tar xzf /backup/n8n_storage_backup.tar.gz -C /data
```

### 容量规划

根据使用情况调整资源:

| 执行量/月 | CPU | 内存 | 磁盘 | Workers |
|-----------|-----|------|------|---------|
| < 10k     | 2核 | 4GB  | 20GB | 1       |
| 10k-50k   | 4核 | 8GB  | 50GB | 2-3     |
| 50k-200k  | 8核 | 16GB | 100GB| 4-6     |
| > 200k    | 16核| 32GB | 200GB| 8+      |

## 生产环境建议

1. **安全性**:
   - 修改所有默认密码
   - 使用强密码（至少 16 字符,包含大小写字母、数字和特殊字符）
   - 考虑使用 Docker secrets 管理敏感信息
   - 配置网络隔离,仅暴露必要端口
   - 启用 HTTPS

2. **备份**:
   - 定期备份 PostgreSQL 数据库（建议每天）
   - 备份 n8n 数据卷（工作流定义和配置）
   - 异地存储备份文件
   - 定期测试备份恢复流程

3. **监控**:
   - 监控服务健康状态（健康检查间隔 5 分钟）
   - 监控 PostgreSQL 和 Redis 资源使用情况
   - 配置日志收集和轮转
   - 设置告警（CPU、内存、磁盘、服务状态）

4. **高可用**:
   - 考虑 PostgreSQL 主从复制
   - 使用负载均衡器分发请求
   - 配置多个 worker 实例
   - 实施故障自动恢复机制

5. **性能**:
   - 根据负载调整数据库参数
   - 优化数据库连接池大小
   - 监控并调整 worker 数量
   - 定期清理执行历史数据

## 更多信息

- [n8n 官方文档](https://docs.n8n.io)
- [n8n Docker 部署](https://docs.n8n.io/hosting/installation/docker/)
- [n8n 托管示例](https://github.com/n8n-io/n8n-hosting)
