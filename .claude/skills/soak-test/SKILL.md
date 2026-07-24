---
name: soak-test
description: "为长时间游玩生成浸泡测试协议。定义长时间游玩期间需要观察、测量和记录的内容，以发现缓慢泄漏、疲劳效应和仅在持续游玩后出现的边界情况。主要用于 Polish 和 Release 阶段。"
argument-hint: "[duration: 30m | 1h | 2h | 4h] [focus: memory | stability | balance | all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: sonnet
---

# 浸泡测试

浸泡测试（也称耐久测试）是带有特定观察目标的长时间游玩。与冒烟检查
（覆盖广泛的关键路径，约 10 分钟）或单功能试玩（约 30 分钟）不同，
浸泡测试会持续 **30 分钟到数小时**，以发现：

- **内存泄漏** — 仅在场景切换后出现的堆内存逐渐增长
- **性能漂移** — 随时间推移不断恶化的帧时间下降
- **状态累积缺陷** — 仅在某项机制重复 N 次后出现的问题
  （背包已满、分数溢出、AI 状态损坏）
- **乐趣疲劳** — 初次游玩时感觉良好，但长时间游玩后变得重复的机制
- **内容耗尽** — 玩家不再遇到新内容的时间点

**本技能生成观察协议和分析框架，实际游玩由人类完成。**

**输出：** `production/qa/soak-test-[date]-[duration].md`

**何时运行：**
- Polish 阶段，在 `/gate-check release` 之前
- 修复内存或稳定性问题后（回归浸泡测试）
- 尚未正式跟踪长时间游玩时

---

## 1. 解析参数

**时长**（默认：`1h`）：
- `30m` — 短时浸泡；适合测试单项机制或场景
- `1h` — 标准浸泡；覆盖最常见的泄漏类别
- `2h` — 延长浸泡；建议用于首次完整的 Polish 浸泡测试
- `4h` — 深度浸泡；采用长时游玩设计的游戏（RPG、模拟游戏）必须使用

**重点**（默认：`all`）：
- `memory` — 重点关注堆大小、对象数量和泄漏模式
- `stability` — 重点检测崩溃、冻结和卡死
- `balance` — 重点关注乐趣疲劳、内容耗尽和难度感受
- `all` — 以上全部

---

## 2. 加载上下文

读取：
- `.claude/docs/technical-preferences.md` — 引擎（用于提供引擎专属的内存监控
  指导）、性能预算（内存上限、目标 FPS）
- `design/gdd/game-concept.md` — 预期单次游玩时长（用于与浸泡测试时长比较）、
  核心循环说明
- `production/playtests/` 中最新的文件 — 以往试玩发现
  （避免重复记录已知问题）
- `production/qa/qa-plan-*.md` 中最新的文件 — 当前迭代的测试覆盖范围
  （用于了解已经正式测试的内容与浸泡测试覆盖内容之间的差异）

记录 technical-preferences.md 中的所有性能预算目标：
- 内存上限：[N MB, or "not set"]
- 目标 FPS：[N, or "not set"]
- 帧预算：[N ms, or "not set"]

---

## 3. 定义观察检查点

根据时长生成定时检查点：

**30m 浸泡测试**：T+0, T+10, T+20, T+30
**1h 浸泡测试**：T+0, T+15, T+30, T+45, T+60
**2h 浸泡测试**：T+0, T+20, T+40, T+60, T+80, T+100, T+120
**4h 浸泡测试**：T+0, T+30, T+60, T+90, T+120, T+180, T+240

在每个检查点，观察者记录第 4 阶段定义的观察项目。

---

## 4. 生成浸泡测试协议

### 内存/稳定性观察项目（如果 focus = memory 或 all）

引擎专属监控指导：

**Godot 4:**
- 打开 Debugger → Monitors 选项卡；在各检查点跟踪 `Memory → Static Memory` 和
  `Object Count → Objects`
- 记录：Static Memory (KB)、Object Count、Orphan Nodes 数量
- 警报阈值：最初 15 分钟后，内存相对 T+0 增长 > 20%
  （加载时出现一定增长属于预期；持续增长表示存在泄漏）
- 注意：在 Godot 4.6 中，`Performance.get_monitor(Performance.MEMORY_STATIC)`
  返回字节数

**Unity:**
- 打开 Memory Profiler（Window → Analysis → Memory Profiler）
- 在每个检查点记录：Total Reserved Memory (MB)、GC Allocated (MB)、Object Count
- 警报阈值：GC Allocated 连续 3 个以上检查点单调增长

**Unreal Engine:**
- 在每个检查点使用控制台命令 `stat memory`
- 记录：Physical Memory Used (MB)、Physical Memory Available
- 警报阈值：整个浸泡测试期间 Physical Memory Used 增长 > 50MB

### 稳定性观察项目（如果 focus = stability 或 all）

在每个检查点记录：
- [ ] 自上一个检查点以来未发生崩溃、卡死或冻结
- [ ] 帧率仍在目标预算内（[target FPS] fps）
- [ ] 音频仍正常播放（没有不同步或静音）
- [ ] 所有 HUD 元素仍正常渲染
- [ ] 输入响应符合预期（没有输入丢失或延迟峰值）

### 平衡性/疲劳观察项目（如果 focus = balance 或 all）

在每个检查点收集主观观察：
- [ ] 核心机制仍让人感到有回报（Y/N）
- [ ] 感受到的难度水平：[too easy / appropriate / too hard]
- [ ] 自上一个检查点以来，是否出现“这个我见过”的时刻？（新内容耗尽）
- [ ] 自上一个检查点以来，是否有感到沮丧的时刻？记录原因。
- [ ] 自上一个检查点以来，是否有投入度达到峰值的时刻？记录原因。

---

## 5. 生成协议文档

```markdown
# 浸泡测试协议

> **日期**：[date]
> **时长**：[duration]
> **重点**：[memory | stability | balance | all]
> **引擎**：[engine]
> **生成者**：/soak-test

---

## 游玩前设置

开始浸泡测试前：

- [ ] 游戏通过**全新启动**运行（不是从先前的游玩恢复）
- [ ] 所有后台应用程序均已关闭（尽量减少操作系统内存干扰）
- [ ] 性能监控工具已打开并正在记录：
  - **Godot**：Debugger → Monitors 选项卡 → Memory 区域可见
  - **Unity**：Memory Profiler 窗口已打开
  - **Unreal**：控制台中已准备好 `stat memory`
- [ ] 已确认浸泡测试目标：[session design intent from game concept]
- [ ] 需要留意的以往已知问题：[from most recent playtest / qa-plan]

---

## 基线（T+0）— 游玩前记录

| 指标 | 基线值 |
|--------|---------------|
| 内存/堆 | [record before first frame of gameplay] |
| 对象数量 | [record] |
| FPS（最初 30 秒） | [record] |
| [Engine-specific metric] | [record] |

---

## 检查点日志

### T+[N] 分钟

**内存/稳定性** *（如适用）*：

| 指标 | 值 | 相对基线的 Δ | 警报？ |
|--------|-------|-----------------|--------|
| 内存/堆 | | | |
| 对象数量 | | | |
| FPS | | | |
| 崩溃/卡死 | | | |

**稳定性检查**：
- [ ] 自上一个检查点以来未发生崩溃或卡死
- [ ] 帧率在预算内（目标为 [N] fps）
- [ ] 音频正常
- [ ] HUD 正常渲染
- [ ] 输入正常响应

**平衡性/疲劳** *（如适用）*：
- 核心机制仍让人感到有回报：Y / N
- 难度感受：too easy / appropriate / too hard
- 值得注意的时刻：[note any peak engagement or frustration]
- 内容耗尽迹象：Y / N — [describe]

**自由观察**：
*（记录自上一个检查点以来观察到的任何意外情况）*

---

[Repeat Checkpoint Log section for each timed checkpoint]

---

## 游玩后分析

### 内存趋势

| 检查点 | 内存 | 推算的 Δ/hr |
|------------|--------|-------------------|
| T+0 | | |
| [T+N] | | |

**检测到泄漏？** Y / N
**按当前速率估算的 OOM 时间**：[N hours / not applicable]

### 稳定性摘要

崩溃总数：[N]
卡死总数：[N]
观察到的最低 FPS：[checkpoint] 时为 [N] fps
性能下降：stable / mild / severe

### 平衡性/疲劳摘要

乐趣曲线：[engaged throughout / fatigue onset at T+N / repetitive from start]
内容耗尽点：[never / at T+N / early]
难度曲线：[appropriate / too easy throughout / difficulty spike at T+N]

### 发现的问题

| ID | 严重程度 | 检查点 | 描述 |
|----|----------|------------|-------------|
| SOAK-001 | S[1-4] | T+[N] | [description] |

---

## 结论：PASS / PASS WITH CONCERNS / FAIL

**PASS**：未检测到泄漏，稳定性保持良好，乐趣因素一致
**PASS WITH CONCERNS**：发现轻微漂移或疲劳；可在 Polish 阶段处理
**FAIL**：确认存在内存泄漏、稳定性失效或严重的乐趣疲劳

---

## 签核

- **测试员**：[name] — [date]
- **QA 负责人审查**：[name] — [date]
```

---

## 6. 写入输出

在对话中展示协议摘要，然后询问：

“可以将此浸泡测试协议写入
`production/qa/soak-test-[date]-[duration].md` 吗？”

仅在获得批准后写入。

写入后：

“协议已写入。要运行浸泡测试：
1. 打开文件并遵循‘游玩前设置’检查清单
2. 游玩时记录每个检查点
3. 完成后填写‘游玩后分析’部分
4. 将‘发现的问题’中的缺陷归档到 `production/qa/bugs/`
5. 游玩结束后运行 `/bug-triage sprint`，以纳入所有 S1/S2 问题

如果结论为 FAIL，请在修复问题后再次运行 `/smoke-check`。”

---

## 协作协议

- **本技能生成协议，由人类执行** — 切勿尝试自动运行浸泡测试。
  这些观察需要人类观察者完成。
- **时长应匹配游戏的单次游玩设计** — 一局 5 分钟的游戏不需要 4h 浸泡测试；
  城市建造游戏可能需要。请酌情判断，不清楚时先询问。
- **首次浸泡测试的 focus 应为 `all`** — 窄重点（仅内存）用于特定修复后的
  回归浸泡测试，不用于首次测试
- **写入前先询问** — 创建协议文件前始终进行确认
