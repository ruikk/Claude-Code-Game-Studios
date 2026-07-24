---
name: team-level
description: "协调关卡设计团队：由 level-designer、narrative-director、world-builder、art-director、systems-designer 和 qa-tester 完成区域或关卡的完整创作。"
argument-hint: "[level name or area to design] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---

调用此技能时：

**决策点：** 每次进入下一步骤时，使用 `AskUserQuestion` 将子代理的方案
作为可选项展示给用户。先在对话中写出代理的完整分析，再用简洁标签记录
决定。必须获得用户批准后才能进入下一步。

## 阶段 0：确定审查模式

1. 如果参数中传入了 `--review [mode]`，使用该模式。
2. 否则读取 `production/review-mode.txt`，使用其中指定的模式。
3. 如果仍未指定，则默认为 `lean`。

模式：
- `full`：按说明生成所有总监和主管门禁
- `lean`：跳过总监门禁，PHASE-GATE 类型除外（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo`：完全不生成任何总监门禁；运行技能时不设置代理门禁

保存最终确定的模式，供后续所有阶段使用。

1. **读取参数**，确定目标关卡或区域（例如 `tutorial`、
   `forest dungeon`、`hub town`、`final boss arena`）。

2. **收集上下文**：
   - 读取 `design/gdd/game-concept.md` 中的游戏概念
   - 读取 `design/gdd/game-pillars.md` 中的游戏支柱
   - 读取 `design/levels/` 中已有的关卡文档
   - 读取 `design/narrative/` 中相关的叙事文档
   - 读取该区域所属地域或阵营的世界构建文档

## 如何委派

使用 Task 工具，将每位团队成员生成为子代理：
- `subagent_type: narrative-director`：叙事目的、角色、情感弧线
- `subagent_type: world-builder`：背景设定、环境叙事、世界规则
- `subagent_type: level-designer`：空间布局、节奏、遭遇、导航
- `subagent_type: systems-designer`：敌人编组、掉落表、难度平衡
- `subagent_type: art-director`：视觉主题、配色、光照、资产需求
- `subagent_type: accessibility-specialist`：导航清晰度、色盲友好性、认知负荷
- `subagent_type: qa-tester`：测试用例、边界测试、试玩检查清单

每个代理的提示词中都必须提供完整上下文（游戏概念、游戏支柱、已有的关卡文档和叙事文档）。

3. 按顺序**协调关卡设计团队**：

### 步骤 1：叙事与视觉方向（narrative-director + world-builder + art-director，并行）

同时生成三个代理，在等待任何结果之前先发出全部三个 Task 调用。

生成 `narrative-director` 代理以：
- 定义该区域的叙事目的（这里会发生哪些故事节点？）
- 确定关键角色、对话触发条件和背景设定元素
- 指定情感弧线（玩家进入、探索和离开时应分别有何感受？）

生成 `world-builder` 代理以：
- 提供该区域的背景设定（历史、阵营活动、生态）
- 确定环境叙事机会
- 指定会影响该区域玩法的世界规则

生成 `art-director` 代理以：
- 确立该区域的视觉主题目标，这些目标是布局的输入，而不是布局的输出
- 定义该区域的色温和光照氛围（与相邻区域有何区别？）
- 指定造型语言方向（棱角分明的堡垒？有机洞穴？衰败的宏伟建筑？）
- 列出用于帮助玩家辨别方向的主要视觉地标
- 如果 `design/art/art-bible.md` 存在，则读取该文件，并以既定美术圣经为所有方向的依据

**必须将在步骤 1 中由 art-director 制定的视觉目标传递给步骤 2 的 level-designer**，并将其作为明确约束。布局决策必须在视觉方向的框架内进行，而不是先于视觉方向。

**门禁**：使用 `AskUserQuestion` 展示步骤 1 的全部三项输出（叙事简报、背景设定基础、视觉方向目标），确认后再进入步骤 2。

### 步骤 2：布局与遭遇设计（level-designer）
生成 `level-designer` 代理，并将步骤 1 的完整输出作为上下文：
- 叙事简报（来自 narrative-director）
- 背景设定基础（来自 world-builder）
- **视觉方向目标（来自 art-director）**：布局必须符合这些目标，不得与其冲突

level-designer 应：
- 设计空间布局（关键路径、可选路径、秘密区域），确保主要路线与步骤 1 的视觉地标目标一致
- 定义节奏曲线（紧张峰值、休息区、探索区），并与 narrative-director 制定的情感弧线协调
- 按难度递进安排遭遇
- 设计环境谜题或导航挑战
- 定义用于寻路的兴趣点和地标，这些内容必须与 art-director 指定的视觉地标一致
- 指定入口、出口以及与相邻区域的连接

**相邻区域依赖检查**：布局生成后，在 `design/levels/` 中检查 level-designer 引用的每个相邻区域。如果任一被引用区域的 `.md` 文件不存在，明确指出此缺口：
> "关卡将 [area-name] 引用为相邻区域，但 `design/levels/[area-name].md` 不存在。"

使用 `AskUserQuestion` 提供以下选项：
- (a) 使用占位引用继续，在关卡文档中将该连接标记为 UNRESOLVED，并将其列入总结报告的待解决跨关卡依赖章节
- (b) 暂停，先运行 `/team-level [area-name]` 建立该区域

不得为缺失的相邻区域虚构内容。

**门禁**：使用 `AskUserQuestion` 展示步骤 2 的布局（包括任何尚未解决的相邻区域依赖），确认后再进入步骤 3。

### 步骤 3：系统集成（systems-designer）
生成 `systems-designer` 代理以：
- 指定敌人编组和遭遇公式
- 定义掉落表和奖励位置
- 根据预期的玩家等级和装备平衡难度
- 设计该区域特有的机制或环境危害
- 指定资源分布（生命补给、存档点、商店）

**门禁**：使用 `AskUserQuestion` 展示步骤 3 的输出，确认后再进入步骤 4。

### 步骤 4：制作概念与无障碍设计（art-director + accessibility-specialist，并行）

**注意**：art-director 已在步骤 1 完成方向设计（视觉主题、色彩目标、氛围）。本轮工作针对具体地点的制作概念，即在布局已定稿的前提下，明确每个具体空间的外观。

生成 `art-director` 代理，并提供步骤 2 的最终布局：
- 为关键空间（入口、关键遭遇区域、地标、出口）制作针对具体地点的概念规格
- 指定哪些美术资产为该区域独有，哪些从全局资产池共享
- 定义各关键空间的视线和光照设置（此时应以布局为依据，而非方向性设计）
- 指定该区域布局特有的 VFX 需求（天气体积、粒子、大气效果）
- 标记布局与步骤 1 目标产生视觉方向冲突的地点，并将其作为制作风险提出

并行生成 `accessibility-specialist` 代理以：
- 审查关卡布局的导航清晰度（玩家能否不只依赖颜色辨别方向？）
- 检查关键路径的引导标识除颜色外是否还使用形状、图标或声音提示
- 审查所有谜题机制的认知负荷，标记任何要求同时记住超过 3 种状态的内容
- 检查关键玩法区域是否为色盲玩家提供足够的对比度
- 输出：标注严重程度的无障碍问题清单（BLOCKING / RECOMMENDED / NICE TO HAVE）

等待两个代理都返回结果后再继续。

**门禁**：使用 `AskUserQuestion` 展示步骤 4 的两项结果。如果 accessibility-specialist 返回任何 BLOCKING 问题，必须醒目标出并提供以下选项：
- (a) 在步骤 5 之前返回 level-designer 和 art-director，重新设计被标记的元素
- (b) 将其记录为已知的无障碍缺口，继续进入步骤 5，并在最终报告中明确记录该问题

在用户确认所有 BLOCKING 无障碍问题之前，不得进入步骤 5。

### 步骤 5：QA 规划（qa-tester）
生成 `qa-tester` 代理以：
- 编写关键路径的测试用例
- 识别边界和极端情况（顺序中断、软锁）
- 为该区域创建试玩检查清单
- 定义关卡完成的验收标准

4. **汇编关卡设计文档**，将所有团队输出整合为
   关卡设计模板格式。

收集所有子代理输出后，通过 Task 生成 `level-designer`，由其汇编并编写最终文档：
- 传入：所有子代理的原始输出、关卡简报、游戏支柱和相关 GDD 章节
- 要求 level-designer：汇编为关卡设计文档格式，然后在写入前请求用户批准（"可以将汇编后的关卡设计写入 design/levels/[level-name].md 吗？"）
- 协调器不得直接调用 Write 写入最终文档。

5. **保存到** `design/levels/[level-name].md`（由 level-designer 子代理在用户批准后处理，见上文）。

6. **输出总结**，包括：区域概览、遭遇数量、预估资产清单、叙事节点、
   所有跨团队依赖或待解决问题、待解决的跨关卡依赖（已引用但尚未设计的
   相邻区域，每项均标记为 UNRESOLVED），以及无障碍问题及其解决状态。

## 文件写入协议

所有文件写入（关卡设计文档、叙事文档、测试检查清单）都委派给通过 Task
生成的子代理。每个子代理都必须执行"可以写入 [path] 吗？"协议。
此协调器不直接写入文件。

结论：**COMPLETE**：关卡设计文档已生成，所有团队输出均已汇编。
结论：**BLOCKED**：一个或多个代理受阻；已生成部分报告并列出未解决事项。

## 后续步骤

- 运行 `/design-review design/levels/[level-name].md`，验证已完成的关卡设计文档。
- 设计获批后，运行 `/dev-story` 实现关卡内容。
- 运行 `/qa-plan`，为该关卡生成 QA 测试计划。

## 错误恢复协议

如果任何通过 Task 生成的代理返回 BLOCKED、发生错误或无法完成任务：

1. **立即提出**：在继续后续依赖阶段前，向用户报告"[AgentName]: BLOCKED — [reason]"
2. **评估依赖**：检查后续阶段是否需要受阻代理的输出。如果需要，未经用户决定，不得越过该依赖点继续。
3. **提供选项**：通过 AskUserQuestion 提供以下选择：
   - 跳过此代理，并在最终报告中注明缺口
   - 缩小范围后重试
   - 在此停止，先解决阻塞问题
4. **始终生成部分报告**：输出已经完成的所有内容。不得因为一个代理受阻而丢弃已有工作。

常见阻塞问题：
- 输入文件缺失（找不到故事、缺少 GDD）→ 转到用于创建该文件的技能
- ADR 状态为 Proposed → 不得实现；先运行 `/architecture-decision`
- 范围过大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事的指示冲突 → 明确指出冲突，不要猜测
