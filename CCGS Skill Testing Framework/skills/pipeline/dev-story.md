# 技能测试规范：/dev-story

## 技能摘要

`/dev-story` 读取故事文件，加载所有必需上下文（引用的 ADR、注册表中的 TR-ID、控制清单、引擎偏好），实现故事，验证所有验收标准已满足，并将故事标记为 Complete。该技能根据引擎和文件类型，将实现路由给正确的专业代理，而不是直接编写源代码。

在 `full` 评审模式下，标记故事 Complete 前运行 LP-CODE-REVIEW 门禁。在 `lean` 或 `solo` 模式下跳过 LP-CODE-REVIEW，用户确认所有标准满足后将故事标记为 Complete。技能在更新故事状态和写入代码文件前询问 "May I write"。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：COMPLETE、BLOCKED、IN PROGRESS、NEEDS CHANGES
- [ ] 包含 "May I write" 协作协议用语（故事状态 + 代码文件）
- [ ] 末尾包含下一步交接（`/story-done`）
- [ ] 说明 LP-CODE-REVIEW 门禁：full 模式启用，lean/solo 模式跳过
- [ ] 说明实现交由专业代理完成，而不是直接完成

---

## 主管门禁检查

在 `full` 模式下：实现完成且所有标准验证通过后、将故事标记为 Complete 前，运行 LP-CODE-REVIEW 门禁。

在 `lean` 模式下：跳过 LP-CODE-REVIEW。输出注明："LP-CODE-REVIEW skipped — lean mode"。用户确认后将故事标记为 Complete。

在 `solo` 模式下：跳过 LP-CODE-REVIEW，并提供等效说明。

---

## 测试用例

### 用例 1：正常路径——故事实现并标记为 Complete（full 模式）

**测试夹具：**
- `production/epics/[layer]/story-[name].md` 存在，且包含：
  - `Status: Ready`
  - 引用已注册需求的 TR-ID
  - 至少 2 个 Given-When-Then 验收标准
  - 测试证据路径
- 引用的 ADR 带有 `Status: Accepted`
- `docs/architecture/control-manifest.md` 存在
- `.claude/docs/technical-preferences.md` 已配置引擎和语言
- `production/session-state/review-mode.txt` 内容为 `full`

**输入：** `/dev-story production/epics/[layer]/story-[name].md`

**预期行为：**
1. 技能读取故事文件和所有引用的上下文
2. 技能验证 ADR 为 Accepted（不阻塞）
3. 技能将实现路由给正确的专业代理
4. 验证所有验收标准均已满足
5. 生成 LP-CODE-REVIEW 门禁并返回 APPROVED
6. 技能询问 "May I update story status to Complete?"
7. 将故事状态更新为 Complete

**断言：**
- [ ] 生成任何代理前读取故事
- [ ] 在开始实现前检查 ADR 状态
- [ ] 实现交由专业代理完成，而非内联完成
- [ ] 在 LP-CODE-REVIEW 前确认所有验收标准
- [ ] 输出显示 LP-CODE-REVIEW 已完成
- [ ] 仅在门禁批准且用户同意后，将故事状态更新为 Complete
- [ ] 测试文件作为实现的一部分写入，而非延后

---

### 用例 2：失败路径——引用的 ADR 为 Proposed

**测试夹具：**
- 故事文件存在且 `Status: Ready`
- 故事的 TR-ID 指向由 `Status: Proposed` ADR 覆盖的需求

**输入：** `/dev-story production/epics/[layer]/story-[name].md`

**预期行为：**
1. 技能读取故事文件
2. 技能解析 TR-ID 并读取主管 ADR
3. ADR 状态为 Proposed，技能输出 BLOCKED 消息
4. 技能指出阻塞故事的具体 ADR
5. 技能建议运行 `/architecture-decision` 推进该 ADR
6. 不开始实现

**断言：**
- [ ] Proposed ADR 下技能不会开始实现
- [ ] BLOCKED 消息指出具体 ADR 编号和标题
- [ ] 技能建议 `/architecture-decision` 作为下一步
- [ ] 故事状态保持不变（不设为 In Progress 或 Complete）

---

### 用例 3：验收标准含糊——技能请求澄清

**测试夹具：**
- 故事文件存在且 `Status: Ready`
- 引用的 ADR 为 Accepted
- 一个验收标准含糊（不是 Given-When-Then，使用了 "feels responsive" 等主观措辞）

**输入：** `/dev-story production/epics/[layer]/story-[name].md`

**预期行为：**
1. 技能读取故事并识别含糊标准
2. 在路由给专业代理前请求用户澄清
3. 用户提供具体、可测试的重新表述
4. 技能使用澄清后的标准继续实现
5. 技能不会猜测预期行为

**断言：**
- [ ] 开始实现前呈现含糊标准
- [ ] 请求用户澄清，而非自动解释
- [ ] 仅在获得澄清后开始实现
- [ ] 测试使用澄清后的标准，而不是原始含糊版本

---

### 用例 4：边界情况——无参数；从会话状态读取

**测试夹具：**
- 未提供参数
- `production/session-state/active.md` 引用了活动故事文件
- 该故事文件存在且 `Status: In Progress`

**输入：** `/dev-story`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 技能读取 `production/session-state/active.md`
3. 技能找到活动故事引用
4. 技能向用户确认："Continuing work on [story title] — is that correct?"
5. 用户确认后，技能继续处理该故事

**断言：**
- [ ] 无参数时读取会话状态
- [ ] 继续前向用户确认活动故事
- [ ] 不经确认静默假定活动故事
- [ ] 会话状态没有活动故事时，询问用户要实现哪个故事

---

### 用例 5：主管门禁——LP-CODE-REVIEW 返回 NEEDS CHANGES；lean 模式跳过门禁

**测试夹具（full 模式）：**
- 故事已实现且所有标准看似满足
- `production/session-state/review-mode.txt` 内容为 `full`
- LP-CODE-REVIEW 门禁返回 NEEDS CHANGES，并附具体反馈

**Full 模式预期行为：**
1. 实现后生成 LP-CODE-REVIEW 门禁
2. 门禁返回 NEEDS CHANGES，并指出 2 个具体问题
3. 故事状态保持 In Progress，不标记为 Complete
4. 向用户显示门禁反馈并询问如何继续

**断言（full 模式）：**
- [ ] LP-CODE-REVIEW 返回 NEEDS CHANGES 时，故事不会标记为 Complete
- [ ] 将门禁反馈原样显示给用户
- [ ] 问题解决且门禁通过前，故事状态保持 In Progress

**测试夹具（lean 模式）：**
- 相同故事，`production/session-state/review-mode.txt` 内容为 `lean`

**Lean 模式预期行为：**
1. 实现完成
2. 跳过 LP-CODE-REVIEW 门禁，并在输出中注明
3. 请求用户确认所有标准均已满足
4. 用户确认后将故事标记为 Complete

**断言（lean 模式）：**
- [ ] 输出中出现 "LP-CODE-REVIEW skipped — lean mode"
- [ ] 用户确认标准后将故事标记为 Complete（不需要门禁）
- [ ] 技能不会被已跳过的门禁阻塞

---

## 协议合规性

- [ ] 不直接写入源代码，将实现交给专业代理
- [ ] 实现前加载所有上下文（故事、TR-ID、ADR、清单、引擎偏好）
- [ ] 更新故事状态和写入代码文件前询问 "May I write"
- [ ] 在输出中按名称和模式注明跳过的门禁
- [ ] 故事完成后更新 `production/session-state/active.md`
- [ ] 以下一步交接结束：`/story-done`

---

## 覆盖说明

- 未按引擎分别测试路由逻辑（Godot、Unity、Unreal）；路由模式一致，引擎选择属于配置事实。
- Visual/Feel 和 UI 故事类型（不要求自动化测试）有不同证据要求，未在这些用例中覆盖。
- Integration 故事类型与 Logic 遵循相同模式，但证据路径不同，未单独使用夹具测试。
