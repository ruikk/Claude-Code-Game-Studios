# 经济模型（Economy Model）: [System Name]

*创建时间： [Date]*
*负责人：economy-designer*
*状态： [Draft / Balanced / Live]*

---

## 概览（Overview）

[该经济系统涵盖哪些资源、货币与交换机制？
它激励玩家形成哪些行为？]

---

## 货币（Currencies）

| 货币 | 类型 | 获取速率 | 消耗速率 | 上限 | 备注 |
| ---- | ---- | ---- | ---- | ---- | ---- |
| [Gold] | Soft | [per hour] | [per hour] | [max or none] | [主要交易货币] |
| [Gems] | Premium | [per day F2P] | [varies] | [max] | [高级货币，可购买] |
| [XP] | Progression | [per action] | [level-up cost] | [none] | [不可交易] |

### 货币规则（Currency Rules）
- [规则 1 —— 例如：“Soft currency 无上限，但通过消耗端控制通胀”]
- [规则 2 —— 例如：“Premium currency 不能反向兑换为真实货币”]
- [规则 3]

---

## 来源（Sources / Faucets）

| 来源 | 货币 | 数量 | 频率 | 条件 |
| ---- | ---- | ---- | ---- | ---- |
| [任务完成] | Gold | [50-200] | [per quest] | [随任务难度缩放] |
| [敌人掉落] | Gold | [1-10] | [per kill] | [受幸运属性修正] |
| [每日登录] | Gems | [5] | [daily] | [连登奖励：每连续 1 天 +1] |
| [成就] | XP | [100-500] | [one-time] | [按成就层级发放] |

---

## 消耗（Sinks / Drains）

| 消耗项 | 货币 | 成本 | 频率 | 目的 |
| ---- | ---- | ---- | ---- | ---- |
| [装备购买] | Gold | [100-5000] | [as needed] | [战力成长] |
| [维修费用] | Gold | [10-100] | [per death] | [死亡惩罚，回收 Gold] |
| [外观商店] | Gems | [50-500] | [optional] | [外观向，高级货币消耗] |
| [重置加点] | Gold | [1000] | [rare] | [流派试错税] |

---

## 平衡目标（Balance Targets）

| 指标 | 目标 | 依据 |
| ---- | ---- | ---- |
| 首次有意义购买所需时间 | [X minutes] | [应让玩家在早期感受到消费能力] |
| 每小时 Gold 获取速率（中期） | [X gold/hr] | [基于会话时长与购买节奏] |
| 到达满级所需天数（F2P） | [X days] | [足够留存，但不能长到引发挫败] |
| 消耗/来源比 | [0.7-0.9] | [轻微盈余可让玩家保持“富足感”] |
| 高级货币 F2P 获取速率 | [X/week] | [足够每月买到一些内容，但不是全部] |

---

## 成长曲线（Progression Curves）

### 等级 XP 需求（Level XP Requirements）
| Level | XP Required | Cumulative XP | Estimated Time |
| ---- | ---- | ---- | ---- |
| 1→2 | [100] | [100] | [10 min] |
| 5→6 | [500] | [1,500] | [2 hrs] |
| 10→11 | [1,500] | [7,500] | [8 hrs] |
| 20→21 | [5,000] | [50,000] | [40 hrs] |

*公式（Formula）*: `XP(n) = [formula, e.g., 100 * n^1.5]`

### 物品价格缩放（Item Price Scaling）
*公式（Formula）*: `Price(tier) = [formula, e.g., base_price * 2^(tier-1)]`

---

## 掉落表（Loot Tables）

### [Drop Source Name]
| Item | Rarity | Drop Rate | Pity Timer | Notes |
| ---- | ---- | ---- | ---- | ---- |
| [Common item] | Common | [60%] | [N/A] | [始终有用，不会让人失望] |
| [Uncommon item] | Uncommon | [25%] | [N/A] | [可感知的提升] |
| [Rare item] | Rare | [12%] | [10 drops] | [令人兴奋，能定义流派] |
| [Legendary item] | Legendary | [3%] | [30 drops] | [改变玩法，值得庆祝的时刻] |

### 保底系统（Pity System）
[描述保底系统如何运作，以防止出现极端非酋连败。]

---

## 经济健康指标（Economy Health Metrics）

| 指标 | 健康区间 | 预警阈值 | 超阈处理动作 |
| ---- | ---- | ---- | ---- |
| 玩家平均 Gold | [X-Y at level Z] | [>Y or <X] | [调整来源/消耗] |
| Gold 基尼系数 | [<0.4] | [>0.5] | [财富过度集中] |
| 触达货币上限的玩家占比 | [<5%] | [>10%] | [提高上限或增加消耗] |
| 高级货币转化率 | [2-5%] | [<1% or >10%] | [重平衡 F2P 获取速率] |
| 两次购买间平均时长 | [X minutes] | [>Y minutes] | [缺少值得购买的内容] |

---

## 伦理护栏（Ethical Guardrails）

- [禁止 pay-to-win：高级货币不能购买影响玩法强度的优势]
- [所有随机掉落都要有保底：在 X 次尝试内保证结果]
- [向玩家透明展示掉落概率]
- [未成年账户设置消费上限]
- [核心物品不使用人为稀缺压力（FOMO 倒计时）]

---

## 模拟结果（Simulation Results）

[如有，请包含经济模拟结果：例如玩家财富分布随时间变化、
消耗机制有效性、通胀率等。]

---

## 依赖关系（Dependencies）

- Depends on: [combat balance, quest design, crafting system]
- Affects: [difficulty curve, player retention, monetization]
- Must coordinate with: `game-designer`, `live-ops-designer`, `analytics-engineer`
