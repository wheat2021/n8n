# 文档贡献指南

感谢你对 n8n 项目文档的贡献！本指南将帮助你了解文档规范和最佳实践。

## 📋 目录

- [文档结构](#文档结构)
- [文档分类](#文档分类)
- [命名规范](#命名规范)
- [元数据规范](#元数据规范)
- [格式规范](#格式规范)
- [使用模板](#使用模板)
- [贡献流程](#贡献流程)
- [审核标准](#审核标准)

## 文档结构

我们采用**按文档类型分类**的组织方式：

```
docs/
├── README.md                    # 文档总索引
├── CONTRIBUTING.md              # 本文件
├── 01-getting-started/          # 入门指南
│   └── README.md
├── 02-architecture/             # 架构设计
│   ├── README.md
│   ├── overview.md
│   └── components.md
├── 03-guides/                   # 操作指南
│   ├── README.md
│   ├── deployment/
│   ├── configuration/
│   └── integration/
├── 04-operations/               # 运维手册
│   ├── README.md
│   ├── maintenance.md
│   └── troubleshooting/
├── 05-reference/                # 参考文档
│   ├── README.md
│   ├── api/
│   └── configuration/
└── _templates/                  # 文档模板
```

## 文档分类

选择正确的分类对文档组织至关重要：

### 01-getting-started/ (入门指南)

**适用于：**
- 快速开始教程
- 安装指南
- 基本概念介绍
- 新手友好的内容

**特点：**
- 简洁明了
- 循序渐进
- 包含实际例子
- 避免过多技术细节

### 02-architecture/ (架构设计)

**适用于：**
- 系统架构说明
- 技术选型文档
- 设计决策记录 (ADR)
- 核心概念深度解析

**特点：**
- 使用架构图（Mermaid）
- 详细的技术说明
- 设计理念阐述
- 面向开发者

### 03-guides/ (操作指南)

**适用于：**
- 部署指南
- 配置指南
- 集成指南
- How-to 类型的文档

**特点：**
- 步骤明确
- 包含命令示例
- 提供验证方法
- 解决具体问题

**子分类：**
- `deployment/` - 部署相关
- `configuration/` - 配置相关
- `integration/` - 集成相关

### 04-operations/ (运维手册)

**适用于：**
- 日常维护操作
- 监控和告警
- 故障排查
- 性能优化

**特点：**
- 操作步骤清晰
- 包含诊断方法
- 提供解决方案
- 注重实用性

**子分类：**
- 根目录 - 维护相关
- `troubleshooting/` - 故障排查

### 05-reference/ (参考文档)

**适用于：**
- API 文档
- 配置参数列表
- 环境变量说明
- 技术规格

**特点：**
- 完整性
- 准确性
- 结构化
- 易于查询

## 命名规范

### 文件命名

✅ **推荐：**
- 使用小写字母
- 使用连字符（-）分隔单词
- 名称简洁明了
- 反映文档内容

```
✅ 正确示例：
docker-compose.md
ssh-tunnel-guide.md
github-integration.md
performance-optimization.md

❌ 错误示例：
DockerCompose.md         # 不要使用驼峰命名
ssh_tunnel_guide.md      # 不要使用下划线
guide1.md                # 名称应该有意义
docker-compose-部署.md   # 文件名使用英文，内容用中文
```

### 目录命名

与文件命名规范相同，但建议：
- 使用复数形式表示包含多个文档
- 使用名词短语

```
✅ 正确示例：
guides/
troubleshooting/
deployment/

❌ 错误示例：
Guide/
trouble_shooting/
deploy/
```

## 元数据规范

每个文档**必须**在开头包含 YAML frontmatter 元数据。

### 必填字段

```yaml
---
title: 文档标题
description: 简短描述（1-2 句话）
category: 文档分类
tags: [标签1, 标签2, 标签3]
author: 作者名称
created: YYYY-MM-DD
updated: YYYY-MM-DD
version: 语义化版本号
status: active
---
```

### 字段说明

| 字段 | 必填 | 说明 | 示例 |
|------|------|------|------|
| `title` | ✅ | 文档标题，应与一级标题一致 | `n8n Docker 部署指南` |
| `description` | ✅ | 1-2 句话简短描述文档内容 | `使用 Docker Compose 部署 n8n` |
| `category` | ✅ | 文档分类路径 | `guides/deployment` |
| `tags` | ✅ | 关键词标签，便于搜索 | `[docker, deployment, postgresql]` |
| `author` | ✅ | 文档作者 | `Terry Chen` |
| `created` | ✅ | 文档创建日期 | `2024-12-29` |
| `updated` | ✅ | 最后更新日期 | `2024-12-29` |
| `version` | ✅ | 语义化版本号 | `1.0.0` |
| `status` | ✅ | 文档状态 | `active` / `deprecated` / `draft` |
| `related_issue` | ❌ | 相关 Issue 或 Ticket | `#123` 或 `LINEAR-456` |

### 分类值参考

```yaml
# 入门指南
category: getting-started

# 架构设计
category: architecture

# 操作指南
category: guides/deployment
category: guides/configuration
category: guides/integration

# 运维手册
category: operations
category: operations/troubleshooting

# 参考文档
category: reference/api
category: reference/configuration
```

### 状态值说明

- `active` - 当前有效的文档
- `draft` - 草稿状态，尚未完成
- `deprecated` - 已过时，应在文档中指向新版本

### 版本号规则

遵循语义化版本 (Semantic Versioning)：

- `1.0.0` - 初始版本
- `1.1.0` - 添加新内容（向后兼容）
- `1.0.1` - 修正错误（向后兼容）
- `2.0.0` - 重大变更（不向后兼容）

## 格式规范

### Markdown 规范

#### 标题层级

- 使用一个一级标题（`#`）作为文档标题
- 合理使用二级（`##`）、三级（`###`）标题
- 不要跳级（如直接从 `##` 跳到 `####`）

```markdown
# 文档标题

## 主要章节

### 小节

#### 细节
```

#### 代码块

- 始终指定语言类型
- 使用正确的语言标识符

```markdown
✅ 正确：
\`\`\`bash
docker-compose up -d
\`\`\`

\`\`\`typescript
interface User {
  name: string;
}
\`\`\`

❌ 错误：
\`\`\`
docker-compose up -d
\`\`\`
```

常用语言标识符：
- `bash` / `shell` - Shell 命令
- `yaml` / `yml` - YAML 配置
- `typescript` / `ts` - TypeScript 代码
- `javascript` / `js` - JavaScript 代码
- `json` - JSON 数据
- `sql` - SQL 语句
- `mermaid` - Mermaid 图表

#### 链接

- 使用相对路径链接文档
- 使用绝对 URL 链接外部资源

```markdown
✅ 正确：
[部署指南](../03-guides/deployment/docker-compose.md)
[n8n 官方文档](https://docs.n8n.io/)

❌ 错误：
[部署指南](/opt/code/n8n/docs/03-guides/deployment/docker-compose.md)
```

#### 表格

- 使用表格展示结构化数据
- 保持表格对齐（便于阅读源码）

```markdown
| 列 1 | 列 2 | 列 3 |
|------|------|------|
| 内容 | 内容 | 内容 |
| 内容 | 内容 | 内容 |
```

#### 列表

- 有序列表使用 `1.`、`2.`
- 无序列表使用 `-`
- 子列表缩进 2 个空格

```markdown
1. 第一步
   - 子项 1
   - 子项 2
2. 第二步
```

#### 强调

- **粗体** - 使用 `**文本**`
- *斜体* - 使用 `*文本*`
- `代码` - 使用 \`代码\`

#### 图表

使用 Mermaid 绘制图表：

```markdown
\`\`\`mermaid
graph LR
    A[开始] --> B[处理]
    B --> C[结束]
\`\`\`
```

支持的图表类型：
- `graph` - 流程图
- `sequenceDiagram` - 序列图
- `classDiagram` - 类图
- `erDiagram` - ER 图

### 中文排版规范

- 中英文之间添加空格
- 中文与数字之间添加空格
- 专有名词使用正确的大小写

```markdown
✅ 正确：
n8n 是一个工作流自动化平台，支持 200+ 个集成。

❌ 错误：
n8n是一个工作流自动化平台，支持200+个集成。
```

### 文档结构建议

#### 操作指南结构

```markdown
# 标题

## 概述
[简要说明]

## 前置条件
- [ ] 条件 1
- [ ] 条件 2

## 操作步骤

### 步骤 1: [步骤名称]
[详细说明]

## 验证
[如何验证操作成功]

## 常见问题
[FAQ]

## 相关文档
[链接]
```

#### 故障排查结构

```markdown
# 问题标题

## 问题描述
[描述]

## 症状表现
- 症状 1
- 症状 2

## 原因分析
[分析]

## 解决方案

### 方案 1（推荐）
[步骤]

### 方案 2
[步骤]

## 验证步骤
[验证]

## 预防措施
[预防]

## 相关问题
[链接]
```

## 使用模板

我们提供了多种文档模板，建议使用模板创建新文档。

### 可用模板

| 模板 | 用途 | 路径 |
|------|------|------|
| 操作指南 | How-to 类型文档 | `_templates/guide-template.md` |
| 故障排查 | 问题诊断和解决 | `_templates/troubleshooting-template.md` |
| 架构设计 | 系统设计文档 | `_templates/architecture-template.md` |
| API 文档 | 接口说明 | `_templates/api-template.md` |
| 功能优化 | 性能优化记录 | `_templates/feature-template.md` |
| 缺陷修复 | Bug 修复记录 | `_templates/bugfix-template.md` |

### 使用方法

1. 复制对应的模板文件
2. 重命名为新文档名称
3. 填写 frontmatter 元数据
4. 根据模板结构填写内容
5. 删除不需要的章节
6. 保存到正确的分类目录

```bash
# 示例：创建新的部署指南
cp docs/_templates/guide-template.md docs/03-guides/deployment/kubernetes.md
# 然后编辑 kubernetes.md
```

## 贡献流程

### 1. 准备工作

- Fork 项目仓库
- Clone 到本地
- 创建新分支

```bash
git clone <your-fork>
cd n8n
git checkout -b docs/new-guide
```

### 2. 创建或编辑文档

- 选择合适的模板
- 按照规范编写文档
- 确保 frontmatter 完整

### 3. 更新索引

在相关的 README.md 中添加文档链接：

- `docs/README.md` - 如果是重要文档
- 对应分类的 `README.md` - 必须更新

### 4. 自检

使用以下清单检查文档质量：

**内容质量**
- [ ] frontmatter 完整且正确
- [ ] 标题层级合理
- [ ] 代码块指定语言
- [ ] 链接可用且使用相对路径
- [ ] 图表清晰（如有）
- [ ] 中英文排版符合规范

**结构完整**
- [ ] 有清晰的概述
- [ ] 步骤详细且可执行
- [ ] 包含示例和验证方法
- [ ] 提供常见问题或故障排查
- [ ] 链接到相关文档

**可读性**
- [ ] 语言简洁明了
- [ ] 避免歧义
- [ ] 格式一致
- [ ] 代码可复制执行

### 5. 提交

```bash
git add docs/
git commit -m "docs: 添加 Kubernetes 部署指南"
git push origin docs/new-guide
```

提交信息格式：
- `docs: 添加 XXX 文档`
- `docs: 更新 XXX 文档`
- `docs: 修复 XXX 文档中的错误`

### 6. 创建 Pull Request

- 提供清晰的 PR 描述
- 说明文档的目的和受众
- 链接相关 Issue（如有）

## 审核标准

文档审核将检查以下方面：

### 1. 技术准确性
- 信息正确无误
- 命令可执行
- 步骤可重现

### 2. 完整性
- frontmatter 完整
- 内容完整
- 索引已更新

### 3. 规范性
- 遵循命名规范
- 遵循格式规范
- 遵循结构建议

### 4. 可用性
- 目标读者明确
- 易于理解
- 实用性强

### 5. 维护性
- 版本号管理
- 更新日期准确
- 相关链接有效

## 常见问题

### Q: 我的文档应该放在哪个分类？

A: 参考 [文档分类](#文档分类) 部分，选择最匹配的分类。如果不确定，可以在 PR 中询问。

### Q: 我可以使用英文编写文档吗？

A: 本项目使用中文文档。如果需要英文版本，可以后续添加。

### Q: 如何添加图片？

A:
1. 优先使用 Mermaid 绘制图表
2. 如需截图，放在 `docs/assets/images/` 目录
3. 使用相对路径引用：`![描述](../assets/images/xxx.png)`

### Q: 文档过时了怎么办？

A:
1. 如果内容仍有参考价值，更新内容并修改 `updated` 日期
2. 如果完全过时，设置 `status: deprecated`，并在文档开头添加指向新文档的链接

### Q: 我需要翻译所有代码注释吗？

A: 不需要。代码示例中的注释可以保持英文，或根据上下文判断是否需要中文解释。

## 相关资源

- [Markdown 指南](https://www.markdownguide.org/)
- [Mermaid 文档](https://mermaid.js.org/)
- [语义化版本](https://semver.org/lang/zh-CN/)
- [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines)

## 反馈

如果你对本贡献指南有任何建议或发现问题，请：

1. 创建 Issue 讨论
2. 直接提交 PR 改进本文档

---

**感谢你的贡献！📚**

[← 返回文档首页](./README.md)
