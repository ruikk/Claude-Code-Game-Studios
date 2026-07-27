# 代理测试规范：ue-blueprint-specialist

## 代理概述
- **领域**：Blueprint 架构、Blueprint/C++ 边界、Blueprint 图表质量、Blueprint 性能优化、Blueprint Function Library 设计
- **不负责**：C++ 实现（engine-programmer 或 gameplay-programmer）、美术资产或着色器、UI/UX 流程设计（ux-designer）
- **模型层级**：Sonnet
- **门禁 ID**：None；跨领域裁决交由 unreal-specialist 或 lead-programmer

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段，且内容针对本领域（提及 Blueprint 架构和优化）
- [ ] `allowed-tools:` 列表与代理职责一致（可对 Blueprint 项目文件使用 Read；不含服务器或部署工具）
- [ ] 模型层级为 Sonnet（专家代理的默认层级）
- [ ] 代理定义未声明对 C++ 实现决策的决定权

---

## 测试用例

### 用例 1：领域内请求——Blueprint 图表性能审查
**输入**：“审查我们的 AI 行为 Blueprint。它包含每帧运行的 tick 逻辑，同时检查 30 个 NPC 的视线。”
**预期行为**：
- 将大量依赖 tick 的逻辑识别为性能问题
- 建议从 EventTick 改为事件驱动模式（感知系统事件、定时器或降低频率的轮询）
- 指出同时执行视线检查时每个 NPC 产生的成本
- 提出替代方案：AIPerception 组件事件、错开 tick 分组，或在实测 Blueprint 开销显著时将系统迁移到 C++
- 输出结构清晰：指出问题、估算影响、列出替代方案

### 用例 2：领域外请求——C++ 实现
**输入**：“为这个能力冷却系统编写 C++ 实现。”
**预期行为**：
- 不生成 C++ 实现代码
- 提供等效的 Blueprint 冷却逻辑（例如使用 Timeline；如果使用 GAS，则使用 GameplayEffect）
- 明确说明：“C++ 实现由 engine-programmer 或 gameplay-programmer 负责；我可以展示 Blueprint 方案，或说明 Blueprint 调用 C++ 的边界”
- 可以指出何种冷却复杂度需要使用 C++ 后端

### 用例 3：领域边界——Blueprint 中不安全的裸指针访问
**输入**：“我们的 Blueprint 调用 GetOwner() 后，未经有效性检查就立即访问返回结果上的组件。”
**预期行为**：
- 将其标记为运行时崩溃风险：GetOwner() 在某些生命周期状态下可能返回 null
- 给出正确的 Blueprint 模式：访问任何属性/组件前先使用 IsValid() 节点
- 指出对于派生自 Actor 的引用，Blueprint 空值检查不可省略
- 不在未解释原实现为何不安全的情况下直接修改代码

### 用例 4：Blueprint 图表复杂度——是否应重构为 Function Library
**输入**：“主 GameMode Blueprint 的单个图表包含 600 多个节点，并在 8 处重复伤害计算逻辑。”
**预期行为**：
- 将其诊断为可维护性和可测试性问题
- 建议将重复逻辑提取到 Blueprint Function Library（BFL）
- 说明 BFL 的组织方式：计算使用纯函数，任何 Blueprint 均可静态调用
- 指出如果伤害逻辑对性能敏感或与 C++ 共享，可以交由 unreal-specialist 审查是否迁移
- 输出具体的重构计划，而非含糊建议

### 用例 5：上下文传递——Blueprint 复杂度预算
**输入上下文**：项目约定每个 Blueprint 事件图最多包含 100 个节点，超过后必须提取到 Function Library。
**输入**：“这是我们的物品栏 Blueprint 图表［展示了 150 个节点］。它可以发布了吗？”
**预期行为**：
- 将给出的 150 个节点与项目约定的 100 个节点预算进行比较
- 标记该图表已超出复杂度阈值
- 不批准其按现状发布
- 列出可提取到 Function Library 的候选子图，使主图表回到预算范围内

---

## 协议合规性

- [ ] 严守既定领域（Blueprint 架构、性能、图表质量）
- [ ] 将 C++ 实现请求转交给 engine-programmer 或 gameplay-programmer
- [ ] 返回结构化结论（问题/影响/替代方案格式），而非随意发表意见
- [ ] 主动执行 Blueprint 安全模式（空值检查、IsValid）
- [ ] 评估图表复杂度时引用项目约定

---

## 覆盖说明
- 用例 3（空指针安全）是安全关键测试；这是发布版本崩溃的常见来源
- 用例 5 要求项目约定中明确节点预算；如果未配置，代理应指出缺失并建议设置
- 没有自动化运行器；通过人工或 `/skill-test` 审查
