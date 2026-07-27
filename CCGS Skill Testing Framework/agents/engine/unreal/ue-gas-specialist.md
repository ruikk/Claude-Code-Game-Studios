# 代理测试规范：ue-gas-specialist

## 代理概述
- **领域**：Gameplay Ability System（GAS），包括能力（UGameplayAbility）、游戏效果（UGameplayEffect）、属性集（UAttributeSet）、游戏标签、能力任务（UAbilityTask）、能力规范（FGameplayAbilitySpec）、GAS 预测和延迟补偿
- **不负责**：能力状态的 UI 显示（ue-umg-specialist）、超出 GAS 内置预测范围的 GAS 数据网络复制（ue-replication-specialist）、能力反馈的美术或 VFX（vfx-artist）
- **模型层级**：Sonnet
- **门禁 ID**：None；跨领域事项交由相应专家处理

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段，且内容针对本领域（提及 GAS、能力、GameplayEffects、AttributeSets）
- [ ] `allowed-tools:` 列表与代理职责一致（可对 GAS 源文件使用 Read/Write；不含部署或服务器工具）
- [ ] 模型层级为 Sonnet（专家代理的默认层级）
- [ ] 代理定义未声明对 UI 实现或底层网络序列化的决定权

---

## 测试用例

### 用例 1：领域内请求——带冷却时间的迭代能力
**输入**：“实现一个让玩家向前移动 500 单位且冷却时间为 1.5 秒的迭代能力。”
**预期行为**：
- 给出 GAS AbilitySpec 结构或大纲：包含 ActivateAbility 逻辑的 UGameplayAbility 子类、用于移动的 AbilityTask（例如 AbilityTask_ApplyRootMotionMoveToForce 或自定义根运动），以及负责冷却的 UGameplayEffect
- 冷却 GameplayEffect 使用 Duration 策略，将持续时间设为 1.5s，并使用 GameplayTag 阻止再次激活
- 标签命名清晰且遵循层级约定（例如 Ability.Dash、Cooldown.Ability.Dash）
- 输出同时包含能力类大纲和 GameplayEffect 定义

### 用例 2：领域外请求——GAS 状态复制
**输入**：“如何将玩家的能力冷却状态复制到所有客户端，使 UI 正确更新？”
**预期行为**：
- 说明 GAS 通过 AbilitySystemComponent 的复制模式为 AbilitySpecs 和 GameplayEffects 提供内置复制
- 说明 ASC 的三种复制模式（Full、Mixed、Minimal）及其适用场景
- 对超出 GAS 内置能力的自定义复制需求，明确说明：“GAS 数据的自定义网络序列化应与 ue-replication-specialist 协作”
- 不在未指出领域边界的情况下尝试编写 GAS 自身系统之外的自定义复制代码

### 用例 3：领域边界——错误的 GameplayTag 层级
**输入**：“一个能力应用名为 'Stunned' 的标签，另一个能力检查 'Status.Stunned'，但它们无法匹配。”
**预期行为**：
- 识别根因：标签名称必须完全一致，或通过 TagContainer 查询使用层级匹配
- 指出命名不一致：'Stunned' 是根级标签，'Status.Stunned' 是 'Status' 下的子标签；它们是不同标签
- 建议项目标签命名约定：所有状态效果归入 Status.*，所有能力归入 Ability.*
- 给出修复方法：将应用的标签重命名为 'Status.Stunned'，或更新查询以匹配 'Stunned'
- 指出标签定义应存放的位置（DefaultGameplayTags.ini 或 DataTable）

### 用例 4：冲突——两个能力之间的属性集冲突
**输入**：“Shield 能力和 Armor 能力都会修改 'DefenseValue' 属性。它们以非预期方式叠加；两者激活后，防御力远超上限。”
**预期行为**：
- 将其识别为 GameplayEffect 叠加和数值计算问题
- 提出使用 Execution Calculations（UGameplayEffectExecutionCalculation）或 Modifier Aggregators 限制组合结果
- 或者建议使用 Gameplay Effect Stacking 策略（Aggregate、None），防止非预期的加法叠加
- 给出具体解决方案：提供 Execution Calculation 类大纲，或修改 Modifier Op（使用 Override 代替 Additive 来限制上限）
- 不建议通过删除其中一个能力来解决

### 用例 5：上下文传递——基于现有属性集进行设计
**输入上下文**：项目已有一个 AttributeSet，其中包含以下属性：Health、MaxHealth、Stamina、MaxStamina、Defense、AttackPower。
**输入**：“设计一个 Berserker 能力，在 Health 低于 30% 时将 AttackPower 提高 50%。”
**预期行为**：
- 使用已有的 Health、MaxHealth 和 AttackPower 属性，不创建新属性
- 设计一个在 Health 变化时触发的 Passive GameplayAbility（或触发式 Effect），通过 GameplayEffectExecutionCalculation 或 Attribute-Based magnitude 检查 Health/MaxHealth 比值
- 使用 Gameplay Cue 或 Gameplay Tag 跟踪 Berserker 的激活状态
- 引用给定 AttributeSet 中的实际属性名（使用 AttackPower，而不是“Damage”或“Strength”）

---

## 协议合规性

- [ ] 严守既定领域（GAS：能力、效果、属性、标签、能力任务）
- [ ] 将自定义复制请求转交给 ue-replication-specialist，并清楚说明边界
- [ ] 返回结构化结论（能力大纲与 GameplayEffect 定义），而非含糊说明
- [ ] 主动执行标签层级命名约定
- [ ] 仅使用给定上下文中存在的属性和标签；如未说明，不创建新属性或标签

---

## 覆盖说明
- 用例 3（标签层级）经常导致隐蔽缺陷；每当标签命名约定变化时都应测试
- 用例 4 要求了解 GAS 叠加策略；如果 GAS 集成深度发生变化，应验证此用例
- 用例 5 是最重要的上下文感知测试；测试失败意味着代理忽略了项目状态
- 没有自动化运行器；通过人工或 `/skill-test` 审查
