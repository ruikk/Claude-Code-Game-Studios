# 代理测试规范：ue-umg-specialist

## 代理概述
- **领域**：UMG 控件层级设计、数据绑定模式、CommonUI 输入路由与动作标签、控件样式（WidgetStyle 资产）、UI 优化（控件池、ListView、失效处理）
- **不负责**：UX 流程和界面导航设计（ux-designer）、游戏玩法逻辑（gameplay-programmer）、后端数据源（游戏代码）、服务器通信
- **模型层级**：Sonnet
- **门禁 ID**：None；UX 流程决策交由 ux-designer

---

## 静态断言（结构）

- [ ] 存在 `description:` 字段，且内容针对本领域（提及 UMG、控件层级、CommonUI）
- [ ] `allowed-tools:` 列表与代理职责一致（可对 UI 资产和 Blueprint 文件使用 Read/Write；不含服务器或游戏玩法源码工具）
- [ ] 模型层级为 Sonnet（专家代理的默认层级）
- [ ] 代理定义未声明对 UX 流程、导航架构或游戏玩法数据逻辑的决定权

---

## 测试用例

### 用例 1：领域内请求——带数据绑定的物品栏控件
**输入**：“创建一个以网格形式显示物品槽位的物品栏控件。每个槽位应显示物品图标、数量和稀有度颜色，并在物品栏变化时更新。”
**预期行为**：
- 给出 UMG 控件结构：父级 WBP_Inventory 包含 UniformGridPanel 或 TileView，每件物品对应一个子级 WBP_InventorySlot 控件
- 说明数据绑定方式：由 Inventory Component 上的 Event Dispatchers 触发刷新，或使用 ListView，并让 UObject 物品数据类实现 IUserObjectListEntry
- 指定稀有度颜色的驱动方式：使用 WidgetStyle 资产或数据表查询，而非硬编码颜色值
- 输出包含控件层级、绑定模式和刷新触发机制

### 用例 2：领域外请求——UX 流程设计
**输入**：“设计物品栏系统的完整导航流程，包括玩家如何打开物品栏、切换到角色属性，以及退出到暂停菜单。”
**预期行为**：
- 不生成导航流程或界面切换架构
- 明确说明：“导航流程和界面切换设计由 ux-designer 负责；流程确定后，我可以实现 UMG 控件结构”
- 在没有 UX 规范时不作 UX 决策（返回按钮行为、切换动画、模态或全屏）

### 用例 3：领域边界——CommonUI 输入动作不匹配
**输入**：“我们的物品栏控件不响应控制器的返回按钮。项目使用 CommonUI。”
**预期行为**：
- 识别可能的原因：控件的返回输入动作标签与项目已注册的 CommonUI InputAction 数据资产不匹配
- 说明 CommonUI 输入路由模型：控件通过 `CommonUI_InputAction` 标签声明输入动作；CommonActivatableWidget 负责路由
- 给出修复方法：确认控件的返回动作标签与项目 CommonUI 输入动作数据表中注册的标签一致
- 将其与硬件输入绑定问题区分开来（后者属于 Enhanced Input 领域）

### 用例 4：控件性能问题——每帧创建大量控件实例
**输入**：“排行榜控件一次创建 500 个独立的 WBP_LeaderboardRow 实例。打开排行榜时，游戏会卡顿 300ms。”
**预期行为**：
- 识别根因：单帧实例化 500 个控件导致构造卡顿
- 建议改用支持虚拟化的 ListView 或 TileView，只构造可见行
- 说明 ListView 数据对象需要实现 IUserObjectListEntry 接口
- 如果 ListView 不适用，建议使用对象池：预先实例化固定数量的行，并用新数据循环复用
- 输出包含要使用的具体 UMG 组件，而不是含糊地说“进行优化”

### 用例 5：上下文传递——CommonUI 已配置
**输入上下文**：项目使用 CommonUI，并注册了以下 InputAction 标签：UI.Action.Confirm、UI.Action.Back、UI.Action.Pause、UI.Action.Secondary。
**输入**：“在物品栏控件中添加一个支持 CommonUI 的‘整理物品栏’按钮。”
**预期行为**：
- 使用 UI.Action.Secondary（如果 Secondary 已被占用，则建议注册 UI.Action.Sort 等新标签）
- 不凭空创建新的 InputAction 标签；如需新建，必须指出应在 CommonUI 数据表中注册
- 当 CommonUI 已是既定模式时，不使用非 CommonUI 的输入绑定方式（例如在 Event Graph 中直接处理按键）
- 在建议中明确引用给定的标签列表

---

## 协议合规性

- [ ] 严守既定领域（UMG 结构、数据绑定、CommonUI、控件性能）
- [ ] 将 UX 流程和导航设计请求转交给 ux-designer
- [ ] 返回结构化结论（控件层级与绑定模式），而非随意发表意见
- [ ] 使用上下文中已有的 CommonUI InputAction 标签；不在未说明注册要求的情况下创建新标签
- [ ] 对大型集合优先推荐虚拟化列表（ListView/TileView），其次才是控件池

---

## 覆盖说明
- 用例 3（CommonUI 输入路由）要求项目已配置 CommonUI；如果项目不使用 CommonUI，则跳过此测试
- 用例 4（性能）是高影响失败模式；300ms 卡顿会阻止发布，应优先执行此测试用例
- 用例 5 是检验 UI 管线一致性时最重要的上下文感知测试
- 没有自动化运行器；通过人工或 `/skill-test` 审查
