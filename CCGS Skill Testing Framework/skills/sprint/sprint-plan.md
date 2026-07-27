# 技能测试规范：/sprint-plan

## 技能摘要

`/sprint-plan` 读取当前里程碑文件和待办故事，然后生成一个新的编号迭代；故事按实现层级和优先级分数排序。
在 `full` 模式下，迭代草稿汇编完成后运行 PR-SPRINT 主管门禁（由 producer 审查计划）。
在 `lean` 和 `solo` 模式下跳过门禁。技能在持久化前会询问
"May I write to `production/sprints/sprint-NNN.md`?"。判定为 COMPLETE（已生成并写入迭代）或 BLOCKED（缺少数据或门禁失败，无法继续）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含判定关键字：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 文本（技能会写入迭代文件）
- [ ] 包含下一步交接（迭代写入后要做什么）

---

## 主管门禁检查

| 门禁 ID | 触发条件 | 模式限制 |
|---------|---------|---------|
| PR-SPRINT | 迭代草稿构建完成后 | 仅 `full`（不含 `lean`/`solo`） |

---

## 测试用例

### 用例 1：正常路径——有故事的待办列表生成迭代

**夹具：**
- `production/milestones/milestone-02.md` 存在，容量为 `10 story points`
- 待办中有跨 2 个史诗的 5 个未开始故事，优先级混合
- `production/session-state/review-mode.txt` 包含 `full`
- 下一个迭代编号为 `003`（迭代 001 和 002 已存在）

**输入：** `/sprint-plan`

**预期行为：**
1. 技能读取当前里程碑，获取容量和目标
2. 技能读取待办中的所有未开始故事，并按层级和优先级排序
3. 技能生成 sprint-003 草稿，故事总量不超过容量
4. 技能在调用门禁前向用户展示草稿
5. 技能在 `full` 模式下调用 PR-SPRINT 门禁；producer 批准
6. 技能询问 "May I write to `production/sprints/sprint-003.md`?"
7. 用户批准；写入文件

**断言：**
- [ ] 故事先按实现层级、再按优先级排序
- [ ] 任何写入或门禁调用前展示迭代草稿
- [ ] 草稿准备好后，`full` 模式调用 PR-SPRINT 门禁
- [ ] 写入迭代文件前询问 "May I write"
- [ ] 写入文件路径符合 `production/sprints/sprint-003.md`
- [ ] 成功写入后判定为 COMPLETE

---

### 用例 2：阻塞路径——待办为空

**夹具：**
- `production/milestones/milestone-02.md` 存在
- 所有史诗待办中都没有未开始故事

**输入：** `/sprint-plan`

**预期行为：**
1. 技能读取待办，发现没有未开始故事
2. 技能输出“待办中没有未开始故事”
3. 技能建议运行 `/create-stories` 填充待办
4. 不调用门禁，也不写入文件

**断言：**
- [ ] 判定为 BLOCKED
- [ ] 输出包含“没有未开始故事”或等价信息
- [ ] 输出建议 `/create-stories`
- [ ] 不调用 PR-SPRINT 门禁
- [ ] 不调用写入工具

---

### 用例 3：门禁返回 CONCERNS——迭代超载，写入前修订

**夹具：**
- 待办有 8 个故事，共 16 点；里程碑容量为 10 点
- `review-mode.txt` 包含 `full`

**输入：** `/sprint-plan`

**预期行为：**
1. 技能生成包含全部 8 个故事的迭代草稿（超过容量）
2. 运行 PR-SPRINT 门禁；producer 返回 CONCERNS：迭代超载
3. 技能向用户展示问题，并询问要延期哪些故事
4. 用户选择延期 3 个故事；迭代修订为 5 个故事 / 10 点
5. 技能询问 "May I write"，使用修订后的迭代在批准后写入

**断言：**
- [ ] PR-SPRINT 门禁返回的 CONCERNS 在写入前展示给用户
- [ ] 门禁反馈后允许修订迭代
- [ ] 写入的是修订后的迭代，而非原始版本
- [ ] 修订并写入后判定为 COMPLETE

---

### 用例 4：Lean 模式——跳过 PR-SPRINT 门禁

**夹具：**
- 待办有 4 个故事；里程碑容量为 8 点
- `review-mode.txt` 包含 `lean`

**输入：** `/sprint-plan`

**预期行为：**
1. 技能读取审查模式，确定为 `lean`
2. 技能生成迭代草稿并向用户展示
3. 跳过 PR-SPRINT 门禁；输出注明“[PR-SPRINT] skipped — Lean mode”
4. 技能请求用户直接批准迭代
5. 用户批准；写入迭代文件

**断言：**
- [ ] `lean` 模式下不调用 PR-SPRINT 门禁
- [ ] 输出明确注明已跳过
- [ ] 写入前仍需用户批准（跳过门禁不等于跳过批准）
- [ ] 写入后判定为 COMPLETE

---

### 用例 5：边界情况——上一个迭代仍有未关闭故事

**夹具：**
- `production/sprints/sprint-002.md` 存在，2 个故事仍为 `Status: In Progress`
- 待办中有 5 个新的未开始故事
- `review-mode.txt` 包含 `full`

**输入：** `/sprint-plan`

**预期行为：**
1. 技能读取 sprint-002，检测到 2 个未关闭的（进行中）故事
2. 技能提示：“迭代 002 有 2 个未关闭故事，请在规划迭代 003 前确认是否结转”
3. 技能让用户选择：结转故事、延期故事或取消
4. 用户确认结转；结转故事以 `[CARRY]` 标签置于新迭代开头
5. 构建迭代草稿；调用 PR-SPRINT 门禁；批准后写入迭代

**断言：**
- [ ] 技能检查最近的迭代文件，查找未关闭故事
- [ ] 继续规划前询问用户是否确认结转
- [ ] 结转故事在新迭代草稿中带有醒目标识
- [ ] 技能不会静默忽略上一个迭代的未关闭故事

---

## 协议合规性

- [ ] 调用 PR-SPRINT 门禁或请求写入前展示迭代草稿
- [ ] 写入迭代文件前始终询问 "May I write"
- [ ] PR-SPRINT 门禁仅在 `full` 模式下运行
- [ ] `lean` 和 `solo` 模式的输出中出现跳过消息
- [ ] 技能输出末尾清晰陈述判定

---

## 覆盖说明

- 未明确测试不存在里程碑文件的情况；其行为遵循 BLOCKED 模式，并建议运行 `/gate-check` 推进里程碑。
- `solo` 模式等同于 `lean`（跳过门禁但仍需用户批准），未单独测试。
- 未测试并行故事选择算法；那属于 sprint-plan 子代理的单元测试范围。
