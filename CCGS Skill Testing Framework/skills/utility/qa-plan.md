# 技能测试规范：/qa-plan

## 技能摘要

`/qa-plan` 为功能或迭代里程碑生成结构化 QA 测试计划。
它读取指定迭代的故事文件，提取每个故事的验收标准，并对照
`coding-standards.md` 中的测试标准分配适当的测试类型（单元、集成、视觉、UI 或配置/数据），然后生成一份按优先级排序的 QA 计划文档。

该技能在持久化输出前询问“May I write to `production/qa/qa-plan-sprint-NNN.md`?”。如果发现同一迭代已有测试计划，技能会提供更新而不是替换的选项。计划写入后，判定结果为 COMPLETE。不使用主管门禁，故事级别的就绪检查由 `/story-readiness` 处理。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：COMPLETE
- [ ] 写入计划前包含“May I write”协作协议措辞
- [ ] 包含下一步交接说明（例如 `/smoke-check` 或 `/story-readiness`）

---

## 主管门禁检查

无。`/qa-plan` 是规划工具。故事就绪门禁独立处理。

---

## 测试用例

### 用例 1：正常路径：包含 4 个故事的迭代生成完整测试计划

**测试夹具：**
- `production/sprints/sprint-003.md` 列出 4 个具有明确验收标准的故事
- 故事类型包括：1 个逻辑（公式）、1 个集成、1 个视觉、1 个 UI
- 存在包含测试证据表的 `coding-standards.md`

**输入：** `/qa-plan sprint-003`

**预期行为：**
1. 技能读取 sprint-003.md 并识别 4 个故事
2. 技能读取每个故事的验收标准
3. 技能根据 coding-standards.md 表格分配测试类型：
   - 逻辑故事 → 单元测试（BLOCKING）
   - 集成故事 → 集成测试（BLOCKING）
   - 视觉故事 → 截图 + 负责人签核（ADVISORY）
   - UI 故事 → 手动演练文档（ADVISORY）
4. 技能按故事逐项起草 QA 计划及测试类型分解
5. 技能询问“May I write to `production/qa/qa-plan-sprint-003.md`?”
6. 获得批准后写入文件；判定结果为 COMPLETE

**断言：**
- [ ] 计划包含全部 4 个故事
- [ ] 测试类型依据 coding-standards.md 分配（不是猜测）
- [ ] 每个故事均注明门禁级别（BLOCKING 或 ADVISORY）
- [ ] 使用正确文件路径询问“May I write”
- [ ] 判定结果为 COMPLETE

---

### 用例 2：故事没有验收标准：标记为 UNTESTABLE

**测试夹具：**
- `production/sprints/sprint-004.md` 列出 3 个故事，其中一个故事的验收标准章节为空

**输入：** `/qa-plan sprint-004`

**预期行为：**
1. 技能读取全部 3 个故事
2. 技能检测到没有 AC 的故事
3. 计划中将该故事标记为 `UNTESTABLE — 需要补充验收标准`
4. 其他 2 个故事获得正常的测试类型分配
5. 写入带有 UNTESTABLE 标记的计划；判定结果为 COMPLETE

**断言：**
- [ ] 没有 AC 的故事显示 UNTESTABLE 标签
- [ ] 计划不被阻塞，其他故事仍正常规划
- [ ] 输出建议为被标记的故事补充 AC（作为下一步）
- [ ] 判定结果为 COMPLETE（计划仍然生成）

---

### 用例 3：发现现有测试计划：提供更新而不是替换

**测试夹具：**
- `production/qa/qa-plan-sprint-003.md` 已由之前的运行生成
- 自上次计划以来，Sprint-003 新增了 2 个故事

**输入：** `/qa-plan sprint-003`

**预期行为：**
1. 技能读取 sprint-003.md，检测到现有计划中没有的 2 个故事
2. 技能报告：“已找到 sprint-003 的现有 QA 计划，提供更新选项”
3. 技能展示 2 个新故事及其建议的测试分配
4. 技能询问“可以更新 `production/qa/qa-plan-sprint-003.md` 吗？”（不是替换）
5. 获得批准后写入更新后的计划

**断言：**
- [ ] 技能检测到现有计划文件
- [ ] 使用“更新”措辞（不是“替换”）
- [ ] 仅建议添加新故事，保留现有条目
- [ ] 判定结果为 COMPLETE

---

### 用例 4：迭代没有故事：报错并提供指导

**测试夹具：**
- `production/sprints/sprint-007.md` 不存在
- 不存在其他匹配 sprint-007 的迭代文件

**输入：** `/qa-plan sprint-007`

**预期行为：**
1. 技能尝试读取 sprint-007.md，但文件不存在
2. 技能输出：“找不到 sprint-007 的迭代文件”
3. 技能建议先运行 `/sprint-plan` 创建迭代
4. 不写入计划，也不询问“May I write”

**断言：**
- [ ] 错误消息指出缺失的迭代文件
- [ ] 建议使用 `/sprint-plan` 作为修复步骤
- [ ] 不调用写入工具
- [ ] 判定结果不是 COMPLETE（错误状态）

---

### 用例 5：主管门禁检查：无门禁，QA 规划是工具技能

**测试夹具：**
- 包含有效故事和 AC 的迭代

**输入：** `/qa-plan sprint-003`

**预期行为：**
1. 技能生成并写入 QA 计划
2. 不启动任何主管代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用主管门禁
- [ ] 不出现跳过门禁的消息
- [ ] 技能无需任何门禁检查即可达到 COMPLETE

---

## 协议合规性

- [ ] 分配测试类型前读取 coding-standards.md 测试证据表
- [ ] 按故事类型分配 BLOCKING 或 ADVISORY 门禁级别
- [ ] 将没有 AC 的故事标记为 UNTESTABLE（不静默跳过）
- [ ] 检测现有计划并提供更新路径
- [ ] 创建或更新计划文件前询问“May I write”
- [ ] 计划写入后判定结果为 COMPLETE

---

## 覆盖说明

- `coding-standards.md` 缺失时（技能无法分配测试类型）的情况没有进行测试夹具验证；行为应遵循 BLOCKED 模式，并提示恢复该标准文件。
- 跨多个迭代的规划（覆盖 2 个迭代）未进行测试；该技能设计为一次处理一个迭代。
- 配置/数据故事类型（平衡调整 → 冒烟检查）遵循用例 1 中与其他类型相同的分配模式，没有单独测试。
