# 技能测试规范：/team-combat

## 技能摘要

为单个战斗功能端到端编排完整战斗团队。协调 game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer、主引擎专家和 qa-tester，依次执行六个阶段：设计 → 架构（含引擎专家验证）→ 并行实现 → 集成 → 验证 → 签核。每次阶段转换使用 `AskUserQuestion`，所有写入委托给子代理。生成含 COMPLETE / NEEDS WORK / BLOCKED 结论的摘要，并交接到 `/code-review`、`/balance-check`、`/team-polish`。

---

## 静态断言（结构）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题（阶段 1 至阶段 6 均存在）
- [ ] 包含结论关键词：COMPLETE、NEEDS WORK、BLOCKED
- [ ] 包含“May I write”或“File Write Protocol”，写入委托给子代理，编排器不直接写文件
- [ ] 末尾有下一步交接（引用 `/code-review`、`/balance-check`、`/team-polish`）
- [ ] 存在 Error Recovery Protocol 章节，且包含全部四个恢复步骤
- [ ] 阶段转换时使用 `AskUserQuestion`，在继续前取得用户批准
- [ ] 阶段 3 明确标记为并行（gameplay-programmer、ai-programmer、technical-artist、sound-designer）
- [ ] 阶段 2 包含启动主引擎专家（从 `.claude/docs/technical-preferences.md` 读取）
- [ ] 团队组成列出全部七个角色（game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer、引擎专家、qa-tester）

---

## 测试用例

### 用例 1：成功路径——所有代理成功，流水线完成

**夹具：**
- `design/gdd/game-concept.md` 存在且已有内容
- `.claude/docs/technical-preferences.md` 已配置引擎（Engine Specialists 章节已填写）
- 请求的战斗功能没有现有 GDD

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. 阶段 1：启动 game-designer；生成覆盖全部 8 个必需章节（概览、玩家幻想、规则、公式、边界情况、依赖、调节旋钮、验收标准）的 `design/gdd/parry-riposte.md`；请求用户批准设计文档
2. 阶段 2：启动 gameplay-programmer 和 ai-programmer；生成包含类结构、接口和文件列表的架构草图；随后启动主引擎专家验证惯用做法；纳入引擎专家输出；阶段 3 开始前用 `AskUserQuestion` 展示架构选项
3. 阶段 3：并行启动 gameplay-programmer、ai-programmer、technical-artist、sound-designer；四者均返回输出后才开始阶段 4
4. 阶段 4：整合全部阶段 3 输出；验证调节旋钮由数据驱动；用 `AskUserQuestion` 确认集成后再进入阶段 5
5. 阶段 5：启动 qa-tester；根据验收标准编写测试用例；验证边界情况；根据预算检查性能影响
6. 阶段 6：生成汇总报告：设计为 COMPLETE，所有团队成员为 COMPLETE，列出测试用例，结论为 COMPLETE
7. 列出下一步：`/code-review`、`/balance-check`、`/team-polish`

**断言：**
- [ ] 每个阶段门均调用 `AskUserQuestion`（至少在阶段 3 和阶段 5 前调用）
- [ ] 阶段 3 代理同时启动；gameplay-programmer、ai-programmer、technical-artist、sound-designer 之间没有顺序依赖
- [ ] 引擎专家在阶段 2、阶段 3 开始前运行（输出纳入架构）
- [ ] 所有文件写入均委托给子代理（编排器不直接调用 Write/Edit）
- [ ] 最终报告包含 COMPLETE 结论
- [ ] 下一步包含 `/code-review`、`/balance-check`、`/team-polish`
- [ ] 设计文档覆盖全部 8 个必需 GDD 章节

---

### 用例 2：代理受阻——子代理在流水线中返回 BLOCKED

**夹具：**
- `design/gdd/parry-riposte.md` 存在（阶段 1 已完成）
- ai-programmer 因不存在 AI 系统架构 ADR 而返回 BLOCKED（ADR 状态为 Proposed）

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. 阶段 1：找到设计文档；game-designer 确认其有效；阶段获批
2. 阶段 2：gameplay-programmer 完成架构草图；ai-programmer 返回 BLOCKED：“AI 行为系统的 ADR 状态为 Proposed——在 ADR 变为 Accepted 前无法实现”
3. 触发 Error Recovery Protocol：“ai-programmer：BLOCKED——AI 行为 ADR 状态为 Proposed”
4. `AskUserQuestion` 展示选项：(a) 跳过 ai-programmer 并记录缺口；(b) 缩小范围后重试；(c) 停止并先运行 `/architecture-decision`
5. 用户选择 (a) 时：阶段 3 仅继续启动 gameplay-programmer、technical-artist、sound-designer；在部分报告中记录 ai-programmer 缺口
6. 生成最终报告：记录部分实现，将 ai-programmer 章节标记为 BLOCKED，总体结论为 BLOCKED

**断言：**
- [ ] BLOCKED 提示在任何依赖阶段继续前出现
- [ ] `AskUserQuestion` 至少提供三个选项：跳过 / 重试 / 停止
- [ ] 生成部分报告，不丢弃已完成代理的工作
- [ ] 任一代理未解决时总体结论为 BLOCKED（而非 COMPLETE）
- [ ] 阻塞原因引用 ADR，并建议运行 `/architecture-decision`
- [ ] 编排器不静默越过阻塞依赖

---

### 用例 3：无参数——显示明确用法指导

**夹具：**
- 任意项目状态

**输入：** `/team-combat`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出说明必需参数（战斗功能描述）的用法消息
3. 提供调用示例：`/team-combat [combat feature description]`
4. 技能退出且不启动任何子代理

**断言：**
- [ ] 未提供参数时技能不会启动任何子代理
- [ ] 用法消息包含 frontmatter 中的 argument-hint 格式
- [ ] 错误消息至少包含一个有效调用示例
- [ ] 除检测缺少参数所需内容外不读取文件
- [ ] 不显示结论（流水线未运行）

---

### 用例 4：并行阶段验证——阶段 3 代理同时运行

**夹具：**
- `design/gdd/parry-riposte.md` 存在且完整
- 架构草图已获批准
- 引擎专家已验证架构

**输入：** `/team-combat parry and riposte system`（从阶段 2 完成处恢复）

**预期行为：**
1. 架构获批后开始阶段 3
2. 在等待任何结果前发出四个 Task 调用：gameplay-programmer、ai-programmer、technical-artist、sound-designer
3. 技能等待四个代理全部完成后才进入阶段 4
4. 即使某个代理提前完成，技能也要等四者全部返回后才开始阶段 4

**断言：**
- [ ] 四个 Task 调用在同一批次发出（之间不顺序等待）
- [ ] 四个阶段 3 代理均返回结果后才开始阶段 4
- [ ] 技能不将一个阶段 3 代理的输出作为另一个阶段 3 代理的输入（彼此独立）
- [ ] 阶段 4 集成步骤引用四个阶段 3 代理的全部结果

---

### 用例 5：架构阶段引擎路由——引擎专家收到正确上下文

**夹具：**
- `.claude/docs/technical-preferences.md` 已填写 Engine Specialists 章节（例如：Primary: godot-specialist）
- gameplay-programmer 生成的架构草图可用
- 引擎版本已固定在 `docs/engine-reference/godot/VERSION.md`

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. 阶段 2——gameplay-programmer 生成架构草图
2. 技能读取 `.claude/docs/technical-preferences.md` 的 Engine Specialists 章节，以识别主引擎专家代理类型
3. 启动引擎专家时提供：架构草图、GDD 路径、`VERSION.md` 中的引擎版本，以及检查已弃用 API 的明确指令
4. 引擎专家输出（惯用做法说明、已弃用 API 警告、原生系统建议）返回给编排器
5. 编排器在向用户展示阶段 2 结果前，将引擎说明纳入架构
6. `AskUserQuestion` 在架构草图旁包含引擎专家说明

**断言：**
- [ ] 引擎专家代理类型从 `.claude/docs/technical-preferences.md` 读取，而非硬编码
- [ ] 引擎专家提示包含架构草图和 GDD 路径
- [ ] 引擎专家根据已固定的引擎版本检查已弃用 API
- [ ] 引擎专家输出在阶段 3 开始前纳入架构（不跳过，也不单独追加）
- [ ] 未配置引擎时跳过引擎专家步骤，并在报告中添加说明

---

## 协议合规性

- [ ] 每次阶段转换使用 `AskUserQuestion`——用户批准后流水线才继续
- [ ] 所有文件写入均通过 Task 委托给子代理——编排器不直接调用 Write 或 Edit
- [ ] 遵循 Error Recovery Protocol：展示 → 评估 → 提供选项 → 部分报告
- [ ] 按技能规范并行启动阶段 3 代理
- [ ] 即使代理处于 BLOCKED，也始终生成部分报告
- [ ] 结论为 COMPLETE / NEEDS WORK / BLOCKED 之一
- [ ] 输出末尾包含下一步：`/code-review`、`/balance-check`、`/team-polish`

---

## 覆盖说明

- NEEDS WORK 结论路径（qa-tester 在阶段 5 发现失败）未单独测试；它遵循用例 2 的错误恢复和部分报告协议。
- 断言中列出了“缩小范围后重试”恢复选项，但其完整递归行为（通过 `/create-stories` 拆分）由 `/create-stories` 规范覆盖。
- 阶段 4 集成逻辑（连接 gameplay、AI、VFX、音频）由成功路径隐式验证；专用集成测试需要夹具代码文件。
- 引擎专家不可用（未配置引擎）在用例 5 断言中得到部分覆盖；为未配置引擎状态增加专用夹具可加强覆盖。
