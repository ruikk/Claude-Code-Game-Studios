---
name: hotfix
description: "紧急修复工作流,绕过正常迭代流程并保留完整审计记录。创建热修复分支,跟踪审批,并确保修复正确回传。"
argument-hint: "[bug-id 或描述]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

> **仅显式调用**:此技能仅应在用户通过 `/hotfix` 显式请求时运行。不要基于上下文匹配自动调用。

## Phase 1: 评估严重性

读取 bug 描述或 ID。使用以下标准评估严重性:

- **S1(关键)**:游戏无法游玩、数据丢失、安全漏洞
- **S2(重大)**:重要功能损坏,存在变通方案
- **S3 或更低**:次要问题 —— 适用正常 bug 修复工作流

通过 `AskUserQuestion` 确认:
- 提示:"我已评估为 **[评估的严重性]** —— [简要理由]。确认严重性以继续:"
- 选项:
  - `[A] S1(关键)—— 游戏无法游玩、数据丢失或安全问题`
  - `[B] S2(重大)—— 重要功能损坏,存在变通方案`
  - `[C] S3 或更低 —— 重定向到正常 bug 修复工作流`

如果选 [C]:停止。结论:**REDIRECTED** —— 对 S3 及以下使用正常 bug 修复工作流。

---

## Phase 2: 创建热修复记录

起草热修复记录:

```markdown
## Hotfix: [简短描述]
Date: [日期]
Severity: [S1/S2]
Reporter: [发现者]
Status: IN PROGRESS

### Problem
[对损坏内容和玩家影响的清晰描述]

### Root Cause
[在调查期间填写]

### Fix
[在实现期间填写]

### Testing
[测试了什么以及如何测试]

### Approvals
- [ ] 修复已由 lead-programmer 审查
- [ ] 回归测试通过(qa-tester)
- [ ] 发布已批准(producer)

### Rollback Plan
[如果修复导致新问题,如何回退]
```

询问:"我可以将此内容写入 `production/hotfixes/hotfix-[date]-[short-name].md` 吗?"

如果是,创建所需目录并写入文件。

---

## Phase 3: 创建热修复分支

检查这是否是 git 仓库:

`Bash: git rev-parse --is-inside-work-tree 2>/dev/null`

如果此命令失败或返回空:记录"非 git 仓库 —— 请手动创建分支。"并跳过分支创建。

如果检查通过,在创建分支之前使用 `AskUserQuestion`:
- 提示:"准备从 [base-ref] 创建热修复分支 'hotfix/[short-name]'?"
- 选项:
  - `[A] 是 —— 创建分支`
  - `[B] 使用不同的基础引用 —— 我来指定`
  - `[C] 跳过 —— 我自己创建分支`

仅当用户选择 [A] 时运行 `git checkout -b hotfix/[short-name] [base-ref]`。如果选 [B]:向用户询问基础引用,然后使用该引用运行命令。如果选 [C]:跳过分支创建并进入 Phase 4。

---

## Phase 4: 调查和实现

专注于解决问题的最小变更。不要在热修复中重构、清理或添加功能。

通过运行受影响系统的针对性测试来验证修复。检查相邻系统的回归。

用根本原因、修复细节和测试结果更新热修复记录。

---

## Phase 5: 收集审批

使用 Task 工具并行请求签核:

- `subagent_type: lead-programmer` —— 审查修复的正确性和副作用
- `subagent_type: qa-tester` —— 在受影响系统上运行针对性回归测试
- `subagent_type: producer` —— 批准部署时机和沟通计划

三个都必须返回 APPROVE 才能继续。如果任何返回 CONCERNS 或 REJECT,不要部署 —— 呈现问题并先解决它。

---

## Phase 5b: QA 重入口门禁

审批后,确定部署热修复前所需的 QA 范围。通过 Task 生成 `qa-lead`,提供:
- 热修复描述和受影响系统
- Phase 5 的回归测试结果
- 所有触及变更文件的系统列表(使用 Grep 查找调用者)

询问 qa-lead:**一次完整 smoke check 就够了,还是此修复需要针对性的 team-qa 通过?**

应用结论:
- **Smoke check 足够** —— 对热修复构建运行 `/smoke-check`。如果 PASS,进入 Phase 6。
- **需要针对性 QA 通过** —— 运行 `/team-qa [affected-system]`,仅限定于变更的系统。如果 QA 返回 APPROVED 或 APPROVED WITH CONDITIONS,进入 Phase 6。
- **需要完整 QA** —— 触及核心系统的 S1 修复可能需要完整的 `/team-qa sprint`。这会延迟部署但能防止糟糕的补丁。

不要跳过此门禁。破坏了其他东西的热修复比原始 bug 更糟糕。

---

## Phase 6: 更新 Bug 状态并部署

如果存在原始 bug 文件,更新它:

```markdown
## Fix Record
**Fixed in**: hotfix/[branch-name] — [commit hash 或描述]
**Fixed date**: [日期]
**Status**: Fixed — Pending Verification
```

在 bug 文件头部设置 `**Status**: Fixed — Pending Verification`。

输出部署摘要:

```
## Hotfix Ready to Deploy: [short-name]

**Severity**: [S1/S2]
**Root cause**: [一行]
**Fix**: [一行]
**QA gate**: [Smoke check PASS / Team-QA APPROVED]
**Approvals**: lead-programmer ✓ / qa-tester ✓ / producer ✓
**Rollback plan**: [来自 Phase 2 记录]

Merge to: 发布分支 AND 开发分支
Next: 部署后运行 /bug-report verify [BUG-ID] 以确认解决
```

### 规则
- 热修复必须是修复问题的最小变更 —— 不清理、不重构
- 每个热修复在部署前必须有已记录的回退计划
- 热修复分支合并到发布分支和开发分支两者
- 所有热修复必须在 48 小时内进行事后评审
- 如果修复复杂到需要超过 4 小时,升级到 `technical-director`

---

## Phase 7: 部署后验证

部署后,运行 `/bug-report verify [BUG-ID]` 以确认修复在部署的构建中解决了问题。

如果 VERIFIED FIXED:运行 `/bug-report close [BUG-ID]` 正式关闭。
如果 STILL PRESENT:热修复失败 —— 立即重新打开,评估回退,并升级。

在 48 小时内使用 `/retrospective hotfix` 安排事后评审。

使用 `AskUserQuestion`:
- 提示:"热修复完成。下一步是什么?"
- 选项:
  - `[A] 运行 /smoke-check 验证修复`
  - `[B] 运行 /patch-notes 记录此热修复`
  - `[C] 到此为止`
