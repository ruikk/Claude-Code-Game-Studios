# 技能测试规范：/sprint-status

## 技能摘要

`/sprint-status` 是一个 Haiku 层级的只读技能，它读取当前活动迭代文件和会话状态，生成简洁的迭代健康摘要。
它按状态报告故事数量（Complete / In Progress / Blocked / Not Started），并输出三种迭代健康判定之一：
ON TRACK、AT RISK 或 BLOCKED。它从不写入文件，也不调用任何主管门禁，适合在会话期间进行快速、低成本的状态检查。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题或编号检查章节
- [ ] 包含判定关键字：ON TRACK、AT RISK、BLOCKED
- [ ] 不要求 "May I write" 文本（只读技能）
- [ ] 包含下一步交接（根据判定说明后续操作）

---

## 主管门禁检查

无。`/sprint-status` 是只读报告技能，不调用门禁。

---

## 测试用例

### 用例 1：正常路径——混合状态迭代，因明确阻塞项判定 AT RISK

**夹具：**
- `production/sprints/sprint-004.md` 存在（活动迭代，在 `active.md` 中关联）
- 迭代包含 6 个故事：
  - 3 个 `Status: Complete`
  - 2 个 `Status: In Progress`
  - 1 个 `Status: Blocked`（阻塞原因：“等待 physics ADR 接受”）
- 距迭代结束还有 2 天

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取 `production/session-state/active.md`，查找活动迭代引用
2. 技能读取 `production/sprints/sprint-004.md`
3. 技能按状态统计故事：3 个 Complete、2 个 In Progress、1 个 Blocked
4. 技能检测到 Blocked 故事和临近的截止日期
5. 技能输出 AT RISK 判定，并明确列出阻塞项

**断言：**
- [ ] 输出包含按状态分解的故事数量
- [ ] 输出列出具体的阻塞故事及阻塞原因
- [ ] 有故事 Blocked 时判定为 AT RISK（而非 BLOCKED 或 ON TRACK）
- [ ] 技能不写入任何文件

---

### 用例 2：所有故事完成——迭代 COMPLETE 判定

**夹具：**
- `production/sprints/sprint-004.md` 存在
- 全部 5 个故事的状态都是 `Status: Complete`

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取迭代文件，确认所有故事均为 Complete
2. 技能输出 ON TRACK 判定或 SPRINT COMPLETE 标签
3. 技能建议运行 `/milestone-review` 或 `/sprint-plan` 作为下一步

**断言：**
- [ ] 全部故事完成时判定为 ON TRACK 或 SPRINT COMPLETE
- [ ] 输出说明迭代已全部完成
- [ ] 下一步建议引用 `/milestone-review` 或 `/sprint-plan`
- [ ] 不写入任何文件

---

### 用例 3：没有活动迭代文件——引导运行 /sprint-plan

**夹具：**
- `production/session-state/active.md` 未引用活动迭代
- `production/sprints/` 目录为空或不存在

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取 `active.md`，发现没有活动迭代引用
2. 技能检查 `production/sprints/`，发现没有文件
3. 技能输出信息提示：未检测到活动迭代
4. 技能建议运行 `/sprint-plan` 创建迭代

**断言：**
- [ ] 没有迭代文件时技能不会报错或崩溃
- [ ] 输出明确说明未找到活动迭代
- [ ] 输出建议下一步运行 `/sprint-plan`
- [ ] 不输出任何判定关键字（没有迭代可评估）

---

### 用例 4：边界情况——停滞的 In Progress 故事（标记出来）

**夹具：**
- `production/sprints/sprint-004.md` 存在
- 一个故事为 `Status: In Progress`，且 `active.md` 中有备注：
  `Last updated: 2026-03-30`（早于当前会话日期超过 2 天）
- 没有故事处于 Blocked 状态

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取迭代文件和会话状态
2. 技能检测到该故事已处于 In Progress 超过 2 天且未更新
3. 技能在输出中将该故事标记为“停滞”
4. 判定为 AT RISK（停滞的进行中故事表示存在隐藏阻塞项）

**断言：**
- [ ] 技能将故事的“最后更新”元数据与会话日期比较
- [ ] 输出按名称标记停滞的 In Progress 故事
- [ ] 检测到停滞故事时判定为 AT RISK，而非 ON TRACK
- [ ] 输出不将“停滞”与“Blocked”混为一谈，两者标签不同

---

### 用例 5：门禁合规性——只读，不调用门禁

**夹具：**
- `production/sprints/sprint-004.md` 存在，包含 4 个故事（2 个 Complete、2 个 In Progress）
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取迭代并生成状态摘要
2. 无论审查模式如何，技能都不调用主管门禁
3. 输出为包含 ON TRACK、AT RISK 或 BLOCKED 判定的普通状态报告
4. 技能不请求用户批准，也不询问写入任何文件

**断言：**
- [ ] 任何审查模式下都不调用主管门禁
- [ ] 输出不包含任何 "May I write" 提示
- [ ] 技能无需用户交互即可完成并返回判定
- [ ] 忽略审查模式文件，或确认该文件与技能无关

---

## 协议合规性

- [ ] 不使用 Write 或 Edit 工具（只读技能）
- [ ] 输出判定前展示故事状态数量分解
- [ ] 不请求批准
- [ ] 根据判定以推荐的下一步结束
- [ ] 使用 Haiku 模型层级（快速、低成本）

---

## 覆盖说明

- 未测试同时有多个活动迭代的情况；技能读取 `active.md` 引用的迭代。
- 未明确验证部分完成百分比；按状态计数的输出已隐含该信息。
- 未单独测试 `solo` 模式的审查模式变体；用例 5 的门禁行为适用于所有模式。
