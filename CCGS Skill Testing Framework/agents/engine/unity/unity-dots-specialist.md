# 代理测试规范：unity-dots-specialist

## 代理摘要
领域：ECS 架构（IComponentData、ISystem、SystemAPI）、Jobs 系统（IJob、IJobEntity、Burst）、Burst 编译器约束、DOTS 游戏逻辑系统及混合渲染器。
不负责：MonoBehaviour 游戏逻辑代码（gameplay-programmer）、UI 实现（unity-ui-specialist）。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段，且内容针对该领域（提及 ECS / Jobs / Burst / IComponentData）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家代理的默认值）
- [ ] 代理定义未声称拥有 MonoBehaviour 游戏逻辑或 UI 系统的权限

---

## 测试用例

### 用例 1：领域内请求——输出适当
**输入：**“将玩家移动系统转换为 ECS。”
**预期行为：**
- 生成：
  - 包含速度、速率和输入向量字段的 `PlayerMovementData : IComponentData` 结构体
  - 在 `OnUpdate()` 中使用 `SystemAPI.Query<>` 或 `IJobEntity` 的 `PlayerMovementSystem : ISystem`
  - 通过 `IBaker` 从烘焙用 MonoBehaviour 转换玩家的初始状态
- 使用 `RefRW<LocalTransform>` 更新位置（而非已弃用的 `Translation`）
- 为作业标记 `[BurstCompile]`，并说明哪些内容必须为非托管类型才能兼容 Burst
- 不修改输入轮询系统，而是从现有 `PlayerInputData` 组件读取数据

### 用例 2：拒绝 MonoBehaviour 方案
**输入：**“玩家移动直接使用 MonoBehaviour 就好，这样更简单。”
**预期行为：**
- 认可简单性方面的理由
- 解释 DOTS 的取舍：前期设置更多，但 ECS/Burst 方案可提供项目 ADR 或需求中记录的性能特性
- 如果项目已决定采用 DOTS，则不实现 MonoBehaviour 版本
- 如果尚未作出决定，则将架构决策提交给 `lead-programmer` / `technical-director` 解决
- 不单方面决定使用 MonoBehaviour 还是 DOTS

### 用例 3：与 Burst 不兼容的托管内存
**输入：**“这个 Burst 作业访问 `List<EnemyData>` 来查找最近的敌人。”
**预期行为：**
- 将 `List<T>` 标记为与 Burst 编译不兼容的托管类型
- 不批准访问托管内存的 Burst 作业
- 根据使用场景提供正确替代方案：`NativeArray<EnemyData>`、`NativeList<EnemyData>` 或 `NativeHashMap<>`
- 说明必须显式释放 `NativeArray`，或使用 `[DeallocateOnJobCompletion]`
- 使用非托管原生容器生成修正后的作业

### 用例 4：混合访问——DOTS 系统需要 MonoBehaviour 数据
**输入：**“DOTS 移动系统需要读取由 MonoBehaviour CameraController 管理的摄像机 Transform。”
**预期行为：**
- 识别出这是混合访问场景
- 提供正确的混合模式：将摄像机 Transform 存储在单例 `IComponentData` 中（由 MonoBehaviour 侧每帧通过 `EntityManager.SetComponentData` 更新）
- 也可以建议使用 `CompanionComponent` / 托管组件方案
- 不从 Burst 作业内部访问 MonoBehaviour，并将这种做法标记为不安全
- 同时提供 MonoBehaviour 侧（写入 ECS）和 DOTS 系统侧（从 ECS 读取）的桥接代码

### 用例 5：上下文传递——性能目标
**输入：**上下文中的技术偏好：目标为 60fps，每帧 CPU 脚本预算最多 2ms。请求：“为 10,000 个敌人实体设计 ECS 块布局。”
**预期行为：**
- 在设计理由中明确引用 2ms CPU 预算
- 为提高缓存效率而设计 `IComponentData` 块布局：
  - 将经常共同查询的组件归入同一原型
  - 将很少使用的数据拆分到独立组件中，使热数据保持紧凑
  - 根据 2ms 预算估算实体迭代耗时
- 提供内存布局分析（每个实体的字节数、16KB 块大小下每块的实体数）
- 如果布局明显会超出给定的 2ms 预算，则必须标记，不得直接采用

---

## 协议合规性

- [ ] 保持在声明的领域内（ECS、Jobs、Burst、DOTS 游戏逻辑系统）
- [ ] 将仅使用 MonoBehaviour 的游戏逻辑重定向到 gameplay-programmer
- [ ] 返回结构化输出（IComponentData 结构体、ISystem 实现、IBaker 烘焙类）
- [ ] 将 Burst 作业中的托管内存访问标记为编译错误，并提供非托管替代方案
- [ ] 当 DOTS 系统需要与 MonoBehaviour 系统交互时，提供混合访问模式
- [ ] 根据提供的性能预算设计块布局

---

## 覆盖说明
- ECS 转换（用例 1）必须包含使用 ECS 测试框架（`World`、`EntityManager`）的单元测试
- Burst 不兼容问题（用例 3）事关安全，代理必须在代码编写前发现此问题
- 块布局（用例 5）用于验证代理会将量化性能推理应用于架构决策
