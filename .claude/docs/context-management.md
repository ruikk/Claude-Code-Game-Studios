# 上下文管理（Context Management）

在 Claude Code 会话中，上下文是最关键的资源。请主动管理它。

## 文件承载状态（File-Backed State，首要策略）

**文件才是记忆，不是对话。** 对话是短暂的，可能会被压缩或丢失。磁盘上的文件会在上下文压缩和会话崩溃后持续保留。

### 会话状态文件（Session State File）

将 `production/session-state/active.md` 维护为一个动态检查点。每次达到重要里程碑后都要更新它：

- 设计章节已获批准并写入文件
- 已做出架构决策
- 达成实现里程碑
- 获得测试结果

状态文件应包含：当前任务、进度检查清单、已做出的关键决策、正在处理的文件、以及待解问题。

### 状态栏区块（Status Line Block，仅 Production+）

当项目处于 Production、Polish 或 Release 阶段时，在 `active.md` 中加入结构化状态区块，供状态栏脚本解析：

```markdown
<!-- STATUS -->
Epic: Combat System
Feature: Melee Combat
Task: Implement hitbox detection
<!-- /STATUS -->
```

- 三个字段（Epic、Feature、Task）均为可选——只填写适用项
- 切换关注领域时更新该区块
- 状态栏会将其显示为面包屑：`Combat System > Melee Combat > Hitboxes`
- 当没有活动工作焦点时，移除该区块或清空其内容

发生任何中断（上下文压缩、崩溃、`/clear`）后，先读取状态文件。

### 增量式写文件（Incremental File Writing）

在创建多章节文档（设计文档、架构文档、世界观/lore 条目）时：

1. 立即创建文件骨架（所有章节标题 + 空内容）
2. 在对话中一次只讨论和起草一个章节
3. 每个章节一经批准就立刻写入文件
4. 每完成一个章节就更新会话状态文件
5. 章节写入后，关于该章节的先前讨论即可安全压缩——决策已经落在文件中

这样可使上下文窗口仅保留*当前*章节讨论（约 3-5k tokens），而不是整个文档的对话历史（约 30-50k tokens）。

## 主动压缩（Proactive Compaction）

- 在上下文使用达到约 60-70% 时**主动压缩**，不要等到触顶再被动处理
- 在无关任务之间，或连续 2 次以上修正失败后，使用 **`/clear`**
- **自然压缩点：**某章节写入文件后、提交后、任务完成后、开始新主题前
- **聚焦压缩：**`/compact Focus on [current task] — sections 1-3 are written to file, working on section 4`

## 按任务类型划分的上下文预算（Context Budgets by Task Type）

- 轻量（阅读/评审）：启动约 3k tokens
- 中等（实现功能）：约 8k tokens
- 重量（多系统重构）：约 15k tokens

## 子代理委派（Subagent Delegation）

使用子代理进行调研和探索，以保持主会话整洁。
子代理在独立上下文窗口中运行，只返回摘要：

- 当你需要跨多个文件调查、探索陌生代码，或进行会消耗 >5k tokens 文件读取量的研究时，**使用子代理**
- 当你明确知道只需查看哪 1-2 个文件时，**直接读取**
- 子代理不会继承对话历史——请在提示词中提供完整上下文

## 压缩说明（Compaction Instructions）

当上下文被压缩时，在摘要中保留以下内容：

- 指向 `production/session-state/active.md` 的引用（通过它恢复状态）
- 本次会话中被修改文件的清单及其用途
- 任何架构决策及其理由
- 活跃 sprint（迭代）任务及其当前状态
- 代理调用及其结果（成功/失败/阻塞）
- 测试结果（通过/失败数量、具体失败项）
- 等待用户输入的未解决阻塞项或问题
- 当前任务及所处步骤
- 当前文档中哪些章节已写入文件、哪些仍在进行中

**压缩后：**读取 `production/session-state/active.md` 与所有正在处理的文件，以恢复完整上下文。决策以文件为准；对话历史是次要的。

## 会话崩溃后的恢复（Recovery After Session Crash）

如果会话中断（“prompt too long”）或你开启新会话以继续工作：

1. `session-start.sh` hook 会自动检测并预览 `active.md`
2. 读取完整状态文件获取上下文
3. 读取状态中列出的未完成文件
4. 从下一个未完成章节或任务继续
