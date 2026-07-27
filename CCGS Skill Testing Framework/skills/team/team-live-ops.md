# 技能测试规范：/team-live-ops

## 技能摘要

通过 7 阶段规划流水线编排 live-ops 团队，产出赛季或活动计划。协调 live-ops-designer、economy-designer、analytics-engineer、community-manager、narrative-director 和 writer。阶段 3 与 4（经济设计和数据分析）同时运行。最后生成汇总赛季计划，经用户批准后交接制作。

---

## 静态断言（结构）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] File Write Protocol 章节包含“May I write”文本（写入委托给子代理）
- [ ] File Write Protocol 章节说明编排器不直接写文件
- [ ] 末尾有下一步交接，引用 `/design-review`、`/sprint-plan` 和 `/team-release`
- [ ] 阶段转换时使用 `AskUserQuestion`，在继续前取得用户批准
- [ ] 明确说明阶段 3 和 4 可以同时运行（并行启动）
- [ ] 存在错误恢复章节（或通过 BLOCKED 处理隐含体现）
- [ ] 输出文档章节指定 `design/live-ops/seasons/` 下的路径

---

## 测试用例

### 用例 1：成功路径——7 个阶段完成并产出赛季计划

**夹具：**
- `design/live-ops/economy-rules.md` 存在并包含当前经济配置
- `design/live-ops/ethics-policy.md` 存在并包含项目伦理政策
- 游戏概念文档存在于其标准路径
- 不存在针对当前计划的新赛季名称的现有赛季文档

**输入：** `/team-live-ops "Season 2: The Frozen Wastes"`

**预期行为：**
1. 阶段 1：通过 Task 启动 `live-ops-designer`；接收包含范围、内容清单和留存机制的赛季简报；向用户展示
2. AskUserQuestion：用户批准阶段 1 输出后，阶段 2 才开始
3. 阶段 2：通过 Task 启动 `narrative-director`；读取阶段 1 赛季简报；生成叙事框架文档（主题、故事钩子、背景知识关联）；向用户展示
4. 阶段 3 和 4（并行）：通过两个 Task 调用同时启动 `economy-designer` 和 `analytics-engineer`，然后才等待结果；economy-designer 读取 `design/live-ops/economy-rules.md`
5. 阶段 5：并行启动 `narrative-director` 和 `writer`，生成游戏内叙事文本和面向玩家的文案；两者都读取阶段 2 叙事框架文档
6. 阶段 6：通过 Task 启动 `community-manager`；读取赛季简报、经济设计和叙事框架；生成包含文案草稿的沟通日历
7. 阶段 7：收集所有阶段输出；展示汇总赛季计划摘要，其中包括经济健康检查、数据分析就绪度、伦理审查和待决问题
8. AskUserQuestion：用户批准完整赛季计划
9. 子代理在写入前询问“May I write to `design/live-ops/seasons/S2_The_Frozen_Wastes.md`?”、`...analytics.md` 和 `...comms.md`
10. 结论：COMPLETE——赛季计划已生成并移交制作

**断言：**
- [ ] 7 个阶段按顺序执行；阶段 3 和 4 通过并行 Task 调用发起
- [ ] 阶段 7 汇总摘要包含全部六个部分（赛季简报、叙事框架、经济设计、数据分析计划、内容清单、沟通日历）
- [ ] 阶段 7 的伦理审查部分明确引用 `design/live-ops/ethics-policy.md`
- [ ] 3 个输出文档以正确命名约定写入 `design/live-ops/seasons/`
- [ ] 文件写入委托给子代理，编排器不直接写入
- [ ] 最终输出中出现结论 COMPLETE
- [ ] 后续步骤引用 `/design-review`、`/sprint-plan` 和 `/team-release`

---

### 用例 2：发现伦理违规——奖励元素违反伦理政策

**夹具：**
- 所有标准 live-ops 夹具均存在（economy-rules.md、ethics-policy.md）
- `design/live-ops/ethics-policy.md` 明确禁止针对 18 岁以下玩家的 loot box
- economy-designer（阶段 3）提出带有随机高级奖励且没有保底计时器的“ Mystery Chest”机制

**输入：** `/team-live-ops "Season 3: Shadow Tournament"`

**预期行为：**
1. 阶段 1–4 正常进行；economy-designer 提出 Mystery Chest 机制
2. 阶段 7：编排器根据伦理政策审查阶段 3 输出；认定 Mystery Chest 违反伦理政策中的“不得提供不透明的随机高级奖励”规则
3. 阶段 7 摘要的伦理审查部分明确标记违规：“ETHICS FLAG: 阶段 3 经济设计中的 Mystery Chest 机制违反了[政策规则]。在解决此问题前，审批被阻止。”
4. 在提供赛季计划审批前，通过 AskUserQuestion 展示解决选项
5. 在伦理违规得到解决或用户明确豁免前，技能不会给出 COMPLETE 结论，也不会写入输出文档

**断言：**
- [ ] 阶段 7 伦理审查部分明确指出违规元素及其违反的政策规则
- [ ] 存在伦理违规时，技能不会自动批准赛季计划
- [ ] 使用 AskUserQuestion 暴露违规并提供解决选项（修改经济设计、以记录在案的理由覆盖、取消）
- [ ] 违规未解决时不会写入输出文档
- [ ] 如果用户选择修改：技能重新启动 economy-designer 生成修正版设计，然后返回阶段 7 审查
- [ ] 仅在 ETHICS FLAG 清除后才给出结论 COMPLETE

---

### 用例 3：无参数——显示用法指导

**夹具：**
- 任意项目状态

**输入：** `/team-live-ops`（无参数）

**预期行为：**
1. 阶段 1：未检测到参数
2. 输出：“用法：`/team-live-ops [season name or event description]`——提供要规划的赛季或实时活动的名称或描述。”
3. 技能立即退出，不启动任何子代理

**断言：**
- [ ] 技能不会猜测赛季名称或捏造范围
- [ ] 错误消息包含带有 argument-hint 的正确用法格式
- [ ] 参数检查失败前不会发起 Task 调用
- [ ] 不读取或写入任何文件

---

### 用例 4：并行阶段验证——阶段 3 与 4 同时运行

**夹具：**
- 所有标准 live-ops 夹具均存在
- 阶段 1（赛季简报）和阶段 2（叙事框架）已获批准
- 阶段 3（economy-designer）和阶段 4（analytics-engineer）的输入彼此独立

**输入：** `/team-live-ops "Season 1: The First Thaw"`（在阶段 3/4 转换处观察）

**预期行为：**
1. 用户批准阶段 2 后，编排器在等待任一结果前发起两个 Task 调用（economy-designer 和 analytics-engineer）
2. 两个代理都接收赛季简报作为上下文；analytics-engineer 不等待 economy-designer 输出即可开始
3. 阶段 5 开始前一并收集 economy-designer 和 analytics-engineer 的输出
4. 如果两个并行代理中的一个受阻，另一个继续；报告部分结果

**断言：**
- [ ] 阶段 3 和阶段 4 的两个 Task 调用均在等待任一结果前发起，而非顺序执行
- [ ] analytics-engineer 提示词不会将 economy-designer 输出作为必需输入（输入彼此独立）
- [ ] 如果 economy-designer 受阻但 analytics-engineer 成功，保留 analytics 输出，并通过 AskUserQuestion 暴露阻塞
- [ ] 阶段 3 和 4 的结果全部收集后，阶段 5 才开始
- [ ] 技能文档明确写明“阶段 3 和 4 可以同时运行”

---

### 用例 5：缺少伦理政策——`design/live-ops/ethics-policy.md` 不存在

**夹具：**
- `design/live-ops/economy-rules.md` 存在
- `design/live-ops/ethics-policy.md` 不存在
- 其他所有夹具均存在

**输入：** `/team-live-ops "Season 4: Desert Heat"`

**预期行为：**
1. 阶段 1–4 继续进行；向 economy-designer 和 analytics-engineer 提供伦理政策路径，但该文件缺失
2. 阶段 7：编排器尝试执行伦理审查；检测到缺少 `design/live-ops/ethics-policy.md`
3. 阶段 7 摘要包含缺口标记：“ETHICS REVIEW SKIPPED: 未找到 `design/live-ops/ethics-policy.md`。经济设计未根据伦理政策进行审查。建议在开始制作前创建该文件。”
4. 技能仍完成赛季计划并达到 COMPLETE 结论，但输出和赛季设计文档中会醒目标记该缺口
5. 后续步骤包括创建伦理政策文档的建议

**断言：**
- [ ] 伦理政策文件缺失时，技能不会报错退出
- [ ] 文件缺失时，技能不会捏造伦理政策规则
- [ ] 阶段 7 摘要明确说明伦理审查被跳过及其原因
- [ ] 即使文件缺失，仍可达到 COMPLETE 结论
- [ ] 缺口标记出现在赛季设计输出文档中，而不仅是对话里
- [ ] 后续步骤建议创建 `design/live-ops/ethics-policy.md`

---

## 协议合规性

- [ ] 每次阶段转换都使用 `AskUserQuestion`，用户批准后下一阶段才开始
- [ ] 阶段 3 和 4 始终并行启动，而非顺序启动
- [ ] File Write Protocol：编排器从不直接调用 Write/Edit，所有写入均委托给子代理
- [ ] 每个输出文档都由相关子代理单独询问“May I write to [path]?”
- [ ] 阶段 7 的伦理审查始终明确引用伦理政策文件路径
- [ ] 错误恢复：任何 BLOCKED 代理都立即通过 AskUserQuestion 展示选项（跳过 / 重试 / 停止）
- [ ] 任一阶段受阻时生成部分报告，不丢弃工作成果
- [ ] 仅在用户批准汇总赛季计划后给出 COMPLETE；存在未解决的伦理违规时给出 BLOCKED
- [ ] 后续步骤始终包括 `/design-review`、`/sprint-plan` 和 `/team-release`

---

## 覆盖说明

- 阶段 5 的并行启动（narrative-director + writer）遵循与阶段 3/4 相同的模式，但未在此单独测试；使用用例 4 验证的并行 Task 协议。
- 未单独测试“economy-rules.md 缺失”边界情况；它会作为 economy-designer 的 BLOCKED 结果出现，并遵循用例 4 隐含测试的标准错误恢复路径。
- 完整内容写作流水线（阶段 5 输出验证）通过用例 1 的成功路径汇总检查隐含验证。
- 社区经理沟通日历格式（预热、上线日、赛季中期、最后一周）通过用例 1 隐含验证；无需单独边界用例。
