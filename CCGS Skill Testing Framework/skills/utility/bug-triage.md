# 技能测试规范：/bug-triage

## 技能摘要

`/bug-triage` 读取 `production/bugs/` 中所有未关闭的缺陷报告，并按严重程度
（CRITICAL → HIGH → MEDIUM → LOW）排序，生成优先级分诊表。它在 Haiku 模型上运行
（只读的格式化/排序任务），不会写入文件，分诊结果以对话形式输出。技能会标记缺少复现
步骤的缺陷，并通过比较标题和受影响系统识别可能的重复项。

结论始终为 TRIAGED，此技能仅提供建议和信息。不适用总监门禁。输出用于帮助制作人或 QA
负责人确定下一步应处理哪些缺陷。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键词：TRIAGED
- [ ] 不包含 "May I write" 语言（此技能为只读）
- [ ] 包含下一步交接（例如用 `/bug-report` 创建新报告，用 `/hotfix` 处理严重缺陷）

---

## 总监门禁检查

无。`/bug-triage` 是只读建议技能，不适用总监门禁。

---

## 测试用例

### 用例 1：正常路径——5 个不同严重程度的缺陷，生成排序表

**测试夹具：**
- `production/bugs/` 包含 5 份缺陷报告文件：
  - bug-2026-03-10-audio-crash.md（CRITICAL）
  - bug-2026-03-12-score-overflow.md（HIGH）
  - bug-2026-03-14-ui-overlap.md（MEDIUM）
  - bug-2026-03-15-typo-tutorial.md（LOW）
  - bug-2026-03-16-vfx-flicker.md（HIGH）

**输入：** `/bug-triage`

**预期行为：**
1. 技能读取全部 5 份缺陷报告文件
2. 技能从每份报告提取严重程度、标题、系统和复现状态
3. 技能生成分诊表，排序为 CRITICAL、HIGH、MEDIUM、LOW
4. 相同严重程度内按日期排序（最早的在前）
5. 结论为 TRIAGED

**断言：**
- [ ] 分诊表恰好有 5 行
- [ ] CRITICAL 缺陷出现在两个 HIGH 缺陷之前
- [ ] HIGH 缺陷出现在 MEDIUM 和 LOW 缺陷之前
- [ ] 结论为 TRIAGED
- [ ] 不写入任何文件

---

### 用例 2：未找到缺陷报告——引导运行 /bug-report

**测试夹具：**
- `production/bugs/` 目录存在但为空（或不存在）

**输入：** `/bug-triage`

**预期行为：**
1. 技能扫描 `production/bugs/`，未找到报告
2. 技能输出：“production/bugs/ 中未找到未关闭的缺陷报告”
3. 技能建议运行 `/bug-report` 创建缺陷报告
4. 不生成分诊表

**断言：**
- [ ] 输出明确说明未找到缺陷
- [ ] 建议将 `/bug-report` 作为下一步
- [ ] 技能不报错，能妥善处理空目录
- [ ] 结论为 TRIAGED（带有“未找到缺陷”的上下文）

---

### 用例 3：缺陷缺少复现步骤——标记为 NEEDS REPRO INFO

**测试夹具：**
  - `production/bugs/` 包含 3 份缺陷报告，其中一份的 “Repro Steps” 章节为空

**输入：** `/bug-triage`

**预期行为：**
1. 技能读取全部 3 份报告
2. 技能检测到缺少复现步骤的报告
3. 该缺陷出现在分诊表中，并带有 `NEEDS REPRO INFO` 标签
4. 其他缺陷正常分诊
5. 结论为 TRIAGED

**断言：**
- [ ] 缺少复现步骤的缺陷旁出现 `NEEDS REPRO INFO` 标签
- [ ] 被标记的缺陷仍包含在表中（不排除）
- [ ] 其他缺陷不受影响
- [ ] 结论为 TRIAGED

---

### 用例 4：可能重复的缺陷——在分诊输出中标记

**测试夹具：**
- `production/bugs/` 包含 2 份标题相似的缺陷报告：
  - bug-2026-03-18-player-fall-through-floor.md
  - bug-2026-03-20-player-clips-through-floor.md
   - 两者均影响 “Physics” 系统，且严重程度相同

**输入：** `/bug-triage`

**预期行为：**
1. 技能读取两份报告，并检测到标题相似、系统相同且严重程度相同
2. 两个缺陷都包含在分诊表中
3. 两者均标记 `POSSIBLE DUPLICATE`，并交叉引用另一份报告
4. 不合并或删除缺陷，标记仅供建议
5. 结论为 TRIAGED

**断言：**
- [ ] 两个缺陷都出现在表中（未合并）
- [ ] 两者均标记 `POSSIBLE DUPLICATE`
- [ ] 每个缺陷都通过文件名或标题交叉引用另一个
- [ ] 结论为 TRIAGED

---

### 用例 5：总监门禁检查——无门禁；分诊仅提供建议

**测试夹具：**
- `production/bugs/` 包含任意数量的报告

**输入：** `/bug-triage`

**预期行为：**
1. 技能生成分诊表
2. 不启动总监代理
3. 输出中不出现门禁 ID
4. 不调用写入工具

**断言：**
- [ ] 不调用总监门禁
- [ ] 不调用写入工具
- [ ] 不出现门禁跳过消息
- [ ] 无需门禁检查即可得出 TRIAGED 结论

---

## 协议合规性

- [ ] 生成表格前读取 `production/bugs/` 中的所有文件
- [ ] 按严重程度排序（CRITICAL → HIGH → MEDIUM → LOW）
- [ ] 标记缺少复现步骤的缺陷
- [ ] 根据标题/系统相似度标记可能的重复项
- [ ] 不写入任何文件
- [ ] 所有情况下（包括空目录）结论均为 TRIAGED

---

## 覆盖说明

- 缺陷报告格式错误（完全缺少严重程度字段）的情况未使用测试夹具验证；技能会将其标记为
  `UNKNOWN SEVERITY`，并在表格中排到最后。
- 状态转换（将缺陷标记为已解决）不属于此技能范围，因为 bug-triage 是只读的。
- 重复检测启发式规则（标题相似度加相同系统）是近似判断；精确匹配逻辑定义在技能正文中。
