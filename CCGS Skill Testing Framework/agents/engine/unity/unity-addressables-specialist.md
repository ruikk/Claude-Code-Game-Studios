# 代理测试规范：unity-addressables-specialist

## 代理摘要
领域：Addressable Asset System，包括分组、异步加载/卸载、句柄生命周期管理、内存预算、内容目录和远程内容分发。
不负责：渲染系统（engine-programmer）、使用已加载资产的游戏逻辑（gameplay-programmer）。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段，且内容针对该领域（提及 Addressables / 资产加载 / 内容目录 / 远程分发）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家代理的默认值）
- [ ] 代理定义未声称拥有渲染系统或使用已加载资产的游戏逻辑的权限

---

## 测试用例

### 用例 1：领域内请求——输出适当
**输入：**“异步加载角色纹理，并在角色销毁时释放它。”
**预期行为：**
- 生成 `Addressables.LoadAssetAsync<Texture2D>()` 调用模式
- 在发起请求的对象中存储返回的 `AsyncOperationHandle<Texture2D>`
- 角色销毁时（`OnDestroy()`），使用存储的句柄调用 `Addressables.Release(handle)`
- 不使用 `Resources.Load()` 作为加载机制
- 说明释放 null 或未初始化的句柄会导致错误，并包含有效性检查
- 说明释放句柄与释放资产之间的区别（释放句柄才是正确做法）

### 用例 2：领域外请求重定向
**输入：**“实现将已加载纹理应用到角色网格的渲染系统。”
**预期行为：**
- 不生成渲染或网格材质赋值代码
- 明确说明渲染系统实现属于 `engine-programmer` 的职责
- 将请求重定向到 `engine-programmer`
- 可以将自己提供的资产类型和 API 接口（例如句柄完成后提供 `Texture2D` 引用）描述为交接规范

### 用例 3：内存泄漏——句柄未释放
**输入：**“每次加载关卡后，内存占用都会持续增长。我们使用 Addressables 加载关卡资产。”
**预期行为：**
- 诊断可能的原因：`AsyncOperationHandle` 对象使用后未释放
- 识别句柄泄漏模式：将加载的资产存入局部变量，随后丢失引用，且从未调用 `Addressables.Release()`
- 生成审计方法：搜索所有 `LoadAssetAsync` / `LoadSceneAsync` 调用，并验证存在匹配的 `Release()` 调用
- 提供修正模式：使用跟踪句柄列表（`List<AsyncOperationHandle>`）和 `ReleaseAll()` 清理方法
- 不在没有证据的情况下假定泄漏发生在其他位置

### 用例 4：远程内容分发——目录版本控制
**输入：**“我们需要支持可下载的内容更新，而不要求完整地重新安装应用。”
**预期行为：**
- 生成远程目录更新模式：
  - 启动时调用 `Addressables.CheckForCatalogUpdates()`
  - 对检测到的更新调用 `Addressables.UpdateCatalogs()`
  - 调用 `Addressables.DownloadDependenciesAsync()` 预热更新内容
- 说明通过目录哈希检查检测变更
- 处理边界情况：如果玩家开始会话后目录在会话中途更新，应定义行为（当前会话继续使用旧目录，下次启动时重新加载）
- 不设计服务端 CDN 基础设施（委派给 devops-engineer）

### 用例 5：上下文传递——平台内存约束
**输入：**平台上下文：目标平台为 Nintendo Switch，内存为 4GB，实际资产内存上限为 512MB。请求：“为大型开放世界关卡设计 Addressables 加载策略。”
**预期行为：**
- 引用提供的上下文中的 512MB 内存上限
- 设计流式加载策略：
  - 将世界划分为可寻址区域，根据玩家距离加载/卸载
  - 定义每个活动区域的内存预算（例如 128MB，最多同时激活 4 个区域）
  - 指定异步预加载触发距离和卸载距离（滞后区间）
- 说明 Switch 特定约束：从 SD 卡加载较慢，建议预热相邻区域
- 如果加载策略会超出给定的 512MB 上限，则必须标记，不得直接采用

---

## 协议合规性

- [ ] 保持在声明的领域内（Addressables 加载、句柄生命周期、内存、目录、远程分发）
- [ ] 将渲染和使用资产的游戏逻辑代码分别重定向到 engine-programmer 和 gameplay-programmer
- [ ] 返回结构化输出（加载模式、句柄生命周期代码、流式区域设计）
- [ ] 始终为 `LoadAssetAsync` 配对相应的 `Release()`，并将句柄泄漏标记为内存缺陷
- [ ] 根据提供的内存上限设计加载策略
- [ ] 不设计 CDN/服务器基础设施，而是将服务端工作委派给 devops-engineer

---

## 覆盖说明
- 句柄生命周期（用例 1）必须包含验证内存在释放后被回收的测试
- 句柄泄漏诊断（用例 3）应生成适合缺陷工单的发现报告
- 平台内存用例（用例 5）用于验证代理会应用上下文中的硬性约束，而非默认假设
