# 技能测试规范：/balance-check

## 技能摘要

`/balance-check` 读取平衡性数据文件（`assets/data/` 中的 JSON 或 YAML），并依据
`design/gdd/` 下 GDD 中定义的设计公式检查每个值。它生成包含“值 → 公式 → 偏差 →
严重程度”列的发现表。不调用总监门禁（只读分析）。技能可以选择写入平衡性报告，
但写入前会询问 "May I write"。结论为：BALANCED、CONCERNS 或 OUT OF BALANCE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：BALANCED、CONCERNS、OUT OF BALANCE
- [ ] 包含 "May I write" 措辞（可选报告写入）
- [ ] 包含下一步交接（审查发现后要做什么）

---

## 总监门禁检查

无。平衡性检查是只读分析技能，不调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——所有平衡值均在公式容差内

**测试夹具：**
- `assets/data/combat-balance.json` 存在，包含 6 个属性值
- `design/gdd/combat-system.md` 包含全部 6 个属性的公式，容差为 ±10%
- 全部 6 个值均在容差内

**输入：** `/balance-check`

**预期行为：**
1. 技能读取 `assets/data/` 中的所有平衡性数据文件
2. 技能从 `design/gdd/` 读取 GDD 公式
3. 技能计算每个值相对于其公式的偏差
4. 所有偏差均在 ±10% 容差内
5. 技能输出发现表，所有行均显示 PASS
6. 结论为 BALANCED

**断言：**
- [ ] 发现表涵盖所有已检查值
- [ ] 每行显示：属性名、公式目标值、实际值、偏差百分比
- [ ] 在容差内时，所有行均显示 PASS 或同等结果
- [ ] 结论为 BALANCED
- [ ] 未经用户批准不写入任何文件

---

### 用例 2：失衡——玩家伤害比公式目标高 40%

**测试夹具：**
- `assets/data/combat-balance.json` 中有 `player_damage_base: 140`
- `design/gdd/combat-system.md` 的公式指定 `player_damage_base = 100`（±10%）
- 其他所有属性均在容差内

**输入：** `/balance-check`

**预期行为：**
1. 技能读取 `combat-balance.json` 并计算 `player_damage_base` 的偏差
2. 偏差为 +40%，远超 ±10% 容差
3. 技能在发现表中将此行严重程度标记为 HIGH
4. 结论为 OUT OF BALANCE
5. 技能在表格前醒目展示 HIGH 严重程度项

**断言：**
- [ ] `player_damage_base` 行显示 +40% 偏差
- [ ] 偏差超出容差 2 倍以上时，严重程度为 HIGH
- [ ] 任一属性存在 HIGH 严重程度偏差时，结论为 OUT OF BALANCE
- [ ] 明确指出 HIGH 严重程度项，不将其埋在表格行中

---

### 用例 3：无 GDD 公式——无法验证并给出指引

**测试夹具：**
- `assets/data/economy-balance.yaml` 存在，包含 10 个属性值
- `design/gdd/` 中没有 GDD 包含经济属性的公式定义

**输入：** `/balance-check`

**预期行为：**
1. 技能读取平衡性数据文件
2. 技能在 GDD 中搜索公式定义，未找到经济属性的公式
3. 技能输出：“无法验证经济属性：未定义公式。请先运行 `/design-system`。”
4. 不为经济属性生成发现表
5. 结论为 CONCERNS（数据存在但无法验证）

**断言：**
- [ ] GDD 中不存在公式目标时，技能不捏造目标
- [ ] 输出明确指出缺失的公式来源
- [ ] 输出建议运行 `/design-system` 定义公式
- [ ] 结论为 CONCERNS（不能验证，因此不是 BALANCED）

---

### 用例 4：孤立引用——平衡性文件引用未定义属性

**测试夹具：**
- `assets/data/combat-balance.json` 包含属性 `legacy_armor_mult: 1.5`
- `design/gdd/combat-system.md` 没有 `legacy_armor_mult` 的公式
- 其他所有属性均有公式定义并通过验证

**输入：** `/balance-check`

**预期行为：**
1. 技能读取 `combat-balance.json` 中的所有属性
2. 技能在任何 GDD 中均找不到 `legacy_armor_mult` 的公式
3. 技能在发现表中将 `legacy_armor_mult` 标记为 ORPHAN REFERENCE
4. 正常评估其他属性；容差内的属性显示 PASS
5. 结论为 CONCERNS（孤立引用导致无法完整验证）

**断言：**
- [ ] `legacy_armor_mult` 在发现表中显示为 ORPHAN REFERENCE 状态
- [ ] 表中将孤立引用与公式偏差区分开
- [ ] 发现任何孤立引用时，结论为 CONCERNS
- [ ] 技能不会静默跳过孤立属性

---

### 用例 5：门禁合规——只读；不调用门禁；可选报告需要批准

**测试夹具：**
- 平衡性数据和 GDD 公式均存在；1 个属性存在 CONCERNS 级偏差（高于目标 15%）
- `review-mode.txt` 包含 `full`

**输入：** `/balance-check`

**预期行为：**
1. 技能读取数据和 GDD，并生成发现表
2. 结论为 CONCERNS（一个属性略微超出范围）
3. 不调用总监门禁
4. 技能向用户展示发现表
5. 技能询问是否写入可选平衡性报告
6. 如果用户同意，技能询问："May I write to `production/qa/balance-report-[date].md`?"
7. 如果用户拒绝，技能结束且不写入

**断言：**
- [ ] 任何审查模式下均不调用总监门禁
- [ ] 展示发现表，但不自动写入任何内容
- [ ] 提供但不强制写入可选报告
- [ ] 仅当用户选择写入报告时才显示 "May I write" 提示

---

## 协议合规性

- [ ] 分析前同时读取平衡性数据文件和 GDD 公式
- [ ] 发现表显示“值”“公式”“偏差”和“严重程度”列
- [ ] 未经用户明确批准不写入任何文件
- [ ] 不调用总监门禁
- [ ] 结论为 BALANCED、CONCERNS、OUT OF BALANCE 之一

---

## 覆盖说明

- 此处未测试 `assets/data/` 完全为空的情况；其行为遵循 CONCERNS 模式，
  并提示未找到数据文件。
- 容差阈值（±10%、±20%）是技能实现细节；测试验证能否检测并分类偏差，
  而非验证确切阈值。
