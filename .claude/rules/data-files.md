---
paths:
  - "assets/data/**"
---

# 数据文件规则 (Data File Rules)

- 所有 JSON 文件必须是合法的 JSON（Valid JSON）——损坏的 JSON 会阻塞整个构建管线（Build Pipeline）
- 文件命名：仅使用小写字母和下划线，遵循 `[system]_[name].json` 模式
- 每个数据文件必须有文档化的模式定义（Schema）（JSON Schema 或在对应设计文档中说明）
- 数值必须附带注释或配套文档，解释其含义
- 使用一致的键命名：JSON 文件内部使用 camelCase（驼峰命名法）
- 不允许孤立的数据条目——每个条目必须被代码或其他数据文件引用
- 进行破坏性模式变更时，必须对数据文件进行版本化（Versioning）
- 所有可选字段必须包含合理的默认值（Sensible Defaults）

## 示例

**正确**的命名和结构 (`combat_enemies.json`)：

```json
{
  "goblin": {
    "baseHealth": 50,
    "baseDamage": 8,
    "moveSpeed": 3.5,
    "lootTable": "loot_goblin_common"
  },
  "goblin_chief": {
    "baseHealth": 150,
    "baseDamage": 20,
    "moveSpeed": 2.8,
    "lootTable": "loot_goblin_rare"
  }
}
```

**错误**示例 (`EnemyData.json`)：

```json
{
  "Goblin": { "hp": 50 }
}
```

违规项：文件名包含大写字母、键名包含大写字母、不符合 `[system]_[name]` 模式、缺少必需字段。
