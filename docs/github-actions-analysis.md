# GitHub Actions 自动运行任务分析报告

## 问题描述

Fork 的仓库 `wheat2021/n8n` 持续接收来自 GitHub Actions 的失败通知邮件：
- 失败任务：`Run Playwright PerformanceTests`
- 触发分支：`master`
- 提交：`30091b1`

## 自动运行的 GitHub Actions 工作流分析

### 1. 定时任务（Schedule）

以下工作流会在特定时间自动运行：

| 工作流名称 | 执行时间 | 用途 | 依赖资源 |
|-----------|---------|------|---------|
| `playwright-test-performance.yml` | 每天 00:00 | 性能测试 | Secrets、Docker、Playwright |
| `test-workflows-nightly.yml` | 每天 02:00 | 工作流测试 | 测试环境 |
| `benchmark-nightly.yml` | 每天 01:30, 02:30, 03:30 | 性能基准测试 | Azure 云环境、Secrets |
| `benchmark-destroy-nightly.yml` | 定时 | 清理基准测试环境 | Azure 资源 |
| `check-documentation-urls.yml` | 定时 | 检查文档链接 | - |
| `chromatic.yml` | 定时 | UI 组件视觉回归测试 | Chromatic 服务 |
| `ci-evals.yml` | 定时 | CI 评估测试 | - |
| `ci-postgres-mysql.yml` | 定时 | 数据库兼容性测试 | 数据库服务 |
| `docker-build-push.yml` | 定时 | Docker 镜像构建推送 | Docker Hub、Secrets |
| `storybook.yml` | 定时 | Storybook 构建部署 | - |
| `update-node-popularity.yml` | 定时 | 更新节点流行度数据 | - |

### 2. Push 触发任务

以下工作流在推送到 `master` 分支时自动运行：

| 工作流名称 | 触发条件 | 用途 |
|-----------|---------|------|
| `ci-master.yml` | push to master/1.x | 主分支 CI：构建、单元测试、Lint |
| `docker-build-push.yml` | push to master | Docker 镜像构建推送 |
| `ci-evals.yml` | push to master | 评估测试 |
| `ci-python.yml` | push 到 Python 相关文件 | Python 组件测试 |

## 失败原因分析

### 核心问题

`playwright-test-performance.yml` 工作流失败的主要原因：

1. **缺少必需的 Secrets**
   - 性能测试工作流需要以下 secrets：
     ```yaml
     CURRENTS_RECORD_KEY
     QA_PERFORMANCE_METRICS_WEBHOOK_URL
     QA_PERFORMANCE_METRICS_WEBHOOK_USER
     QA_PERFORMANCE_METRICS_WEBHOOK_PASSWORD
     N8N_LICENSE_ACTIVATION_KEY
     N8N_ENCRYPTION_KEY
     ```
   - Fork 的仓库默认不会复制这些敏感配置

2. **自定义 Runner 不可用**
   - 工作流使用自定义 runner：`blacksmith-2vcpu-ubuntu-2204`
   - 这是 n8n 官方仓库的专用 runner，fork 仓库无法访问

3. **云服务依赖**
   - Benchmark 任务需要 Azure 云环境和相关凭证
   - 需要特定的云资源配置

4. **测试容器镜像**
   - 可能需要访问私有 Docker registry
   - 需要特定的测试环境配置

### 具体分析

查看 `.github/workflows/playwright-test-performance.yml`:

```yaml
on:
  workflow_call:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * *' # 每天午夜运行
  pull_request:
    paths:
      - '.github/workflows/playwright-test-performance.yml'
```

该工作流会在以下情况触发：
- 每天午夜自动运行
- 手动触发
- 被其他工作流调用
- 修改工作流文件本身时

## 建议处理方案

### 方案一：禁用所有不必要的工作流（推荐）

**适用场景**：个人/团队 fork，不需要完整的 CI/CD 流程

**步骤**：
1. 在仓库设置中禁用 GitHub Actions
   - 访问 `https://github.com/wheat2021/n8n/settings/actions`
   - 选择 "Disable Actions" 或 "Allow select actions"

2. 或者删除/重命名不需要的工作流文件：
   ```bash
   # 创建备份目录
   mkdir -p .github/workflows-disabled

   # 移动不需要的工作流
   mv .github/workflows/playwright-test-performance.yml .github/workflows-disabled/
   mv .github/workflows/benchmark-nightly.yml .github/workflows-disabled/
   mv .github/workflows/test-workflows-nightly.yml .github/workflows-disabled/
   # ... 移动其他定时任务
   ```

**优点**：
- 立即停止失败通知
- 节省 GitHub Actions 配额
- 保留工作流文件以备将来使用

**缺点**：
- 失去自动化测试能力

### 方案二：选择性保留工作流

**适用场景**：需要部分 CI 功能，但不需要完整的测试套件

**保留的工作流**（建议）：
- `ci-pull-requests.yml` - PR 检查
- `linting-reusable.yml` - 代码检查
- 删除或禁用所有定时任务

**步骤**：
```bash
# 禁用定时任务
mv .github/workflows/playwright-test-performance.yml .github/workflows-disabled/
mv .github/workflows/benchmark-nightly.yml .github/workflows-disabled/
mv .github/workflows/benchmark-destroy-nightly.yml .github/workflows-disabled/
mv .github/workflows/test-workflows-nightly.yml .github/workflows-disabled/
mv .github/workflows/chromatic.yml .github/workflows-disabled/
mv .github/workflows/check-documentation-urls.yml .github/workflows-disabled/
mv .github/workflows/ci-evals.yml .github/workflows-disabled/
mv .github/workflows/ci-postgres-mysql.yml .github/workflows-disabled/
mv .github/workflows/docker-build-push.yml .github/workflows-disabled/
mv .github/workflows/storybook.yml .github/workflows-disabled/
mv .github/workflows/update-node-popularity.yml .github/workflows-disabled/
```

### 方案三：配置 Fork 专用的工作流

**适用场景**：需要完整的 CI/CD，愿意投入时间配置

**要求**：
- 配置所有必需的 Secrets
- 设置自己的 Docker Hub 账号
- 配置云服务（如果需要 benchmark）
- 修改工作流使用标准 GitHub runners

**步骤**：
1. 修改所有工作流，将 `blacksmith-2vcpu-ubuntu-2204` 替换为 `ubuntu-latest`
2. 配置必需的 Secrets（或移除对它们的依赖）
3. 移除云服务相关的工作流

## 推荐操作

### 立即行动（停止失败通知）：

```bash
# 1. 创建备份目录
mkdir -p .github/workflows-disabled

# 2. 移动所有定时任务到备份目录
mv .github/workflows/playwright-test-performance.yml .github/workflows-disabled/
mv .github/workflows/benchmark-nightly.yml .github/workflows-disabled/
mv .github/workflows/benchmark-destroy-nightly.yml .github/workflows-disabled/
mv .github/workflows/test-workflows-nightly.yml .github/workflows-disabled/

# 3. 提交更改
git add .github/
git commit -m "#FICC-9999# 禁用从上游继承的定时任务工作流"
git push origin master
```

### 长期方案：

1. **定期同步上游更新时**：
   - 不要同步 `.github/workflows/` 中的定时任务
   - 或在同步后立即移动这些文件

2. **在仓库设置中配置**：
   - Settings > Actions > General
   - 选择 "Allow select actions and reusable workflows"
   - 可以精确控制哪些工作流可以运行

3. **如果需要测试**：
   - 只保留 PR 触发的工作流
   - 手动运行特定测试（使用 `workflow_dispatch`）

## 总结

- **问题根源**：Fork 继承了 n8n 官方仓库的完整 CI/CD 配置，但缺少运行这些工作流所需的资源和凭证
- **影响范围**：至少 12 个定时任务每天自动运行并失败
- **推荐方案**：禁用所有定时任务，仅保留必要的 PR 检查工作流
- **预期效果**：停止失败通知，减少资源消耗，保持代码质量检查
