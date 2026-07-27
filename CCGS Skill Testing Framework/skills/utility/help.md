# 技能测试规范：/help

## 技能摘要

`/help` 分析项目工作流中已完成的事项和下一步行动。它运行在 Haiku 模型上（只读、格式化任务），读取 `production/stage.txt`、当前迭代文件和最近的会话状态，生成简明的情境指导摘要。该技能也可接受上下文查询（例如 `/help testing`），以呈现特定主题的相关技能。

输出始终仅供参考，不写入文件，也不调用导演门禁。verdict 始终为 HELP COMPLETE。该技能充当工作流导航器，根据当前项目状态建议 2-3 个后续技能。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含 verdict 关键字：HELP COMPLETE
- [ ] 不包含“May I write”措辞（该技能为只读）
- [ ] 包含下一步交接（根据状态建议 2-3 个相关技能）

---

## 导演门禁检查

无。`/help` 是只读导航技能，不适用导演门禁。

---

## 测试用例

### 用例 1：正常路径——Production 阶段存在当前迭代

**测试夹具：**
- `production/stage.txt` 包含 `Production`
- `production/sprints/sprint-004.md` 存在，且包含进行中的故事
- `production/session-state/active.md` 包含最近的检查点

**输入：** `/help`

**预期行为：**
1. 技能读取 stage.txt 和当前迭代
2. 技能识别当前迭代编号和进行中故事数量
3. 技能输出当前阶段、迭代摘要和 3 个建议的后续技能（例如 `/sprint-status`、`/dev-story`、`/story-done`）
4. 建议按其与当前迭代状态的相关性排序
5. Verdict 为 HELP COMPLETE

**断言：**
- [ ] 显示当前阶段（Production）
- [ ] 提及当前迭代编号和故事数量
- [ ] 恰好给出 2-3 个后续技能建议（不是所有技能的列表）
- [ ] 建议适用于 Production 阶段
- [ ] Verdict 为 HELP COMPLETE
- [ ] 不写入文件

---

### 用例 2：Concept 阶段——展示从概念到系统设计的工作流路径

**测试夹具：**
- `production/stage.txt` 包含 `Concept`
- 没有迭代文件，也没有 GDD 文件
- `technical-preferences.md` 已配置（已选择引擎）

**输入：** `/help`

**预期行为：**
1. 技能读取 stage.txt，检测到 Concept 阶段
2. 技能输出 Concept 阶段工作流：brainstorm → map-systems → design-system
3. 建议技能为 `/brainstorm`、`/map-systems`（如果概念已存在）
4. 记录当前进度：“引擎已配置，概念尚未创建”

**断言：**
- [ ] 阶段识别为 Concept
- [ ] 工作流路径显示该阶段的预期顺序
- [ ] 建议不包含 Production 阶段技能（例如 `/dev-story`）
- [ ] Verdict 为 HELP COMPLETE

---

### 用例 3：没有 stage.txt——展示完整工作流概览

**测试夹具：**
- 没有 `production/stage.txt`
- 没有迭代文件
- `technical-preferences.md` 含占位符

**输入：** `/help`

**预期行为：**
1. 技能无法通过 stage.txt 确定阶段
2. 技能运行 project-stage-detect 逻辑，根据产物推断阶段
3. 如果无法推断阶段：输出从 Concept 到 Release 的完整工作流概览，作为参考地图
4. 首要建议是使用 `/start` 开始配置

**断言：**
- [ ] stage.txt 缺失时技能不会崩溃
- [ ] 无法确定阶段时展示完整工作流概览
- [ ] `/start` 或 `/project-stage-detect` 位列首要建议
- [ ] Verdict 为 HELP COMPLETE

---

### 用例 4：上下文查询——用户请求测试帮助

**测试夹具：**
- `production/stage.txt` 包含 `Production`
- 当前迭代包含 `Status: In Review` 的故事

**输入：** `/help testing`

**预期行为：**
1. 技能读取上下文查询：“testing”
2. 技能呈现与测试相关的技能：`/qa-plan`、`/smoke-check`、`/regression-suite`、`/test-setup`、`/test-evidence-review`
3. 输出聚焦于测试工作流，而非常规迭代导航
4. 将当前处于 `in-review` 状态的故事标记为测试候选

**断言：**
- [ ] 输出确认上下文查询（“帮助主题：testing”）
- [ ] 至少列出 3 个与测试相关的技能
- [ ] 常规迭代技能（例如 `/sprint-plan`）不是首要建议
- [ ] Verdict 为 HELP COMPLETE

---

### 用例 5：导演门禁检查——无门禁；`help` 是只读导航

**测试夹具：**
- 任意项目状态

**输入：** `/help`

**预期行为：**
1. 技能生成工作流指导摘要
2. 不启动导演代理
3. 输出中不出现门禁 ID
4. 不调用写入工具

**断言：**
- [ ] 不调用导演门禁
- [ ] 不调用写入工具
- [ ] 不出现跳过门禁的消息
- [ ] 不执行任何门禁检查，verdict 仍为 HELP COMPLETE

---

## 协议合规性

- [ ] 生成建议前读取阶段、迭代和会话状态
- [ ] 建议针对当前项目状态，而非泛泛而谈
- [ ] 提供上下文查询时缩小建议范围
- [ ] 不写入任何文件
- [ ] 所有情况下 verdict 均为 HELP COMPLETE

---

## 覆盖说明

- 当前迭代已完成（所有故事均为 Done）的情况未单独测试；技能会建议使用 `/sprint-plan` 规划下一迭代。
- `/help` 不验证建议的技能是否可用，而是假定标准技能目录可用。
- 阶段检测回退逻辑（stage.txt 缺失时）委托给与 `/project-stage-detect` 相同的逻辑，本文件不再详细重复测试。
