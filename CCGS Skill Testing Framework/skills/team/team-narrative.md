# 技能测试规范：/team-narrative

## 技能摘要

通过五阶段流水线编排叙事团队：叙事方向
（narrative-director）→ 世界基础与对话起草（world-builder 和 writer
并行）→ 关卡叙事整合（level-designer）→ 一致性审查
（narrative-director）→ 打磨与本地化合规（writer、localization-lead
和 world-builder 并行）。每次阶段转换使用 `AskUserQuestion`，以可选选项展示提案。生成叙事汇总报告，
并通过分别执行“May I write?”协议的子代理交付叙事文档。所有阶段成功时结论为 COMPLETE，依赖未解决时为 BLOCKED。
。所有阶段成功时结论为 COMPLETE，依赖未解决时为 BLOCKED。

---

## 静态断言（结构）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含“File Write Protocol”章节
- [ ] 文件写入委托给子代理，编排器不直接写文件
- [ ] 子代理每次写入前执行“May I write to [path]?”
- [ ] 末尾有下一步交接（引用 `/design-review`、`/localize extract`、`/dev-story`）
- [ ] 存在 Error Recovery Protocol 章节
- [ ] 阶段转换前使用 `AskUserQuestion`
- [ ] 阶段 2 明确并行启动 world-builder 和 writer
- [ ] 阶段 5 明确并行启动 writer、localization-lead 和 world-builder

---

## 测试用例

### 用例 1：成功路径——五个阶段完成并交付叙事文档

**夹具：**
- 目标功能有游戏概念和 GDD（例如 `design/gdd/faction-intro.md`）
- 角色语音档案存在（例如 `design/narrative/characters/`）
- 存在可供交叉引用的现有背景知识条目（例如 `design/narrative/lore/`）
- 现有条目与新内容之间不存在背景知识矛盾

**输入：** `/team-narrative faction introduction cutscene for the Ironveil faction`

**预期行为：**
1. 阶段 1：启动 narrative-director；输出定义故事节拍、相关角色、情绪基调和背景依赖的叙事简报
2. `AskUserQuestion` 展示叙事简报；用户批准后才开始阶段 2
3. 阶段 2：并行启动 world-builder 和 writer；world-builder 为 Ironveil faction 生成背景知识条目；writer 使用角色语音档案起草对话
4. `AskUserQuestion` 展示世界基础和对话草稿；用户批准后阶段 3 才开始
5. 阶段 3：启动 level-designer；生成环境叙事布局、触发器放置和节奏计划
6. `AskUserQuestion` 展示关卡叙事计划；用户批准后阶段 4 才开始
7. 阶段 4：narrative-director 根据语音档案审查所有对话，验证背景知识一致性并确认节奏；批准或标记问题
8. `AskUserQuestion` 展示审查结果；用户批准后阶段 5 才开始
9. 阶段 5：并行启动 writer、localization-lead 和 world-builder；writer 执行最终自审；localization-lead 验证 i18n 合规性；world-builder 最终确定正史层级
10. 展示最终汇总报告；子代理写入前询问“May I write the narrative document to [path]?”
11. 结论：COMPLETE

**断言：**
- [ ] 阶段 1 在其他代理之前启动 narrative-director
- [ ] `AskUserQuestion` 出现在阶段 1 输出之后、阶段 2 启动之前
- [ ] 阶段 2 同时发起 world-builder 和 writer 的 Task 调用，而非顺序发起
- [ ] 阶段 2 的 `AskUserQuestion` 获批前不会启动 level-designer
- [ ] 阶段 4 重新启动 narrative-director 执行一致性审查
- [ ] 阶段 5 同时启动 3 个代理（writer、localization-lead、world-builder）
- [ ] 汇总报告包含：叙事简报状态、创建/更新的背景知识条目、已写对话行、关卡叙事整合点、一致性审查结果
- [ ] 编排器不直接写入任何文件
- [ ] 交付后结论为 COMPLETE

---

### 用例 2：发现背景矛盾——writer 继续前由 world-builder 发现冲突

**夹具：**
- `design/narrative/lore/ironveil-history.md` 中的现有背景知识条目写明 Ironveil 阵营于 200 年前建立
- 新叙事简报（来自阶段 1）写明 Ironveil 于 50 年前建立
- 阶段 2 中 writer 已与 world-builder 并行启动

**输入：** `/team-narrative ironveil faction introduction cutscene`

**预期行为：**
1. 阶段 1–2 正常开始
2. 阶段 2 的 world-builder 检测到叙事简报与现有背景知识之间的事实矛盾：建立时间冲突
3. world-builder 返回 BLOCKED，原因：“发现背景知识矛盾——建立时间与 `design/narrative/lore/ironveil-history.md` 冲突”
4. 编排器立即暴露矛盾：“world-builder: BLOCKED——背景知识矛盾：叙事简报中的建立时间（50 年前）与现有正史（`ironveil-history.md` 中的 200 年前）冲突”
5. 编排器评估依赖关系：writer 的对话依赖正史背景知识；解决矛盾前无法完成 writer 草稿
6. `AskUserQuestion` 展示选项：
   - 修改叙事简报以匹配现有正史（200 年前）
   - 更新现有背景知识条目以反映新正史（50 年前）
   - 停在这里，先解决背景知识文档中的矛盾
7. 保留 Writer 输出，但标记为等待正史解决；不丢弃工作成果
8. 在矛盾解决或用户明确选择跳过前，编排器不会进入阶段 3

**断言：**
- [ ] 矛盾在阶段 3 开始前被暴露
- [ ] 编排器不会擅自选择一个版本来静默解决矛盾
- [ ] `AskUserQuestion` 至少展示 3 个选项，包括“停止并先解决”
- [ ] Writer 草稿输出保留在部分报告中，不被丢弃
- [ ] 用户解决矛盾前不会启动阶段 3（level-designer）
- [ ] 如果用户停下来解决矛盾，结论为 BLOCKED（而非 COMPLETE）

---

### 用例 3：无参数——显示用法指导

**夹具：**
- 任意项目状态

**输入：** `/team-narrative`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法指导，例如：“用法：`/team-narrative [narrative content description]`——描述要处理的故事内容、场景或叙事区域（例如 `boss encounter cutscene`、`faction intro dialogue`、`tutorial narrative`）”
3. 技能退出，不启动任何代理

**断言：**
- [ ] 未提供参数时技能不会启动任何代理
- [ ] 用法消息包含带参数示例的正确调用格式
- [ ] 技能不会尝试从项目文件猜测或推断叙事主题
- [ ] 不使用 `AskUserQuestion`，直接输出指导

---

### 用例 4：本地化合规——localization-lead 标记不可翻译字符串

**夹具：**
- 阶段 1–4 成功完成
- 阶段 5 开始；writer 和 world-builder 顺利完成
- localization-lead 发现某行对话使用硬编码格式化日期字符串（例如 `"On March 12th, Year 3"`），没有区域感知格式化器就无法适应特定区域的翻译

**输入：** `/team-narrative ironveil faction introduction cutscene`（阶段 5 场景）

**预期行为：**
1. 阶段 5 并行启动 writer、localization-lead 和 world-builder
2. localization-lead 完成审查并标记：“字符串键 `dialogue.ironveil.intro.003` 包含硬编码日期格式（`March 12th, Year 3`），无法正确本地化，需要区域感知的日期占位符”
3. 编排器在汇总报告中暴露本地化阻塞项
4. 最终报告将本地化问题标记为 BLOCKING（而非建议项）
5. `AskUserQuestion` 展示选项：
   - 立即修复字符串（writer 修改该行）
   - 记录缺口并交付标记了问题的叙事文档
   - 停止并在最终确定前解决问题
6. 如果用户选择带着标记的问题继续，结论为 COMPLETE，并注明本地化债务；如果用户停止，结论为 BLOCKED

**断言：**
- [ ] 阶段 5 同时启动 localization-lead、writer 和 world-builder
- [ ] 硬编码日期格式被识别为本地化阻塞项，而不是静默通过
- [ ] 问题报告包含具体字符串键和原因
- [ ] `AskUserQuestion` 提供立即修复或标记后继续的选项
- [ ] 用户不修复而继续时，结论注明本地化债务
- [ ] 未经用户批准，技能不会自动改写违规行

---

### 用例 5：Writer 受阻——缺少角色语音档案

**夹具：**
- 阶段 1 narrative-director 生成引用两名角色 Commander Varek 和 Advisor Selene 的叙事简报
- `design/narrative/characters/` 中不存在这两名角色的语音档案
- 阶段 2 开始；world-builder 正常进行

**输入：** `/team-narrative ironveil surrender negotiation scene`

**预期行为：**
1. 阶段 1 完成；叙事简报列出角色 Commander Varek 和 Advisor Selene
2. 阶段 2：writer 与 world-builder 并行启动
3. writer 返回 BLOCKED：“无法生成对话——在 `design/narrative/characters/` 中找不到 Commander Varek 或 Advisor Selene 的语音档案。需要语音档案来匹配角色的语气和说话方式。”
4. 编排器立即暴露阻塞项：“writer: BLOCKED——缺少前置条件：Commander Varek 和 Advisor Selene 的角色语音档案”
5. 保留 world-builder 输出；生成包含背景知识条目的部分报告
6. `AskUserQuestion` 展示选项：
   - 先创建语音档案（转到 narrative-director 或设计工作流）
   - 在行内提供最少的声音指导，并使用该上下文重试 writer
   - 停在这里，创建语音档案后再继续
7. 没有 writer 输出时，编排器不会进入阶段 3（level-designer）

**断言：**
- [ ] Writer 阻塞在阶段 3 开始前被暴露
- [ ] world-builder 已完成的背景知识输出保留在部分报告中
- [ ] 具体指出缺少的前置条件（角色名称和预期文件路径）
- [ ] `AskUserQuestion` 至少提供一个解决缺少前置条件的选项
- [ ] 编排器不会捏造语音档案或虚构角色声音
- [ ] writer 处于 BLOCKED 时，未经用户明确授权不会启动阶段 3

---

## 协议合规性

- [ ] 每个阶段输出后、下一阶段启动前都使用 `AskUserQuestion`
- [ ] 并行启动：阶段 2（world-builder + writer）和阶段 5（writer + localization-lead + world-builder）在等待结果前发起所有 Task 调用
- [ ] 编排器不直接写入文件，所有写入均委托给子代理
- [ ] 每个子代理在任何写入前执行“May I write to [path]?”协议
- [ ] 任何代理的 BLOCKED 状态都立即暴露，不静默跳过
- [ ] 部分代理完成而其他代理受阻时，始终生成部分报告
- [ ] 结论严格为 COMPLETE 或 BLOCKED，不使用其他结论值
- [ ] 后续步骤交接引用 `/design-review`、`/localize extract` 和 `/dev-story`

---

## 覆盖说明

- 阶段 3（level-designer）和阶段 4（narrative-director 审查）的成功路径通过用例 1 隐含验证。这些阶段无需单独边界用例，因为其失败模式遵循标准 Error Recovery Protocol。
- Error Recovery Protocol 中“以更窄范围重试”和“跳过此代理”的解决路径未单独测试；它们遵循用例 2 和 5 验证的 `AskUserQuestion` + 部分报告模式。
- 用例 4 区分建议性本地化问题（例如德语/芬兰语 +30% 扩展警告）与阻塞性问题（硬编码格式）；仅建议性场景遵循相同模式但不会改变结论。
- 阶段 5 中 writer 的“所有行少于 120 个字符”和“使用字符串键而非原始字符串”检查，由用例 4 的本地化合规场景隐含覆盖。
