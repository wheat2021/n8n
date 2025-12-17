# n8n Docker 问题处理指南

## 场景 1: 数据库连接异常 (503 错误)

### 问题症状

- 前端访问返回 `{"code":503,"message":"Database is not ready!"}`
- 无法正常访问 n8n 服务

### 根本原因分析

通过日志分析可能发现以下问题：

1. **PostgreSQL 频繁崩溃**
   - 错误信息: `server process was terminated by signal 13: Broken pipe`
   - 数据库不断进入恢复模式
   - 非正常关机导致需要执行 WAL 恢复

2. **n8n 数据库连接超时**
   - 日志显示: `timeout exceeded when trying to connect`
   - 由于 PostgreSQL 不稳定导致连接失败

3. **Docker Desktop 环境问题**
   - macOS 上 Docker 虚拟化可能导致文件系统性能问题
   - 资源限制可能不足

### 解决方案

#### 步骤 1: 快速重启服务

```bash
./restart-n8n.sh
```

#### 步骤 2: 检查服务日志

```bash
# 检查 PostgreSQL 日志
docker-compose logs postgres --tail 50

# 检查 n8n 日志
docker-compose logs n8n --tail 50
```

#### 步骤 3: 验证健康状态

```bash
# 验证 PostgreSQL
docker-compose exec postgres pg_isready -U n8n_admin -d n8n

# 验证 n8n
curl http://localhost:5678/healthz
```

#### 步骤 4: 优化配置（如果问题持续）

**优化 PostgreSQL 配置** - 在 `docker-compose.yml` 中添加：

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

**优化 n8n 数据库连接** - 添加环境变量：

```yaml
environment:
  - DB_POSTGRESDB_POOL_SIZE=10
  - DB_LOGGING_ENABLED=false
  - DB_LOGGING_MAX_EXECUTION_TIME=0
```

#### 步骤 5: 检查 Docker 资源

- 打开 Docker Desktop → Settings → Resources
- 确保资源配置满足要求：
  - 内存: 至少 4GB (推荐 8GB)
  - CPU: 至少 2 核 (推荐 4 核)
  - 磁盘: 至少 60GB

### 验证结果

确认以下检查项全部通过：

- ✅ PostgreSQL 健康检查通过
- ✅ n8n 前端可访问 (http://localhost:5678)
- ✅ 健康端点返回: `{"status":"ok"}`

## 场景 2: 服务性能下降

### 问题症状

- 服务响应缓慢
- 工作流执行延迟
- 资源使用率高

### 诊断步骤

1. **检查资源使用情况**
   ```bash
   docker stats --no-stream
   ```

2. **检查日志中的警告**
   ```bash
   docker-compose logs --tail 100 | grep -i warning
   ```

3. **检查数据库连接数**
   ```bash
   docker-compose exec postgres psql -U n8n_admin -d n8n -c "SELECT count(*) FROM pg_stat_activity;"
   ```

### 解决方案

根据诊断结果选择相应的优化措施：

#### CPU 使用率过高 (> 80%)
- 增加 Docker Desktop CPU 核心数
- 调整 worker 数量
- 优化工作流逻辑

#### 内存使用率过高 (> 85%)
- 增加 Docker Desktop 内存分配
- 优化 PostgreSQL 缓冲区配置
- 减少并发执行数量

#### 数据库连接数过多 (> 150)
- 增加 `max_connections` 配置
- 调整 `DB_POSTGRESDB_POOL_SIZE`

#### Redis 队列积压 (> 1000)
- 增加 worker 数量
- 检查工作流执行性能

## 场景 3: 数据持久化问题

### 问题症状

- 重启后数据丢失
- 工作流配置消失
- 执行历史记录缺失

### 诊断步骤

1. **检查数据卷挂载**
   ```bash
   docker-compose config | grep volumes -A 5
   ```

2. **检查数据卷内容**
   ```bash
   docker volume inspect n8n_postgres_data
   docker volume inspect n8n_redis_data
   docker volume inspect n8n_data
   ```

### 解决方案

1. **确认 docker-compose.yml 中有正确的卷配置**
   ```yaml
   volumes:
     postgres_data:
     redis_data:
     n8n_data:
   ```

2. **恢复数据（如果有备份）**
   ```bash
   # 停止服务
   docker-compose down
   
   # 恢复卷数据
   # ... 执行恢复步骤
   
   # 重启服务
   docker-compose up -d
   ```

## 场景 4: 服务无法启动

### 问题症状

- `docker-compose up -d` 后服务未运行
- 容器不断重启
- 健康检查失败

### 诊断步骤

1. **查看容器状态**
   ```bash
   docker-compose ps
   ```

2. **查看启动日志**
   ```bash
   docker-compose logs
   ```

3. **检查端口占用**
   ```bash
   lsof -i :5678
   lsof -i :5432
   lsof -i :6379
   ```

### 解决方案

#### 端口冲突
- 修改 `docker-compose.yml` 中的端口映射
- 或停止占用端口的进程

#### 配置错误
- 检查 `.env` 文件配置
- 验证环境变量设置
- 确认文件权限正确

#### 依赖服务未就绪
- 检查 `depends_on` 配置
- 增加健康检查 `start_period`
- 手动启动依赖服务

## 故障恢复流程

遇到任何问题时，按以下顺序执行：

### 第一步: 快速重启
```bash
./restart-n8n.sh
```

### 第二步: 检查日志
```bash
docker-compose logs postgres --tail 50
docker-compose logs n8n --tail 50
```

### 第三步: 验证健康状态
```bash
docker-compose exec postgres pg_isready -U n8n_admin -d n8n
curl http://localhost:5678/healthz
```

### 第四步: 深度诊断
- 检查 Docker Desktop 资源
- 查看系统日志
- 考虑增加资源限制

### 第五步: 寻求支持
如问题仍未解决，收集以下信息后寻求技术支持：
- 完整的日志输出
- Docker 版本信息
- 系统资源使用情况
- 配置文件内容

## 相关资源

- [维护指南](./maintenance.md) - 日常维护操作
- [DOCKER_COMPOSE_README.md](./DOCKER_COMPOSE_README.md) - 完整部署指南
- [n8n 官方文档](https://docs.n8n.io)

## 技术支持

- n8n 社区: https://community.n8n.io
- GitHub Issues: https://github.com/n8n-io/n8n/issues
