# 技能测试规范：/team-polish

## 技能摘要

通过六阶段流水线编排打磨团队：性能评估（performance-analyst）→ 优化（发现引擎层根因时可选启动 engine-programmer）→ 视觉打磨（technical-artist，与阶段 2 并行）→ 音频打磨（sound-designer，与阶段 2 并行）→ 加固（qa-tester）→ 签核（编排器收集全部结果并给出 READY FOR RELEASE 或 NEEDS MORE WORK）。每次阶段转换使用 `AskUserQuestion`。仅当阶段 1 识别出引擎层根因时才按条件启动 engine-programmer。结论为 READY FOR RELEASE 或 NEEDS MORE WORK。

---

## 静态断言（结构）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：READY FOR RELEASE、NEEDS MORE WORK
- [ ] 包含“File Write Protocol”章节
- [ ] 文件写入委托给子代理，编排器不直接写文件
- [ ] 子代理每次写入前执行“May I write to [path]?”
- [ ] 末尾有下一步交接（引用 `/release-checklist`、`/sprint-plan update`、`/gate-check`）
- [ ] 存在 Error Recovery Protocol 章节
- [ ] 阶段转换前使用 `AskUserQuestion`
- [ ] 阶段 3（视觉打磨）和阶段 4（音频打磨）明确与阶段 2 并行运行
- [ ] 仅当阶段 1 识别出引擎层根因时，阶段 2 才按条件启动 engine-programmer
- [ ] 阶段 6 签核在给出结论前将指标与预算比较

---

## 测试用例

### 用例 1：成功路径——流水线完成，结论为 READY FOR RELEASE

**夹具：**
- 功能存在且功能完整（例如 `combat` 系统）
- technical-preferences.md 中定义了性能预算（例如目标 60fps、16ms 帧预算）
- 打磨开始前不存在帧预算违规
- 没有缺失的音频事件；VFX 资产完整
- 打磨改动不会引入回归

**输入：** `/team-polish combat`

**预期行为：**
1. 阶段 1：启动 performance-analyst；分析 combat 系统、测量帧预算并检查内存使用；输出显示所有指标在预算内且无违规的性能报告
2. `AskUserQuestion` 展示性能报告；用户批准后才开始阶段 2、3、4
3. 阶段 2：performance-analyst 执行小幅优化（例如绘制调用批处理）；不需要 engine-programmer（未识别出引擎层根因）
4. 阶段 3 和 4 与阶段 2 并行启动：
   - 阶段 3：technical-artist 审查 VFX 质量、优化粒子系统、加入屏幕震动和视觉反馈
   - 阶段 4：sound-designer 审查音频事件完整性、检查混音音量、加入环境音层
5. 三个并行阶段全部完成；`AskUserQuestion` 展示结果；用户批准后开始阶段 5
6. 阶段 5：qa-tester 运行边界情况、浸泡、压力和回归测试；全部通过
7. `AskUserQuestion` 展示测试结果；用户批准后进入阶段 6
8. 阶段 6：编排器收集全部结果，将打磨前后性能指标与预算比较；所有指标通过
9. 写入前子代理询问“May I write the polish report to `production/qa/evidence/polish-combat-[date].md`?”
10. 结论：READY FOR RELEASE

**断言：**
- [ ] 阶段 1 在其他代理之前首先启动 performance-analyst
- [ ] `AskUserQuestion` 出现在阶段 1 输出之后、阶段 2/3/4 启动之前
- [ ] 阶段 3 和 4 的 Task 调用与阶段 2 同时发起，而不是阶段 2 完成后再发起
- [ ] 阶段 1 未发现引擎层根因时，不启动 engine-programmer
- [ ] 并行阶段完成且用户批准前，不启动 qa-tester（阶段 5）
- [ ] 阶段 6 结论基于指标与已定义预算的比较
- [ ] 汇总报告包含：打磨前后性能指标、视觉打磨改动、音频打磨改动、测试结果
- [ ] 编排器不直接写入任何文件
- [ ] 结论为 READY FOR RELEASE

---

### 用例 2：性能阻塞——帧预算违规无法完全解决

**夹具：**
- 打磨功能：`particle-storm` VFX 系统
- 阶段 1 识别出帧预算违规：particle-storm 在目标硬件上成本为 12ms（该系统预算为 6ms）
- 阶段 2 performance-analyst 执行优化，将成本降至 9ms，但仍超过 6ms 预算
- 不进行根本性设计变更，阶段 2 无法完全解决该违规

**输入：** `/team-polish particle-storm`

**预期行为：**
1. 阶段 1：performance-analyst 识别出帧成本为 12ms，而预算为 6ms；报告“FRAME BUDGET VIOLATION: particle-storm 成本为 12ms，预算为 6ms”
2. `AskUserQuestion` 展示违规；用户选择继续尝试优化
3. 阶段 2：performance-analyst 执行优化；达到 9ms，虽已降低但仍超出预算；报告“优化将成本降至 9ms（原为 12ms），超出预算 3ms。除非修改设计，否则无法进一步提升。”
4. 阶段 3 和 4 与阶段 2 并行运行（视觉和音频打磨）
5. 阶段 5：qa-tester 运行回归和边界情况测试；全部通过
6. 阶段 6：编排器收集结果；帧预算违规（9ms 对 6ms 预算）仍未解决
7. 结论：NEEDS MORE WORK
8. 报告列出具体未解决问题：“particle-storm 帧成本（9ms）超出预算（6ms）3ms，需要缩减设计范围或重新协商预算”
9. 后续步骤：在 `/sprint-plan update` 中安排剩余问题；修复后重新运行 `/team-polish`

**断言：**
- [ ] 阶段 1 以具体数字（实际值与预算）标记帧预算违规
- [ ] 阶段 2 明确报告优化后的指标（达到 9ms，仍超出 3ms）
- [ ] 预算违规仍存在时，结论为 NEEDS MORE WORK（而非 READY FOR RELEASE）
- [ ] 按名称列出具体未解决问题，并量化剩余差距
- [ ] 后续步骤引用 `/sprint-plan update` 来安排剩余修复
- [ ] 阶段 3 和 4 仍然运行（不会因阶段 2 部分解决而放弃打磨工作）
- [ ] 阶段 5 qa-tester 仍然运行（回归测试独立于性能结果）

---

### 用例 3：无参数——显示用法指导

**夹具：**
- 任意项目状态

**输入：** `/team-polish`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法指导，例如：“用法：`/team-polish [feature or area]`——指定要打磨的功能或区域（例如 `combat`、`main menu`、`inventory system`、`level-1`）”
3. 技能退出，不启动任何代理

**断言：**
- [ ] 未提供参数时技能不会启动任何代理
- [ ] 用法消息包含带参数示例的正确调用格式
- [ ] 技能不会尝试从项目文件猜测功能
- [ ] 不使用 `AskUserQuestion`，直接输出指导

---

### 用例 4：引擎层瓶颈——阶段 2 按条件启动 engine-programmer

**夹具：**
- 打磨功能：`open-world` 环境流式加载
- 阶段 1 识别出渲染管线中的性能瓶颈，根因为：“绘制调用开销由引擎在空间索引器中的场景树遍历导致，这是引擎层问题，而非游戏代码问题”
- 性能预算已定义；渲染开销超过目标帧预算

**输入：** `/team-polish open-world`

**预期行为：**
1. 阶段 1：performance-analyst 分析环境；识别帧预算违规；根因分析指向引擎层渲染管线（空间索引器遍历开销）
2. 阶段 1 输出明确将根因归类为引擎层
3. `AskUserQuestion` 展示包含引擎层根因的性能报告；用户批准后才进入阶段 2
4. 阶段 2：启动 performance-analyst 执行游戏代码层优化，并行启动 engine-programmer 修复引擎层渲染
5. 阶段 3 和 4 也与阶段 2 并行运行（视觉和音频打磨）
6. engine-programmer 处理空间索引器遍历；提供性能分析器验证，显示修复降低了开销
7. 阶段 5：qa-tester 运行回归测试，包括引擎层修复测试
8. 阶段 6：编排器收集所有结果；如果指标已在预算内，结论为 READY FOR RELEASE，否则为 NEEDS MORE WORK

**断言：**
- [ ] 除非阶段 1 明确识别出引擎层根因，否则阶段 2 不启动 engine-programmer
- [ ] 阶段 1 识别出引擎层根因时，阶段 2 启动 engine-programmer
- [ ] 阶段 2 中 engine-programmer 和 performance-analyst 的 Task 调用同时发起，而非顺序发起
- [ ] 阶段 3 和 4 也与阶段 2 并行运行，而不是推迟到阶段 2 完成后
- [ ] engine-programmer 输出包含修复的性能分析器验证
- [ ] 阶段 5 的 qa-tester 运行覆盖引擎层改动的回归测试
- [ ] 结论正确反映包括引擎修复在内的所有指标是否满足预算

---

### 用例 5：发现回归——打磨改动破坏现有功能

**夹具：**
- 打磨功能：`inventory-ui`
- 阶段 1–4 成功完成；性能和打磨改动已应用
- 阶段 5：qa-tester 运行回归测试，发现阶段 3 应用的着色器优化破坏了悬停时的物品高亮光晕效果，这是打磨前正常工作的现有功能

**输入：** `/team-polish inventory-ui`（阶段 5 场景）

**预期行为：**
1. 阶段 1–4 完成；打磨改动包含 technical-artist 的着色器优化
2. 阶段 5：qa-tester 运行回归测试并发现“悬停时物品高亮光晕不再渲染——回归由阶段 3 的着色器优化引入”
3. qa-tester 返回标记了该回归的测试结果
4. 编排器立即暴露回归：“qa-tester: REGRESSION FOUND——`item-highlight-hover` 光晕被阶段 3 的着色器优化破坏”
5. 子代理在写入前询问“May I write the bug report to `production/qa/evidence/bug-polish-inventory-ui-[date].md`?”
6. 获批后写入缺陷报告；包含：故障行为、导致问题的打磨改动、复现步骤和严重程度
7. `AskUserQuestion` 展示回归及以下选项：
   - 回退着色器优化并寻找替代方案
   - 修复着色器优化以保留光晕效果
   - 接受该回归，并在下一次迭代安排修复
8. 结论：NEEDS MORE WORK（无论用户选择哪条解决路径，只要回归存在且未在当前会话修复）

**断言：**
- [ ] 回归在阶段 6 签核前被暴露
- [ ] 报告同时写明具体故障行为和责任改动
- [ ] 子代理在提交前询问“May I write the bug report to [path]?”
- [ ] 缺陷报告包含：故障行为、原因改动、复现步骤、严重程度
- [ ] `AskUserQuestion` 提供回退、就地修复和稍后安排等选项
- [ ] 存在未解决回归时，结论为 NEEDS MORE WORK
- [ ] 仅当回归在当前打磨会话中修复且 qa-tester 重新运行确认后，结论才可变为 READY FOR RELEASE

---

## 协议合规性

- [ ] 阶段 1（评估）必须在其他阶段开始前完成
- [ ] 每个阶段输出后、下一阶段启动前都使用 `AskUserQuestion`
- [ ] 阶段 3 和 4 始终与阶段 2 并行启动，而非推迟
- [ ] 仅当阶段 1 明确识别出引擎层根因时才启动 engine-programmer
- [ ] 编排器不直接写入文件，所有写入均委托给子代理
- [ ] 每个子代理在任何写入前执行“May I write to [path]?”协议
- [ ] 任何代理的 BLOCKED 状态都立即暴露，不静默跳过
- [ ] 部分代理完成而其他代理受阻时，始终生成部分报告
- [ ] 结论严格为 READY FOR RELEASE 或 NEEDS MORE WORK，不使用其他结论值
- [ ] NEEDS MORE WORK 结论始终列出具体剩余问题及严重程度
- [ ] 后续步骤交接在成功时引用 `/release-checklist`，失败时引用 `/sprint-plan update` + `/gate-check`

---

## 覆盖说明

- tools-programmer 可选代理（用于内容流水线工具验证）未单独测试；它遵循与 engine-programmer 相同的条件启动模式，仅在打磨区域涉及内容制作工具时调用。
- Error Recovery Protocol 中“以更窄范围重试”和“跳过此代理”的解决路径未单独测试；它们遵循用例 2 和 5 验证的 `AskUserQuestion` + 部分报告模式。
- 阶段 6 签核逻辑（收集并比较所有指标）通过用例 1 和 2 隐含验证。这些用例分别检验 READY FOR RELEASE 和 NEEDS MORE WORK 两个方向。
- 浸泡测试和压力测试（阶段 5）通过用例 1 的 qa-tester 输出隐含验证。用例 5 重点验证阶段 5 的回归检测。
- 阶段 5 的“最低规格硬件”测试路径未单独测试；硬件可用时遵循相同的 qa-tester 委托模式。
