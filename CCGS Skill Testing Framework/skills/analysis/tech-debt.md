# 技能测试规范：/tech-debt

## 技能摘要

`/tech-debt` 跟踪、分类并排序代码库中的技术债务。读取 `docs/tech-debt-register.md`，扫描 `src/` 中的 `TODO` 和 `FIXME`，合并后按严重程度排序。不调用总监门禁。更新前询问 "May I write to `docs/tech-debt-register.md`?"。结论：REGISTER UPDATED 或 NO NEW DEBT FOUND。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：REGISTER UPDATED、NO NEW DEBT FOUND
- [ ] 包含 "May I write"
- [ ] 包含下一步交接

---

## 总监门禁检查

无。技术债务跟踪是内部代码库分析技能，不调用门禁。

---

## 测试用例

### 用例 1：正常路径——合并内联 TODO 与现有登记项

**测试夹具：** 
- `docs/tech-debt-register.md` 有 2 项（LOW、MEDIUM）；
- `src/gameplay/combat.gd` 有 2 个 `# TODO` 和 1 个 `# FIXME`；
- `src/ui/hud.gd` 没有内联债务注释。

**输入：** `/tech-debt`

**预期行为：**
1. Skill 读取 `docs/tech-debt-register.md` —— 找到 2 个已有条目
2. Skill 扫描 `src/` —— 找到 3 条内联注释（2 个 TODO，1 个 FIXME）
3. Skill 检查内联注释是否已经存在于登记表中（去重）
4. Skill 展示按严重性排序的合并列表（默认情况下 FIXME 在 TODO 之前）
5. Skill 提问“我可以写入 `docs/tech-debt-register.md` 吗？”
6. 用户批准；登记表更新；结果 REGISTER UPDATED

**断言：**
- [ ] 通过递归扫描 `src/` 找到内联注释
- [ ] 不重复已有的登记表条目
- [ ] 合并列表按严重性排序
- [ ] 写入前会出现“我可以写吗”提示
- [ ] 结果为 REGISTER UPDATED

---

### 用例 2：登记表不存在——提供创建选项

**测试夹具：** 
- `docs/tech-debt-register.md` 不存在；
- `src/` 有 4 个 TODO/FIXME。

**输入：** `/tech-debt`

**预期行为：**
1. 技能尝试读取 `docs/tech-debt-register.md` — 未找到
2. 技能通知用户：“未找到 tech-debt-register.md”
3. 技能提供使用它找到的内联条目创建该登记表
4. 技能询问“我可以写入 `docs/tech-debt-register.md` 吗？”（创建）
5. 用户同意；登记表创建，包含 4 个条目；结果为 REGISTER UPDATED

**断言：**
- [ ] 当登记表文件缺失时，技能不会崩溃
- [ ] 用户会被提供创建登记表的选项（不会悄悄跳过）
- [ ] “我可以写入”提示反映文件创建（而非更新）
- [ ] 创建后结果为 REGISTER UPDATED

---

### 用例 3：检测已解决项——在登记表中标记

**测试夹具：** 
- `docs/tech-debt-register.md` 有 3 个条目；其中一个引用了 `src/gameplay/legacy_input.gd`
- `src/gameplay/legacy_input.gd` 已被删除（已重构）
- 所引用的 TODO 注释在源码中已不存在

**输入：** `/tech-debt`

**预期行为：**
1. 技能读取登记表 — 找到 3 个条目
2. 技能扫描 `src/` — 没有找到条目 2 引用的源码位置
3. 技能将条目 2 标记为已解决（源码已消失）
4. 技能向用户展示已解决的条目以确认
5. 经用户批准后，登记表更新，条目 2 标记为 `状态: 已解决`

**断言：**
- [ ] 技能检查每个登记表条目的源码引用是否仍然存在
- [ ] 源码位置缺失会导致条目被标记为已解决
- [ ] 在写入已解决条目前需用户确认
- [ ] 已解决的条目保留在登记表中（不删除），用于审计历史记录

---

### 用例 4：边界情况——CRITICAL 债务醒目显示

**测试夹具：** 
- `src/core/network_sync.gd` 有 `# FIXME(CRITICAL): race condition in sync buffer — can corrupt save data`；
- `docs/tech-debt-register.md` 有 5 个低严重度项。

**输入：** `/tech-debt`

**预期行为：**
1. 技能扫描源文件并找到标记为 CRITICAL 的 FIXME
2. 技能将 CRITICAL 项目显示在输出顶部——在完整表格之前
3. 技能在继续之前要求用户确认该关键项目
4. 确认之后，技能展示完整的债务表并请求写入
5. 注册表会更新，CRITICAL 项目置于顶部；状态显示 REGISTER UPDATED

**断言：**
- [ ] CRITICAL 项目出现在输出顶部，而不是被埋在表格里
- [ ] 技能在请求写入之前显示 CRITICAL 项目
- [ ] 请求用户确认 CRITICAL 项目
- [ ] 写入注册表时保留 CRITICAL 严重性

---

### 用例 5：门禁合规——不调用门禁；仅经批准更新

**测试夹具：** 
- 找到 2 个新 TODO，登记表有 3 项；
- `review-mode.txt` 包含 `full`。

**输入：** `/tech-debt`

**预期行为:**
1. 技能扫描源代码并读取登记册；编译合并的债务清单
2. 无论审核模式如何，都不会触发主管权限
3. 技能向用户展示排序后的债务表
4. 技能询问“我可以写入 `docs/tech-debt-register.md` 吗？”
5. 用户批准；登记册更新；结果 REGISTER UPDATED

**断言:**
- [ ] 在任何审核模式下都不会触发主管权限
- [ ] 债务表在任何写入提示之前显示
- [ ] “我可以写入”提示在文件更新之前出现
- [ ] 仅在用户明确批准的情况下才会写入
---

## 协议合规性

- [ ] 编译前读取登记表并扫描 `src/`
- [ ] 将内联注释与现有登记项去重
- [ ] 按严重程度排序
- [ ] 更新前总是询问 "May I write"
- [ ] 不调用总监门禁
- [ ] 结论为 REGISTER UPDATED 或 NO NEW DEBT FOUND

---

## 覆盖说明

- `src/` 为空或不存在的情况未测试；内联扫描遵循 NO NEW DEBT FOUND，但仍读取登记项。
- 没有严重程度标签的 TODO 默认按 LOW 处理，此实现细节未测试。
