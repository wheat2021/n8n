# n8n 项目文档

> 最后更新：2024-12-29

欢迎来到 n8n 项目文档中心！本文档库包含项目部署、架构设计、操作指南和故障排查等全方位的技术文档。

## 🚀 快速开始

**新用户从这里开始：**

1. **了解架构** - [n8n 核心架构](overview.md) | [队列模式组件](19_repo_doc_ref/n8n/02-architecture/components.md)
2. **部署服务** - [Docker Compose 部署指南](docker-compose.md)
3. **安全访问** - [SSH 隧道访问](ssh-tunnel.md)

## 📚 文档分类

### 🏗️ [01 - 入门指南](./01-getting-started/)
> 快速上手和安装指南

**即将添加的内容：**
- 快速开始
- 安装指南
- 基本概念

### 🎯 [02 - 架构设计](./02-architecture/)
> 系统架构、设计思想和技术选型

- [核心架构概览](overview.md) - Monorepo 结构、技术栈、核心概念
- [队列模式组件](19_repo_doc_ref/n8n/02-architecture/components.md) - Docker 容器架构、数据流向

### 📖 [03 - 操作指南](./03-guides/)
> 具体功能的配置和使用方法

#### 部署相关
- [Docker Compose 部署](docker-compose.md) - 完整的生产环境部署指南

#### 配置相关
- [SSH 隧道配置](ssh-tunnel.md) - 安全访问远程 n8n 服务

#### 集成相关
- [GitHub SSH 集成](github-ssh.md) - 配置 Git 仓库访问

### 🔧 [04 - 运维手册](./04-operations/)
> 部署、维护、监控和故障排查

#### 维护
- [日常维护指南](19_repo_doc_ref/n8n/04-operations/maintenance.md) - 健康检查、备份、监控

#### 故障排查
- [常见问题处理](common-issues.md) - 数据库、性能、服务启动
- [IP 访问问题](ip-access.md) - Web Crypto API 安全上下文

### 📋 [05 - 参考文档](./05-reference/)
> API、配置项详细说明

**即将添加的内容：**
- API 文档
- 配置参考
- 环境变量

## 🔍 常用文档

以下是访问频率最高的文档链接：

1. [Docker Compose 部署指南](docker-compose.md) ⭐⭐⭐⭐⭐
2. [SSH 隧道访问指南](ssh-tunnel.md) ⭐⭐⭐⭐
3. [常见问题处理](common-issues.md) ⭐⭐⭐⭐
4. [n8n 核心架构](overview.md) ⭐⭐⭐
5. [维护指南](19_repo_doc_ref/n8n/04-operations/maintenance.md) ⭐⭐⭐

## 🛠️ 文档模板

为保持文档风格一致，我们提供了以下模板供参考：

- [操作指南模板](19_repo_doc_ref/n8n/_templates/guide-template.md) - 用于编写 How-to 类型的文档
- [故障排查模板](19_repo_doc_ref/n8n/_templates/troubleshooting-template.md) - 用于编写问题诊断和解决方案
- [架构设计模板](19_repo_doc_ref/n8n/_templates/architecture-template.md) - 用于编写系统设计和技术决策
- [API 文档模板](19_repo_doc_ref/n8n/_templates/api-template.md) - 用于编写接口说明文档
- [功能优化模板](19_repo_doc_ref/n8n/_templates/feature-template.md) - 用于记录性能优化和功能改进
- [缺陷修复模板](19_repo_doc_ref/n8n/_templates/bugfix-template.md) - 用于记录 bug 修复过程

## 📝 如何贡献文档

我们欢迎所有形式的文档贡献！在编写或更新文档前，请阅读：

- [文档贡献指南](CONTRIBUTING.md) - 文档规范和最佳实践

### 快速开始贡献

1. **选择合适的模板** - 根据文档类型从 `_templates/` 目录选择模板
2. **遵循命名规范** - 使用小写字母和连字符（如 `my-guide.md`）
3. **添加 frontmatter** - 在文档开头添加完整的元数据
4. **保持简洁明了** - 使用清晰的标题层级和代码示例
5. **更新索引** - 在相关目录的 README.md 中添加文档链接

### 文档规范要点

- ✅ 使用中文编写（本项目）
- ✅ 每个文档开头包含 YAML frontmatter
- ✅ 使用 Markdown 标准语法
- ✅ 代码块标注语言类型
- ✅ 及时更新文档的 `updated` 字段
- ✅ 过时文档标记为 `status: deprecated`

## 📊 文档结构说明

我们采用**按文档类型分类**的组织方式：

```
docs/
├── README.md                    # 本文件 - 文档总索引
├── CONTRIBUTING.md              # 文档贡献指南
├── 01-getting-started/          # 入门指南
│   └── README.md
├── 02-architecture/             # 架构设计
│   ├── README.md
│   ├── overview.md
│   └── components.md
├── 03-guides/                   # 操作指南
│   ├── README.md
│   ├── deployment/              # 部署指南
│   ├── configuration/           # 配置指南
│   └── integration/             # 集成指南
├── 04-operations/               # 运维手册
│   ├── README.md
│   ├── maintenance.md
│   └── troubleshooting/         # 故障排查
├── 05-reference/                # 参考文档
│   ├── README.md
│   ├── api/
│   └── configuration/
└── _templates/                  # 文档模板
```

## 🔗 相关资源

### 官方资源

- [n8n 官方文档](https://docs.n8n.io/)
- [n8n GitHub 仓库](https://github.com/n8n-io/n8n)
- [n8n 社区论坛](https://community.n8n.io/)

### 项目相关

- [项目架构指南](../../AGENTS.md) - 开发规范和架构说明
- [Docker Compose 配置](../../docker-compose.yml)
- [环境变量示例](../../.env.example)

## 📮 反馈和建议

如果您在使用文档过程中遇到问题或有改进建议：

1. **文档问题** - 直接编辑相关文档并提交 Pull Request
2. **新文档需求** - 创建 Issue 说明需求
3. **内容错误** - 创建 Issue 或直接修正

## 📜 版本历史

| 版本 | 日期 | 更新内容 | 作者 |
|------|------|---------|------|
| 2.0.0 | 2024-12-29 | 重构文档结构，添加分类和模板 | Terry Chen |
| 1.0.0 | 2024-12-24 | 初始版本 | Terry Chen |

---

**📖 Happy Reading & Coding! 🚀**
