# 技能测试规范：/consistency-check

## 技能摘要

`/consistency-check` 扫描 `design/gdd/` 中的所有 GDD，检查文档间的内部冲突。
它生成结构化发现表，列为：系统 A 与系统 B、冲突类型、严重程度（HIGH / MEDIUM / LOW）。
冲突类型包括：公式不匹配、所有权冲突、过时引用和依赖缺口。

技能在分析期间只读，不设总监门禁。如果用户请求，可将可选一致性报告写入
`design/consistency-report-[date].md`，但写入前技能会询问 "May I write"。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：CONSISTENT、CONFLICTS FOUND、DEPENDENCY GAP
- [ ] 分析期间不要求使用 "May I write" 措辞（只读扫描）
- [ ] 末尾包含下一步交接
- [ ] 说明报告写入是可选操作且需要批准

---

## 总监门禁检查

不调用总监门禁，此技能不会生成总监门禁代理。一致性检查是机械扫描，
扫描本身不需要创意总监或技术总监审查。

---

## 测试用例

### 用例 1：正常路径——4 个 GDD 无冲突

**测试夹具：**
- `design/gdd/` 恰好包含 4 个系统 GDD
- 所有 GDD 的公式一致（不存在值不同的重叠变量）
- 没有两个 GDD 声称拥有同一游戏实体或机制
- 所有依赖引用均指向现有 GDD

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取 `design/gdd/` 中全部 4 个 GDD
2. 执行跨 GDD 一致性检查（公式、所有权、引用）
3. 未发现冲突
4. 输出结构化发现表，显示 0 个问题
5. 结论：CONSISTENT

**断言：**
- [ ] 生成输出前读取全部 4 个 GDD
- [ ] 存在发现表（即使为空，也显示“未发现冲突”）
- [ ] 不存在冲突时，结论为 CONSISTENT
- [ ] 未经用户批准，技能不写入任何文件
- [ ] 包含下一步交接

---

### 用例 2：失败路径——两个 GDD 的伤害公式冲突

**测试夹具：**
- GDD-A 定义伤害公式：`damage = attack * 1.5`
- GDD-B 为同一实体类型定义伤害公式：`damage = attack * 2.0`
- 两个 GDD 均引用同一 `attack` 变量

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取所有 GDD 并检测到公式不匹配
2. 发现表包含一项：GDD-A vs GDD-B | Formula Mismatch | HIGH
3. 显示发生冲突的具体公式（而非仅说明“存在公式冲突”）
4. 结论：CONFLICTS FOUND

**断言：**
- [ ] 结论为 CONFLICTS FOUND（而非 CONSISTENT）
- [ ] 冲突项指出两个 GDD 文件名
- [ ] 冲突类型为 "Formula Mismatch"
- [ ] 直接公式矛盾的严重程度为 HIGH
- [ ] 发现表显示两个冲突公式
- [ ] 技能不自动解决冲突

---

### 用例 3：部分路径——GDD 引用了没有 GDD 的系统

**测试夹具：**
- GDD-A 的 Dependencies 章节将 `system-B` 列为依赖
- `design/gdd/` 中不存在 system-B 的 GDD
- 其他所有 GDD 均一致

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取所有 GDD 并检查依赖引用
2. GDD-A 对 `system-B` 的引用无法解析，因为不存在对应 GDD
3. 发现表包含：GDD-A vs (missing) | Dependency Gap | MEDIUM
4. 结论：DEPENDENCY GAP（不是 CONSISTENT，也不是 CONFLICTS FOUND）

**断言：**
- [ ] 结论为 DEPENDENCY GAP（区别于 CONSISTENT 和 CONFLICTS FOUND）
- [ ] 发现项指出 GDD-A 和缺失的 system-B
- [ ] 无法解析的依赖引用严重程度为 MEDIUM
- [ ] 技能建议运行 `/design-system system-B` 创建缺失的 GDD

---

### 用例 4：边界情况——未找到 GDD

**测试夹具：**
- `design/gdd/` 目录为空或不存在

**输入：** `/consistency-check`

**预期行为：**
1. 技能尝试读取 `design/gdd/` 中的文件
2. 未找到 GDD 文件
3. 技能输出错误：“在 `design/gdd/` 中未找到 GDD。请先运行 `/design-system` 创建 GDD。”
4. 不生成发现表
5. 不给出结论

**断言：**
- [ ] 未找到 GDD 时，技能输出清晰的错误消息
- [ ] 不输出结论（CONSISTENT / CONFLICTS FOUND / DEPENDENCY GAP）
- [ ] 技能建议正确的下一步操作（`/design-system`）
- [ ] 技能不会崩溃或生成不完整报告

---

### 用例 5：总监门禁——不生成门禁；不读取 review-mode.txt

**测试夹具：**
- `design/gdd/` 包含至少 2 个 GDD
- `production/session-state/review-mode.txt` 存在且内容为 `full`

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取所有 GDD 并执行一致性扫描
2. 技能不读取 `production/session-state/review-mode.txt`
3. 任何时候都不生成总监门禁代理
4. 正常生成发现表和结论

**断言：**
- [ ] 不生成总监门禁代理（没有以 CD-、TD-、PR-、AD- 为前缀的门禁）
- [ ] 技能不读取 `production/session-state/review-mode.txt`
- [ ] 输出不包含 "Gate: [GATE-ID]" 或门禁跳过项
- [ ] 审查模式不影响此技能的行为

---

## 协议合规性

- [ ] 生成发现表前读取所有 GDD
- [ ] 如请求报告，在任何写入询问前完整显示发现表
- [ ] 结论严格为 CONSISTENT、CONFLICTS FOUND、DEPENDENCY GAP 之一
- [ ] 不调用总监门禁，也不读取 review-mode.txt
- [ ] 如请求写入报告，须经 "May I write" 批准
- [ ] 以适合当前结论的下一步交接结束

---

## 覆盖说明

- 此技能检查 GDD 间的结构一致性。深层设计理论分析（支柱偏移、支配策略）由
  `/review-all-gdds` 处理。
- 公式冲突检测依赖 GDD 间一致的公式记法；可能无法检测同一机制的非正式描述。
- 冲突严重程度评判标准（HIGH / MEDIUM / LOW）在技能正文中定义，此处不再列举。
