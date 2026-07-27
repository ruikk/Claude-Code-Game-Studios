# 技能测试规范：/team-qa

## 技能摘要

通过 7 阶段结构化测试周期编排 QA 团队。协调 qa-lead（策略、测试计划、签核报告）和 qa-tester（测试用例、缺陷报告），覆盖范围检测、故事分类、QA 计划生成、冒烟检查门、测试用例编写、带缺陷提交的手动 QA，以及结论为 APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED 的最终签核报告。阶段 5 为独立故事并行启动 qa-tester。

---

## 静态断言（结构）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 签核报告包含结论关键词：APPROVED、APPROVED WITH CONDITIONS、NOT APPROVED
- [ ] QA 计划和签核报告都包含“May I write”文本
- [ ] 存在“错误恢复协议”章节
- [ ] 阶段转换时使用 `AskUserQuestion`，在继续前取得用户批准
- [ ] 阶段 4（冒烟检查）是硬门：FAIL 会停止周期
- [ ] 缺陷报告写入 `production/qa/bugs/`，命名为 `BUG-[NNN]-[short-slug].md`
- [ ] 下一步指导随结论不同而变化（APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED）
- [ ] 阶段 5 中相互独立的 qa-tester 任务并行启动

---

## 测试用例

### 用例 1：成功路径——所有故事通过手动 QA，结论为 APPROVED

**夹具：**
- `production/sprints/sprint-03/` 存在且包含 4 个故事文件
- 故事类型混合：1 个 Logic、1 个 Integration、2 个 Visual/Feel
- 所有故事均已填写验收标准
- `tests/smoke/` 包含冒烟测试清单；所有项目均可验证
- `production/qa/bugs/` 中不存在现有缺陷

**输入：** `/team-qa sprint-03`

**预期行为：**
1. 阶段 1：读取 `production/sprints/sprint-03/` 中的所有故事文件；读取 `production/stage.txt`；报告“找到 4 个故事。当前阶段：[stage]。准备开始 QA 策略了吗？”
2. 阶段 2：通过 Task 启动 `qa-lead`；生成包含全部 4 个故事分类的策略表；未标记阻塞项；呈现给用户；AskUserQuestion：用户选择“看起来不错——继续制定测试计划”
3. 阶段 3：生成 QA 计划文档；询问“May I write the QA plan to `production/qa/qa-plan-sprint-03-[date].md`?”；获批后写入
4. 阶段 4：通过 Task 启动 `qa-lead`；审查 `tests/smoke/`；返回 PASS；报告“冒烟检查通过。继续编写测试用例。”
5. 阶段 5：为每个 Visual/Feel 和 Integration 故事（2–3 个故事）通过 Task 启动 `qa-tester`；并行运行；按故事分组呈现测试用例；每组使用 AskUserQuestion；用户批准
6. 阶段 6：逐一检查每个已批准的故事；用户将全部标记为 PASS；结果摘要：“故事 PASS：4，FAIL：0，BLOCKED：0”
7. 阶段 7：通过 Task 启动 `qa-lead` 生成签核报告；报告显示所有故事均为 PASS；未提交缺陷；结论：APPROVED；询问“May I write this QA sign-off report to `production/qa/qa-signoff-sprint-03-[date].md`?”；获批后写入
8. 结论：COMPLETE——QA 周期完成

**断言：**
- [ ] 阶段 1 正确统计并报告 4 个故事及当前阶段
- [ ] 阶段 2 的策略表按正确类型分类全部 4 个故事
- [ ] QA 计划仅在“May I write?”获批后写入
- [ ] 冒烟检查 PASS 后流水线无需用户干预即可继续
- [ ] 阶段 5 中独立故事的 qa-tester 任务并行发出
- [ ] 签核报告包含测试覆盖摘要表和结论：APPROVED
- [ ] 签核报告仅在“May I write?”获批后写入
- [ ] 最终输出中出现结论：COMPLETE
- [ ] 下一步：“运行 `/gate-check` 验证阶段推进。”

---

### 用例 2：冒烟检查失败——QA 周期在阶段 4 停止

**夹具：**
- `production/sprints/sprint-04/` 存在且包含 3 个故事文件
- `tests/smoke/` 存在且包含 5 个冒烟测试项目；其中 2 个无法验证（例如构建不稳定、核心导航损坏）

**输入：** `/team-qa sprint-04`

**预期行为：**
1. 阶段 1–3 正常完成；QA 计划已写入
2. 阶段 4：通过 Task 启动 `qa-lead`；冒烟检查返回 FAIL；识别出两个具体失败项
3. 技能报告：“冒烟检查失败。必须先解决以下问题才能开始 QA：[2 个失败项列表]。修复后重新运行 `/smoke-check`，或问题解决后重新运行 `/team-qa`。”
4. 技能在阶段 4 后立即停止——不执行阶段 5、6 或 7
5. 不生成签核报告；不发出签核用的“May I write?”询问

**断言：**
- [ ] 冒烟检查 FAIL 导致流水线在阶段 4 停止——不执行阶段 5、6、7
- [ ] 向用户明确展示失败项列表（不含糊概括）
- [ ] 技能建议重新运行 `/smoke-check` 和 `/team-qa` 作为修复步骤
- [ ] 不写入或提供 QA 签核报告
- [ ] 技能不生成 COMPLETE 结论
- [ ] 阶段 3 已写入的任何 QA 计划均得到保留（不删除）

---

### 用例 3：发现缺陷——Visual/Feel 故事未通过手动 QA，提交缺陷报告

**夹具：**
- `production/sprints/sprint-05/` 存在且包含 2 个故事文件：1 个 Logic（自动化测试通过）、1 个 Visual/Feel
- `tests/smoke/` 冒烟检查通过
- Visual/Feel 故事的动画时序明显错误（未满足验收标准）
- `production/qa/bugs/` 目录存在（为空或包含现有缺陷）

**输入：** `/team-qa sprint-05`

**预期行为：**
1. 阶段 1–5 正常完成；为 Visual/Feel 故事编写测试用例
2. 阶段 6：用户将 Visual/Feel 故事标记为 FAIL；AskUserQuestion 收集失败描述：“动画以 2 倍速播放——每次循环都能看到抖动”
3. 阶段 6：通过 Task 启动 `qa-tester` 编写正式缺陷报告；缺陷报告写入 `production/qa/bugs/BUG-001-animation-speed-jitter.md`（或存在缺陷时使用下一个递增编号）；报告包含严重性字段
4. 结果摘要：“故事 PASS：1，FAIL：1——已提交缺陷：BUG-001”
5. 阶段 7：启动 `qa-lead` 生成签核报告；“发现的缺陷”表列出 BUG-001、严重性和状态 Open；结论：NOT APPROVED（S1/S2 缺陷处于 Open，或 FAIL 且没有记录在案的变通方案）
6. 提供签核报告写入选项；获批后写入
7. 下一步：“解决 S1/S2 缺陷并重新运行 `/team-qa`，或在推进前执行针对性的手动 QA。”

**断言：**
- [ ] 阶段 6 的 FAIL 结果触发 AskUserQuestion，在写入缺陷报告前收集失败描述
- [ ] 通过 Task 启动 `qa-tester` 编写缺陷报告——编排器不直接写入
- [ ] 缺陷报告遵循命名约定：位于 `production/qa/bugs/` 中的 `BUG-[NNN]-[short-slug].md`
- [ ] 缺陷报告的 NNN 根据目录中的现有缺陷正确递增
- [ ] 阶段 7 签核报告的“发现的缺陷”表包含缺陷 ID、故事名称、严重性和状态
- [ ] 签核报告结论为 NOT APPROVED
- [ ] 下一步明确提到重新运行 `/team-qa`
- [ ] 编排器仍发布结论：COMPLETE（QA 周期已完成——结论为 NOT APPROVED，但技能完成了流水线）

---

### 用例 4：无参数——推断活动迭代或询问用户

**夹具（变体 A——存在状态文件）：**
- `production/session-state/active.md` 存在且包含对 `sprint-06` 的引用
- `production/sprint-status.yaml` 存在且将 `sprint-06` 标识为活动迭代

**夹具（变体 B——不存在状态文件）：**
- `production/session-state/active.md` 不存在
- `production/sprint-status.yaml` 不存在

**输入：** `/team-qa`（无参数）

**预期行为（变体 A）：**
1. 阶段 1：未提供参数；读取 `production/session-state/active.md`；读取 `production/sprint-status.yaml`
2. 从两个来源识别出活动迭代为 `sprint-06`
3. 按 `/team-qa sprint-06` 作为输入继续；报告“未提供迭代参数——根据会话状态推断为 sprint-06。找到 [N] 个故事。”

**预期行为（变体 B）：**
1. 阶段 1：未提供参数；尝试读取 `production/session-state/active.md`——文件缺失；尝试读取 `production/sprint-status.yaml`——文件缺失
2. 无法推断迭代；使用 AskUserQuestion：“QA 应覆盖哪个迭代或功能？”并提供输入迭代标识符或取消选项

**断言：**
- [ ] 未提供参数时，技能不会默认使用硬编码的迭代名称
- [ ] 技能在询问用户前读取 `production/session-state/active.md` 和 `production/sprint-status.yaml`（变体 A）
- [ ] 两个状态文件都缺失时，技能使用 AskUserQuestion 而非猜测（变体 B）
- [ ] 继续前向用户报告推断出的迭代（变体 A 的透明性）
- [ ] 状态文件缺失时技能不报错——回退到询问用户（变体 B）

---

### 用例 5：结果混合——部分 PASS、一个带 S1 缺陷的 FAIL、一个 BLOCKED

**夹具：**
- `production/sprints/sprint-07/` 存在且包含 4 个故事文件
- 冒烟检查通过
- 故事 A（Logic）：自动化测试通过——PASS
- 故事 B（UI）：手动 QA——PASS WITH NOTES（轻微文字溢出）
- 故事 C（Visual/Feel）：手动 QA——FAIL；测试人员发现激活能力时发生 S1 崩溃
- 故事 D（Integration）：无法测试——BLOCKED（依赖系统尚未实现）

**输入：** `/team-qa sprint-07`

**预期行为：**
1. 阶段 1–5 继续执行；阶段 5 的测试用例覆盖故事 B、C、D
2. 阶段 6：用户将故事 A 隐式标记为 PASS（自动化）；故事 B：PASS WITH NOTES；故事 C：FAIL；故事 D：BLOCKED
3. 故事 C FAIL 后：启动 qa-tester 编写严重性为 S1 的缺陷报告 `BUG-001-crash-ability-activation.md`
4. 呈现结果摘要：“故事 PASS：1，PASS WITH NOTES：1，FAIL：1——已提交缺陷：BUG-001（S1），BLOCKED：1”
5. 阶段 7：qa-lead 生成覆盖全部 4 个故事的签核报告；BUG-001 列为 S1/Open；故事 D 列为 BLOCKED；结论：NOT APPROVED
6. 签核报告在“May I write?”获批后写入
7. 下一步：“解决 S1/S2 缺陷并重新运行 `/team-qa`，或在推进前执行针对性的手动 QA。”

**断言：**
- [ ] 全部 4 个故事都出现在阶段 7 签核报告的测试覆盖摘要表中——不得静默遗漏
- [ ] 故事 D（BLOCKED）以 BLOCKED 状态列入报告，不得静默丢弃
- [ ] 无论其他故事是否通过，S1 缺陷都会导致结论为 NOT APPROVED
- [ ] PASS WITH NOTES 故事不会降级为 FAIL——单独跟踪
- [ ] “发现的缺陷”表中将 BUG-001 的严重性列为 S1
- [ ] 保留部分结果——即使存在失败和阻塞，仍生成签核报告
- [ ] 编排器发布结论：COMPLETE（流水线完成）；签核结论为 NOT APPROVED

---

## 协议合规性

- [ ] 阶段 2（策略审查）、阶段 5（按组批准测试用例）和阶段 6（逐故事手动 QA 结果）使用 `AskUserQuestion`
- [ ] 阶段 4 冒烟检查是硬门：FAIL 无例外地使流水线在阶段 4 停止
- [ ] QA 计划（阶段 3）和签核报告（阶段 7）分别询问“May I write?”
- [ ] 缺陷报告始终由 `qa-tester` 通过 Task 写入——编排器不直接写入
- [ ] 阶段 5 中独立故事的 qa-tester 任务尽可能并行发出
- [ ] 错误恢复：任何 BLOCKED 代理都立即呈现，并通过 AskUserQuestion 提供选项
- [ ] 始终生成部分报告——不会因一个故事失败或阻塞而丢弃工作
- [ ] 严格应用签核结论规则：任何 S1/S2 缺陷处于 Open 都是 NOT APPROVED；无例外
- [ ] 编排器级结论 COMPLETE 与签核报告的 APPROVED/NOT APPROVED 结论相互独立

---

## 覆盖说明

- “APPROVED WITH CONDITIONS”结论路径（S3/S4 缺陷、PASS WITH NOTES）由用例 5 的 PASS WITH NOTES 故事（故事 B）隐式覆盖——如果不存在 S1/S2 缺陷，该用例会产生 APPROVED WITH CONDITIONS。结论逻辑由表驱动，因此不需要专门用例。
- `feature: [system-name]` 参数形式未单独测试——它与迭代形式遵循相同的阶段 1 逻辑，只是使用 glob 而非目录读取。无参数推断路径（用例 4）已足够覆盖检测逻辑。
- 自动化测试通过的 Logic 故事不需要手动 QA——用例 5（故事 A）隐式验证了这一点，其中 Logic 故事不进入手动 QA 阶段。
- 阶段 5 并行启动 qa-tester 由用例 1 隐式验证（同时发出多个 Visual/Feel 故事）；除静态断言检查外，不需要专门的并行用例。
