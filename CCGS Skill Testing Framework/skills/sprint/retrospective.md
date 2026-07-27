# 技能测试规范：/retrospective

## 技能摘要

`/retrospective` 生成结构化的迭代或里程碑回顾，涵盖三个类别：做得好的方面、做得不好的方面和行动项。
它读取迭代文件和会话日志以汇编观察结果，然后生成回顾文档。不使用主管门禁，因为回顾是团队自省产物。
技能在持久化前会询问 "May I write to `production/retrospectives/retro-sprint-NNN.md`?"。
判定始终为 COMPLETE（回顾是结构化输出，不是通过/失败评估）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含判定关键字：COMPLETE
- [ ] 包含 "May I write" 文本（技能会写入回顾文档）
- [ ] 包含下一步交接（回顾写入后要做什么）

---

## 主管门禁检查

无。回顾是团队自省文档，不调用门禁。

---

## 测试用例

### 用例 1：正常路径——结果混合的迭代

**夹具：**
- `production/sprints/sprint-005.md` 存在，包含 6 个故事（4 个 Complete、1 个 Blocked、1 个 Deferred）
- `production/session-logs/` 包含迭代期间的日志条目
- sprint-005 尚无之前的回顾

**输入：** `/retrospective sprint-005`

**预期行为：**
1. 技能读取 sprint-005 和会话日志
2. 技能汇编三个回顾类别：做得好（交付 4 个故事）、做得不好（1 个阻塞、1 个延期），以及行动项（解决阻塞根因）
3. 技能向用户展示回顾草稿
4. 技能询问 "May I write to `production/retrospectives/retro-sprint-005.md`?"
5. 用户批准；写入文件；判定为 COMPLETE

**断言：**
- [ ] 回顾包含全部三个类别（做得好 / 做得不好 / 行动项）
- [ ] 被阻塞和延期的故事出现在“做得不好”章节
- [ ] 至少根据被阻塞故事生成一个行动项
- [ ] 写入文件前询问 "May I write"
- [ ] 成功写入后判定为 COMPLETE

---

### 用例 2：没有迭代数据——回退到手动输入

**夹具：**
- 用户调用 `/retrospective sprint-009`
- `production/sprints/sprint-009.md` 不存在
- 没有会话日志引用 sprint-009

**输入：** `/retrospective sprint-009`

**预期行为：**
1. 技能尝试读取 sprint-009，但未找到
2. 技能告知用户未找到 sprint-009 的迭代数据
3. 技能提示用户手动提供回顾输入（做得好、做得不好、行动项）
4. 用户提供输入；技能将其格式化为回顾结构
5. 技能询问 "May I write"，批准后写入文档

**断言：**
- [ ] 缺少迭代文件时技能不会崩溃或生成空文档
- [ ] 提示用户手动提供输入
- [ ] 手动输入格式化为三个类别的结构
- [ ] 写入文件前仍出现 "May I write" 提示

---

### 用例 3：已有回顾——提供追加或替换选项

**夹具：**
- `production/retrospectives/retro-sprint-005.md` 已存在且包含内容
- 用户在发生变更后重新运行 `/retrospective sprint-005`

**输入：** `/retrospective sprint-005`

**预期行为：**
1. 技能检测到 `retro-sprint-005.md` 已存在
2. 技能让用户选择：追加新观察或替换现有文件
3. 用户选择“替换”；技能重新汇编回顾
4. 技能询问 "May I write to `production/retrospectives/retro-sprint-005.md`?"，并确认覆盖
5. 文件被覆盖；判定为 COMPLETE

**断言：**
- [ ] 汇编前检查现有回顾文件
- [ ] 为用户提供追加或替换选项，而非静默覆盖
- [ ] "May I write" 提示体现覆盖场景
- [ ] 无论追加还是替换，写入后判定均为 COMPLETE

---

### 用例 4：边界情况——上次回顾有未解决的行动项

**夹具：**
- `production/retrospectives/retro-sprint-004.md` 存在，包含 2 个标记为 `[ ]`（未完成）的行动项
- 用户运行 `/retrospective sprint-005`

**输入：** `/retrospective sprint-005`

**预期行为：**
1. 技能读取最近的上一次回顾（retro-sprint-004）
2. 技能检测到 sprint-004 中 2 个未勾选的行动项
3. 技能在新回顾中包含“从迭代 004 结转”章节
4. 列出未解决项，并注明它们未得到跟进

**断言：**
- [ ] 技能读取最近的上一次回顾，检查未关闭的行动项
- [ ] 未解决的行动项出现在新回顾的结转章节
- [ ] 结转项与新生成的行动项明确区分
- [ ] 输出注明这些事项在上一个迭代中未得到跟进

---

### 用例 5：门禁合规性——任何模式下均不调用门禁

**夹具：**
- `production/sprints/sprint-005.md` 存在且包含已完成故事
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/retrospective sprint-005`

**预期行为：**
1. 技能在 `full` 模式下汇编回顾
2. 不调用主管门禁（回顾是团队自省，不是交付门禁）
3. 技能请求用户批准，确认后写入文件
4. 判定为 COMPLETE

**断言：**
- [ ] 无论审查模式如何，都不调用主管门禁
- [ ] 输出不包含任何门禁调用或门禁结果标记
- [ ] 技能从汇编直接进入 "May I write" 提示
- [ ] 审查模式文件内容与该技能行为无关

---

## 协议合规性

- [ ] 请求写入前始终展示回顾草稿
- [ ] 写入回顾文件前始终询问 "May I write"
- [ ] 不调用主管门禁
- [ ] 判定始终为 COMPLETE（不是通过/失败类技能）
- [ ] 检查上一次回顾中未解决的行动项

---

## 覆盖说明

- 里程碑回顾与迭代回顾遵循相同模式，但读取里程碑文件而非迭代文件；未单独测试。
- 会话日志为空的情况类似用例 2（无数据）；两种情况下技能都会回退到手动输入。
