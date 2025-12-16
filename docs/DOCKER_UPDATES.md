# Docker 维护更新记录

## 更新日期: 2025-12-08

### 问题描述
本地 Docker 运行的 n8n 服务出现数据库连接异常,导致前端无法访问,返回 503 错误。

### 修复内容

#### 1. 优化 docker-compose.yml 配置

**PostgreSQL 服务优化:**
- 增加共享内存限制 (`shm_size: 256mb`)
- 添加数据库参数优化,提高稳定性
- 调整健康检查参数,增加启动宽限期
- 优化 WAL 配置,确保数据持久化

**n8n 服务优化:**
- 添加数据库连接池配置 (`DB_POSTGRESDB_POOL_SIZE=10`)
- 禁用数据库日志以减少开销
- 优化数据库连接超时处理

#### 2. 新增维护工具

**restart-n8n.sh**
- 安全重启服务脚本
- 包含完整的健康检查流程
- 自动验证服务状态

#### 3. 完善文档

**DOCKER_COMPOSE_README.md**
- 添加故障排查章节
- 针对 503 错误提供详细解决方案
- 添加运维最佳实践
- 提供性能优化建议

**MAINTENANCE_SUMMARY.md**
- 详细的问题诊断报告
- 修复方案说明
- 后续运维建议
- 故障恢复流程

### 使用说明

#### 快速重启服务
```bash
./restart-n8n.sh
```

#### 健康检查
```bash
# PostgreSQL
docker-compose exec postgres pg_isready -U n8n_admin -d n8n

# Redis
docker-compose exec redis redis-cli ping

# n8n
curl http://localhost:5678/healthz
```

#### 查看服务状态
```bash
docker-compose ps
docker-compose logs -f
```

### 后续建议

1. **检查 Docker Desktop 资源分配**
   - 内存: 至少 4GB (推荐 8GB)
   - CPU: 至少 2 核 (推荐 4 核)

2. **配置定期健康检查**
   - 使用 crontab 每 5 分钟检查服务状态

3. **配置自动备份**
   - 每天自动备份数据库和数据卷

4. **监控关键指标**
   - CPU/内存使用率
   - 数据库连接数
   - Redis 队列长度

详细信息请参考:
- [DOCKER_COMPOSE_README.md](./DOCKER_COMPOSE_README.md)
- [MAINTENANCE_SUMMARY.md](./MAINTENANCE_SUMMARY.md)
