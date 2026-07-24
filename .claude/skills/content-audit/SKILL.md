---
name: content-audit
description: "审计 GDD 规定的内容数量与已实现内容，识别计划内容与已构建内容之间的差异。"
argument-hint: "[system-name | --summary | (无参数 = 完整审计)]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: sonnet
agent: producer
---

调用此技能时：

解析参数：
- 无参数 → 对所有系统执行完整审计
- `[system-name]` → 仅审计该单个系统
- `--summary` → 仅输出汇总表，不写入文件

---

## 阶段 1 — 上下文收集

1. **读取 `design/gdd/systems-index.md`**，获取完整的系统列表、系统类别和
   MVP/优先级层级。

2. **L0 预扫描**：在完整读取任何 GDD 之前，使用 Grep 在所有 GDD 文件中查找
   `## Summary` 章节及常见的内容数量关键词：
   ```
   Grep pattern="(## Summary|N enemies|N levels|N items|N abilities|enemy types|item types)" glob="design/gdd/*.md" output_mode="files_with_matches"
   ```
   对于单系统审计：跳过此步骤，直接完整读取。
   对于完整审计：仅完整读取匹配到内容数量关键词的 GDD。
   对于不含内容数量表述的 GDD（纯机制 GDD），无需完整读取，标注为
   “没有可审计的内容数量”。

3. **完整读取范围内的 GDD 文件**（如果提供了系统名称，则读取该单个系统的
   GDD）。

4. **从每个 GDD 中提取明确的内容数量或列表。** 查找以下
   模式：
   - “N 个敌人” / “敌人类型：” / 具名敌人列表
   - “N 个关卡” / “N 个区域” / “N 张地图” / “N 个阶段”
   - “N 件物品” / “N 件武器” / “N 件装备”
   - “N 个能力” / “N 个技能” / “N 个法术”
   - “N 个对话场景” / “N 段对话” / “N 个过场动画”
   - “N 个任务” / “N 个使命” / “N 个目标”
   - 任何明确的枚举列表（具名内容项的项目符号列表）

4. **根据提取的数据构建内容清单表**：

   | System | Content Type | Specified Count/List | Source GDD |
   |--------|-------------|---------------------|------------|

   注意：如果 GDD 仅定性描述内容而未给出数量，则记录为
   `Unspecified` 并进行标记，因为未明确数量是值得关注的设计缺口。

---

## 阶段 2 — 实现扫描

对于阶段 1 中发现的每种内容类型，扫描相关目录并统计已实现内容。
使用 Glob 和 Grep 定位文件。

**关卡 / 区域 / 地图：**
- Glob `assets/**/*.tscn`, `assets/**/*.unity`, `assets/**/*.umap`
- Glob `src/**/*.tscn`, `src/**/*.unity`
- 在名为 `levels/`、`areas/`、`maps/`、`worlds/`、`stages/` 的子目录中
  查找场景文件
- 统计看似属于关卡/场景定义的唯一文件（不包括 UI 场景）

**敌人 / 角色 / NPC：**
- Glob `assets/data/**/enemies/**`, `assets/data/**/characters/**`
- Glob `src/**/enemies/**`, `src/**/characters/**`
- 查找定义实体属性的 `.json`、`.tres`、`.asset`、`.yaml` 数据文件
- 在角色子目录中查找场景/预制体文件

**物品 / 装备 / 战利品：**
- Glob `assets/data/**/items/**`, `assets/data/**/equipment/**`,
  `assets/data/**/loot/**`
- 查找 `.json`、`.tres`、`.asset` 数据文件

**能力 / 技能 / 法术：**
- Glob `assets/data/**/abilities/**`, `assets/data/**/skills/**`,
  `assets/data/**/spells/**`
- 查找 `.json`、`.tres`、`.asset` 数据文件

**对白 / 对话 / 过场动画：**
- Glob `assets/**/*.dialogue`, `assets/**/*.csv`, `assets/**/*.ink`
- 使用 Grep 在 `assets/data/` 中查找对话数据文件

**任务 / 使命：**
- Glob `assets/data/**/quests/**`, `assets/data/**/missions/**`
- 查找 `.json`、`.yaml` 定义文件

**引擎特定说明（需在报告中注明）：**
- 统计结果为近似值，此技能无法完美解析每种引擎格式，也无法区分仅供编辑器使用的
  文件与已发布内容
- 场景文件可能同时包含游戏内容和系统/UI 场景；扫描会统计所有匹配项，
  并注明此限制

---

## 阶段 3 — 缺口报告

生成缺口表：

```
| System | Content Type | Specified | Found | Gap | Status |
|--------|-------------|-----------|-------|-----|--------|
```

**Status 类别：**
- `COMPLETE` — Found ≥ Specified（100% 及以上）
- `IN PROGRESS` — Found 为 Specified 的 50–99%
- `EARLY` — Found 为 Specified 的 1–49%
- `NOT STARTED` — Found 为 0

**优先级标记：**
如果满足以下条件，则在报告中将系统标记为 `HIGH PRIORITY`：
- Status 为 `NOT STARTED` 或 `EARLY`，并且
- 系统在系统索引中标记为 MVP 或 Vertical Slice，或者
- 系统索引表明该系统正在阻塞下游系统

**汇总行：**
- 规定的内容项总数（所有 Specified 列值之和）
- 找到的内容项总数（所有 Found 列值之和）
- 总体缺口百分比：`(Specified - Found) / Specified * 100`

---

## 阶段 4 — 输出

### 完整审计和单系统模式

向用户展示缺口表和汇总。询问：“可以将完整报告写入 `docs/content-audit-[YYYY-MM-DD].md` 吗？”

如果同意，则写入文件：

```markdown
# Content Audit — [Date]

## Summary
- **Total specified**: [M] 个系统中的 [N] 个内容项
- **Total found**: [N]
- **Gap**: [N] 个内容项（[X%] 尚未实现）
- **Scope**: [Full audit | System: name]

> 注意：数量是根据文件扫描得出的近似值。
> 审计无法区分已发布内容与编辑器/测试资产。
> 建议手动验证所有 HIGH PRIORITY 缺口。

## Gap Table

| System | Content Type | Specified | Found | Gap | Status |
|--------|-------------|-----------|-------|-----|--------|

## HIGH PRIORITY Gaps

[列出标记为 HIGH PRIORITY 的系统及理由]

## Per-System Breakdown

### [System Name]
- **GDD**: `design/gdd/[file].md`
- **Content types audited**: [list]
- **Notes**: [关于此系统扫描准确性的任何限制说明]

## Recommendation

重点将实现工作投入到：
1. [缺口最大的 HIGH PRIORITY 系统]
2. [第二个系统]
3. [第三个系统]

## Unspecified Content Counts

以下 GDD 描述了内容，但未给出明确数量。
考虑补充数量以提高可审计性：
[列出包含 `Unspecified` 的 GDD 和内容类型]
```

写入报告后，询问：

> “是否要为其中的内容缺口创建待办故事？”

如果同意：对于用户选择的每个系统，建议一个故事标题，并根据缺口大小引导用户
使用 `/create-stories [epic-slug]` 或 `/quick-design`。

### --summary 模式

直接在对话中输出 Gap Table 和 Summary。不要写入文件。
最后提示：“运行不带 `--summary` 的 `/content-audit` 以写入完整报告。”

---

## 阶段 5 — 后续步骤

审计后，推荐价值最高的后续操作：

- 如果有任何系统为 `NOT STARTED` 且标记为 MVP → “运行 `/design-system [name]`，
  在实现开始前向 GDD 补充缺失的内容数量。”
- 如果总缺口大于 50% → “运行 `/sprint-plan`，将内容工作分配到即将开展的迭代中。”
- 如果需要待办故事 → “针对每个 HIGH PRIORITY 缺口运行 `/create-stories [epic-slug]`。”
- 如果使用了 `--summary` → “运行不带标志的 `/content-audit`，将完整报告写入 `docs/`。”

Verdict: **COMPLETE** — 内容审计已完成。
