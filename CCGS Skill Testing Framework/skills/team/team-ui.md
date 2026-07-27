# 技能测试规范：/team-ui

## 技能摘要

为单个 UI 功能编排完整 UX 流水线。协调 ux-designer、ui-programmer、art-director、引擎 UI 专家和 accessibility-specialist，执行五个结构化阶段：上下文收集与 UX 规范（阶段 1a/1b）→ UX 审查门（阶段 1c）→ 视觉设计（阶段 2）→ 实现（阶段 3）→ 并行审查（阶段 4）→ 打磨（阶段 5）。每次阶段转换使用 `AskUserQuestion`。所有写入委托给子代理和子技能（`/ux-design`、`ui-programmer`）。生成 COMPLETE / BLOCKED 摘要并交接到 `/ux-review`、`/code-review`、`/team-polish`。

---

## 静态断言（结构）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题（阶段 1a 至阶段 5 均存在）
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含“May I write”或“文件写入协议”，写入委托给子代理和子技能，编排器不直接写文件
- [ ] 末尾有下一步交接（引用 `/ux-review`、`/code-review`、`/team-polish`）
- [ ] 存在“错误恢复协议”章节，且包含全部四个恢复步骤
- [ ] 阶段转换时使用 `AskUserQuestion`，在继续前取得用户批准
- [ ] 阶段 4 明确标记为并行（ux-designer、art-director、accessibility-specialist）
- [ ] UX 审查门（阶段 1c）定义为阻塞门；没有 APPROVED 结论不得进入阶段 2
- [ ] 团队组成列出全部五个角色（ux-designer、ui-programmer、art-director、引擎 UI 专家、accessibility-specialist）
- [ ] 引用交互模式库（`design/ux/interaction-patterns.md`），ui-programmer 必须使用现有模式
- [ ] 阶段 1a 在设计开始前读取 `design/accessibility-requirements.md`

---

## 测试用例

### 用例 1：成功路径——从 UX 规范到打磨的完整流水线成功

**夹具：**
- `design/gdd/game-concept.md` 存在且包含平台目标和目标受众
- `design/player-journey.md` 存在
- `design/ux/interaction-patterns.md` 存在且包含相关模式
- `design/accessibility-requirements.md` 存在且有已确定的等级（例如 Enhanced）
- `.claude/docs/technical-preferences.md` 已配置引擎 UI 专家

**输入：** `/team-ui inventory screen`

**预期行为：**
1. 阶段 1a：编排器读取 game-concept.md、player-journey.md、相关 GDD UI 章节、interaction-patterns.md 和 accessibility-requirements.md；为 ux-designer 汇总简报
2. 阶段 1b：调用 `/ux-design inventory-screen`（或直接启动 ux-designer）；使用 `ux-spec.md` 模板生成 `design/ux/inventory-screen.md`；用 `AskUserQuestion` 在审查前确认规范
3. 阶段 1c：调用 `/ux-review design/ux/inventory-screen.md`；返回 APPROVED；通过门禁后进入阶段 2
4. 阶段 2：启动 art-director；审查完整 UX 规范（不只是线框图）；应用视觉处理；验证颜色对比度；生成含资产清单的视觉设计规范；用 `AskUserQuestion` 确认后进入阶段 3
5. 阶段 3：先启动引擎 UI 专家（从 technical-preferences.md 读取）；为 ui-programmer 生成实现说明；将 UX 规范、视觉规范和引擎说明传给 ui-programmer；生成实现；若引入新模式则更新 interaction-patterns.md
6. 阶段 4：并行启动 ux-designer、art-director、accessibility-specialist；三者均返回结果后才进入阶段 5
7. 阶段 5：处理审查反馈；验证动画可跳过；通过音频事件系统确认 UI 音效；完成 interaction-patterns.md 最终检查；结论为 COMPLETE
8. 汇总报告：UX 规范 APPROVED、视觉设计 COMPLETE、实现 COMPLETE、无障碍 COMPLIANT，支持所有输入方式，模式库已更新，结论为 COMPLETE

**断言：**
- [ ] 阶段 1a 在向 ux-designer 汇报前读取全部五个来源
- [ ] 阶段 2 前检查 UX 审查门——在 APPROVED 前不得开始阶段 2
- [ ] 阶段 2 的 art-director 审查完整规范，而不只是线框图
- [ ] 阶段 3 在 ui-programmer 之前启动引擎 UI 专家
- [ ] 阶段 4 代理同时启动（ux-designer、art-director、accessibility-specialist）
- [ ] 所有文件写入均委托给子代理和子技能
- [ ] 最终摘要报告中的结论为 COMPLETE
- [ ] 下一步包含 `/ux-review`、`/code-review`、`/team-polish`

---

### 用例 2：UX 审查门——规范审查失败，技能在实现前停止

**夹具：**
- `design/ux/inventory-screen.md` 由阶段 1b 生成
- `/ux-review` 返回 NEEDS REVISION，并标出具体问题（例如手柄导航流程不完整、对比度低于最低值）

**输入：** `/team-ui inventory screen`

**预期行为：**
1. 阶段 1a + 1b 完成，生成 UX 规范
2. 阶段 1c：`/ux-review design/ux/inventory-screen.md` 返回 NEEDS REVISION
3. 技能不得进入阶段 2
4. `AskUserQuestion` 展示具体问题和选项：
   - (a) 返回 ux-designer 修复问题并重新审查
   - (b) 接受风险并继续进入阶段 2（明确的有意识决策）
5. 用户选择 (a) 时：ux-designer 修订规范，重新运行 `/ux-review`；循环持续到 APPROVED 或用户覆盖
6. 用户选择 (b) 时：技能继续，但在最终报告中明确记录 NEEDS REVISION
7. 技能不得静默越过门禁

**断言：**
- [ ] UX 审查结论为 NEEDS REVISION 时不得开始阶段 2
- [ ] `AskUserQuestion` 在提供选项前展示明确标记的问题
- [ ] 用户必须有意识地选择覆盖——技能不假定用户会覆盖
- [ ] 用户接受风险时，最终报告记录 NEEDS REVISION 问题
- [ ] 提供修订并重新审查的循环（不只是一次性失败）
- [ ] 审查失败时技能不丢弃已生成的 UX 规范

---

### 用例 3：无参数——显示用法指导

**夹具：**
- 任意项目状态

**输入：** `/team-ui`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法消息，说明必需参数（UI 功能描述）
3. 提供调用示例：`/team-ui [UI feature description]`
4. 技能退出，不启动任何子代理或读取任何项目文件

**断言：**
- [ ] 未提供参数时技能不启动任何子代理
- [ ] 用法消息包含 frontmatter 中的 argument-hint 格式
- [ ] 至少展示一个有效调用示例
- [ ] 失败前不读取 UX 规范文件或 GDD
- [ ] 不展示结论（流水线从未开始）

---

### 用例 4：并行无障碍审查——阶段 4 同时运行三条流

**夹具：**
- `design/ux/inventory-screen.md` 存在（APPROVED）
- 视觉设计规范已完成
- 实现已完成
- `design/accessibility-requirements.md` 中记录的等级：Enhanced

**输入：** `/team-ui inventory screen`（从阶段 3 完成处恢复）

**预期行为：**
1. 实现确认完成后开始阶段 4
2. 同时发出三个 Task 调用：ux-designer、art-director、accessibility-specialist
3. 每条流独立运行：
   - ux-designer：验证实现与线框图一致，测试仅键盘和仅手柄的导航，检查无障碍功能是否正常
   - art-director：在支持的最低和最高分辨率下验证与美术圣经的视觉一致性
   - accessibility-specialist：根据 `design/accessibility-requirements.md` 中的 Enhanced 无障碍等级进行审计；任何违规均标记为阻塞项
4. 技能等待三个结果全部返回后再进入阶段 5
5. 阶段 5 开始前，`AskUserQuestion` 展示全部三个审查结果

**断言：**
- [ ] 在等待任何结果前发出全部三个 Task 调用（并行而非顺序）
- [ ] 三个阶段 4 代理全部返回前不得开始阶段 5
- [ ] accessibility-specialist 明确读取 `design/accessibility-requirements.md` 中记录的等级
- [ ] 无障碍违规标记为 BLOCKING（而非仅提供建议）
- [ ] 阶段 5 获批前，`AskUserQuestion` 一并展示三条审查流的结果
- [ ] 任何阶段 4 代理的输出都不作为另一个阶段 4 代理的输入

---

### 用例 5：缺少交互模式库——记录缺口而不是臆造模式

**夹具：**
- `design/ux/interaction-patterns.md` 不存在
- 其他所有必需文件均存在

**输入：** `/team-ui settings menu`

**预期行为：**
1. 阶段 1a——编排器尝试读取 `design/ux/interaction-patterns.md`；找不到文件
2. 技能呈现缺口：“interaction-patterns.md 不存在——没有可复用的现有模式”
3. `AskUserQuestion` 提供选项：
    - (a) 先运行 `/ux-design patterns` 建立模式库，再继续
    - (b) 不使用模式库继续——ux-designer 将记录创建的新模式
4. 技能不从其他来源臆造或假定模式
5. 用户选择 (b) 时：明确指示 ui-programmer 将创建的所有模式视为新模式，并在完成时将每个模式添加到新的 `design/ux/interaction-patterns.md`
6. 最终报告注明 interaction-patterns.md 已创建（或用户跳过时仍然缺失）

**断言：**
- [ ] 技能不静默忽略缺失的模式库
- [ ] 技能不只根据功能名称或 GDD 臆测模式
- [ ] `AskUserQuestion` 提供“先创建模式库”选项（引用 `/ux-design patterns`）
- [ ] 用户不使用模式库继续时，告知 ui-programmer 将所有模式视为新模式
- [ ] 最终报告记录模式库状态（已创建 / 缺失 / 已更新）
- [ ] 技能不完全失败——记录缺口并向用户提供选择

---

## 协议合规性

- [ ] 每次阶段转换均使用 `AskUserQuestion`——用户批准后流水线才推进
- [ ] UX 审查门（阶段 1c）是阻塞门——没有 APPROVED 或用户明确覆盖不得开始阶段 2
- [ ] 所有文件写入均委托给子代理和子技能——编排器不直接调用 Write 或 Edit
- [ ] 阶段 4 代理按技能规范并行启动
- [ ] 遵循错误恢复协议：呈现 → 评估 → 提供选项 → 部分报告
- [ ] 即使代理处于 BLOCKED 状态，也始终生成部分报告
- [ ] 结论为 COMPLETE / BLOCKED 之一
- [ ] 末尾提供下一步：`/ux-review`、`/code-review`、`/team-polish`

---

## 覆盖说明

- HUD 专用路径（`/ux-design hud` + `hud-design.md` 模板 + 阶段 5 的视觉预算检查）未在此单独测试；它共享相同的阶段结构，但使用不同模板。
- interaction-patterns.md 的“就地更新”路径（实现期间添加新模式）在用例 1 步骤 5 中隐式执行——增加一个包含已知新模式的专用夹具会加强覆盖。
- 引擎 UI 专家不可用（未配置引擎）——技能规范说明“如果未配置引擎则跳过”；用例 1 断言了此路径，但没有专用夹具。
- NEEDS REVISION 的接受风险覆盖（用例 2 选项 b）要求在报告中明确记录覆盖；此点已断言，但未进一步测试其下游影响。
