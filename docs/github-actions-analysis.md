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
| `storybook.yml` | 定时 | Storybook 构建部署 | - |
| `update-node-popularity.yml` | 定时 | 更新节点流行度数据 | - |

### 2. 失败原因分析

`playwright-test-performance.yml` 及其他工作流失败的主要原因：

1. **缺少必需的 Secrets**
   - 性能测试工作流需要以下 secrets：
     - `CURRENTS_RECORD_KEY`
     - `QA_PERFORMANCE_METRICS_WEBHOOK_URL`
     - `QA_PERFORMANCE_METRICS_WEBHOOK_USER`
     - `QA_PERFORMANCE_METRICS_WEBHOOK_PASSWORD`
     - `N8N_LICENSE_ACTIVATION_KEY`
     - `N8N_ENCRYPTION_KEY`
   - Fork 的仓库默认不会复制这些敏感配置

2. **自定义 Runner 不可用**
   - 工作流使用自定义 runner：`blacksmith-2vcpu-ubuntu-2204`
   - 这是 n8n 官方仓库的专用 runner，fork 仓库无法访问

3. **云服务依赖**
   - Benchmark 任务需要 Azure 云环境和相关凭证
   - 需要特定的云资源配置

4. **第三方服务依赖**
   - Chromatic 视觉测试服务
   - Storybook 部署服务
   - 需要对应的 API keys 和账号配置

## 解决方案

### 已执行操作（2025-12-31）

已将以下 10 个定时任务工作流移动到 `.github/workflows-disabled/` 目录：

1. `playwright-test-performance.yml` - Playwright 性能测试
2. `benchmark-nightly.yml` - 夜间性能基准测试
3. `benchmark-destroy-nightly.yml` - 清理基准测试环境
4. `test-workflows-nightly.yml` - 夜间工作流测试
5. `chromatic.yml` - Chromatic 视觉测试
6. `check-documentation-urls.yml` - 文档链接检查
7. `ci-evals.yml` - CI 评估测试
8. `ci-postgres-mysql.yml` - 数据库兼容性测试
9. `storybook.yml` - Storybook 构建
10. `update-node-popularity.yml` - 更新节点流行度

### 效果

- ✅ 停止每日自动运行的定时任务
- ✅ 消除 GitHub Actions 失败通知邮件
- ✅ 节省 GitHub Actions 运行配额
- ✅ 保留工作流文件以备将来使用（在 workflows-disabled 目录）
- ✅ 保留 PR 触发的 CI 检查功能

### 保留的工作流

以下工作流仍然保留并正常运行：

- `ci-pull-requests.yml` - PR 检查
- `ci-master.yml` - master 分支 CI
- `linting-reusable.yml` - 代码检查
- `units-tests-reusable.yml` - 单元测试
- 其他按需触发的工作流

### 恢复方法

如果将来需要恢复某个工作流，只需将对应文件从 `.github/workflows-disabled/` 移回 `.github/workflows/` 即可：

```bash
# 例如恢复性能测试
mv .github/workflows-disabled/playwright-test-performance.yml .github/workflows/
git add .github/workflows/playwright-test-performance.yml
git commit -m "恢复 Playwright 性能测试工作流"
git push
```

## 后续建议

1. **定期同步上游更新时**：
   - 检查 `.github/workflows/` 中是否有新增的定时任务
   - 根据需要决定是否保留或移动到 `workflows-disabled/`

2. **如果需要完整的 CI/CD**：
   - 配置所有必需的 Secrets
   - 修改工作流使用标准 GitHub runners（`ubuntu-latest`）
   - 移除或替换第三方服务依赖

3. **监控邮件通知**：
   - 观察是否还有其他工作流失败通知
   - 如有，可以采用相同方式处理
