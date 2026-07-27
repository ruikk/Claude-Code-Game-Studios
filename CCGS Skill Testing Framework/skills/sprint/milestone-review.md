# 技能测试规范：/milestone-review

## 技能摘要

`/milestone-review` 为已完成的里程碑生成全面评审：已交付内容、速率指标、延期项、暴露的风险及回顾素材。
在 `full` 模式下，评审汇编完成后运行 PR-MILESTONE 主管门禁（由 producer 审查范围交付）。
在 `lean` 和 `solo` 模式下跳过门禁。技能在持久化前会询问
"May I write to `production/milestones/review-milestone-N.md`?"。判定为 MILESTONE COMPLETE 或 MILESTONE INCOMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含判定关键字：MILESTONE COMPLETE、MILESTONE INCOMPLETE
- [ ] 包含 "May I write" 文本（技能会写入评审文档）
- [ ] 包含下一步交接（评审写入后要做什么）

---

## 主管门禁检查

| 门禁 ID | 触发条件 | 模式限制 |
|---------|---------|---------|
| PR-MILESTONE | 评审文档汇编完成后 | 仅 `full`（不含 `lean`/`solo`） |

---

## 测试用例

### 用例 1：正常路径——里程碑接近完成，仅一个故事延期

**夹具：**
- `production/milestones/milestone-03.md` 存在，包含 8 个故事
- 7 个故事为 `Status: Complete`
- 1 个故事为 `Status: Deferred`（延期至 milestone-04）
- `review-mode.txt` 包含 `full`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. 技能读取 `milestone-03.md` 和所有被引用的迭代文件
2. 技能汇编：已交付 7 个、延期 1 个；包含速率；无阻塞项
3. 技能向用户展示评审草稿
4. 调用 PR-MILESTONE 门禁；producer 批准
5. 技能询问 "May I write to `production/milestones/review-milestone-03.md`?"
6. 用户批准；写入文件；判定为 MILESTONE COMPLETE

**断言：**
- [ ] 评审注明延期故事及其目标里程碑
- [ ] 尽管有一个延期故事，判定仍为 MILESTONE COMPLETE
- [ ] `full` 模式下，草稿汇编后调用 PR-MILESTONE 门禁
- [ ] 写入评审文件前询问 "May I write"
- [ ] 评审文档路径符合 `production/milestones/review-milestone-03.md`

---

### 用例 2：里程碑受阻——多个故事被阻塞

**夹具：**
- `production/milestones/milestone-03.md` 存在，包含 5 个故事
- 2 个故事为 `Status: Complete`
- 3 个故事为 `Status: Blocked`（各故事中列出明确阻塞项）
- `review-mode.txt` 包含 `full`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. 技能读取里程碑和迭代文件
2. 技能找到 3 个被阻塞故事并汇编阻塞详情
3. 判定为 MILESTONE INCOMPLETE
4. 运行 PR-MILESTONE 门禁；producer 指出未解决的阻塞项
5. 批准后写入包含阻塞项列表的评审

**断言：**
- [ ] 任何故事为 Blocked 时，判定为 MILESTONE INCOMPLETE
- [ ] 评审列出每个被阻塞故事的名称和阻塞原因
- [ ] 即使判定为 INCOMPLETE，`full` 模式仍调用 PR-MILESTONE 门禁
- [ ] 写入文件前仍出现 "May I write" 提示

---

### 用例 3：Full 模式——PR-MILESTONE 返回 CONCERNS

**夹具：**
- Milestone-03 有 6 个已完成故事，但其中 2 个不在原始范围内（迭代期间添加）
- `review-mode.txt` 包含 `full`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. 技能汇编评审，并注明交付了 2 个范围外故事
2. 调用 PR-MILESTONE 门禁；producer 针对范围漂移返回 CONCERNS
3. 技能向用户展示 CONCERNS，并在评审中添加“范围漂移”说明
4. 用户批准修订后的评审；文件以带有附带说明的 MILESTONE COMPLETE 写入

**断言：**
- [ ] PR-MILESTONE 门禁返回的 CONCERNS 在写入前展示给用户
- [ ] 写入的评审文档明确注明范围漂移
- [ ] 判定为 MILESTONE COMPLETE（故事已交付），并带有 CONCERNS 注解
- [ ] 技能不隐瞒门禁反馈

---

### 用例 4：边界情况——找不到指定的里程碑文件

**夹具：**
- 用户调用 `/milestone-review milestone-07`
- `production/milestones/milestone-07.md` 不存在

**输入：** `/milestone-review milestone-07`

**预期行为：**
1. 技能尝试读取 `production/milestones/milestone-07.md`
2. 未找到文件；技能输出错误消息
3. 技能建议在 `production/milestones/` 中检查可用里程碑
4. 不调用门禁，也不写入文件

**断言：**
- [ ] 缺少里程碑文件时技能不会崩溃
- [ ] 错误消息包含预期文件路径
- [ ] 输出建议在 `production/milestones/` 中检查有效里程碑名称
- [ ] 判定为 BLOCKED（无法评审不存在的里程碑）

---

### 用例 5：Lean/Solo 模式——跳过 PR-MILESTONE 门禁

**夹具：**
- `production/milestones/milestone-03.md` 存在，包含 5 个已完成故事
- `review-mode.txt` 包含 `solo`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. 技能读取审查模式，确定为 `solo`
2. 技能汇编评审草稿
3. 跳过 PR-MILESTONE 门禁；输出注明“[PR-MILESTONE] skipped — Solo mode”
4. 技能请求用户直接批准评审
5. 用户批准；写入评审文件；判定为 MILESTONE COMPLETE

**断言：**
- [ ] `solo`（或 `lean`）模式下不调用 PR-MILESTONE 门禁
- [ ] 技能输出明确注明已跳过
- [ ] 写入前仍需用户直接批准
- [ ] 成功写入后判定为 MILESTONE COMPLETE

---

## 协议合规性

- [ ] 调用 PR-MILESTONE 或请求写入前展示汇编后的评审草稿
- [ ] 写入评审文档前始终询问 "May I write"
- [ ] PR-MILESTONE 门禁仅在 `full` 模式下运行
- [ ] `lean` 和 `solo` 输出中出现跳过消息
- [ ] 清晰陈述 MILESTONE COMPLETE 或 MILESTONE INCOMPLETE 判定

---

## 覆盖说明

- 未测试里程碑没有任何故事的情况；其行为遵循 MILESTONE INCOMPLETE 模式，并注明该里程碑可能尚未规划。
- 未验证速率计算的具体方式（故事点与故事数量）；它们属于评审汇编阶段的实现细节。
