# Hook: post-sprint-retrospective

## 触发（Trigger）

在每个迭代（sprint）结束时手动触发（通常由 `producer` agent 或人类开发者调用）。

## 目的（Purpose）

通过分析迭代（sprint）数据，自动生成复盘起点：计划与完成对比、速度变化、缺陷趋势以及常见阻塞项。
这不是 git hook，而是通过 `producer` agent 调用的 workflow hook（工作流钩子）。

## 实现（Implementation）

这是一个 workflow hook（工作流钩子），不是 git hook。通过运行以下命令调用：

```
@producer Generate sprint retrospective for Sprint [N]
```

`producer` agent 应当：

1. 从 `production/sprints/sprint-[N].md` **读取迭代计划**
2. **计算指标**：
   - 计划任务数 vs 完成任务数
   - 计划故事点 vs 完成故事点（若使用）
   - 从上一个迭代（sprint）结转的事项
   - 迭代中途新增任务
   - 任务平均完成时间
3. **分析模式**：
   - 最常见阻塞项
   - 哪个 agent/领域未完成工作最多
   - 哪些估算最不准确
4. **生成复盘文档**：

```markdown
# Sprint [N] Retrospective

## Metrics
| Metric | Value |
|--------|-------|
| Tasks Planned | [N] |
| Tasks Completed | [N] |
| Completion Rate | [X%] |
| Carryover from Previous | [N] |
| New Tasks Added | [N] |
| Bugs Found | [N] |
| Bugs Fixed | [N] |

## Velocity Trend
[Sprint N-2]: [X] | [Sprint N-1]: [Y] | [Sprint N]: [Z]
Trend: [Improving / Stable / Declining]

## What Went Well
- [Automatically detected: tasks completed ahead of estimate]
- [Facilitator adds team observations]

## What Went Poorly
- [Automatically detected: tasks that were carried over or cut]
- [Automatically detected: areas with significant estimate overruns]
- [Facilitator adds team observations]

## Blockers
| Blocker | Frequency | Resolution Time | Prevention |
|---------|-----------|----------------|-----------|

## Action Items for Next Sprint
| # | Action | Owner | Priority |
|---|--------|-------|----------|

## Estimation Accuracy
| Area | Avg Planned | Avg Actual | Accuracy |
|------|------------|-----------|----------|
```

5. **保存**到 `production/sprints/sprint-[N]-retro.md`
