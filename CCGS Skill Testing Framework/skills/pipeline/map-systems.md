# 技能测试规范：/map-systems

## 技能摘要

`/map-systems` 将游戏概念分解为系统索引。它读取已批准的游戏概念和支柱，枚举显式与隐式系统，映射系统间依赖关系，分配优先级层级（MVP / Vertical Slice / Alpha / Full Vision），并按分层设计顺序（Foundation → Core → Feature → Presentation）组织系统。用户批准后，输出写入 `design/systems-index.md`。

该技能必须在游戏概念获批后、为各系统创建 GDD 前运行，是管线中的强制门禁。在 `full` 评审模式下，分解草稿完成后并行生成 CD-SYSTEMS（creative-director）和 TD-SYSTEM-BOUNDARY（technical-director）。在 `lean` 或 `solo` 模式下跳过两个门禁。该技能写入 `design/systems-index.md`。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 协作协议用语（用于 systems-index.md）
- [ ] 末尾包含下一步交接（`/design-system`）
- [ ] 说明门禁行为：full 模式下并行运行 CD-SYSTEMS + TD-SYSTEM-BOUNDARY

---

## 主管门禁检查

在 `full` 模式下：系统分解草稿完成后、写入 `design/systems-index.md` 前，并行生成 CD-SYSTEMS（creative-director）和 TD-SYSTEM-BOUNDARY（technical-director）。

在 `lean` 模式下：跳过两个门禁。输出注明："CD-SYSTEMS skipped — lean mode" 和 "TD-SYSTEM-BOUNDARY skipped — lean mode"。

在 `solo` 模式下：跳过两个门禁，并提供等效说明。

---

## 测试用例

### 用例 1：正常路径——游戏概念存在，识别出 5 至 8 个系统

**测试夹具：**
- `design/gdd/game-concept.md` 存在，且包含 Core Mechanics 和 MVP Definition 章节
- `design/gdd/game-pillars.md` 存在，且定义了至少 1 个支柱
- `design/systems-index.md` 尚不存在
- `production/session-state/review-mode.txt` 内容为 `full`

**输入：** `/map-systems`

**预期行为：**
1. 技能读取 game-concept.md 和 game-pillars.md
2. 识别 5 至 8 个系统（显式 + 隐式）
3. 映射系统间依赖关系并分配层级
4. 并行生成 CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY，二者返回 APPROVED
5. 询问 "May I write `design/systems-index.md`?"
6. 获批后写入 systems-index.md
7. 更新 `production/session-state/active.md`

**断言：**
- [ ] 识别出 5 至 8 个系统（不能更少；如无说明也不能更多）
- [ ] 并行而非顺序生成 CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY
- [ ] 两个门禁均在 "May I write" 询问前完成
- [ ] 写入前询问 "May I write `design/systems-index.md`?"
- [ ] 未经批准，不写入 systems-index.md
- [ ] 写入后更新会话状态
- [ ] 结论为 COMPLETE

---

### 用例 2：失败路径——未找到游戏概念

**测试夹具：**
- `design/gdd/game-concept.md` 不存在
- `design/gdd/` 目录可能为空或不存在

**输入：** `/map-systems`

**预期行为：**
1. 技能尝试读取 `design/gdd/game-concept.md`
2. 未找到文件
3. 技能输出："No game concept found. Run `/brainstorm` to create one, then return to `/map-systems`."
4. 技能退出，不创建 systems-index.md

**断言：**
- [ ] 技能输出清晰错误并指出缺失文件路径
- [ ] 技能建议下一步运行 `/brainstorm`
- [ ] 不创建 systems-index.md
- [ ] 结论为 BLOCKED

---

### 用例 3：主管门禁——CD-SYSTEMS 返回 CONCERNS（缺少核心系统）

**测试夹具：**
- 游戏概念存在
- `production/session-state/review-mode.txt` 内容为 `full`
- CD-SYSTEMS 门禁返回 CONCERNS："The [core-system] is implied by the concept but not identified"

**输入：** `/map-systems`

**预期行为：**
1. 起草系统列表（初步识别 5 至 8 个系统）
2. CD-SYSTEMS 门禁返回 CONCERNS，并指出缺少的核心系统
3. TD-SYSTEM-BOUNDARY 返回 APPROVED
4. 技能向用户呈现 CD-SYSTEMS 关注项
5. 询问用户：修改系统列表以加入缺失系统，或按原样继续
6. 如修改，则在 "May I write" 询问前显示更新后的系统列表

**断言：**
- [ ] 写入前向用户显示 CD-SYSTEMS 关注项
- [ ] CONCERNS 未解决时，技能不会自动写入 systems-index.md
- [ ] 向用户提供修改或继续的选项
- [ ] 修改后、最终询问 "May I write" 前，再次显示系统列表

---

### 用例 4：边界情况——systems-index.md 已存在

**测试夹具：**
- `design/gdd/game-concept.md` 存在
- `design/systems-index.md` 已存在并包含 N 个系统

**输入：** `/map-systems`

**预期行为：**
1. 技能读取现有 systems-index.md 并呈现其当前状态
2. 技能询问："systems-index.md already exists with [N] systems. Update with new systems, or review and revise priorities?"
3. 用户选择一项操作
4. 技能不会静默覆盖现有索引

**断言：**
- [ ] 继续前检测并读取现有 systems-index.md
- [ ] 向用户提供更新/评审选项，而非自动覆盖
- [ ] 向用户显示现有系统数量
- [ ] 除非用户选择重新完整分解，否则技能不会这样做

---

### 用例 5：主管门禁——Lean 和 solo 模式均跳过门禁并注明

**测试夹具（lean 模式）：**
- 游戏概念存在
- `production/session-state/review-mode.txt` 内容为 `lean`

**Lean 模式预期行为：**
1. 分解系统并起草列表
2. 跳过 CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY
3. 输出注明："CD-SYSTEMS skipped — lean mode" 和 "TD-SYSTEM-BOUNDARY skipped — lean mode"
4. 直接进行 "May I write" 询问

**断言（lean 模式）：**
- [ ] 输出中出现两个门禁跳过说明
- [ ] 无需门禁批准，技能即可进行 "May I write" 询问
- [ ] 用户批准后写入 systems-index.md

**测试夹具（solo 模式）：**
- 使用相同的游戏概念，`production/session-state/review-mode.txt` 内容为 `solo`

**Solo 模式预期行为：**
1. 使用相同的分解工作流
2. 跳过两个门禁，输出中以 "solo mode" 注明
3. 进行 "May I write" 询问

**断言（solo 模式）：**
- [ ] 两项跳过说明均带有 "solo mode" 标签
- [ ] 除此以外，该技能的行为与 lean 模式相同

---

## 协议合规性

- [ ] 开始任何分解前读取 game-concept.md 和 game-pillars.md
- [ ] 写入前询问 "May I write `design/systems-index.md`?"
- [ ] 未经用户批准，不写入 systems-index.md
- [ ] 在 full 模式下并行生成 CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY
- [ ] 在 lean/solo 输出中按名称和模式注明跳过的门禁
- [ ] 以下一步交接结束：`/design-system [next-system]`

---

## 覆盖说明

- 循环依赖检测（系统 A 依赖系统 B，而系统 B 又依赖系统 A）属于依赖映射阶段，此处未单独使用夹具测试。
- 优先级层级分配（MVP 启发式规则）作为用例 1 协作工作流的一部分评估，而非单独评估。
- `next` 参数模式（将优先级最高且尚未设计的系统交接给 `/design-system`）未在此测试，它只是索引创建后的便捷功能。
