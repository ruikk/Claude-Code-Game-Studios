# 代理测试规范：unreal-specialist

## 代理概述
- **领域**：Unreal Engine 模式与架构，包括 Blueprint 与 C++ 的选型、UE 子系统（GAS、Enhanced Input、Niagara）、UE 项目结构、插件集成和引擎级配置
- **不负责**：美术风格和视觉方向（art-director）、服务器基础设施和部署（devops-engineer）、UI/UX 流程设计（ux-designer）
- **模型层级**：Sonnet
- **门禁 ID**：None；门禁结论交由 technical-director 判定

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段，且内容针对本领域（提及 Unreal Engine）
- [ ] `allowed-tools:` 列表与代理职责一致（可对 UE 项目文件使用 Read、Write；不含部署工具）
- [ ] 模型层级为 Sonnet（专家代理的默认层级）
- [ ] 代理定义未声明超出其既定领域的权限（不负责美术或服务器基础设施）

---

## 测试用例

### 用例 1：领域内请求——Blueprint 与 C++ 的选型标准
**输入**：“我们的连击系统应该用 Blueprint 还是 C++ 实现？”
**预期行为**：
- 提供结构化的判断标准：复杂度、复用频率、团队技能和性能要求
- 对每帧调用或由 5 种以上能力类型共享的系统推荐 C++
- 对设计师可调参数和一次性逻辑推荐 Blueprint
- 在不了解项目上下文时不作最终判断；缺少上下文时提出澄清问题
- 输出采用标准表或项目符号列表等结构化形式，而非随意发表意见

### 用例 2：领域外请求——Unity C# 代码
**输入**：“编写一个处理玩家生命值并在死亡时触发 Unity 事件的 C# MonoBehaviour。”
**预期行为**：
- 不生成 Unity C# 代码
- 明确说明：“本项目使用 Unreal Engine；在 UE 中，对应实现是 UE C++ Actor Component 或 Blueprint Actor Component”
- 可以提出按需提供 UE 对应实现
- 不转交给 Unity 专家（框架中不存在该代理）

### 用例 3：领域边界——UE5.4 API 要求
**输入**：“我需要使用 UE5.4 引入的新 Motion Matching API。”
**预期行为**：
- 指出 UE5.4 是具体版本，LLM 训练数据对它的覆盖可能有限
- 建议先对照 Unreal 官方文档或项目的 engine-reference 目录，再采信任何 API 建议
- 尽力提供 API 指导，并明确标注不确定性（例如“请对照 UE5.4 发布说明进行验证”）
- 不在缺少警告的情况下直接给出过时或错误的 API 签名

### 用例 4：冲突——核心系统中的 Blueprint 意大利面代码
**输入**：“我们的复制逻辑全部位于一个深度嵌套的 Blueprint 事件图中，包含 300 多个节点且没有函数，已经越来越难以维护。”
**预期行为**：
- 将其识别为 Blueprint 架构问题，而不是轻微的风格问题
- 建议将核心复制逻辑迁移到 C++ ActorComponent 或 GameplayAbility 系统
- 指出所需协作：修改复制架构必须让 lead-programmer 参与
- 不在未向用户说明重构范围的情况下单方面宣布“迁移到 C++”
- 给出具体的迁移建议，而非含糊建议

### 用例 5：上下文传递——适配版本的 API 建议
**输入上下文**：项目的 engine-reference 文件指定 Unreal Engine 5.3。
**输入**：“如何为新角色设置 Enhanced Input 动作？”
**预期行为**：
- 使用 UE5.3 时期的 Enhanced Input API（InputMappingContext、UEnhancedInputComponent::BindAction）
- 如未标明可能不可用，则不引用 UE5.3 之后引入的 API
- 在回复中引用项目指定的引擎版本
- 提供具体且与版本对应的代码或 Blueprint 节点名称

---

## 协议合规性

- [ ] 严守既定领域（Unreal 模式、Blueprint/C++、UE 子系统）
- [ ] 转交 Unity 或其他引擎的请求，不生成错误引擎的代码
- [ ] 返回结构化结论（标准表、决策树、迁移计划），而非随意发表意见
- [ ] 在提供 API 建议前明确标示版本不确定性
- [ ] 对架构级重构与 lead-programmer 协作，而非单方面决定

---

## 覆盖说明
- 代理行为测试没有自动化运行器；这些测试通过人工或 `/skill-test` 审查
- 版本感知（用例 3、用例 5）是此代理风险最高的失败模式；引擎版本变化时应定期测试
- 用例 4 中与 lead-programmer 的配合是协作测试，而非技术正确性测试
