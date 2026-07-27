# 技能测试规范：/team-level

## 技能摘要

为单个关卡或区域编排完整关卡设计团队。协调 narrative-director、world-builder、level-designer、systems-designer、art-director、accessibility-specialist 和 qa-tester，执行五个顺序步骤，其中步骤 4 并行。将全部输出汇编为 `design/levels/[level-name].md`。每次步骤转换使用 `AskUserQuestion`，所有写入委托给子代理。生成 COMPLETE / BLOCKED 摘要并交接到 `/design-review`、`/dev-story`、`/qa-plan`。

---

## 静态断言（结构）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段/步骤标题（步骤 1 至步骤 5 均存在）
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含“May I write”或“File Write Protocol”，写入委托给子代理，编排器不直接写文件
- [ ] 末尾有下一步交接（引用 `/design-review`、`/dev-story`、`/qa-plan`）
- [ ] 存在 Error Recovery Protocol 章节，且包含全部四个恢复步骤
- [ ] 步骤转换时使用 `AskUserQuestion`，在继续前取得用户批准
- [ ] 步骤 4 明确标记为并行（art-director 和 accessibility-specialist 同时运行）
- [ ] 上下文收集读取：`design/gdd/game-concept.md`、`design/gdd/game-pillars.md`、`design/levels/`、`design/narrative/` 及相关世界构建文档
- [ ] 团队组成列出全部七个角色（narrative-director、world-builder、level-designer、systems-designer、art-director、accessibility-specialist、qa-tester）
- [ ] accessibility-specialist 输出包含严重程度评级（BLOCKING / RECOMMENDED / NICE TO HAVE）
- [ ] 最终关卡设计文档保存到 `design/levels/[level-name].md`

---

## 测试用例

### 用例 1：成功路径——团队成员均产出内容，文档汇编并保存

**夹具：**
- `design/gdd/game-concept.md` 存在且已有内容
- `design/gdd/game-pillars.md` 存在
- `design/levels/` 目录存在（可以包含其他关卡文档）
- `design/narrative/` 目录存在且包含相关叙事文档

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 上下文收集：编排器读取 game-concept.md、game-pillars.md、`design/levels/` 中的现有关卡文档、`design/narrative/` 中的叙事文档，以及森林区域的世界构建文档
2. 步骤 1：启动 narrative-director，定义叙事目的、关键角色、对话触发器和情感弧线；启动 world-builder，提供背景知识、环境叙事机会和世界规则；用 `AskUserQuestion` 确认步骤 1 输出后再进入步骤 2
3. 步骤 2：启动 level-designer，设计空间布局（关键路径、可选路径、秘密区域）、节奏曲线、遭遇、谜题、入口/出口及相邻区域连接；用 `AskUserQuestion` 确认布局后再进入步骤 3
4. 步骤 3：启动 systems-designer，规定敌人构成、战利品表、难度平衡、区域机制和资源分布；用 `AskUserQuestion` 确认系统后再进入步骤 4
5. 步骤 4：并行启动 art-director 和 accessibility-specialist；art-director 负责视觉主题、色板、光照、资产清单和 VFX 需求；accessibility-specialist 负责导航清晰度、色盲安全性和认知负荷检查，每项问题评级为 BLOCKING / RECOMMENDED / NICE TO HAVE；用 `AskUserQuestion` 在步骤 5 前展示两者输出
6. 步骤 5：启动 qa-tester，编写关键路径、边界情况（流程跳过、软锁）的测试用例、试玩清单和验收标准
7. 编排器将团队输出汇编为关卡设计文档格式；子代理先询问“May I write to `design/levels/forest-dungeon.md`?”；随后保存文件
8. 汇总报告包含区域概览、遭遇数量、预计资产清单、叙事节拍、跨团队依赖，结论为 COMPLETE
9. 列出下一步：`/design-review design/levels/forest-dungeon.md`、`/dev-story`、`/qa-plan`

**断言：**
- [ ] 在启动任何代理前，已在上下文收集期间读取全部五个来源
- [ ] 步骤 1 同时启动 narrative-director 和 world-builder（可以顺序或并行，但两者都必须在步骤 2 前完成）
- [ ] 每个步骤门均调用 `AskUserQuestion`（至少在步骤 1、步骤 2、步骤 3、步骤 4 之后）
- [ ] 同时启动步骤 4 代理（art-director、accessibility-specialist）
- [ ] 所有文件写入均委托给子代理——编排器不直接写入
- [ ] 关卡文档保存到 `design/levels/forest-dungeon.md`（由参数转换为 slug）
- [ ] 最终汇总报告包含 COMPLETE 结论
- [ ] 下一步包含 `/design-review`、`/dev-story`、`/qa-plan`
- [ ] 汇总报告包含：区域概览、遭遇数量、预计资产清单、叙事节拍

---

### 用例 2：代理受阻（world-builder）——生成记录缺口的部分报告

**夹具：**
- `design/gdd/game-concept.md` 存在
- 森林区域的世界构建文档不存在
- world-builder 代理返回 BLOCKED：“未找到森林区域的世界构建文档——无法提供背景知识上下文”

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 上下文收集完成；记录缺失的世界构建文档
2. 步骤 1——narrative-director 成功完成；启动 world-builder 并返回 BLOCKED
3. 触发 Error Recovery Protocol：“world-builder: BLOCKED——没有森林区域的世界构建文档”
4. `AskUserQuestion` 提供以下选项：
    - (a) 跳过 world-builder，并在关卡文档中记录背景知识缺口
    - (b) 缩小范围后重试（world-builder 仅关注可从 game-concept.md 推断的内容）
    - (c) 暂停并先创建世界构建文档
5. 如果用户选择 (a)：流水线仅使用 narrative-director 上下文继续步骤 2–5；关卡文档包含明确标记的缺口章节：“世界构建上下文：未提供——请参阅开放依赖项”
6. 生成最终报告：记录部分输出，将 world-builder 章节标记为 BLOCKED，总体结论为 BLOCKED

**断言：**
- [ ] world-builder 失败时立即展示 BLOCKED 消息——未经用户输入不得开始步骤 2
- [ ] `AskUserQuestion` 至少提供三个选项（跳过 / 重试 / 停止）
- [ ] 生成部分报告——不丢弃 narrative-director 已完成的工作
- [ ] 关卡文档（如已汇编）明确标记缺失的世界构建上下文缺口
- [ ] world-builder 仍未解决时总体结论为 BLOCKED（而非 COMPLETE）
- [ ] 技能不会静默编造背景知识内容来填补缺口

---

### 用例 3：无参数——显示用法指导

**夹具：**
- 任意项目状态

**输入：** `/team-level`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法消息，说明必需参数（要设计的关卡名称或区域）
3. 提供调用示例：`/team-level tutorial`、`/team-level forest dungeon`、`/team-level final boss arena`
4. 技能退出，不读取任何项目文件或启动任何子代理

**断言：**
- [ ] 未提供参数时，技能不会启动任何子代理
- [ ] 用法消息包含 frontmatter 中的 argument-hint 格式
- [ ] 至少展示一个有效调用示例
- [ ] 失败前不读取 GDD 或关卡文件
- [ ] 不显示结论（流水线从未启动）

---

### 用例 4：无障碍审查门——签核前暴露阻塞问题

**夹具：**
- 步骤 1–3 成功完成
- `design/accessibility-requirements.md` 中记录的等级为 Enhanced
- accessibility-specialist（步骤 4，并行）指出一个 BLOCKING 问题：穿过森林地城的关键路径要求玩家仅凭颜色区分两种环境危害（毒池和浅水），没有形状、图标或音频提示进行区分

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 步骤 1–3 完成；开始步骤 4 并行阶段
2. accessibility-specialist 返回：BLOCKING 问题——“关键路径危害区分仅依赖颜色（毒池和浅水）。根据 Enhanced 无障碍等级，必须增加形状、图标或音频提示。”
3. art-director 返回步骤 4 输出（完成）
4. 技能通过 `AskUserQuestion` 展示步骤 4 的两个结果，并突出显示 BLOCKING 问题
5. `AskUserQuestion` 提供：
    - (a) 在步骤 5 前将 level-designer 和 art-director 退回，重新设计危害的视觉/音频语言
    - (b) 将其记录为已知无障碍缺口，并记录该问题后继续步骤 5
6. 技能不会静默越过 BLOCKING 问题继续执行
7. 如果用户选择 (a)：启动 level-designer 和 art-director 修订，并重新运行步骤 4 的无障碍检查
8. 无论用户选择什么，最终报告都包含 BLOCKING 问题及其解决状态

**断言：**
- [ ] BLOCKING 无障碍问题不被视为建议——而是作为阻塞项展示
- [ ] `AskUserQuestion` 展示具体问题文本（而不只是“发现无障碍问题”）
- [ ] 未经用户确认 BLOCKING 问题，步骤 5（qa-tester）不会开始
- [ ] 提供修订路径：继续之前可以退回 level-designer + art-director
- [ ] 最终报告包含无障碍问题及其解决状态
- [ ] accessibility-specialist 阻塞时，不丢弃 art-director 已完成的输出

---

### 用例 5：循环关卡引用——标记相邻区域依赖

**夹具：**
- 步骤 1–3 正在进行
- level-designer（步骤 2）生成的布局指定了连接到“水晶洞窟”（相邻区域）的入口/出口点
- `design/levels/crystal-caves.md` 不存在——水晶洞窟区域尚未设计

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 步骤 2——level-designer 生成包含以下内容的布局：“西侧出口连接到 crystal-caves 入口点 A”
2. 编排器（或 level-designer 子代理）检查 `design/levels/` 中的 `crystal-caves.md`；未找到文件
3. 展示依赖缺口：“关卡引用了 crystal-caves 作为相邻区域，但 `design/levels/crystal-caves.md` 不存在”
4. `AskUserQuestion` 提供以下选项：
    - (a) 使用占位引用继续——在关卡文档中将该依赖记录为 UNRESOLVED
    - (b) 暂停并先运行 `/team-level crystal caves` 建立该区域
5. 技能不会为满足引用而编造水晶洞窟内容
6. 如果用户选择 (a)：汇编关卡文档，并将西侧出口标记为“→ crystal-caves（UNRESOLVED——区域尚未设计）”；在汇总报告的开放依赖章节中标记
7. 最终报告包含开放的跨关卡依赖章节

**断言：**
- [ ] 技能通过检查 `design/levels/` 检测缺失的相邻区域，而不是假定稍后会创建
- [ ] 技能不会编造水晶洞窟内容（背景知识、布局、连接）来解决引用
- [ ] `AskUserQuestion` 提供引用 `/team-level` 的“先设计水晶洞窟”选项
- [ ] 如果用户使用占位符继续，关卡文档明确将西侧出口标记为 UNRESOLVED
- [ ] 汇总报告包含开放的跨关卡依赖章节，并列出未解决的引用
- [ ] 循环或前向引用不会导致技能循环或崩溃

---

## 协议合规性

- [ ] 每次步骤转换使用 `AskUserQuestion`——用户批准后流水线才继续
- [ ] 所有文件写入均通过 Task 委托给子代理——编排器不直接调用 Write 或 Edit
- [ ] 遵循 Error Recovery Protocol：展示 → 评估 → 提供选项 → 部分报告
- [ ] 按技能规范并行启动步骤 4 代理（art-director、accessibility-specialist）
- [ ] 即使代理处于 BLOCKED，也始终生成部分报告
- [ ] 无障碍 BLOCKING 问题在签核前展示，并要求用户明确确认
- [ ] 结论为 COMPLETE / BLOCKED 之一
- [ ] 输出末尾包含下一步：`/design-review`、`/dev-story`、`/qa-plan`

---

## 覆盖说明

- 步骤 1 中 narrative-director 和 world-builder 可以顺序或并行执行——技能规范会启动两者，但不要求同时启动；要覆盖步骤 1 的并行行为，需要明确的时序断言夹具。
- 受阻 world-builder 用例（用例 2）中的“缩小范围后重试”选项——重试行为本身未深入测试；其完整路径类似于用例 2 和其他 team-* 规范覆盖的代理受阻模式。
- systems-designer（步骤 3）的阻塞场景未单独测试；同样适用 Error Recovery Protocol，且用例 2 已验证该模式。
- 步骤 4 的并行顺序（art-director 先于或后于 accessibility-specialist 完成）不影响结果——无论顺序如何，两者都必须在步骤 5 前返回。
- 用例 1 隐式测试关卡文档的 slug 约定（参数 → 文件名）（`forest dungeon` → `forest-dungeon.md`）；多词 slug 转换边界情况（特殊字符、超长名称）未覆盖。
