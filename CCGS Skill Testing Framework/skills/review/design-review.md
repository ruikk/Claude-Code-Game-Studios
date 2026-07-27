# 技能测试规范：/design-review

## 技能摘要

`/design-review` 读取游戏设计文档（GDD），并依据项目的八章节设计标准（概述、
玩家幻想、详细规则、公式、边界情况、依赖项、调优参数、验收标准）进行评估。
它检查内部一致性、可实现性和跨系统冲突，并给出 APPROVED、NEEDS REVISION
或 MAJOR REVISION NEEDED 结论。该技能为只读技能（不写入文件），并作为
`context: fork` 子代理运行。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题或编号步骤
- [ ] 包含结论关键字：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 不要求使用 "May I write" 措辞（只读技能，`allowed-tools` 不包含 Write/Edit）
- [ ] 已说明输出格式（技能正文中展示了评审模板）

---

## 测试用例

### 用例 1：正常路径 - 完整 GDD，八个章节齐全

**测试夹具：**
- `design/gdd/light-manipulation.md` 存在（使用 `_fixtures/minimal-game-concept.md`
  作为替代，代表包含全部必需内容的完整文档）
- 八个必需章节均填有实质内容
- 公式章节至少包含一个公式，且变量均有定义
- 验收标准章节至少包含 3 条可测试标准

**输入：** `/design-review design/gdd/light-manipulation.md`

**预期行为：**
1. 技能完整读取目标文档
2. 技能读取 CLAUDE.md，以获取项目上下文和标准
3. 技能评估全部八个必需章节（检查存在或缺失）
4. 技能检查内部一致性（公式与所述行为一致）
5. 技能检查可实现性（规则足够精确，可据此编码）
6. 技能按章节输出结构化评审结果
7. 技能输出 APPROVED 结论

**断言：**
- [ ] 技能在产生任何输出前读取目标文件
- [ ] 输出包含“完整性”章节，显示已有 X/8 个章节
- [ ] 输出包含“内部一致性”章节
- [ ] 输出包含“可实现性”章节
- [ ] 输出以结论行结束：APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED
- [ ] 八个章节齐全且一致时，给出 APPROVED 结论

---

### 用例 2：失败路径 - GDD 不完整（4/8 个章节）

**测试夹具：**
- `design/gdd/light-manipulation.md` 存在，内容来自
  `tests/skills/_fixtures/incomplete-gdd.md`（八个章节中仅四个有内容；
  缺少公式、边界情况、调优参数和验收标准）

**输入：** `/design-review design/gdd/light-manipulation.md`

**预期行为：**
1. 技能读取文档
2. 技能识别出 4 个缺失章节
3. 技能输出“完整性：已有 4/8 个章节”
4. 技能明确列出缺失的 4 个章节
5. 技能输出 MAJOR REVISION NEEDED 结论（而非 APPROVED 或 NEEDS REVISION）

**断言：**
- [ ] 输出在完整性章节中显示“4/8”（不得为更大的数字）
- [ ] 输出明确指出每个缺失章节（公式、边界情况、调优参数、验收标准）
- [ ] 缺失不少于 3 个章节时，结论为 MAJOR REVISION NEEDED（而非 APPROVED 或 NEEDS REVISION）
- [ ] 输出不得暗示文档已可实施
- [ ] 技能不写入任何文件（强制只读）

---

### 用例 3：部分路径 - 7/8 个章节，存在轻微不一致

**测试夹具：**
- GDD 除公式外，其余章节齐全
- 所述行为提到数值，但未定义公式
- 验收标准存在但含糊（“感觉良好”，而非可度量标准）

**输入：** `/design-review design/gdd/[document].md`

**预期行为：**
1. 技能识别出缺少公式章节
2. 技能将含糊的验收标准标记为可实现性问题
3. 技能输出 NEEDS REVISION 结论（而非 APPROVED 或 MAJOR REVISION NEEDED）
4. 技能为每个问题提供明确的补救说明

**断言：**
- [ ] 对存在问题的 7/8 章节文档，结论为 NEEDS REVISION（而非 APPROVED 或 MAJOR REVISION NEEDED）
- [ ] 输出明确识别出缺少公式章节
- [ ] 输出将含糊的验收标准标记为可实现性缺口
- [ ] 每个标记的问题都有明确、可执行的补救说明

---

### 用例 4：边界情况 - 找不到文件

**测试夹具：**
- 提供的路径在项目中不存在

**输入：** `/design-review design/gdd/nonexistent.md`

**预期行为：**
1. 技能尝试读取文件
2. 找不到文件
3. 技能输出错误消息，并指出缺失的文件
4. 技能建议检查路径或列出 `design/gdd/` 中的文件
5. 技能不产生结论

**断言：**
- [ ] 找不到文件时，技能输出清晰的错误消息
- [ ] 文件缺失时，技能不输出 APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED
- [ ] 技能建议纠正措施（检查路径、列出可用 GDD）

---

---

### 用例 5：主管门禁 - 无论评审模式为何，均不生成门禁

**测试夹具：**
- `design/gdd/light-manipulation.md` 存在且八个章节齐全
- `production/session-state/review-mode.txt` 存在，内容为 `full`（最宽松模式）

**输入：** `/design-review design/gdd/light-manipulation.md`（启用 `full` 评审模式）

**预期行为：**
1. 技能读取 GDD 文档
2. 技能不读取 `review-mode.txt`，因为该技能没有主管门禁
3. 技能正常产生评审输出
4. 全程不生成任何主管门禁代理
5. 结论为 APPROVED（测试夹具中的八个章节齐全）

**断言：**
- [ ] 技能不生成任何主管门禁代理（以 CD-、TD-、PR-、AD- 为前缀的代理）
- [ ] 技能不读取 `review-mode.txt` 或同类模式文件
- [ ] `--review` 标志或 `full` 模式状态对是否生成主管代理没有任何影响
- [ ] 输出不包含任何 "Gate: [GATE-ID]" 条目
- [ ] 该技能本身即执行评审，不会将评审委派给主管

---

## 协议合规性

- [ ] 不使用 Write 或 Edit 工具（只读技能）
- [ ] 在给出任何结论前呈现完整发现
- [ ] 产生输出前不请求批准（没有需要批准的写入操作）
- [ ] 以建议的下一步结束（例如修复问题后重新运行，或继续执行 `/map-systems`）

---

## 覆盖说明

- 此处不直接测试跨系统一致性检查（技能自身阶段列表中的用例 3），因为它需要比较多个 GDD 文件；
  此项改由 `/review-all-gdds` 规范覆盖。
- 不在规范层面测试技能的 `context: fork` 行为（作为子代理运行）；这是需手动验证的运行时行为。
- 性能以及超大型 GDD 文件相关的边界情况不在范围内。
