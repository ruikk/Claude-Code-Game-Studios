---
name: setup-engine
description: "配置项目的游戏引擎和版本。在CLAUDE.md中固定引擎，并检测知识缺口，当版本超出LLM的训练数据时，通过WebSearch填充引擎参考文档。"
argument-hint: "[引擎] | [引擎版本] | refresh | upgrade [旧版本] [新版本] | 无参数时进入引导选择"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, WebFetch, Task, AskUserQuestion
model: sonnet
---

当调用此技能时:

## 1. 解析参数

四种模式:

- **全指定**: `/setup-engine godot 4.6` — 引擎和版本都提供
- **仅引擎**: `/setup-engine unity` — 只提供引擎，版本会另行查询
- **无参数**: `/setup-engine` — 全程引导模式（引擎推荐 + 版本）
- **刷新**: `/setup-engine refresh` — 更新参考文档（见第10节）
- **升级**: `/setup-engine upgrade [old-version] [new-version]` — 升级到新版本（见第11节）

---

## 2. 引导模式（无参数）

如果未指定引擎，则运行一个交互式引擎选择过程：

### 检查现有游戏概念
- 如果 `design/gdd/game-concept.md` 存在，则读取它，提取类型、范围、目标平台、美术风格、团队规模，以及来自 `/brainstorm` 的引擎推荐
- 如果没有概念存在，通知用户：
  未找到游戏概念。可以先运行 `/brainstorm` 来发现你想要做的游戏——它还会推荐一个引擎。或者告诉我你的游戏，我可以帮你选择。

### 如果用户想在没有概念的情况下选择，按顺序询问：

**问题1 — 以往经验** (总是首先询问，通过 `AskUserQuestion`):
- 提示: "你以前用过这些引擎吗？"
- 选项: `Godot` / `Unity` / `Unreal Engine 5` / `多个 - 我会解释` / `都没有`
- 如果用户选择了特定引擎 → 推荐该引擎。以往经验比其他所有因素都重要。向用户确认后跳过矩阵。
- 如果选择“无”或“多个” → 继续下面的问题。

**问题2-6 — 决策矩阵输入** (仅在没有以往引擎经验时):

**问题2 — 目标平台** (总是首先询问，通过 `AskUserQuestion`):
- 提示: "这个游戏的目标平台是什么？"
- 选项: `PC（Steam / Epic）` / `移动设备（iOS / Android）` / `主机` / `网页 / 浏览器` / `多平台`
- 直接影响推荐的平台注册规则:
  - 移动设备 → 强烈推荐 Unity；Unreal 不太适合；Godot 可用于简单移动游戏
  - 主机 → Unity 或 Unreal；Godot 主机支持需要第三方发行商或大量额外工作
  - 网页 → Godot 可顺畅导出到网页；Unity WebGL 功能可用；Unreal 对网页支持较差
  - 仅 PC → 所有引擎均可行；由其他因素决定
  - 多平台 → Unity 是最便携的，跨 PC/移动/主机

1. **游戏类型？** (2D, 3D, 或者两者都有？)
2. **主要输入方法？** (键盘/鼠标, 游戏pad, 触摸, 或者混合？)
3. **团队大小和经验？** (单人新手、单人有经验开发者、小团队？)
4. **任何强烈的语言偏好？** (GDScript, C#, C++, 视觉脚本？)
5. **引擎授权许可预算？** (仅限免费，还是可接受商业授权？)

### 给出一个推荐

不要使用一个简单的评分矩阵来消除引擎。相反，根据用户资料和诚实的权衡来推荐引擎，并始终让最终选择权在用户手中。

**引擎诚实权衡：**

**Godot 4**
- 真正的优势：一流的 2D 能力、风格化/独立 3D、快速迭代、永久免费（MIT）、开源、学习曲线最平缓，最适合希望完全掌控项目的独立开发者
- 实际限制：与 Unity/Unreal 相比，3D 生态较薄弱（针对 3D 特定问题的教程、资产和社区解答较少）；大型 3D 开放世界在 Godot 中实现难度很高且基本未经验证；主机导出需要第三方发行商或大量额外工作；专业岗位市场较小
- 授权实情：真正免费，永远没有收入门槛。MIT 许可证意味着所有成果都归你所有。
- 最适合：任何规模的 2D 游戏；风格化/氛围型 3D；范围受控的 3D 世界（非开放世界）；重视学习曲线的首个游戏项目；任何规模下预算都是硬约束的项目

**Unity**
- 真正的优势：中等规模 3D 和移动游戏的行业标准；庞大的资产商店和教程生态；C# 是专业编程语言；为独立开发者提供最佳的主机认证支持；几乎每种类型都有强大的社区支持
- 实际限制：2023 年的授权争议损害了信任（曾提出运行时费用，后又撤回，政策变更风险仍然存在）；C# 的入门曲线比 GDScript 更陡；对于简单项目，编辑器比 Godot 更笨重
- 授权实情：收入低于 20 万美元且安装量低于 20 万次时免费（Unity Personal/Plus）。只有游戏真正成功后成本才会上升，而大多数独立游戏不会达到这个门槛。2023 年的争议值得了解，但当前条款对大多数独立开发者而言是合理的。
- 最适合：移动游戏；中等规模 3D；面向主机的游戏；有 C# 背景的开发者；需要大型资产商店的项目；2-5 人团队

**Unreal Engine 5**
- 真正的优势：一流的 3D 视觉效果（Lumen、Nanite、Chaos 物理）；AAA 和写实 3D 的行业标准；大型开放世界支持成熟且经过生产验证；Blueprint 可视化脚本降低了 C++ 门槛；特别适合面向高端 PC 或主机的游戏
- 实际限制：学习曲线最陡；编辑器最笨重（编译慢、项目体积大）；对风格化、2D 或小规模游戏而言过于庞大；C++ 确实很难；不适合移动端或网页；单款游戏总收入超过 100 万美元后收取 5% 版税
- 授权实情：单款游戏总收入超过 100 万美元后才收取 5% 版税。首款游戏或任何未达到 100 万美元收入的游戏均无需付费。这个门槛足够高，大多数独立开发者永远不会支付版税。
- 最适合：AAA 品质 3D；大型开放世界游戏；写实视觉效果；有 C++ 经验或愿意使用 Blueprint 的开发者；以视觉保真度为核心卖点、面向高端 PC/主机的游戏

**特定类型指南**（纳入推荐考量）：
- 任何风格的 2D → 强烈推荐 Godot
- 风格化/氛围型/范围受控的 3D 世界 → Godot 可行，Unity 是稳妥备选
- 大型无缝 3D 开放世界 → Unity 或 Unreal；Godot 尚未在此类生产项目中得到验证
- 写实 3D / AAA 品质 → Unreal
- 移动端优先 → 强烈推荐 Unity
- 主机优先 → Unity 或 Unreal；Godot 的主机支持需要额外工作
- 恐怖/叙事/步行模拟 → 任何引擎均可；根据美术风格和团队经验选择
- 动作 RPG / 类魂 → 3D 项目使用 Unity 或 Unreal；此类项目很依赖社区支持和资产
- 2D 平台游戏 → Godot
- 策略/俯视角/RTS → 根据 2D 或 3D 选择 Godot 或 Unity

**推荐格式：**
1. 展示比较表，以用户的具体考虑因素作为行
2. 给出首选建议并坦诚说明理由
3. 指出最佳备选方案，以及应改选该方案的条件
4. 明确说明："这只是起点，不是最终结论。你随时可以迁移引擎，许多开发者也会在不同项目间切换引擎。"
5. 使用 `AskUserQuestion` 确认："这个推荐符合你的预期吗，还是你想探索其他引擎？"
   - 选项：`[首选引擎]（推荐）` / `[备选引擎]` / `[第三个引擎]` / `深入探索` / `自行输入`

**如果用户选择“深入探索”：**
使用 `AskUserQuestion` 提供针对该概念的深入主题。必须根据用户的实际概念生成选项，不要使用通用选项。至少应包含：
- 首选引擎对此概念的具体限制（例如：“Godot 3D 实际能将[类型]做到什么程度？”）
- 备选引擎对此概念的具体权衡
- 语言选择对该概念技术难点的影响
- 任何概念特有的技术问题（例如自适应音频、开放世界流式加载、多人网络代码）

用户可以选择多个主题。深入回答每个选中主题后，再回到引擎确认问题。

---

## 3. 查询当前版本

选择引擎后：

- 如果提供了版本，则使用该版本
- 如果未提供版本，则使用 WebSearch 查找最新稳定版本：
  - 搜索：`"[引擎] 最新稳定版本 [当前年份]"`
  - 向用户确认："[引擎] 的最新稳定版本是 [版本]。使用这个版本吗？"

---

## 4. 更新 CLAUDE.md 技术栈

### 语言选择（仅限 Godot）

如果选择了 Godot，在展示拟议的技术栈**之前**，询问用户要使用哪种语言：

> "Godot 支持两种主要语言：
>
>   **A) GDScript** — 类似 Python、Godot 原生、迭代最快。最适合初学者、独立开发者和有 Python 或 Lua 背景的团队。
>   **B) C#** — .NET 8+，Unity 开发者更熟悉，IDE 工具（Rider / Visual Studio）更强，在重逻辑场景下略有性能优势。
>   **C) 两者都用** — GDScript 用于玩法/UI 脚本，C# 用于性能关键系统。这是高级配置，需要同时安装 .NET SDK 和 Godot。
>
> 这个项目主要使用哪一种？"

记录该选择。它决定 CLAUDE.md 模板、命名约定、专家路由，以及整个项目中处理代码文件时启动的代理。

---

读取 `CLAUDE.md`，向用户展示拟议的技术栈变更。
询问："可以将这些引擎设置写入 `CLAUDE.md` 吗？"

得到确认后才能进行任何编辑。

更新技术栈部分，将 `[CHOOSE]` 占位符替换为实际值：

**Godot**：使用与上述语言选择相匹配的模板。三种变体（GDScript、C#、两者都用）见本技能底部的**附录 A**。

**Unity：**
```markdown
- **引擎**：Unity [版本]
- **语言**：C#
- **构建系统**：Unity Build Pipeline
- **资产管线**：Unity Asset Import Pipeline + Addressables
```

**Unreal：**
```markdown
- **引擎**：Unreal Engine [版本]
- **语言**：C++（主要），Blueprint（玩法原型）
- **构建系统**：Unreal Build Tool（UBT）
- **资产管线**：Unreal Content Pipeline
```

---

## 5. 填充技术偏好

更新 CLAUDE.md 后，使用适合该引擎的默认值创建或更新 `.claude/docs/technical-preferences.md`。先读取现有模板，再填充：

### 引擎与语言部分
- 根据第 4 步的引擎选择填写

### 命名约定（引擎默认值）

**Godot**：GDScript、C# 和两者都用的变体见**附录 A**。

**Unity（C#）：**
- 类：PascalCase（例如 `PlayerController`）
- 公共字段/属性：PascalCase（例如 `MoveSpeed`）
- 私有字段：_camelCase（例如 `_moveSpeed`）
- 方法：PascalCase（例如 `TakeDamage()`）
- 文件：使用与类名匹配的 PascalCase（例如 `PlayerController.cs`）
- 常量：PascalCase 或 UPPER_SNAKE_CASE

**Unreal（C++）：**
- 类：带前缀的 PascalCase（Actor 使用 `A`，UObject 使用 `U`，结构体使用 `F`）
- 变量：PascalCase（例如 `MoveSpeed`）
- 函数：PascalCase（例如 `TakeDamage()`）
- 布尔值：使用 `b` 前缀（例如 `bIsAlive`）
- 文件：与去掉前缀后的类名匹配（例如 `PlayerController.h`）

### 输入与平台部分

使用第 2 节收集的答案（或从游戏概念中提取的信息）填充 `## 输入与平台`。按以下映射推导值：

| 目标平台 | 游戏手柄支持 | 触摸支持 |
|----------|--------------|----------|
| 仅 PC | 部分（推荐） | 无 |
| 主机 | 完整 | 无 |
| 移动端 | 无 | 完整 |
| PC + 主机 | 完整 | 无 |
| PC + 移动端 | 部分 | 完整 |
| 网页 | 部分 | 部分 |

对于**主要输入方式**，使用该游戏类型的主流输入方式：
- 面向主机的动作/RPG/平台游戏 → 游戏手柄
- 策略/点击式冒险/RTS → 键盘/鼠标
- 移动游戏 → 触摸
- 跨平台 → 询问用户

展示推导出的值，并在写入前请用户确认或调整。

填充示例：
```markdown
## 输入与平台
- **目标平台**：PC、主机
- **输入方式**：键盘/鼠标、游戏手柄
- **主要输入方式**：游戏手柄
- **游戏手柄支持**：完整
- **触摸支持**：无
- **平台说明**：所有 UI 必须支持方向键导航。不得使用仅悬停时可用的交互。
```

### 其余部分
- **性能预算**：使用 `AskUserQuestion`：
  - 提示："现在设置默认性能预算，还是留到以后？"
  - 选项：`[A] 现在设置默认值（60fps、16.6ms 帧预算、适合引擎的绘制调用上限）` / `[B] 保留为 [待配置]，等明确目标硬件后再设置`
  - 如果选择 [A]：填入建议的默认值。如果选择 [B]：保留占位符。
- **测试**：建议适合引擎的框架（Godot 使用 GUT、Unity 使用 NUnit 等），添加前先询问。
- **禁止模式**：保留占位符，不要预先填充。
- **允许的库**：保留占位符，不要预先填充项目当前不需要的依赖。仅在实际开始集成某个库时添加，不要投机性添加。

> **护栏**：绝不向“允许的库”添加投机性依赖。例如，除非本次会话正在开始 Steam 集成，否则不要添加 GodotSteam。发布后的集成应在相关工作开始时加入“允许的库”，而不是在引擎设置阶段添加。

### 引擎专家路由

同时在 `technical-preferences.md` 的 `## 引擎专家` 部分填入所选引擎的正确路由：

**Godot**：与所选语言匹配的路由表见**附录 A**。

**Unity：**
```markdown
## 引擎专家
- **主要专家**：unity-specialist
- **语言/代码专家**：unity-specialist（C# 审查由主要专家负责）
- **着色器专家**：unity-shader-specialist（Shader Graph、HLSL、URP/HDRP 材质）
- **UI 专家**：unity-ui-specialist（UI Toolkit UXML/USS、UGUI Canvas、运行时 UI）
- **其他专家**：unity-dots-specialist（ECS、Jobs 系统、Burst 编译器）、unity-addressables-specialist（资产加载、内存管理、内容目录）
- **路由说明**：架构和常规 C# 代码审查调用主要专家。任何 ECS/Jobs/Burst 代码调用 DOTS 专家。渲染和视觉效果调用着色器专家。所有界面实现调用 UI 专家。资产管理系统调用 Addressables 专家。

### 文件扩展名路由

| 文件扩展名/类型 | 启动的专家 |
|-----------------|------------|
| 游戏代码（.cs 文件） | unity-specialist |
| 着色器/材质文件（.shader、.shadergraph、.mat） | unity-shader-specialist |
| UI/屏幕文件（.uxml、.uss、Canvas 预制体） | unity-ui-specialist |
| 场景/预制体/关卡文件（.unity、.prefab） | unity-specialist |
| 原生扩展/插件文件（.dll、原生插件） | unity-specialist |
| 常规架构审查 | unity-specialist |
```

**Unreal：**
```markdown
## 引擎专家
- **主要专家**：unreal-specialist
- **语言/代码专家**：ue-blueprint-specialist（Blueprint 图表）或 unreal-specialist（C++）
- **着色器专家**：unreal-specialist（没有专门的着色器专家，由主要专家负责材质）
- **UI 专家**：ue-umg-specialist（UMG 控件、CommonUI、输入路由、控件样式）
- **其他专家**：ue-gas-specialist（Gameplay Ability System、属性、玩法效果）、ue-replication-specialist（属性复制、RPC、客户端预测、网络代码）
- **路由说明**：C++ 架构和广泛的引擎决策调用主要专家。Blueprint 图表架构和 BP/C++ 边界设计调用 Blueprint 专家。所有能力和属性代码调用 GAS 专家。任何多人或联网系统调用复制专家。所有 UI 实现调用 UMG 专家。

### 文件扩展名路由

| 文件扩展名/类型 | 启动的专家 |
|-----------------|------------|
| 游戏代码（.cpp、.h 文件） | unreal-specialist |
| 着色器/材质文件（.usf、.ush、Material 资产） | unreal-specialist |
| UI/屏幕文件（.umg、UMG Widget Blueprints） | ue-umg-specialist |
| 场景/预制体/关卡文件（.umap、.uasset） | unreal-specialist |
| 原生扩展/插件文件（Plugin .uplugin、模块） | unreal-specialist |
| Blueprint 图表（.uasset BP 类） | ue-blueprint-specialist |
| 常规架构审查 | unreal-specialist |
```

### 协作步骤
向用户展示填充后的偏好。对于 Godot，包含所选语言，并说明完整命名约定和路由表的位置：
> "以下是 [引擎]（[如果是 Godot，填写语言]）的默认技术偏好。命名约定和专家路由位于本技能的附录 A，我会应用 [GDScript/C#/两者都用] 变体。你想自定义其中的内容，还是保存默认值？"

对于其他引擎，直接展示默认值，不引用附录。

获得批准后才能写入文件。

---

## 6. 确定知识缺口

检查引擎版本是否可能超出 LLM 的训练数据范围。

**已知的大致覆盖范围**（随模型变化更新）：
- LLM 知识截止时间：**2025 年 5 月**
- Godot：训练数据可能覆盖至约 4.3
- Unity：训练数据可能覆盖至约 2023.x / 6000.x 早期版本
- Unreal：训练数据可能覆盖至约 5.3 / 5.4 早期版本

将用户选择的版本与这些基线比较：

- **在训练数据范围内** → `低风险`：参考文档可选，但建议创建
- **接近边界** → `中风险`：建议创建参考文档
- **超出训练数据** → `高风险`：必须创建参考文档

告知用户所属类别及原因。

---

## 7. 填充引擎参考文档

### 如果在训练数据范围内（低风险）：

创建最简的 `docs/engine-reference/<引擎>/VERSION.md`：

```markdown
# [引擎] - 版本参考

| 字段 | 值 |
|------|----|
| **引擎版本** | [版本] |
| **项目固定日期** | [今天的日期] |
| **LLM 知识截止时间** | 2025 年 5 月 |
| **风险级别** | 低：版本在 LLM 训练数据范围内 |

## 说明

此引擎版本在 LLM 的训练数据范围内。引擎参考文档是可选的；如果代理建议了错误的 API，可以稍后添加。

随时运行 `/setup-engine refresh` 填充完整参考文档。
```

不要创建 breaking-changes.md、deprecated-apis.md 等文件，它们价值有限，却会增加上下文成本。

### 如果超出训练数据（中风险或高风险）：

通过网络搜索创建完整的参考文档集：

1. **搜索官方迁移/升级指南**：
   - `"[引擎] [旧版本] 到 [新版本] 迁移指南"`
   - `"[引擎] [版本] 破坏性变更"`
   - `"[引擎] [版本] 更新日志"`
   - `"[引擎] [版本] 已弃用 API"`

2. 从官方文档中**获取并提取**：
   - 从训练数据截止版本到当前版本之间各版本的破坏性变更
   - 已弃用的 API 及其替代方案
   - 新功能和最佳实践

询问："可以在 `docs/engine-reference/<引擎>/` 下创建引擎参考文档吗？"

得到确认后才能写入任何文件。

3. **创建完整的参考目录**：
   ```
   docs/engine-reference/<引擎>/
   ├── VERSION.md                 # 固定版本 + 知识缺口分析
   ├── breaking-changes.md        # 各版本的破坏性变更
   ├── deprecated-apis.md         # “不要使用 X → 改用 Y”表格
   ├── current-best-practices.md  # 训练数据截止时间之后的新实践
   └── modules/                   # 各子系统参考（按需创建）
   ```

4. 使用网络搜索获得的真实数据**填充每个文件**，遵循现有参考文档建立的格式。每个文件必须包含“最后验证：[日期]”标题。

5. **对于模块文件**：仅为发生重大变化的子系统创建模块。不要创建空的或内容极少的模块文件。

---

## 8. 更新 CLAUDE.md 导入

询问："可以更新 `CLAUDE.md` 中的 `@` 导入，使其指向新的引擎参考文档吗？"

得到确认后，更新“引擎版本参考”下的 `@` 导入，使其指向正确的引擎：

```markdown
## 引擎版本参考

@docs/engine-reference/<引擎>/VERSION.md
```

如果之前的导入指向其他引擎（例如从 Godot 切换到 Unity），则更新它。

---

## 9. 更新代理指令

进行任何编辑前，询问："可以在引擎专家代理文件中添加‘版本意识’部分吗？"

验证所选引擎的专家代理是否包含“版本意识”部分。如果没有，按照现有 Godot 专家代理中的模式添加。

该部分应指示代理：
1. 读取 `docs/engine-reference/<引擎>/VERSION.md`
2. 建议代码前检查已弃用的 API
3. 检查相关版本迁移的破坏性变更
4. 使用 WebSearch 验证不确定的 API

---

## 10. refresh 子命令

如果以 `/setup-engine refresh` 调用：

1. 读取现有的 `docs/engine-reference/<引擎>/VERSION.md`，获取当前引擎和版本
2. 使用 WebSearch 检查：
   - 自上次验证以来发布的新引擎版本
   - 更新后的迁移指南
   - 新近弃用的 API
3. 使用新发现更新所有参考文档
4. 更新所有已修改文件的“最后验证”日期
5. 报告变更内容

---

## 11. upgrade 子命令

如果以 `/setup-engine upgrade [旧版本] [新版本]` 调用：

### 第 1 步 - 读取当前版本状态

读取 `docs/engine-reference/<引擎>/VERSION.md`，确认当前固定版本、风险级别，以及已记录的迁移说明 URL。如果参数中未提供 `旧版本`，则使用该文件中的固定版本。

### 第 2 步 - 获取迁移指南

使用 WebSearch 和 WebFetch 查找 `旧版本` 与 `新版本` 之间的官方迁移指南：

- 搜索：`"[引擎] [旧版本] 到 [新版本] 迁移指南"`
- 搜索：`"[引擎] [新版本] 破坏性变更 更新日志"`
- 如果 VERSION.md 中已记录迁移指南 URL，则获取该 URL；否则使用搜索找到的 URL。

提取：已重命名的 API、已移除的 API、发生变化的默认值、行为变更，以及所有“必须迁移”项。

### 第 3 步 - 升级前审计

扫描 `src/`，查找使用目标版本中已知弃用或变更 API 的代码：

- 使用 Grep 搜索从迁移指南提取的已弃用 API 名称（例如旧函数名、已移除的节点类型、已更改的属性名）
- 列出每个匹配文件及找到的具体 API 引用

以表格形式展示审计结果：

```
升级前审计：[引擎] [旧版本] → [新版本]
===========================================

需要变更的文件：
  文件                               | 发现的已弃用 API           | 工作量
  ---------------------------------- | -------------------------- | ------
  src/gameplay/player_movement.gd    | old_api_name               | 低
  src/ui/hud.gd                      | removed_node_type          | 中

需要关注的破坏性变更：
  - [迁移指南中的变更说明]
  - [迁移指南中的变更说明]

建议迁移顺序（按依赖项排序）：
  1. [依赖最少的系统/层优先]
  2. [下一个系统]
  ...
```

如果在 `src/` 中未找到已弃用的 API，则报告："在 src/ 中未发现已弃用 API 的使用，升级风险可能较低。"

### 第 4 步 - 更新前确认

进行任何变更前询问用户：

> "升级前审计完成。发现 [N] 个文件使用了已弃用的 API。
> 是否继续将 VERSION.md 升级到 [新版本]？
> （这会更新固定版本并添加迁移说明，但不会更改任何源文件。源代码迁移需手动完成或通过故事执行。）"

得到明确确认后才能继续。

### 第 5 步 - 更新 VERSION.md

确认后：

1. 更新 `docs/engine-reference/<引擎>/VERSION.md`：
   - `引擎版本` → `[新版本]`
   - `项目固定日期` → 今天的日期
   - `最后文档验证日期` → 今天的日期
   - 如果新版本超出 LLM 知识截止范围，重新评估并更新`风险级别`和`截止时间后版本时间线`表格
   - 添加 `## 迁移说明 - [旧版本] → [新版本]` 部分，其中包含：迁移指南 URL、关键破坏性变更、项目中发现的已弃用 API，以及审计得出的建议迁移顺序

2. 如果引擎参考目录中存在 `breaking-changes.md` 或 `deprecated-apis.md`，则将新版本的变更追加到这些文件中。

### 第 6 步 - 升级后提醒

更新 VERSION.md 后，输出：

```
VERSION.md 已更新：[引擎] [旧版本] → [新版本]

后续步骤：
1. 迁移上述 [N] 个文件中已弃用 API 的用法
2. 升级实际引擎二进制文件后运行 /setup-engine refresh，确认没有遗漏新的弃用项
3. 运行 /architecture-review，引擎升级可能会使引用特定 API 或引擎能力的 ADR 失效
4. 如果有 ADR 失效，运行 /propagate-design-change 更新下游故事
```

---

## 12. 输出摘要

设置完成后，输出：

```
引擎设置完成
============
引擎：          [名称] [版本]
语言：          [GDScript | C# | GDScript + C# | C# | C++ + Blueprint]
知识风险：      [低/中/高]
参考文档：      [已创建/已跳过]
CLAUDE.md：     [已更新]
技术偏好：      [已创建/已更新]
代理配置：      [已验证]

后续步骤：
1. 审查 docs/engine-reference/<引擎>/VERSION.md
2. [如果来自 /brainstorm] 运行 /map-systems，将游戏概念拆分为独立系统
3. [如果来自 /brainstorm] 运行 /design-system，按引导逐节编写各系统 GDD
4. [如果来自 /brainstorm] 运行 /prototype [核心机制]，在编写 GDD 前验证核心创意
5. [如果是全新开始] 运行 /brainstorm 探索游戏概念
6. 创建第一个里程碑：/sprint-plan new
```

---

结论：**COMPLETE（完成）** - 引擎已配置，参考文档已填充。

## 护栏

- 绝不猜测引擎版本，始终通过 WebSearch 或用户确认进行验证
- 未经询问，绝不覆盖现有参考文档，只能追加或更新
- 如果已存在其他引擎的参考文档，替换前先询问
- 编辑 CLAUDE.md 前，始终向用户展示即将进行的变更
- 如果 WebSearch 返回模糊结果，展示给用户并由用户决定
- 当用户选择 **GDScript** 时：严格复制附录 A1 中的 GDScript CLAUDE.md 模板。绝不在“语言”字段中添加“通过 GDExtension 使用 C++”。GDScript 项目可以使用 GDExtension，但它不是项目的主要语言。路由表中的 `godot-gdextension-specialist` 可在需要原生扩展时使用，但这并不会使 C++ 成为项目语言。

---

## 附录 A - Godot 语言配置

这里包含所有依赖语言的 Godot 专用配置变体，供第 4 节和第 5 节引用，仅在选择 Godot 时适用。使用与第 4 节所选语言匹配的小节。

---

### A1. CLAUDE.md 技术栈模板

**GDScript:**
```markdown
- **引擎**：Godot [版本]
- **语言**：GDScript
- **构建系统**：SCons（引擎）、Godot 导出模板
- **资产管线**：Godot 导入系统 + 自定义资源管线
```

> **护栏**：使用此 GDScript 模板时，“语言”字段必须严格写为“`GDScript`”，不得添加任何内容。不要追加“通过 GDExtension 使用 C++”或任何其他语言。下方 C# 模板包含 GDExtension，是因为 C# 项目通常会封装原生代码，而 GDScript 项目通常不会。

**C#:**
```markdown
- **引擎**：Godot [版本]
- **语言**：C#（.NET 8+，主要），通过 GDExtension 使用 C++（仅限原生插件）
- **构建系统**：.NET SDK + Godot 导出模板
- **资产管线**：Godot 导入系统 + 自定义资源管线
```

**两者都用 - GDScript + C#：**
```markdown
- **引擎**：Godot [版本]
- **语言**：GDScript（玩法/UI 脚本）、C#（性能关键系统）、通过 GDExtension 使用 C++（仅限原生代码）
- **构建系统**：.NET SDK + Godot 导出模板
- **资产管线**：Godot 导入系统 + 自定义资源管线
```

---

### A2. 命名约定

**GDScript：**
- 类：PascalCase（例如 `PlayerController`）
- 变量/函数：snake_case（例如 `move_speed`）
- 信号：使用过去式的 snake_case（例如 `health_changed`）
- 文件：使用与类名匹配的 snake_case（例如 `player_controller.gd`）
- 场景：使用与根节点匹配的 PascalCase（例如 `PlayerController.tscn`）
- 常量：UPPER_SNAKE_CASE（例如 `MAX_HEALTH`）

**C#：**
- 类：PascalCase（`PlayerController`），且必须为 `partial`
- 公共属性/字段：PascalCase（`MoveSpeed`、`JumpVelocity`）
- 私有字段：`_camelCase`（`_currentHealth`、`_isGrounded`）
- 方法：PascalCase（`TakeDamage()`、`GetCurrentHealth()`）
- 信号委托：PascalCase + `EventHandler` 后缀（`HealthChangedEventHandler`）
- 文件：使用与类名匹配的 PascalCase（`PlayerController.cs`）
- 场景：使用与根节点匹配的 PascalCase（`PlayerController.tscn`）
- 常量：PascalCase（`MaxHealth`、`DefaultMoveSpeed`）

**两者都用 - GDScript + C#：**
`.gd` 文件使用 GDScript 约定，`.cs` 文件使用 C# 约定。不存在混合语言文件，语言边界以文件为单位。如果不确定新系统应使用哪种语言，询问用户并将决定记录在 `technical-preferences.md` 中。

---

### A3. 引擎专家路由

**GDScript：**
```markdown
## 引擎专家
- **主要专家**：godot-specialist
- **语言/代码专家**：godot-gdscript-specialist（所有 .gd 文件）
- **着色器专家**：godot-shader-specialist（.gdshader 文件、VisualShader 资源）
- **UI 专家**：godot-specialist（没有专门的 UI 专家，由主要专家负责所有 UI）
- **其他专家**：godot-gdextension-specialist（仅限 GDExtension / 原生 C++ 绑定）
- **路由说明**：架构决策、ADR 验证和横切代码审查调用主要专家。代码质量、信号架构、静态类型强制和 GDScript 惯用法调用 GDScript 专家。材质设计和着色器代码调用着色器专家。仅在涉及原生扩展时调用 GDExtension 专家。

### 文件扩展名路由

| 文件扩展名/类型 | 启动的专家 |
|-----------------|------------|
| 游戏代码（.gd 文件） | godot-gdscript-specialist |
| 着色器/材质文件（.gdshader、VisualShader） | godot-shader-specialist |
| UI/屏幕文件（Control 节点、CanvasLayer） | godot-specialist |
| 场景/预制体/关卡文件（.tscn、.tres） | godot-specialist |
| 原生扩展/插件文件（.gdextension、C++） | godot-gdextension-specialist |
| 常规架构审查 | godot-specialist |
```

**C#：**
```markdown
## 引擎专家
- **主要专家**：godot-specialist
- **语言/代码专家**：godot-csharp-specialist（所有 .cs 文件）
- **着色器专家**：godot-shader-specialist（.gdshader 文件、VisualShader 资源）
- **UI 专家**：godot-specialist（没有专门的 UI 专家，由主要专家负责所有 UI）
- **其他专家**：godot-gdextension-specialist（仅限 GDExtension / 原生 C++ 绑定）
- **路由说明**：架构决策、ADR 验证和横切代码审查调用主要专家。代码质量、[Signal] 委托模式、[Export] 特性、.csproj 管理和 C# 专用 Godot 惯用法调用 C# 专家。材质设计和着色器代码调用着色器专家。仅在涉及原生 C++ 插件时调用 GDExtension 专家。

### 文件扩展名路由

| 文件扩展名/类型 | 启动的专家 |
|-----------------|------------|
| 游戏代码（.cs 文件） | godot-csharp-specialist |
| 着色器/材质文件（.gdshader、VisualShader） | godot-shader-specialist |
| UI/屏幕文件（Control 节点、CanvasLayer） | godot-specialist |
| 场景/预制体/关卡文件（.tscn、.tres） | godot-specialist |
| 项目配置（.csproj、NuGet） | godot-csharp-specialist |
| 原生扩展/插件文件（.gdextension、C++） | godot-gdextension-specialist |
| 常规架构审查 | godot-specialist |
```

**两者都用 - GDScript + C#：**
```markdown
## 引擎专家
- **主要专家**：godot-specialist
- **GDScript 专家**：godot-gdscript-specialist（.gd 文件，玩法/UI 脚本）
- **C# 专家**：godot-csharp-specialist（.cs 文件，性能关键系统）
- **着色器专家**：godot-shader-specialist（.gdshader 文件、VisualShader 资源）
- **UI 专家**：godot-specialist（没有专门的 UI 专家，由主要专家负责所有 UI）
- **其他专家**：godot-gdextension-specialist（仅限 GDExtension / 原生 C++ 绑定）
- **路由说明**：跨语言架构决策以及系统应归属哪种语言时调用主要专家。.gd 文件调用 GDScript 专家。.cs 文件和 .csproj 管理调用 C# 专家。在语言边界上，优先使用信号而不是直接跨语言调用方法。

### 文件扩展名路由

| 文件扩展名/类型 | 启动的专家 |
|-----------------|------------|
| 游戏代码（.gd 文件） | godot-gdscript-specialist |
| 游戏代码（.cs 文件） | godot-csharp-specialist |
| 跨语言边界决策 | godot-specialist |
| 着色器/材质文件（.gdshader、VisualShader） | godot-shader-specialist |
| UI/屏幕文件（Control 节点、CanvasLayer） | godot-specialist |
| 场景/预制体/关卡文件（.tscn、.tres） | godot-specialist |
| 项目配置（.csproj、NuGet） | godot-csharp-specialist |
| 原生扩展/插件文件（.gdextension、C++） | godot-gdextension-specialist |
| 常规架构审查 | godot-specialist |
```
