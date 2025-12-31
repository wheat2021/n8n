# 架构设计

本部分文档详细介绍 n8n 的系统架构、设计理念、技术选型和核心概念。

## 📖 文档列表

### 核心架构

- **[架构概览](./overview.md)** - n8n 的整体架构、Monorepo 结构、技术栈和核心概念
  - Monorepo 组织结构
  - 前端技术栈（Vue 3 + Vite + Pinia）
  - 后端技术栈（Node.js + Express + TypeORM）
  - 核心包详解
  - 架构模式（DI、MVC、事件驱动）
  - 系统架构图
  - 数据流和执行流程

- **[队列模式组件](./components.md)** - Queue Mode 部署架构的组件详解
  - 核心组件模块（n8n、worker、PostgreSQL、Redis）
  - 模块架构图
  - 数据持久化机制

## 🎯 架构要点

### 1. Monorepo 结构

n8n 采用 pnpm workspaces 管理多个相互关联的包：

- `packages/cli` - 主应用和 REST API
- `packages/core` - 工作流执行引擎
- `packages/workflow` - 核心类型定义
- `packages/editor-ui` - Vue 3 前端应用
- `packages/@n8n/*` - 内部工具包

### 2. 队列模式

生产环境推荐使用队列模式部署：

- **Main Process** - 处理 Web 请求和 API
- **Worker Process** - 执行工作流任务（可水平扩展）
- **Redis** - 任务队列和缓存
- **PostgreSQL** - 数据持久化

### 3. 技术栈亮点

- **前端**: Vue 3 组合式 API + TypeScript + Vite
- **后端**: Express + TypeORM + 依赖注入
- **测试**: Jest (后端) + Vitest (前端) + Playwright (E2E)
- **构建**: Turbo + pnpm workspaces

## 🔍 深入了解

### 推荐阅读顺序

1. **[架构概览](./overview.md)** - 了解整体架构
2. **[队列模式组件](./components.md)** - 理解部署架构
3. **[Docker Compose 部署](../03-guides/deployment/docker-compose.md)** - 实际部署

### 相关主题

- [部署指南](../03-guides/deployment/) - 了解如何部署 n8n
- [运维手册](../04-operations/) - 了解如何维护 n8n

## 📚 外部资源

- [n8n GitHub 仓库](https://github.com/n8n-io/n8n)
- [n8n 架构决策记录 (ADR)](https://github.com/n8n-io/n8n/tree/master/docs/adr)
- [n8n 开发者文档](https://docs.n8n.io/integrations/)

## 📝 贡献

如果你想补充架构文档或纠正错误，请参考 [文档贡献指南](../CONTRIBUTING.md)。

---

[← 返回文档首页](../README.md)
