# 技能测试规范：/release-checklist

## 技能摘要

`/release-checklist` 生成内部发布就绪清单，涵盖：迭代故事完成情况、开放缺陷严重程度、QA 签核状态、构建稳定性和变更日志就绪情况。它是内部门禁，不是平台/商店清单（后者是 `/launch-checklist`）。如果存在上一份发布清单，它会展示已解决和新引入问题的差异。

该技能在询问“May I write”后将清单报告写入 `production/releases/release-checklist-[date].md`。不适用主管门禁，正式阶段门禁逻辑由 `/gate-check` 处理。判定结果：RELEASE READY、RELEASE BLOCKED 或 CONCERNS。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含判定关键词：RELEASE READY、RELEASE BLOCKED、CONCERNS
- [ ] 写入报告前包含“May I write”协作协议措辞
- [ ] 包含下一步交接说明（例如外部发布使用 `/launch-checklist`，阶段推进使用 `/gate-check`）

---

## 主管门禁检查

无。`/release-checklist` 是内部审计工具。正式阶段推进由 `/gate-check` 管理。

---

## 测试用例

### 用例 1：正常路径：所有迭代故事完成、QA 通过、RELEASE READY

**测试夹具：**
- `production/sprints/sprint-008.md`：所有故事均为 `Status: Done`
- `production/bugs/` 中没有严重程度为 HIGH 或 CRITICAL 的开放缺陷
- `production/qa/qa-plan-sprint-008.md` 包含 QA 签核标注
- 存在此版本的变更日志条目
- `production/stage.txt` 包含 `Polish`

**输入：** `/release-checklist`

**预期行为：**
1. 技能读取 sprint-008：所有故事均为 Done
2. 技能读取缺陷：没有 HIGH 或 CRITICAL 开放缺陷
3. 技能确认 QA 计划已签核
4. 技能确认存在变更日志条目
5. 所有检查通过；技能询问“May I write to
   `production/releases/release-checklist-2026-04-06.md`?"
6. 写入报告；判定结果为 RELEASE READY

**断言：**
- [ ] 评估全部 4 个检查类别（故事、缺陷、QA、变更日志）
- [ ] 所有项目均显示 PASS 标记
- [ ] 判定结果为 RELEASE READY
- [ ] 写入前询问“May I write”

---

### 用例 2：存在 HIGH 严重程度缺陷：RELEASE BLOCKED

**测试夹具：**
- 所有迭代故事均为 Done
- `production/bugs/` 包含 2 个严重程度为 HIGH 的开放缺陷

**输入：** `/release-checklist`

**预期行为：**
1. 技能读取迭代：故事已完成
2. 技能读取缺陷：有 2 个 HIGH 严重程度缺陷开放
3. 技能报告：“RELEASE BLOCKED — 必须解决 2 个开放的 HIGH 严重程度缺陷”
4. 报告列出两个缺陷文件名
5. 判定结果为 RELEASE BLOCKED

**断言：**
- [ ] 判定结果为 RELEASE BLOCKED（不是 CONCERNS）
- [ ] 明确列出两个缺陷文件名
- [ ] 技能明确 HIGH 严重程度缺陷会阻塞发布（不是提示项）

---

### 用例 3：未生成变更日志：CONCERNS

**测试夹具：**
- 所有故事均为 Done，没有 HIGH/CRITICAL 缺陷
- 未找到当前版本/迭代的变更日志条目

**输入：** `/release-checklist`

**预期行为：**
1. 技能检查所有项目
2. 变更日志检查失败：未找到变更日志条目
3. 技能报告：“CONCERNS — 此发布未生成变更日志”
4. 技能建议运行 `/changelog` 生成变更日志
5. 判定结果为 CONCERNS（提示项，不是硬阻塞）

**断言：**
- [ ] 判定结果为 CONCERNS（不是 RELEASE BLOCKED，变更日志是提示项）
- [ ] 建议使用 `/changelog` 修复
- [ ] 报告展示其他已通过的检查
- [ ] 将缺少变更日志描述为提示项，而非阻塞项

---

### 用例 4：存在上一份发布清单：展示与上次发布的差异

**测试夹具：**
- `production/releases/release-checklist-2026-03-20.md` 存在
- 上一份状态：1 个故事未完成，1 个 HIGH 缺陷开放
- 当前状态：所有故事均为 Done，HIGH 缺陷已解决，但新增 1 个 MEDIUM 缺陷

**输入：** `/release-checklist`

**预期行为：**
1. 技能找到并加载上一份清单
2. 生成并比较新清单：
     - 新解决项：“故事 [X] — 之前未完成，现为 Done”
     - 新解决项：“HIGH 缺陷 [filename] — 之前开放，现已关闭”
    - 新项目：“出现 1 个 MEDIUM 缺陷（提示项）”
3. 差异章节突出显示所有变更
4. 判定结果为 CONCERNS（MEDIUM 缺陷是提示项，不会阻塞发布）

**断言：**
- [ ] 报告包含差异章节，并列出已解决项目和新项目
- [ ] 标注上一份清单中的新解决项目
- [ ] 突出显示上一份清单中不存在的新项目
- [ ] 判定结果反映当前状态（不是上一份状态）

---

### 用例 5：主管门禁检查：无门禁，release-checklist 是内部审计

**测试夹具：**
- 包含故事和缺陷报告的活动迭代

**输入：** `/release-checklist`

**预期行为：**
1. 技能运行完整清单并写入报告
2. 不启动任何主管代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用主管门禁
- [ ] 不出现跳过门禁的消息
- [ ] 判定结果为 RELEASE READY、RELEASE BLOCKED 或 CONCERNS，不是门禁判定

---

## 协议合规性

- [ ] 检查迭代故事完成状态
- [ ] 检查开放缺陷严重程度（CRITICAL/HIGH = BLOCKED；MEDIUM/LOW = CONCERNS）
- [ ] 检查 QA 计划签核状态
- [ ] 检查变更日志是否存在
- [ ] 存在上一份清单时与其比较
- [ ] 写入报告前询问“May I write”
- [ ] 判定结果为 RELEASE READY、RELEASE BLOCKED 或 CONCERNS

---

## 覆盖说明

- 构建稳定性验证（没有失败的 CI 运行）列为检查类别，但依赖外部 CI 系统状态；如果未配置 CI 集成，技能将其标记为 MANUAL CHECK。
- 无论其他项目如何，CRITICAL 缺陷始终导致 RELEASE BLOCKED；这与用例 2 中的 HIGH 严重程度情形等价。
- `Status: In Review`（而不是 Done）的故事视为未完成，并导致 RELEASE BLOCKED；该边界情况遵循 HIGH 缺陷情形的相同模式。
