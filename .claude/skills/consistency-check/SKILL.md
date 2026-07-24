---
name: consistency-check
description: "对照实体注册表扫描所有 GDD，以检测跨文档不一致：同一实体的属性不同、同一物品的数值不同、同一公式的变量不同。采用 Grep 优先方法：先读取注册表，再仅定位存在冲突的 GDD 章节，而不是读取完整文档。"
argument-hint: "[full | since-last-review | entity:<name> | item:<name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# 一致性检查

通过对照实体注册表（`design/registry/entities.yaml`）比较所有 GDD，检测跨文档
不一致。采用 Grep 优先方法：读取注册表一次，然后仅定位提及已注册名称的 GDD
章节；除非需要调查冲突，否则不读取完整文档。

**本技能是写作时的安全网。** 它会捕获 `/design-system` 的逐章节检查可能遗漏、
而 `/review-all-gdds` 的整体审查发现得太晚的问题。

**运行时机：**
- 每写完一个新 GDD 后（在转向下一个系统之前）
- `/review-all-gdds` 之前（使该技能从干净的基线开始）
- `/create-architecture` 之前（不一致会污染下游 ADR）
- 按需运行：使用 `/consistency-check entity:[name]` 专门检查一个实体

**输出：** 冲突报告 + 可选的注册表修正

---

## 阶段 1：解析参数并加载注册表

**模式：**
- 无参数 / `full`：对照所有 GDD 检查所有已注册条目
- `since-last-review`：仅检查自上次审查报告以来修改过的 GDD
- `entity:<name>`：在所有 GDD 中检查一个指定实体
- `item:<name>`：在所有 GDD 中检查一个指定物品

**加载注册表：**

```
Read path="design/registry/entities.yaml"
```

如果文件不存在或没有条目：
> “实体注册表为空。请运行 `/design-system` 编写 GDD；每个 GDD 完成后，注册表
> 会自动填充。目前没有可检查的内容。”

停止并退出。

根据注册表构建四个查找表：
- **entity_map**: `{ name → { source, attributes, referenced_by } }`
- **item_map**: `{ name → { source, value_gold, weight, ... } }`
- **formula_map**: `{ name → { source, variables, output_range } }`
- **constant_map**: `{ name → { source, value, unit } }`

统计已注册条目总数。报告：
```
注册表已加载：[N] 个实体、[N] 个物品、[N] 个公式、[N] 个常量
范围：[full | since-last-review | entity:name]
```

---

## 阶段 2：定位范围内的 GDD

```
Glob pattern="design/gdd/*.md"
```

排除：`game-concept.md`、`systems-index.md`、`game-pillars.md`；这些不是系统 GDD。

对于 `since-last-review` 模式：
```bash
git log --name-only --pretty=format: -- design/gdd/ | grep "\.md$" | sort -u
```
仅保留自最近的 `design/gdd/gdd-cross-review-*.md` 文件创建日期以来修改过的 GDD。

扫描前报告范围内的 GDD 列表。

---

## 阶段 3：Grep 优先冲突扫描

对于每个已注册条目，在每个范围内的 GDD 中 Grep 该条目的名称。
不要读取完整文档；仅提取匹配行及其紧邻上下文（`-C 3` 行）。

这是核心优化：不读取 10 个 GDD × 每个 400 行（共 4,000 行），而是对 50 个
实体名称 × 10 个 GDD 执行 Grep（50 次定向搜索，每次命中返回约 10 行）。

### 3a：实体扫描

对于 entity_map 中的每个实体：

```
Grep pattern="[entity_name]" glob="design/gdd/*.md" output_mode="content" -C 3
```

对于每个命中的 GDD，提取实体名称附近提到的值：
- 任何数值属性（数量、成本、持续时间、范围、比率）
- 任何分类属性（类型、层级、类别）
- 任何派生值（总数、输出、结果）
- entity_map 中注册的任何其他属性

将提取的值与注册表条目进行比较。

**冲突检测：**
- 注册表声明 `[entity_name].[attribute] = [value_A]`，GDD 声明 `[entity_name]` 的值为 `[value_B]`。→ **CONFLICT**
- 注册表声明 `[item_name].[attribute] = [value_A]`，GDD 声明 `[item_name]` 为 `[value_B]`。→ **CONFLICT**
- GDD 提及 `[entity_name]`，但未指定该属性。→ **NOTE**（没有冲突，只是无法验证）

### 3b：物品扫描

对于 item_map 中的每个物品，在所有 GDD 中 Grep 物品名称。提取：
- 售价 / 价值 / 金币价值
- 重量
- 堆叠规则（可堆叠 / 不可堆叠）
- 类别

与注册表条目值进行比较。

### 3c：公式扫描

对于 formula_map 中的每个公式，在所有 GDD 中 Grep 公式名称。提取：
- 公式附近提到的变量名称
- 提到的输出范围或上限值

与注册表条目进行比较：
- 变量名称不同 → **CONFLICT**
- 输出范围表述不同 → **CONFLICT**

### 3d：常量扫描

对于 constant_map 中的每个常量，在所有 GDD 中 Grep 常量名称。提取：
- 常量名称附近提到的任何数值

与注册表值进行比较：
- 数字不同 → **CONFLICT**

---

## 阶段 4：深入调查（仅限冲突）

对于阶段 3 中发现的每个冲突，定向读取冲突 GDD 的完整章节，以获取准确上下文：

```
Read path="design/gdd/[conflicting_gdd].md"
```
（如果文件很大，也可使用具有更宽上下文的 Grep）

结合完整上下文确认冲突。确定：
1. **哪个 GDD 正确？** 检查注册表中的 `source:` 字段；源 GDD 是权威所有者。
   任何与其矛盾的其他 GDD 都需要更新。
2. **注册表本身是否过时？** 如果源 GDD 在注册表条目写入后更新过（检查 git log），
   注册表可能已过时。
3. **这是否是真正的设计变更？** 如果冲突代表有意的设计决策，解决方式是：更新源
   GDD、更新注册表，然后修正所有其他 GDD。

对每个冲突进行分类：
- **🔴 CONFLICT**：同名实体/物品/公式/常量在不同 GDD 中具有不同的值。
  必须在架构工作开始前解决。
- **⚠️ STALE REGISTRY**：源 GDD 的值已更改，但注册表未更新。
  需要更新注册表；其他 GDD 可能已经正确。
- **ℹ️ UNVERIFIABLE**：提及了实体，但未说明可比较的属性。
  这不是冲突，只是记录该引用。

---

## 阶段 5：输出报告

```
## 一致性检查报告
日期：[date]
已检查的注册表条目：[N 个实体、N 个物品、N 个公式、N 个常量]
已扫描的 GDD：[N]（[名称列表]）

---

### 发现的冲突（必须在架构工作开始前解决）

🔴 [实体/物品/公式/常量名称]
   注册表（source: [gdd]）：[attribute] = [value]
   [other_gdd].md 中的冲突：[attribute] = [different_value]
   → 需要解决：[要更改的文档及目标内容]

---

### 过时的注册表条目（注册表落后于 GDD）

⚠️ [条目名称]
   注册表声明：[value]（写于 [date]）
   源 GDD 现在声明：[新值]
   → 更新注册表条目以匹配源 GDD，然后检查 referenced_by 文档。

---

### 无法验证的引用（无冲突，仅供参考）

ℹ️ [gdd].md 提及 [entity_name]，但未说明可比较的属性。
   未检测到冲突。无需操作。

---

### 无问题条目（未发现问题）

✅ 已在所有 GDD 中验证 [N] 个注册表条目，未发现冲突。

---

Verdict: PASS | CONFLICTS FOUND
```

**结论：**
- **PASS**：无冲突。注册表与 GDD 对所有已检查的值均一致。
- **CONFLICTS FOUND**：检测到一个或多个冲突。列出解决步骤。

---

## 阶段 6：修正注册表

如果发现过时的注册表条目，询问：
> “可以更新 `design/registry/entities.yaml` 以修正 [N] 个过时条目吗？”

对于每个过时条目：
- 更新 `value` / 属性字段
- 将 `revised:` 设为今天的日期
- 添加包含旧值的 YAML 注释：`# 原值：[old_value]，更改前日期：[date]`

如果在 GDD 中发现注册表尚未收录的新条目，询问：
> “发现 GDD 中提到的 [N] 个实体/物品尚未进入注册表。
> 可以将其添加到 `design/registry/entities.yaml` 吗？”

仅添加出现在多个 GDD 中的条目（真正的跨系统事实）。

**绝不删除注册表条目。** 如果某个条目已从所有 GDD 中移除，请设置
`status: deprecated`。

写入后：Verdict: **COMPLETE**：一致性检查已完成。
如果仍有冲突未解决：Verdict: **BLOCKED**：[N] 个冲突需要在架构工作开始前手动解决。

### 6b：追加到反思日志

如果发现任何 🔴 CONFLICT 条目（无论是否已解决），请为每个冲突向
`docs/consistency-failures.md` 追加一个条目：

```markdown
### [YYYY-MM-DD] — /consistency-check — 🔴 CONFLICT
**Domain**: [涉及的系统领域]
**Documents involved**: [源 GDD] vs [冲突 GDD]
**What happened**: [具体冲突：实体名称、属性、不同的值]
**Resolution**: [如何修正，或“未解决：需要手动操作”]
**Pattern**: [一般化经验，例如“战斗 GDD 中定义的物品数值在编写经济 GDD 前未被
引用；务必先检查 entities.yaml”]
```

如果 `docs/consistency-failures.md` 不存在，请先使用以下文件头创建该文件，再追加内容：

```markdown
# 一致性失败日志

<!-- 由 /consistency-check 自动维护。请勿手动编辑。 -->
<!-- 每个检测到的冲突对应一个条目，按时间顺序排列。 -->

| Date | GDD A | GDD B | Conflict Type | Status |
|------|-------|-------|---------------|--------|
```

然后追加新的冲突条目。绝不能跳过记录；文件缺失不是丢失冲突历史的理由。

---

## 阶段 7：会话状态与结束

展示拟追加的会话状态摘要，并使用 `AskUserQuestion` 询问用户是否可以更新 `production/session-state/active.md`。获得批准后，追加以下内容（如果文件不存在则创建）：

```
<!-- CONSISTENCY-CHECK: [date] | GDDs checked: [N] | Conflicts found: [N] | Report: docs/consistency-report-[date].md -->
```

然后使用 `AskUserQuestion` 组件结束：

- **Prompt**：“一致性检查完成，发现 [N] 个冲突。下一步做什么？”
- **Options**：
  - `[A] 立即修正优先级最高的冲突`
  - `[B] 保存完整报告并停止`
  - `[C] 对冲突最多的 GDD 运行 /design-review`
  - `[D] 在此停止`

绝不能以纯文本结束本技能。始终使用此组件结束。

---

## 恢复 / 参考

- **如果为 PASS**：运行 `/review-all-gdds` 进行整体设计理论审查；如果所有 MVP GDD
  均已完成，则运行 `/create-architecture`。
- **如果为 CONFLICTS FOUND**：修正已标记的 GDD，然后重新运行
  `/consistency-check` 以确认问题已解决。
- **如果为 STALE REGISTRY**：更新注册表（阶段 6），然后重新运行以验证。
- 每写完一个新 GDD 后运行 `/consistency-check`，尽早发现问题，而不是等到架构阶段。
