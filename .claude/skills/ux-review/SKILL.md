---
name: ux-review
description: "验证 UX 规格、HUD 设计或交互模式库的完整性、无障碍合规性、GDD 一致性和实现就绪度。针对具体缺口给出 APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED 结论。"
argument-hint: "[file-path or 'all' or 'hud' or 'patterns']"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: sonnet
agent: ux-designer
---

## 概述

在 UX 设计文档进入实现管线前对其进行验证。
在 `/team-ui` 管线中，充当 UX 设计与视觉设计/实现之间的质量关卡。

**在以下情况运行此技能：**
- 使用 `/ux-design` 完成 UX 规格后
- 移交给 `ui-programmer` 或 `art-director` 之前
- 从 Pre-Production 进入 Production 的关卡检查之前（该检查要求关键界面具备经过评审的 UX 规格）
- UX 规格经过重大修订后

**结论级别：**
- **APPROVED**：规格完整、一致且已可实现
- **NEEDS REVISION**：发现具体缺口；移交前需要修复，但无需全面重新设计
- **MAJOR REVISION NEEDED**：范围、玩家需求或完整性存在根本问题；需要大幅返工

---

## 阶段 1：解析参数

- **具体文件路径**（例如 `/ux-review design/ux/inventory.md`）：验证该文档
- **`all`**：查找并逐一验证 `design/ux/` 中的所有文件
- **`hud`**：专门验证 `design/ux/hud.md`
- **`patterns`**：专门验证 `design/ux/interaction-patterns.md`
- **无参数**：询问用户要验证哪份规格

对于 `all`，先输出汇总表（文件 | 结论 | 主要问题），再输出每个文件的完整详情。

---

## 阶段 2：加载交叉引用上下文

验证任何规格前，加载：

1. **输入与平台配置**：读取 `.claude/docs/technical-preferences.md` 并提取
   `## Input & Platform`。这是游戏支持哪些输入方式的权威来源，应据此执行阶段 3A
   的输入方式覆盖检查，而不是依据规格自身的页头。若尚未配置，则回退到规格页头。
2. `design/accessibility-requirements.md` 中承诺的无障碍级别（如果存在）
3. `design/ux/interaction-patterns.md` 中的交互模式库（如果存在）
4. 规格页头引用的 GDD（读取其中的 UI Requirements 章节）
5. `design/player-journey.md` 中的玩家旅程图（如果存在），用于验证到达情境

---

## 阶段 3A：UX 规格验证清单

对基于 `ux-spec.md` 的文档执行所有检查。

### 完整性（必需章节）

- [ ] 文档页头存在，包含 Status、Author、Platform Target
- [ ] Purpose & Player Need：包含从玩家视角描述的需求陈述（而非开发者视角）
- [ ] Player Context on Arrival：描述玩家的状态和此前活动
- [ ] Navigation Position：说明界面在层级结构中的位置
- [ ] Entry & Exit Points：记录所有进入来源和退出目标
- [ ] Layout Specification：已定义区域，并包含组件清单表
- [ ] States & Variants：至少记录 loading、empty/populated 和 error 状态
- [ ] Interaction Map：覆盖所有目标输入方式（检查页头中的平台目标）
- [ ] Data Requirements：每个显示的数据元素都有来源系统和负责人
- [ ] Events Fired：每个玩家操作都有对应事件或 null 说明
- [ ] Transitions & Animations：至少明确进入/退出过渡效果
- [ ] Accessibility Requirements：包含界面级要求
- [ ] Localization Considerations：为文本元素规定最大字符数
- [ ] Acceptance Criteria：至少包含 5 条具体且可测试的标准

### 质量检查

**玩家需求清晰度**
- [ ] Purpose 从玩家视角而非系统/开发者视角编写
- [ ] 玩家到达时的目标清晰明确（“玩家到达时希望 ___”）
- [ ] 玩家到达时的情境具体明确（不能只有“他们打开了物品栏”）

**状态完整性**
- [ ] 已记录 error 状态（不能只有正常路径）
- [ ] 已记录 empty 状态（无数据场景）
- [ ] 如果界面异步获取数据，已记录 loading 状态
- [ ] 任何包含计时器或自动关闭机制的状态都记录了持续时间

**输入方式覆盖**
- [ ] 如果平台包含 PC：完整规定仅使用键盘的导航方式
- [ ] 如果平台包含主机/手柄：记录方向键导航和正面按键映射
- [ ] 手柄上的任何交互都不要求类似鼠标的精确度
- [ ] 已定义焦点顺序（键盘的 Tab 顺序、手柄的方向键顺序）

**数据架构**
- [ ] 没有任何数据元素将 "UI" 列为负责人（UI 不得拥有游戏状态）
- [ ] 为所有实时数据规定更新频率（不能只有 "realtime"，还需说明由什么触发更新）
- [ ] 为所有数据元素规定 null 处理方式（数据不可用时显示什么？）

**无障碍**
- [ ] 达到或超过 `accessibility-requirements.md` 中的无障碍级别
- [ ] 如果为 Basic 级别：不使用仅靠颜色传达信息的指示器
- [ ] 如果为 Standard 级别及以上：记录焦点顺序并规定文本对比度
- [ ] 如果为 Comprehensive 级别及以上：关键状态变化提供屏幕阅读器播报
- [ ] 色觉障碍检查：所有颜色编码元素都有非颜色替代方案

**GDD 一致性**
- [ ] 规格覆盖页头所引用的每项 GDD UI Requirement
- [ ] 没有任何 UI 元素在缺少对应 GDD 要求的情况下显示或修改游戏状态
- [ ] 规格没有遗漏任何 GDD UI Requirement（交叉检查引用的 GDD 章节）

**模式库一致性**
- [ ] 所有交互组件都引用模式库（或注明它们是新模式）
- [ ] 如果模式库中已有某种模式，不从头重新规定其行为
- [ ] 规格中新创的任何模式都标记为需要加入模式库

**本地化**
- [ ] 所有文本密集型元素都包含字符数限制警告
- [ ] 所有对布局至关重要的文本都标记为需预留 40% 的扩展空间

**验收标准质量**
- [ ] 标准足够具体，未看过设计文档的 QA 测试人员也能执行
- [ ] 包含性能标准（界面在 Xms 内打开）
- [ ] 包含分辨率标准
- [ ] 评估任何标准都不需要阅读其他文档

---

## 阶段 3B：HUD 验证清单

对基于 `hud-design.md` 的文档执行所有检查。

### 完整性

- [ ] 已定义 HUD Philosophy
- [ ] Information Architecture 表涵盖 GDD 中所有包含 UI Requirements 的系统
- [ ] 已定义 Layout Zones，并包含所有目标平台的安全区边距
- [ ] 每个 HUD 元素都有完整规格（区域、可见性触发条件、数据源、优先级）
- [ ] HUD States by Gameplay Context 至少涵盖：探索、战斗、对话/过场动画、暂停
- [ ] 已定义 Visual Budget（同时显示的最大元素数量、占屏幕面积的最大百分比）
- [ ] Platform Adaptation 涵盖所有目标平台
- [ ] 玩家可调整的元素包含 Tuning Knobs

### 质量检查

- [ ] 没有任何 HUD 元素在缺少隐藏规则的情况下遮挡画面中央的游玩区域
- [ ] 任一 GDD 中存在的每条信息都已纳入 HUD，或明确归类为 "hidden/demand"
- [ ] 所有使用颜色编码的 HUD 元素都有色觉障碍适配变体
- [ ] Feedback & Notification 章节中的 HUD 元素已定义队列/优先级行为
- [ ] 符合 Visual Budget：同时显示的元素总数未超出预算

### GDD 一致性

- [ ] `design/gdd/systems-index.md` 中所有归为 UI 类别的系统都在 HUD 中有所体现（或有合理的缺席理由）

---

## 阶段 3C：模式库验证清单

- [ ] 模式目录索引为最新版本（与文档中的实际模式一致）
- [ ] 已规定所有标准控件模式：按钮变体、开关、滑块、下拉菜单、列表、网格、模态框、
  对话框、Toast、工具提示、进度条、输入字段、标签栏、滚动
- [ ] 包含当前 UX 规格所需的所有游戏特定模式
- [ ] 每种模式都包含：When to Use、When NOT to Use、完整状态规格、无障碍规格、实现说明
- [ ] 包含 Animation Standards 表
- [ ] 包含 Sound Standards 表
- [ ] 模式之间没有冲突行为（例如，所有导航模式中的 "Back" 行为保持一致）

---

## 阶段 4：输出结论

```markdown
## UX 评审：[Document Name]
**日期**：[date]
**评审者**：ux-review skill
**文档**：[file path]
**平台目标**：[from header]
**无障碍级别**：[from header or accessibility-requirements.md]

### 完整性：[X/Y sections present]
- [x] Purpose & Player Need
- [ ] States & Variants：缺失：未记录 error 状态

### 质量问题：[N found]
1. **[Issue title]** [BLOCKING / ADVISORY]
   - 问题：[specific description]
   - 位置：[section name]
   - 修复方式：[specific action to take]

### GDD 一致性：[ALIGNED / GAPS FOUND]
- GDD [name] UI Requirements：[X/Y requirements covered]
- 缺失项：[list any uncovered GDD requirements]

### 无障碍：[COMPLIANT / GAPS / NON-COMPLIANT]
- 目标级别：[tier]
- [list specific accessibility findings]

### 模式库：[CONSISTENT / INCONSISTENCIES FOUND]
- [findings]

### 结论：APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED
**阻塞问题**：[N]：必须在实现前解决
**建议问题**：[N]：建议解决，但不构成阻塞

[For APPROVED]：此规格已可移交给 `/team-ui` 阶段 2（视觉设计）。

[For NEEDS REVISION]：解决以上 [N] 个阻塞问题，然后重新运行 `/ux-review`。

[For MAJOR REVISION NEEDED]：规格在 [areas] 方面存在根本缺口。
建议返回 `/ux-design` 重新设计 [sections]。
```

---

## 阶段 5：协作协议

此技能为 READ-ONLY，不会编辑或写入文件，只报告发现的问题。

给出结论后：
- 对于 **APPROVED**：建议运行 `/team-ui` 以开始协调实现
- 对于 **NEEDS REVISION**：提出协助修复具体缺口（“需要我帮忙起草缺失的 error 状态吗？”），
  但不要自动修复；等待用户指示
- 对于 **MAJOR REVISION NEEDED**：建议返回 `/ux-design`，并指出需要重新设计的具体章节

绝不阻止用户继续推进，结论仅供参考。记录风险、陈述发现的问题，并由用户决定是否在存在疑虑的情况下继续。
如果用户选择基于 NEEDS REVISION 规格继续推进，则由其承担已记录的风险。
