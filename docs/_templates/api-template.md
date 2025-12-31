---
title: [API 名称]
description: [API 的简短描述]
category: reference/api
tags: []
author: [作者名称]
created: [YYYY-MM-DD]
updated: [YYYY-MM-DD]
version: 1.0.0
status: active
---

# [API 名称]

## 概述

[简要说明这个 API 的用途和功能]

## 基础信息

- **Base URL:** `https://api.example.com/v1`
- **认证方式:** [Bearer Token | API Key | OAuth 2.0]
- **数据格式:** JSON
- **字符编码:** UTF-8

## 认证

### 获取访问令牌

[说明如何获取和使用认证令牌]

```bash
curl -X POST https://api.example.com/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username": "user", "password": "pass"}'
```

响应示例：
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

### 使用令牌

```bash
curl -H "Authorization: Bearer {access_token}" \
  https://api.example.com/v1/resource
```

## API 端点

### 获取资源列表

```http
GET /v1/resources
```

**描述：** [端点功能描述]

**请求参数：**

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| page | integer | 否 | 1 | 页码 |
| limit | integer | 否 | 20 | 每页数量，最大 100 |
| sort | string | 否 | created_at | 排序字段 |
| order | string | 否 | desc | 排序方向：asc/desc |

**请求示例：**

```bash
curl -X GET "https://api.example.com/v1/resources?page=1&limit=10" \
  -H "Authorization: Bearer {access_token}"
```

**响应示例：**

```json
{
  "data": [
    {
      "id": "123",
      "name": "Resource 1",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 10
  }
}
```

**响应字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| data | array | 资源列表 |
| data[].id | string | 资源 ID |
| data[].name | string | 资源名称 |
| data[].created_at | string | 创建时间（ISO 8601） |
| meta.total | integer | 总记录数 |
| meta.page | integer | 当前页码 |
| meta.limit | integer | 每页数量 |

**状态码：**

- `200 OK` - 请求成功
- `400 Bad Request` - 请求参数错误
- `401 Unauthorized` - 未授权
- `500 Internal Server Error` - 服务器错误

---

### 获取单个资源

```http
GET /v1/resources/{id}
```

**描述：** [端点功能描述]

**路径参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 资源 ID |

**请求示例：**

```bash
curl -X GET "https://api.example.com/v1/resources/123" \
  -H "Authorization: Bearer {access_token}"
```

**响应示例：**

```json
{
  "id": "123",
  "name": "Resource 1",
  "description": "Description of resource",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-02T00:00:00Z"
}
```

**状态码：**

- `200 OK` - 请求成功
- `404 Not Found` - 资源不存在
- `401 Unauthorized` - 未授权

---

### 创建资源

```http
POST /v1/resources
```

**描述：** [端点功能描述]

**请求体：**

```json
{
  "name": "New Resource",
  "description": "Resource description",
  "tags": ["tag1", "tag2"]
}
```

**请求字段说明：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 是 | 资源名称，最长 100 字符 |
| description | string | 否 | 资源描述，最长 500 字符 |
| tags | array | 否 | 标签列表 |

**请求示例：**

```bash
curl -X POST "https://api.example.com/v1/resources" \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Resource",
    "description": "Resource description"
  }'
```

**响应示例：**

```json
{
  "id": "124",
  "name": "New Resource",
  "description": "Resource description",
  "created_at": "2024-01-03T00:00:00Z"
}
```

**状态码：**

- `201 Created` - 创建成功
- `400 Bad Request` - 请求参数错误
- `409 Conflict` - 资源已存在

---

### 更新资源

```http
PUT /v1/resources/{id}
PATCH /v1/resources/{id}
```

**描述：** [端点功能描述]

- `PUT` - 完整更新（所有字段）
- `PATCH` - 部分更新（仅指定字段）

**请求体：**

```json
{
  "name": "Updated Resource",
  "description": "Updated description"
}
```

**请求示例：**

```bash
curl -X PATCH "https://api.example.com/v1/resources/123" \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Resource"}'
```

**状态码：**

- `200 OK` - 更新成功
- `404 Not Found` - 资源不存在
- `400 Bad Request` - 请求参数错误

---

### 删除资源

```http
DELETE /v1/resources/{id}
```

**描述：** [端点功能描述]

**请求示例：**

```bash
curl -X DELETE "https://api.example.com/v1/resources/123" \
  -H "Authorization: Bearer {access_token}"
```

**响应示例：**

```json
{
  "message": "Resource deleted successfully"
}
```

**状态码：**

- `200 OK` - 删除成功
- `204 No Content` - 删除成功（无响应体）
- `404 Not Found` - 资源不存在

## 错误处理

### 错误响应格式

```json
{
  "error": {
    "code": "INVALID_PARAMETER",
    "message": "The 'name' field is required",
    "details": [
      {
        "field": "name",
        "issue": "required"
      }
    ]
  }
}
```

### 常见错误码

| HTTP 状态码 | 错误码 | 说明 |
|------------|--------|------|
| 400 | INVALID_PARAMETER | 请求参数无效 |
| 401 | UNAUTHORIZED | 未授权或令牌过期 |
| 403 | FORBIDDEN | 权限不足 |
| 404 | NOT_FOUND | 资源不存在 |
| 409 | CONFLICT | 资源冲突 |
| 429 | RATE_LIMIT_EXCEEDED | 超过请求频率限制 |
| 500 | INTERNAL_ERROR | 服务器内部错误 |

## 速率限制

- **限制：** 每个 API Key 每分钟最多 100 个请求
- **响应头：**
  - `X-RateLimit-Limit`: 速率限制
  - `X-RateLimit-Remaining`: 剩余请求数
  - `X-RateLimit-Reset`: 限制重置时间（Unix 时间戳）

## 数据模型

### Resource 对象

```typescript
interface Resource {
  id: string;              // 唯一标识符
  name: string;            // 资源名称
  description?: string;    // 资源描述（可选）
  tags: string[];          // 标签列表
  created_at: string;      // 创建时间（ISO 8601）
  updated_at: string;      // 更新时间（ISO 8601）
}
```

## SDK 示例

### JavaScript/TypeScript

```typescript
import { ApiClient } from '@example/api-client';

const client = new ApiClient({
  apiKey: 'your-api-key',
  baseUrl: 'https://api.example.com/v1'
});

// 获取资源列表
const resources = await client.resources.list({ page: 1, limit: 10 });

// 创建资源
const newResource = await client.resources.create({
  name: 'New Resource',
  description: 'Description'
});
```

### Python

```python
from example_api import ApiClient

client = ApiClient(api_key='your-api-key')

# 获取资源列表
resources = client.resources.list(page=1, limit=10)

# 创建资源
new_resource = client.resources.create(
    name='New Resource',
    description='Description'
)
```

## 最佳实践

1. **使用幂等性**：对于 PUT 和 DELETE 请求，重复执行应产生相同结果
2. **处理分页**：使用分页参数避免一次性加载大量数据
3. **错误重试**：对于 5xx 错误，使用指数退避策略重试
4. **缓存响应**：合理使用 HTTP 缓存头减少 API 调用
5. **验证输入**：在客户端验证输入以减少无效请求

## 变更日志

### v1.1.0 (2024-01-15)

- 新增：批量操作端点
- 优化：响应速度提升 30%
- 修复：分页参数验证问题

### v1.0.0 (2024-01-01)

- 初始版本

## 相关文档

- [认证指南](./authentication.md)
- [SDK 文档](./sdk-reference.md)
- [迁移指南](./migration-guide.md)

## 更新历史

| 版本 | 日期 | 更新内容 | 作者 |
|------|------|---------|------|
| 1.0.0 | YYYY-MM-DD | 初始版本 | [作者] |
