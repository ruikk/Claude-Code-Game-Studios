# 代理测试规范：qa-lead

## 代理摘要
**负责领域：** 测试策略、QL-STORY-READY 门禁、QL-TEST-COVERAGE 门禁、缺陷严重程度分诊、发布质量门禁。
**不负责：** 功能实现（程序员）、游戏设计决策、创意方向、制作排期。
**模型层级：** Sonnet（单系统分析，负责故事就绪度与覆盖率评估）。
**处理的门禁 ID：** QL-STORY-READY、QL-TEST-COVERAGE。

---

## 静态断言（结构）

通过读取代理的 `.claude/agents/qa-lead.md` frontmatter 进行验证：

- [ ] 存在 `description:` 字段，且内容针对具体领域（提及测试策略、故事就绪度、覆盖率、缺陷分诊，而非泛泛描述）
- [ ] `allowed-tools:` 列表以读取工具为主；可包含 Read，用于读取故事文件、测试文件和 coding-standards；仅在需要运行测试命令时使用 Bash
- [ ] 根据 coordination-rules.md，模型层级为 `claude-sonnet-4-6`
- [ ] 代理定义未声称拥有实现决策权或游戏设计决定权

---

## 测试用例

### 用例 1：领域内请求，输出格式恰当
**场景：** 提交“玩家受到危险地块伤害”的故事进行就绪检查。故事有三条验收标准：(1) 玩家生命值按危险地块的伤害值减少；(2) 播放伤害视觉反馈；(3) 玩家在 0.5 秒内不能再次受到伤害（无敌时间窗）。三条 AC 均可度量且明确。请求标记为 QL-STORY-READY。
**预期：** 返回 `QL-STORY-READY: ADEQUATE`，并说明三条 AC 均已提供、明确且可测试。
**断言：**
- [ ] 结论必须为 ADEQUATE / INADEQUATE 之一
- [ ] 结论标记格式为 `QL-STORY-READY: ADEQUATE`
- [ ] 理由提及 AC 的具体数量（3），并确认每条均可度量
- [ ] 输出保持在 QA 范围内，不评价机制设计是否优秀

### 用例 2：领域外请求，转交或升级
**场景：** 开发者要求 qa-lead 为新的物理系统实现自动化测试框架。
**预期：** 代理拒绝实现测试代码，并转交给适当的程序员（gameplay-programmer 或 lead-programmer）。
**断言：**
- [ ] 不编写或提出代码实现
- [ ] 明确指出应由 `lead-programmer` 或 `gameplay-programmer` 负责实现
- [ ] 可以定义测试应验证什么（测试策略），但将代码编写交给程序员

### 用例 3：门禁结论，术语正确
**场景：** 提交“战斗响应迅速且富有冲击力”的故事进行就绪检查。唯一的验收标准是：“战斗应让玩家感觉良好。”该标准主观且不可度量。请求标记为 QL-STORY-READY。
**预期：** 返回 `QL-STORY-READY: INADEQUATE`，明确指出不可度量的 AC，并指导如何使其可测试（例如“从输入到命中反馈的延迟 ≤ 100ms”）。
**断言：**
- [ ] 结论必须为 ADEQUATE / INADEQUATE 之一，不得使用自由文本
- [ ] 结论标记格式为 `QL-STORY-READY: INADEQUATE`
- [ ] 理由指出未满足可度量要求的具体 AC
- [ ] 就如何将 AC 改写为可测试标准提供可执行指导

### 用例 4：冲突升级，提交给正确上级
**场景：** gameplay-programmer 与 qa-lead 对“敌人巡逻路径在 5 秒内经过所有路径点”这一断言是否足够确定、能否作为有效自动化测试存在分歧。gameplay-programmer 认为时间波动会使测试不稳定，qa-lead 则认为可以接受。
**预期：** qa-lead 承认测试不稳定这一技术顾虑，并升级给 lead-programmer，由其对自动化测试可接受的确定性标准作出技术裁决。
**断言：**
- [ ] 升级给 `lead-programmer`，由其裁决确定性技术标准
- [ ] 不单方面否决 gameplay-programmer 对测试不稳定的顾虑
- [ ] 清楚说明升级原因：“这是技术标准问题，不是 QA 覆盖率问题”
- [ ] 不放弃覆盖率要求；如果当前方案被判定为不稳定，则要求提供确定性替代方案

### 用例 5：传入上下文，使用所提供的信息
**场景：** 代理收到包含 coding-standards.md 测试标准章节的门禁上下文块，其中规定：Logic 故事需要阻断性的自动化单元测试；Visual/Feel 故事需要截图和负责人签核（建议性）；Config/Data 故事需要通过冒烟检查（建议性）。一个分类为 `Logic` 的故事只提交了手动演练文档作为证据。
**预期：** 评估引用 coding-standards.md 中的具体测试证据要求，指出 `Logic` 故事需要自动化单元测试，而非仅有手动演练，并引用该具体要求返回 INADEQUATE。
**断言：**
- [ ] 引用所提供上下文中的具体故事类型分类（`Logic`）
- [ ] 引用 coding-standards.md 对 Logic 故事规定的具体证据要求（自动化单元测试）
- [ ] 指出提交的证据类型（手动演练）不足以满足该故事类型
- [ ] 不将建议性要求作为阻断性要求

---

## 协议合规性

- [ ] QL-STORY-READY 结论仅使用 ADEQUATE / INADEQUATE 术语
- [ ] QL-TEST-COVERAGE 结论仅使用 ADEQUATE / INADEQUATE 术语（发布门禁则使用 PASS / FAIL）
- [ ] 保持在声明的 QA 和测试策略领域内
- [ ] 将技术标准争议升级给 lead-programmer
- [ ] 在输出中使用门禁 ID（例如 `QL-STORY-READY: INADEQUATE`），而非行内文字结论
- [ ] 不对实现或游戏设计作出约束性决定

---

## 覆盖说明
- 尚未覆盖 QL-TEST-COVERAGE（迭代或里程碑的整体覆盖率评估）；有覆盖率报告后应增加专门用例。
- 此处尚未覆盖缺陷严重程度分诊（P0/P1/P2 分类），留待与 /bug-triage 技能集成。
- 尚未覆盖发布质量门禁行为（PASS / FAIL 术语变体）。
- 尚未覆盖 QL-STORY-READY 与故事完成标准（/story-done 技能）之间的交互。
