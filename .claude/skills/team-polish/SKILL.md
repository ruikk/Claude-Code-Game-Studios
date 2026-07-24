---
name: team-polish
description: "编排打磨团队：协调 performance-analyst、technical-artist、sound-designer 和 qa-tester，对功能或区域进行优化、打磨和加固，使其达到发布质量。"
argument-hint: "[feature or area to polish] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
如果未提供参数，则输出使用说明并退出，不生成任何代理：
> 用法：`/team-polish [feature or area]` — 指定要打磨的功能或区域（例如 `combat`、`main menu`、`inventory system`、`level-1`）。此处不要使用 `AskUserQuestion`；直接输出说明。

使用参数调用此技能时，通过结构化管线编排打磨团队。

**决策点：** 在每次阶段转换时，使用 `AskUserQuestion` 将子代理的提案作为
可选项呈现给用户。先在对话中写出代理的完整分析，再用简洁标签记录决策。
必须获得用户批准后才能进入下一阶段。

## 阶段 0：确定审查模式

1. 如果参数中传入了 `--review [mode]`，则使用该模式。
2. 否则读取 `production/review-mode.txt`，使用其中记录的模式。
3. 否则默认为 `lean`。

模式：
- `full` — 按说明启动所有总监和主管门禁
- `lean` — 跳过总监门禁，除非它们属于 PHASE-GATE 类型（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo` — 完全跳过所有总监门禁；运行技能时不使用任何代理门禁

保存确定的模式，供所有后续阶段使用。

**总监门禁跳过规则：** 在生成任何 Tier 1 总监或主管进行审查前（PHASE-GATE 触发器除外），应用已确定的模式：`solo` 模式下跳过；`lean` 模式下，如果不是 PHASE-GATE，则跳过。

## 团队构成
- **performance-analyst** — 性能分析、优化、内存分析、帧预算
- **engine-programmer** — 引擎级瓶颈：渲染管线、内存、资源加载（当 performance-analyst 发现底层根因时调用）
- **technical-artist** — VFX 打磨、着色器优化、视觉质量
- **sound-designer** — 音频打磨、混音、环境音层、反馈音效
- **tools-programmer** — 内容管线工具验证、编辑器工具稳定性、自动化修复（当打磨区域涉及内容创作工具时调用）
- **qa-tester** — 边界情况测试、回归测试、浸泡测试

## 如何委派

使用 Task 工具将每位团队成员作为子代理启动：
- `subagent_type: performance-analyst` — 性能分析、优化、内存分析
- `subagent_type: engine-programmer` — 针对渲染、内存、资源加载的引擎级修复
- `subagent_type: technical-artist` — VFX 打磨、着色器优化、视觉质量
- `subagent_type: sound-designer` — 音频打磨、混音、环境音层
- `subagent_type: tools-programmer` — 内容管线和编辑器工具验证
- `subagent_type: qa-tester` — 边界情况测试、回归测试、浸泡测试

始终在每个代理的提示词中提供完整上下文（目标功能/区域、性能预算、已知问题）。在管线允许时并行启动相互独立的代理（例如，阶段 3 和阶段 4 可以同时运行）。

## 管线

### 阶段 1：评估
委派给 **performance-analyst**：
- 使用 `/perf-profile` 分析目标功能/区域的性能
- 识别性能瓶颈和帧预算超标问题
- 测量内存使用量并检查泄漏
- 按目标硬件规格进行基准测试
- 输出：包含按优先级排序的优化清单的性能报告

### 阶段 2：优化
委派给 **performance-analyst**（按需配合相关程序员）：
- 修复阶段 1 中发现的性能热点
- 优化绘制调用，减少过度绘制
- 修复内存泄漏并降低分配压力
- 验证优化不会改变游戏行为
- 输出：优化后的代码及优化前后指标

如果阶段 1 发现了引擎级根因（渲染管线、资源加载、内存分配器），则并行将这些修复委派给 **engine-programmer**：
- 优化引擎系统中的热点路径
- 修复核心循环中的分配压力
- 输出：经性能分析器验证的引擎级修复

### 阶段 3：视觉打磨（与阶段 2 并行）
委派给 **technical-artist**：
- 审查 VFX 的质量及其与美术圣经的一致性
- 优化粒子系统和着色器效果
- 在适当位置添加屏幕震动、镜头效果和视觉表现增强
- 确保效果在较低设置下平稳降级
- 输出：打磨后的视觉效果

### 阶段 4：音频打磨（与阶段 2 并行）
委派给 **sound-designer**：
- 审查音频事件的完整性（是否有任何操作缺少声音反馈？）
- 检查音频混音电平，确保相对于整体混音没有声音过响或过轻
- 添加环境音层以营造氛围
- 验证音频能够按空间定位正确播放
- 输出：音频打磨清单和混音说明

### 阶段 5：加固
委派给 **qa-tester**：
- 测试所有边界情况：边界条件、快速输入、异常操作序列
- 浸泡测试：长时间运行该功能，检查是否出现性能或质量衰退
- 压力测试：最大实体数量、最坏情况场景
- 回归测试：验证打磨变更未破坏现有功能
- 在最低规格硬件上测试（如果可用）
- 输出：测试结果及所有遗留问题

### 阶段 6：签核
- 汇总所有团队成员的结果
- 将性能指标与预算进行比较
- 报告：READY FOR RELEASE / NEEDS MORE WORK
- 列出所有遗留问题及其严重程度和建议

## 错误恢复协议

如果任何通过 Task 启动的代理返回 BLOCKED、发生错误或无法完成任务：

1. **立即告知：** 在继续执行依赖阶段前，向用户报告 "[AgentName]: BLOCKED — [reason]"
2. **评估依赖项：** 检查后续阶段是否需要被阻塞代理的输出。如果需要，未经用户确认，不得越过该依赖点继续执行。
3. **提供选项：** 通过 AskUserQuestion 提供以下选择：
   - 跳过此代理，并在最终报告中注明缺失项
   - 缩小范围后重试
   - 在此停止，优先解决阻塞项
4. **始终生成部分报告：** 输出所有已完成的内容。绝不能因一个代理受阻而丢弃工作成果。

常见阻塞项：
- 缺少输入文件（未找到故事、缺少 GDD）→ 转到创建该文件的技能
- ADR 状态为 Proposed → 不要实施；先运行 `/architecture-decision`
- 范围过大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事的指令冲突 → 明确指出冲突，不要猜测

## 文件写入协议

所有文件写入（性能报告、测试结果、证据文档）均委派给通过 Task 启动的
子代理。每个子代理都执行“可以将此内容写入 [path] 吗？”协议。
此编排器不直接写入文件。

## 输出

一份汇总报告，涵盖：优化前后性能指标、视觉打磨变更、音频打磨变更、测试结果和发布就绪度评估。

## 后续步骤

- 如果为 READY FOR RELEASE：运行 `/release-checklist` 进行最终发布前验证。
- 如果为 NEEDS MORE WORK：在 `/sprint-plan update` 中安排遗留问题，并在修复后重新运行 `/team-polish`。
- 移交发布前，运行 `/gate-check` 获取正式的阶段门禁结论。
