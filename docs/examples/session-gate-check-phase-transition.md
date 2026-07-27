# 示例会话：/gate-check 阶段转换 — 系统设计 → 技术设置

**背景：** 独立开发者单人开发，第 5 周末。系统设计阶段看起来已经完成：已编写 6 份 MVP GDD，完成交叉审查，也已配置引擎。用户希望正式进入技术设置。

**起始状态：**
- `production/stage.txt` — 当前为 `systems-design`
- `design/gdd/systems-index.md` — 列出 6 个 MVP 系统，全部标记为 `Status: GDD Complete`
- `design/gdd/` — 存在 6 份 GDD 文件
- `design/gdd/gdd-cross-review-2026-03-10.md` — 交叉审查报告，结论：CONCERNS（1 条低优先级备注）
- 已配置引擎（Godot 4.6，`/setup-engine` 已完成）

**会话时长：**约 20 分钟
**轮次：**7
**结果：** 门禁通过，`stage.txt` 已更新为 `technical-setup`，并获得明确的后续事项列表

---

## 第 1 轮：用户发起门禁检查

**用户：**
> /gate-check

## 第 2 轮：代理检测当前阶段并执行检查

**代理（通过 /gate-check）：**
> 正在读取 `production/stage.txt` — 当前阶段：**systems-design**
>
> 正在运行门禁：**系统设计 → 技术设置**
>
> ---
> **必需产物清单：**
>
> | 产物 | 要求 | 状态 |
> |----------|-------------|--------|
> | `design/gdd/systems-index.md` | 存在且列出所有 MVP 系统 | ✅ |
> | 各系统 GDD | 所有 MVP 系统都有 GDD | ✅ (6/6) |
> | 每份 GDD 的 `/design-review` | 每份 GDD 都已审查 | ✅（找到 6/6 条审查意见） |
> | GDD 交叉审查报告 | 存在 `design/gdd/gdd-cross-review-*.md` | ✅ |
> | 交叉审查结论 | PASS 或 CONCERNS（不能是 FAIL） | ✅ CONCERNS |
> | 引擎已配置 | `production/stage.txt` 或 CLAUDE.md 中有引擎条目 | ✅ Godot 4.6 |
>
> ---
> **内容扫描：**
>
> 正在检查 GDD 完整性（每份包含 8 个必需章节）……
>
> | GDD | 缺失章节 |
> |-----|-----------------|
> | movement-system.md | None ✅ |
> | stamina-system.md | None ✅ |
> | combat-system.md | None ✅ |
> | inventory-system.md | None ✅ |
> | crafting-system.md | None ✅ |
> | exploration-system.md | None ✅ |
>
> ---
> **交叉审查问题（来自 `gdd-cross-review-2026-03-10.md`）：**
>
> 1. ⚠️ LOW — Crafting 和 inventory 分别定义了“item stack size”，且默认值不同（crafting：99，inventory：64）。应由一个系统作为权威，另一个系统引用它。不构成阻塞，可在 ADR 中解决。
>
> ---
> **结论：PASS**
>
> 所有必需产物均已存在。交叉审查问题的严重程度为 LOW，可以在技术设置阶段通过 ADR 解决。这是当前阶段的正常发现。
>
> **我可以将 `production/stage.txt` 推进到 `technical-setup` 吗？**

## 第 3 轮：用户确认

**用户：**
> 是的，推进吧。

## 第 4 轮：代理更新阶段并介绍下一步

**代理：**
> 已更新 `production/stage.txt` → `technical-setup`
>
> ---
> **你现在处于：技术设置**
>
> 本阶段将在生产编码开始前建立技术基础。目标是形成一份完整且获批准的架构，让预制作阶段编写的每个故事都有清晰、明确的技术指导。
>
> **本阶段的必需步骤（按顺序）：**
>
> 1. **`/create-architecture`** — 编写主架构文档，涵盖系统分解、数据流、层边界和模块职责。
>
> 2. **`/architecture-decision`（每项重大技术选择一个）** — 至少包括：
>    - 渲染方案（2D 摄像机、视口等）
>    - 保存/加载策略
>    - 音频总线架构
>    - 交叉审查提出的“物品堆叠大小权威”问题（制作系统与库存系统）
>
> 3. **`/architecture-review`** — 验证所有 ADR 的完整性、依赖顺序和 GDD 可追溯性，并生成 TR-registry。
>
> 4. **`/create-control-manifest`** — 将 Accepted ADR 转换为扁平的程序员规则表，供实现代理编码时查阅。
>
> 5. **`/gate-check`** — 技术设置 → 预制作门禁。要求具备架构文档、全部 ADR 为 Accepted、控制清单，并解决依赖顺序。
>
> **可选但推荐：**
> - 如果有计划保留的原型代码，运行 `/tech-debt` 扫描
> - 如果还没有获取 Godot 4.6 API 快照，重新运行 `/setup-engine`
>
> **提示：** 先用 `/architecture-decision` 处理物品堆叠大小冲突。这是一个快速收尾事项，可以在该问题给后续两份 ADR 造成歧义前关闭这个开放问题。

## 第 5 轮：用户询问交叉审查问题

**用户：**
> 关于堆叠大小冲突，我在 ADR 中究竟应该写什么？

## 第 6 轮：代理提供建议

**代理：**
> ADR 要决定的是：**哪个系统拥有规范的 `max_stack_size` 值？**
>
> 可以考虑两个选项：
>
> **选项 A：由 Inventory 所有**
> - `ItemData` resource（由库存系统拥有）获得 `max_stack_size: int = 64`
> - 制作系统从 `ItemData` 读取，不设置自己的值
> - 优点：库存系统是所有物品属性的权威来源
> - 缺点：制作团队需要知道应查阅库存数据
>
> **选项 B：由 Item data resource 所有（共享资源）**
> - `ItemData.max_stack_size` 是两个系统共同遵循的权威值
> - 制作系统和库存系统都从 `ItemData` 导入
> - 优点：单一来源，制作模块与库存模块之间没有耦合
> - 缺点：共享数据层中多出一项内容
>
> 当超过 2 个系统会访问物品数据时，大多数工作室会选择 B（共享资源）。但对于单人项目，两种方案都合理。
>
> 运行 `/architecture-decision`，它会引导你完成 ADR 格式，包括将此 ADR 链接回两份 GDD 的依赖项章节。

## 第 7 轮：用户结束会话

**用户：**
> 明白了。我会从 /architecture-decision 开始处理。

**代理：**
> 这是个很好的起点。ADR 会记录决策、理由以及它所覆盖的 GDD 需求，这样几个月后编写代码时，背后的依据仍然清楚。
>
> 你的阶段门禁已记录。在技术设置期间随时运行 `/help`，即可查看相对于必需清单的当前进度。

---

## 这个示例展示了什么

- **门禁检查是自动的，而不是手动的**：代理读取并检查产物，用户不需要填写表格
- **CONCERNS ≠ FAIL**：交叉审查问题的严重程度为 LOW，仍可通过门禁。FAIL 则必须解决后才能推进。
- **Stage.txt 是权威来源**：状态行、`/help` 和所有技能都从 `production/stage.txt` 读取，在此更新会改变后续所有技能看到的阶段
- **下一步与阶段相关**：代理不会泛泛地说“祝你好运”，而是给出技术设置阶段专属的有序清单
- **门禁检查会暴露遗留工作**：堆叠大小冲突原本只是交叉审查备注，门禁检查确保它变成具体 ADR，而不是被遗忘
- **每个门禁只推进一次**：用户明确确认了推进。门禁不会自动推进，必须由人确认。
