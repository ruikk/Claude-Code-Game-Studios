# 技能测试规范：/brainstorm

## 技能摘要

`/brainstorm` 引导用户构思游戏概念。它展示 2-4 个包含优缺点的概念选项，让用户选择并
完善概念，最终生成结构化的 `design/gdd/game-concept.md` 文档。此技能采用协作方式：在
提出选项前先提问，并持续迭代，直到用户批准概念方向。

在 `full` 审查模式下，概念草拟完成后会并行启动 4 个总监门禁：CD-PILLARS
（creative-director）、AD-CONCEPT-VISUAL（art-director）、TD-FEASIBILITY
（technical-director）和 PR-SCOPE（producer）。在 `lean` 模式下，4 个内联门禁全部跳过
（lean 模式只运行 PHASE-GATE，而 brainstorm 没有 PHASE-GATE）。在 `solo` 模式下，所有
门禁均跳过。写入 `design/gdd/game-concept.md` 前，技能会询问 "May I write"。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键词：APPROVED、REJECTED、CONCERNS
- [ ] 包含针对 game-concept.md 的 "May I write" 协作协议语言
- [ ] 末尾包含下一步交接（`/map-systems`）
- [ ] 记录 full 模式下的 4 个总监门禁：CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY、PR-SCOPE
- [ ] 记录 lean 和 solo 模式下 4 个门禁均跳过

---

## 总监门禁检查

在 `full` 模式下，用户批准概念草稿后，CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY
和 PR-SCOPE 并行启动。

在 `lean` 模式下，4 个内联门禁全部跳过（brainstorm 没有 PHASE-GATE，因此 lean 模式
会跳过全部内容）。输出将 4 个门禁分别记为："[GATE-ID] skipped — lean mode"。

在 `solo` 模式下，4 个门禁全部跳过。输出将 4 个门禁分别记为："[GATE-ID] skipped — solo mode"。

---

## 测试用例

### 用例 1：正常路径——Full 模式、3 个概念、用户选择其一、4 位总监全部批准

**测试夹具：**
- 不存在 `design/gdd/game-concept.md`
- `production/session-state/review-mode.txt` 内容为 `full`

**输入：** `/brainstorm`

**预期行为：**
1. 技能询问用户的类型、范围和目标感受
2. 技能展示 3 个概念选项及各自的优缺点
3. 用户选择一个概念
4. 技能将选定概念扩展为结构化草稿
5. 4 个总监门禁并行启动：CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY、PR-SCOPE
6. 4 个门禁全部返回 APPROVED
7. 技能询问“May I write `design/gdd/game-concept.md`?”
8. 获得批准后写入概念

**断言：**
- [ ] 恰好展示 3 个概念选项（不是 1 个，也不是 5 个以上）
- [ ] 4 个总监门禁并行启动（不是顺序启动）
- [ ] 4 个门禁全部完成后才询问“May I write”
- [ ] 写入前询问“May I write `design/gdd/game-concept.md`?”
- [ ] 未经用户批准不得写入概念文件
- [ ] 包含移交下一步 `/map-systems`

---

### 用例 2：失败路径——CD-PILLARS 返回 REJECT

**测试夹具：**
- 概念草稿已完成
- `production/session-state/review-mode.txt` 内容为 `full`
- CD-PILLARS 门禁返回 REJECT：“该概念没有可识别的创意支柱”

**输入：** `/brainstorm`

**预期行为：**
1. CD-PILLARS 门禁返回 REJECT 及具体反馈
2. 技能向用户展示拒绝结果
3. 概念不会写入文件
4. 询问用户是重新思考概念方向，还是覆盖该拒绝结果
5. 如果重新思考，技能返回概念选项阶段

**断言：**
- [ ] CD-PILLARS 返回 REJECT 时不会写入概念
- [ ] 向用户逐字展示拒绝反馈
- [ ] 为用户提供重新思考或覆盖的选项
- [ ] 用户选择重新思考时，技能返回概念构思阶段

---

### 用例 3：Lean 模式——4 个门禁全部跳过；用户确认后写入概念

**测试夹具：**
- 不存在现有游戏概念
- `production/session-state/review-mode.txt` 内容为 `lean`

**输入：** `/brainstorm`

**预期行为：**
1. 展示概念选项，用户选择一个
2. 将概念扩展为结构化草稿
3. 4 个总监门禁全部跳过——分别记录为："[GATE-ID] skipped — lean mode"
4. 技能询问用户确认概念是否可以写入
5. 确认后询问“May I write `design/gdd/game-concept.md`?”
6. 获得批准后写入概念

**断言：**
- [ ] 出现全部 4 条门禁跳过说明："CD-PILLARS skipped — lean mode"、"AD-CONCEPT-VISUAL skipped — lean mode"、"TD-FEASIBILITY skipped — lean mode"、"PR-SCOPE skipped — lean mode"
- [ ] 仅在用户确认后写入概念（lean 模式不需要总监批准）
- [ ] 写入前仍会询问“May I write”

---

### 用例 4：Solo 模式——所有门禁跳过；仅经用户批准即可写入概念

**测试夹具：**
- 不存在现有游戏概念
- `production/session-state/review-mode.txt` 内容为 `solo`

**输入：** `/brainstorm`

**预期行为：**
1. 展示概念选项，用户选择一个
2. 向用户展示概念草稿
3. 4 个总监门禁全部跳过——每个门禁均标记为 "solo mode"
4. 询问 "May I write `design/gdd/game-concept.md`?"
5. 获得用户批准后写入概念

**断言：**
- [ ] 出现带有“solo mode”标签的全部 4 条跳过说明
- [ ] 不启动任何总监代理
- [ ] 仅经用户批准即可写入概念
- [ ] 该技能的其他行为与 lean 模式相同

---

### 用例 5：总监门禁——PR-SCOPE 返回 CONCERNS（范围过大）

**测试夹具：**
- 概念草稿已完成
- `production/session-state/review-mode.txt` 内容为 `full`
- PR-SCOPE 门禁返回 CONCERNS：“该概念的范围需要单人开发者投入 18 个月以上”

**输入：** `/brainstorm`

**预期行为：**
1. PR-SCOPE 门禁返回 CONCERNS 及具体范围反馈
2. 技能向用户展示范围风险
3. 写入前将范围风险记录在概念草稿中
4. 询问用户是缩小范围、接受风险并记录，还是重新思考
5. 如果用户接受风险，在概念中嵌入“Scope Risk”说明后写入

**断言：**
- [ ] 在询问“May I write”前向用户展示 PR-SCOPE 风险
- [ ] 技能不得在展示范围风险前写入概念
- [ ] 用户接受后，概念文件中记录范围风险
- [ ] 技能不得因 PR-SCOPE CONCERNS 自动拒绝概念（由用户决定）

---

## 协议合规性

- [ ] 在用户作出决定前展示 2-4 个包含优缺点的概念选项
- [ ] 在调用总监门禁前由用户确认概念方向
- [ ] 在 full 模式下 4 个总监门禁并行启动
- [ ] 在 lean 和 solo 模式下 4 个门禁全部跳过——分别按名称记录
- [ ] 写入前询问“May I write `design/gdd/game-concept.md`?”
- [ ] 以移交下一步 `/map-systems` 结束

---

## 覆盖说明

- AD-CONCEPT-VISUAL 门禁（美术总监可行性）与其他 3 个门禁一起并行启动，未单独使用测试夹具验证。
- 迭代概念完善循环（用户拒绝所有选项，技能生成新选项）未使用测试夹具验证，遵循与选项选择阶段相同的模式。
- game-concept.md 文档结构（必需章节）定义在技能正文中，未在测试断言中重复列出。
