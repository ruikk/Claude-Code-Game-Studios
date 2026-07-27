# 技能测试规范：/team-release

## 技能摘要

通过 7 阶段流水线编排发布团队，从候选版本推进到部署和发布后监控。协调 release-manager、qa-lead、devops-engineer、producer、security-engineer（可选，但在线/多人游戏必需）、network-programmer（可选，但多人游戏必需）、analytics-engineer 和 community-manager。阶段 3 的代理并行运行。最后作出 go/no-go 决策；若 producer 判定 NO-GO，则跳过阶段 6 部署。以发布后监控计划收尾。

---

## 静态断言（结构）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] “文件写入协议”章节包含“May I write”文本（写入委托给子代理）
- [ ] “文件写入协议”章节说明编排器不直接写文件
- [ ] “错误恢复协议”章节包含四个恢复选项（呈现 / 评估 / 提供选项 / 部分报告）
- [ ] 末尾有下一步交接，引用发布后监控、`/retrospective` 和 `production/stage.txt`
- [ ] 需要用户批准后再继续的阶段转换使用 `AskUserQuestion`
- [ ] 明确说明阶段 3 代理（qa-lead、devops-engineer，以及可选的 security-engineer、network-programmer）并行运行
- [ ] 阶段 6（部署）取决于阶段 5 的 GO 决策
- [ ] security-engineer 仅在在线功能 / 玩家数据场景下按条件启动，不是始终启动

---

## 测试用例

### 用例 1：成功路径（单人）——所有阶段完成并部署版本

**夹具：**
- `production/stage.txt` 存在且包含 Production 或更晚阶段
- 所有里程碑验收标准均已满足（producer 可确认）
- 没有在线功能、多人游戏或玩家数据收集
- 当前分支的所有 CI 构建均干净
- 没有未解决的 S1/S2 缺陷
- `production/sprints/` 包含本里程碑已完成的迭代故事

**输入：** `/team-release v1.0.0`

**预期行为：**
1. 阶段 1：通过 Task 启动 `producer`；确认所有里程碑验收标准满足；识别延后范围；生成发布授权并呈现给用户；用户通过 AskUserQuestion 批准后进入阶段 2
2. 阶段 2：通过 Task 启动 `release-manager`；从约定提交创建发布分支；提升版本号；调用 `/release-checklist`；冻结分支；输出分支名和清单；用户通过 AskUserQuestion 批准后进入阶段 3
3. 阶段 3（并行）：同时为 `qa-lead`（回归套件、关键路径签核）和 `devops-engineer`（构建产物、CI 验证）发出 Task 调用；security-engineer 不启动（无在线功能）；network-programmer 不启动（无多人游戏）；两者均成功完成
4. 阶段 4：验证本地化字符串已全部翻译；`analytics-engineer` 验证发布构建正确触发遥测；性能基准通过；生成签核
5. 阶段 5：通过 Task 启动 `producer`；收集 qa-lead、release-manager、devops-engineer 的签核；无未解决阻塞问题；producer 宣布 GO；用户通过 AskUserQuestion 查看 GO 决策并确认部署
6. 阶段 6：并行启动 `release-manager` 和 `devops-engineer`；在版本控制中标记发布；调用 `/changelog`；部署到预发布环境；冒烟测试通过后部署到生产环境；同时启动 `community-manager`，通过 `/patch-notes v1.0.0` 完成补丁说明并准备发布公告
7. 阶段 7：release-manager 生成发布报告；producer 更新里程碑跟踪；qa-lead 开始回归监控；community-manager 发布沟通内容；analytics-engineer 确认线上仪表板健康
8. 结论：COMPLETE，发布已执行并部署

**断言：**
- [ ] 阶段 3 的 qa-lead 和 devops-engineer Task 调用同时发出，而非顺序发出
- [ ] 游戏没有在线功能、多人游戏或玩家数据时，不启动 security-engineer
- [ ] 阶段 5 的 producer 在宣布 GO 前收集所有必需参与方的签核
- [ ] 阶段 6 仅在用户确认 GO 决策后开始部署
- [ ] 阶段 6 由 release-manager 调用 `/changelog`（不直接写入）
- [ ] 阶段 6 由 community-manager 调用 `/patch-notes v1.0.0`
- [ ] 阶段 7 监控计划包含 48 小时发布后监控承诺
- [ ] 下一步建议成功部署后将 `production/stage.txt` 更新为 `Live`
- [ ] 最终输出中出现结论：COMPLETE

---

### 用例 2：Go/No-Go：NO——阶段 3 发现 S1 缺陷，跳过部署

**夹具：**
- v0.9.0 的候选版本分支存在
- qa-lead 在阶段 3 回归测试期间发现主菜单中一个此前未报告的 S1 崩溃
- devops-engineer 的构建干净且产物已就绪
- producer 已知悉该 S1 缺陷

**输入：** `/team-release v0.9.0`

**预期行为：**
1. 阶段 1–2 正常完成；创建候选版本
2. 阶段 3（并行）：devops-engineer 返回构建干净的签核；qa-lead 返回已识别 S1 缺陷且回归套件失败；qa-lead 宣布质量门：NOT PASSED
3. 编排器立即呈现 qa-lead 的结果：“QA-LEAD：发现 S1 缺陷——[崩溃描述]。质量门：NOT PASSED。”
4. 阶段 4 谨慎继续或暂停（AskUserQuestion：继续阶段 4，还是跳到阶段 5 进行 go/no-go 决策？）
5. 阶段 5：通过 Task 启动 `producer`；producer 收到 qa-lead 的 NOT PASSED 结论；没有可用的 S1 签核；producer 以“ S1 缺陷 [ID] 处于 Open 且未解决状态，发布不安全。”为理由宣布 NO-GO
6. AskUserQuestion：向用户展示 NO-GO 决策和 S1 缺陷详情；选项：修复缺陷并重新运行、延期发布，或覆盖决策（提供记录在案的理由）
7. 阶段 6（部署）完全跳过——不标记分支、不部署到预发布环境、不部署到生产环境
8. 阶段 6 不启动 community-manager（没有要宣布的部署）
9. 技能以部分报告结束，概述已完成的阶段（阶段 1–5）、跳过的阶段（阶段 6）及原因
10. 结论：BLOCKED——版本未部署

**断言：**
- [ ] 阶段 3 完成后立即向用户呈现 qa-lead 发现的 S1 缺陷，而非压到阶段 5 才呈现
- [ ] producer 的 NO-GO 决策明确引用 S1 缺陷和质量门结果
- [ ] producer 宣布 NO-GO 时完全跳过阶段 6 部署
- [ ] NO-GO 时不启动 community-manager 编写补丁说明或发布公告
- [ ] 部分报告明确说明哪些阶段完成、哪些阶段跳过及原因
- [ ] 因 NO-GO 跳过部署时，结论为 BLOCKED（而非 COMPLETE）
- [ ] AskUserQuestion 向用户提供解决选项（修复并重新运行 / 延期 / 提供理由后覆盖）
- [ ] 若选择覆盖路径，进入阶段 6 前必须要求用户提供记录在案的理由

---

### 用例 3：在线游戏安全审计——阶段 3 启动 security-engineer

**夹具：**
- 游戏具有多人游戏功能并存储玩家账户数据
- v2.1.0 的候选版本存在
- qa-lead 和 devops-engineer 均返回干净的签核
- 根据团队组成规则，必须进行 security-engineer 审计

**输入：** `/team-release v2.1.0`

**预期行为：**
1. 阶段 1–2 正常完成
2. 阶段 3（并行）：编排器检测到游戏具有在线/多人游戏功能和玩家数据；同时为 `qa-lead`、`devops-engineer` 和 `security-engineer` 发出 Task 调用；另外启动 `network-programmer` 进行网络代码稳定性签核
3. security-engineer 执行发布前安全审计：审查身份验证流程、反作弊机制和数据隐私合规性；返回签核
4. network-programmer 验证负载下的延迟补偿、重连处理和带宽；返回签核
5. 四个阶段 3 代理全部完成；收集它们的结果后才开始阶段 4
6. 阶段 5：producer 在作出 go/no-go 决策前收集四个阶段 3 代理（qa-lead、devops-engineer、security-engineer、network-programmer）的签核
7. 其余阶段正常继续至 COMPLETE

**断言：**
- [ ] 游戏具有在线功能、多人游戏或玩家数据时，阶段 3 启动 security-engineer——不得跳过
- [ ] 游戏具有多人游戏时，阶段 3 启动 network-programmer
- [ ] 四个阶段 3 Task 调用（qa-lead、devops-engineer、security-engineer、network-programmer）同时发出
- [ ] security-engineer 审计涵盖身份验证、反作弊和数据隐私合规性
- [ ] 阶段 5 producer 收集签核时包含 security-engineer（四方而非两方）
- [ ] security-engineer 签核前不得开始阶段 6 部署
- [ ] 对于具有玩家数据的游戏，技能不得将 security-engineer 视为可选

---

### 用例 4：本地化遗漏——未翻译字符串阻止发布

**夹具：**
- v1.2.0 的候选版本存在
- 阶段 3（qa-lead、devops-engineer）以干净的签核完成
- 阶段 4：本地化验证在法语区域检测到 47 个未翻译字符串（法语是游戏本地化范围内的受支持语言）
- localization-lead 可作为委派代理使用

**输入：** `/team-release v1.2.0`

**预期行为：**
1. 阶段 1–3 以干净的签核完成
2. 阶段 4：本地化验证步骤检测到未翻译字符串；识别出法语区域中的 47 个字符串；启动 localization-lead（如果可用）评估严重性
3. 编排器呈现：“LOCALIZATION MISS：在法语区域发现 47 个未翻译字符串。发货前必须取得本地化签核。”
4. AskUserQuestion：提供选项——(a) 修复翻译并重新运行阶段 4；(b) 从本次发布中移除法语区域；(c) 原样发布并附带已知问题说明
5. 用户选择 (a) 时：提供翻译后重新运行阶段 4；技能等待本地化签核
6. 本地化签核未完成时，阶段 5 go/no-go 不得继续
7. 本地化问题解决或得到明确豁免前，发货受阻（不进入阶段 6）

**断言：**
- [ ] 阶段 4 的本地化验证检测并统计未翻译字符串（不只是说“缺少一些字符串”）
- [ ] 受支持区域中的未翻译字符串会在阶段 5 前阻塞流水线
- [ ] 使用 AskUserQuestion 提供解决选项——技能不自动豁免
- [ ] 本地化签核待完成时，不调用阶段 5 go/no-go
- [ ] 用户选择重新运行阶段 4 时，技能不要求从阶段 1 重新开始
- [ ] 用户明确豁免（原样发货）时，在发布报告（阶段 7）中将豁免记录为已知问题
- [ ] 技能不伪造翻译字符串来解除自身阻塞

---

### 用例 5：无参数——推断版本或询问用户

**夹具（变体 A——存在里程碑数据）：**
- `production/milestones/` 存在且包含里程碑文件；最近的里程碑是“v1.1.0 — Gold”
- `production/session-state/active.md` 引用一个版本或里程碑

**夹具（变体 B——无法发现版本）：**
- `production/milestones/` 不存在
- `production/session-state/active.md` 不引用版本
- 不存在可用于推断版本的 git 标签

**输入：** `/team-release`（无参数）

**预期行为（变体 A）：**
1. 阶段 1：未提供参数；读取 `production/session-state/active.md`；读取 `production/milestones/` 中最近的里程碑文件
2. 推断 v1.1.0 为目标版本；报告“未提供版本参数——根据里程碑数据推断为 v1.1.0。继续。”
3. 在正式开始阶段 1 前通过 AskUserQuestion 确认：“正在发布 v1.1.0。这样正确吗？”
4. 按 `/team-release v1.1.0` 作为输入继续

**预期行为（变体 B）：**
1. 阶段 1：未提供参数；读取可用状态文件——无法发现版本
2. 使用 AskUserQuestion：“应发布哪个版本号？（例如 v1.0.0）”
3. 等待用户输入后再继续

**断言：**
- [ ] 未提供参数时技能不默认使用硬编码版本字符串
- [ ] 技能在询问前读取 `production/session-state/active.md` 和里程碑文件（变体 A）
- [ ] 推断出的版本在继续前通过 AskUserQuestion 与用户确认（变体 A）
- [ ] 无法发现版本时使用 AskUserQuestion——技能不猜测（变体 B）
- [ ] 里程碑文件缺失时技能不报错——回退到询问用户（变体 B）

---

## 协议合规性

- [ ] 每个阶段转换门均使用 `AskUserQuestion`（阶段 1 后、阶段 2 后、阶段 3/4 出现问题时、阶段 5 go/no-go 后）
- [ ] 阶段 3 代理始终以并行 Task 调用发出——qa-lead 和 devops-engineer 从不顺序执行
- [ ] 根据游戏功能有条件地启动 security-engineer——存在相关功能时不得静默跳过
- [ ] 文件写入协议：编排器从不直接调用 Write/Edit——所有写入均委托给子代理或子技能
- [ ] 阶段 6 部署严格取决于阶段 5 的 GO 结论——不得自动触发
- [ ] 错误恢复：任何 BLOCKED 代理都在继续依赖阶段前立即呈现
- [ ] 任一阶段失败或流水线停止时始终生成部分报告（用例 2）
- [ ] 仅在部署完成时结论为 COMPLETE；go/no-go 为 NO 或硬阻塞项未解决时为 BLOCKED
- [ ] 下一步始终包含 48 小时发布后监控、`/retrospective` 建议，以及将 `production/stage.txt` 更新为 `Live`

---

## 覆盖说明

- 阶段 7 发布后操作（发布报告、里程碑跟踪、社区发布、仪表板监控）由用例 1 隐式验证。阶段 7 不设门禁且没有会阻塞流程的失败模式，因此不需要单独边界用例。
- “devops-engineer 构建失败”路径未单独测试——它会在阶段 3 呈现为 BLOCKED 结果，并遵循标准错误恢复协议（呈现 → 评估 → AskUserQuestion 选项）。静态断言中的错误恢复检查会从结构上验证该路径。
- 阶段 4 并行路径（本地化、性能和分析与阶段 3 同时运行）是技能中记录的选项（“资源可用时可与阶段 3 并行运行”）。用例 4 将阶段 4 作为顺序门测试；并行变体交由技能自行判断实现。
- 多人游戏的 `network-programmer` 签核路径作为用例 3 的一部分验证，而非单独用例，因为它遵循与 security-engineer 相同的并行启动模式。
- 用例 2 中“提供记录在案的理由覆盖 NO-GO”路径已被引用但未穷尽测试——这是技能必须支持的逃生通道，其存在性由用例 2 的 AskUserQuestion 选项断言验证。
