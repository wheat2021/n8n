# 参考文档

本部分包含 n8n 的 API 文档、配置参考和其他技术参考资料。

## 📖 文档分类

### 🔌 [API 文档](./api/)

**即将添加：**
- REST API 参考
- WebSocket API 参考
- Webhook API 参考
- 认证和授权

### ⚙️ [配置参考](./configuration/)

**即将添加：**
- 环境变量完整列表
- 配置文件参考
- 数据库配置
- Redis 配置
- 安全配置

## 🎯 快速查询

### 环境变量

**即将添加完整的环境变量列表**

常用环境变量：

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `N8N_HOST` | n8n 主机名 | `localhost` |
| `N8N_PORT` | n8n 端口 | `5678` |
| `N8N_PROTOCOL` | 访问协议 | `http` |
| `ENCRYPTION_KEY` | 加密密钥 | **必须设置** |
| `DB_TYPE` | 数据库类型 | `sqlite` |
| `EXECUTIONS_MODE` | 执行模式 | `regular` |
| `QUEUE_BULL_REDIS_HOST` | Redis 主机 | `redis` |

### API 端点

**即将添加完整的 API 文档**

常用端点：

- `GET /healthz` - 健康检查
- `GET /workflows` - 获取工作流列表
- `POST /workflows` - 创建工作流
- `POST /workflows/:id/run` - 执行工作流
- `POST /webhook/:path` - Webhook 入口

## 📚 外部参考

### 官方文档

- [n8n API 文档](https://docs.n8n.io/api/)
- [n8n 环境变量](https://docs.n8n.io/hosting/configuration/environment-variables/)
- [n8n Webhook](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)

### 相关技术

- [TypeORM 文档](https://typeorm.io/)
- [Bull Queue 文档](https://github.com/OptimalBits/bull)
- [Vue 3 文档](https://vuejs.org/)
- [Pinia 文档](https://pinia.vuejs.org/)

## 📝 贡献

如果你想补充参考文档：

1. 选择合适的子分类（api / configuration）
2. 使用 [API 文档模板](../_templates/api-template.md)
3. 遵循文档规范
4. 更新本索引文件

详见 [文档贡献指南](../CONTRIBUTING.md)。

---

[← 返回文档首页](../README.md)
