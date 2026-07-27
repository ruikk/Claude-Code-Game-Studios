# 技能测试规范：/adopt

## 技能摘要

`/adopt` 审核现有项目的产物，包括 GDD、ADR、故事、基础设施文件和
`technical-preferences.md`，检查它们是否符合模板技能流水线的格式要求。它按严重程度
（BLOCKING / HIGH / MEDIUM / LOW）对每项缺口分类，编制有编号且有顺序的迁移计划，
并在通过 `AskUserQuestion` 获得用户明确批准后，将计划写入 `docs/adoption-plan-[date].md`。

此技能不同于 `/project-stage-detect`（后者只检查已有内容）。
`/adopt` 检查现有内容是否真的能与模板技能协同工作。

不适用任何总监门禁。此技能不会调用任何总监代理。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含严重程度等级关键词：BLOCKING、HIGH、MEDIUM、LOW
- [ ] 在写入迁移计划前包含“可以写入吗”或 `AskUserQuestion` 语言
- [ ] 末尾包含下一步交接（例如提供立即修复最高优先级缺口的选项）

---

## 总监门禁检查

无。`/adopt` 是棕地项目审核工具，不适用总监门禁。

---

## 测试用例

### 用例 1：正常路径——所有 GDD 合规、无缺口，COMPLIANT

**测试夹具：**
- `design/gdd/` 包含 3 个 GDD 文件；每个文件都包含全部 8 个必需章节及其内容
- `docs/architecture/adr-0001.md` 存在，并包含 `## Status`、`## Engine Compatibility`
  以及其他所有必需章节
- `production/stage.txt` 存在
- `docs/architecture/tr-registry.yaml` 和 `docs/architecture/control-manifest.md` 存在
- 已在 `technical-preferences.md` 中配置引擎

**输入：** `/adopt`

**预期行为：**
1. 技能输出“正在扫描项目产物……”，随后静默读取所有产物
2. 报告检测到的阶段、GDD 数量、ADR 数量和故事数量
3. 阶段 2 审核：3 个 GDD 均包含全部 8 个章节，且 Status 字段存在并有效
4. ADR 审核：所有必需章节均存在
5. 基础设施审核：所有关键文件均存在
6. 阶段 3：BLOCKING、HIGH、MEDIUM、LOW 缺口均为 0
7. 摘要报告：“没有阻塞缺口——此项目与模板兼容”
8. 使用 `AskUserQuestion` 询问是否写入计划；用户选择写入
9. 迁移计划写入 `docs/adoption-plan-[date].md`
10. 阶段 7 提供下一步操作：没有阻塞缺口时，提供后续步骤选项

**断言：**
- [ ] 技能在展示任何输出前静默读取
- [ ] “正在扫描项目产物……”出现在静默读取阶段之前
- [ ] 缺口计数显示 BLOCKING 为 0、HIGH 为 0、MEDIUM 为 0（或仅存在 LOW）
- [ ] 写入收养计划前使用 `AskUserQuestion`
- [ ] 收养计划文件写入 `docs/adoption-plan-[date].md`
- [ ] 阶段 7 提供具体的下一步操作（而不只是列表）

---

### 用例 2：文档不合规——GDD 缺少章节，NEEDS MIGRATION

**测试夹具：**
- `design/gdd/` 包含 2 个 GDD 文件：
  - `combat.md` — 缺少 `## Acceptance Criteria` 和 `## Formulas` 章节
  - `movement.md` — 8 个章节全部存在
- 一个 ADR（`adr-0001.md`）缺少 `## Status` 章节
- `docs/architecture/tr-registry.yaml` 不存在

**输入：** `/adopt`

**预期行为：**
1. 技能扫描所有产物
2. 阶段 2 审核发现：
   - `combat.md`：缺少 2 个章节（Acceptance Criteria、Formulas）
   - `adr-0001.md`：缺少 `## Status`，影响为 BLOCKING
   - `tr-registry.yaml`：缺失，影响为 HIGH
3. 阶段 3 分类结果：
   - BLOCKING：`adr-0001.md` 缺少 `## Status`（story-readiness 会静默通过）
   - HIGH：缺少 `tr-registry.yaml`；`combat.md` 缺少 Acceptance Criteria（无法生成故事）
   - MEDIUM：`combat.md` 缺少 Formulas
4. 阶段 4 生成有序迁移计划：
   - 第 1 步（BLOCKING）：向 `adr-0001.md` 添加 `## Status`，命令：`/architecture-decision retrofit`
   - 第 2 步（HIGH）：运行 `/architecture-review` 生成初始 tr-registry.yaml
   - 第 3 步（HIGH）：向 `combat.md` 添加 Acceptance Criteria，命令：`/design-system retrofit`
   - 第 4 步（MEDIUM）：向 `combat.md` 添加 Formulas
5. 缺口预览将 BLOCKING 项列为项目符号（显示实际文件名），将 HIGH/MEDIUM 显示为数量
6. `AskUserQuestion` 询问是否写入计划；获得批准后写入
7. 阶段 7 提供立即修复最高优先级缺口（ADR Status）的选项

**断言：**
- [ ] 缺口预览将 BLOCKING 缺口列为明确的文件名项目符号
- [ ] 缺口预览将 HIGH 和 MEDIUM 缺口显示为数量
- [ ] 迁移计划项目按 BLOCKING 优先的顺序排列
- [ ] 每个计划项目都包含修复命令或手动步骤
- [ ] 写入前使用 `AskUserQuestion`
- [ ] 阶段 7 提供立即修复第一个 BLOCKING 项目的选项

---

### 用例 3：混合状态——部分文档合规、部分不合规，生成部分报告

**测试夹具：**
- 4 个 GDD 文件：2 个完全合规，2 个存在缺口（一个缺少 Tuning Knobs，一个缺少 Edge Cases）
- ADR：3 个文件，其中 2 个合规，1 个缺少 `## ADR Dependencies`
- 故事：5 个文件，其中 3 个包含 TR-ID 引用，2 个不包含
- 基础设施：所有关键文件都存在；`technical-preferences.md` 已完整配置

**输入：** `/adopt`

**预期行为：**
1. 技能审核所有类型的产物
2. 审核摘要显示总数：“4 个 GDD（2 个完全合规，2 个存在缺口）；3 个 ADR
   （2 个完全合规，1 个存在缺口）；5 个故事（3 个包含 TR-ID，2 个不包含）”
3. 缺口分类：
   - 没有 BLOCKING 缺口
   - HIGH：1 个 ADR 缺少 `## ADR Dependencies`
   - MEDIUM：2 个 GDD 缺少章节；2 个故事缺少 TR-ID
    - LOW：无
4. 迁移计划先列出 HIGH 缺口，再按顺序列出 MEDIUM 缺口
5. 计划中包含说明：“现有故事会继续工作——不要重新生成进行中或已完成的故事”
6. `AskUserQuestion` 询问是否写入计划；获得批准后写入

**断言：**
- [ ] 显示每类产物的合规统计（N 个合规，M 个存在缺口）
- [ ] 计划中包含现有故事兼容性说明
- [ ] 没有 BLOCKING 缺口时，迁移计划中不包含 BLOCKING 章节
- [ ] 计划顺序中 HIGH 缺口位于 MEDIUM 缺口之前
- [ ] 写入前使用 `AskUserQuestion`

---

### 用例 4：未找到产物——全新项目，引导运行 /start

**测试夹具：**
- `design/gdd/`、`docs/architecture/`、`production/epics/` 中没有文件
- `production/stage.txt` 不存在
- `src/` 目录不存在，或其中少于 10 个文件
- 没有 game-concept.md，也没有 systems-index.md

**输入：** `/adopt`

**预期行为：**
1. 阶段 1 的存在性检查未找到任何产物
2. 技能判断项目为“全新”，没有棕地工作需要迁移
3. 使用 `AskUserQuestion`：
    - “这看起来是一个全新项目，没有找到现有产物。`/adopt` 用于迁移已有工作的项目。你想怎么做？”
    - 选项：“运行 `/start`”、“我的产物位于非标准位置”、“取消”
4. 技能停止，无论用户选择什么都不会继续审核

**断言：**
- [ ] 找不到产物时使用 `AskUserQuestion`（而不是纯文本消息）
- [ ] 将 `/start` 作为命名选项提供
- [ ] 技能在提问后停止，不运行任何审核阶段
- [ ] 不写入收养计划文件

---

### 用例 5：总监门禁检查——无门禁；adopt 是审核工具技能

**测试夹具：**
- 项目包含合规和不合规的 GDD

**输入：** `/adopt`

**预期行为：**
1. 技能完成完整审核并生成迁移计划
2. 全程不启动任何总监代理
3. 输出中不出现任何门禁 ID（CD-*、TD-*、AD-*、PR-*）
4. 技能运行期间不调用 `/gate-check`

**断言：**
- [ ] 不调用任何总监门禁
- [ ] 不出现跳过门禁的消息
- [ ] 技能在没有任何门禁结论的情况下进入计划写入或取消流程

---

## 协议合规性

- [ ] 在静默读取阶段前输出“正在扫描项目产物……”
- [ ] 在展示任何结果前静默读取所有产物
- [ ] 在询问是否写入前显示审核摘要和缺口预览
- [ ] 写入收养计划文件前使用 `AskUserQuestion`
- [ ] 收养计划写入 `docs/adoption-plan-[date].md`，不得写入其他路径
- [ ] 迁移计划项目按以下顺序排列：BLOCKING 第一、HIGH 第二、MEDIUM 第三、LOW 最后
- [ ] 阶段 7 始终提供一个具体的下一步操作（而不是通用列表）
- [ ] 从不重新生成现有产物，只填补已有产物中的缺口
- [ ] 任何时候都不调用总监门禁

---

## 覆盖说明

- `gdds`、`adrs`、`stories` 和 `infra` 参数模式会缩小审核范围；每种模式都遵循完整审核的相同流程，
  但只处理对应类型的产物。此处未单独使用测试夹具验证。
- systems-index.md 的括号状态值检查（BLOCKING）是特殊情况，会在写入计划前立即提供修复选项；未单独测试。
- 如果不存在 `production/review-mode.txt`，review-mode.txt 提示（阶段 6b）会在写入计划后运行；此处未单独测试。
