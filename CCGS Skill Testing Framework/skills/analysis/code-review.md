# 技能测试规范：/code-review

## 技能摘要

`/code-review` 对 `src/` 中的源文件执行架构代码审查，检查 `CLAUDE.md` 中的编码标准
（公共 API 的文档注释、优先使用依赖注入而非单例、数据驱动值、可测试性）。发现仅供建议。
不调用总监门禁，也不编辑代码。结论为：APPROVED、CONCERNS 或 NEEDS CHANGES。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：APPROVED、CONCERNS、NEEDS CHANGES
- [ ] 不要求使用 "May I write" 措辞（只读；发现为建议性输出）
- [ ] 包含下一步交接（如何处理发现）

---

## 总监门禁检查

无。代码审查是只读建议技能，不调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——源文件遵循所有编码标准

**测试夹具：**
- `src/gameplay/health_component.gd` exists with:
  - 所有公共方法都有文档注释（`##` 记法）
  - 不使用单例；通过构造函数注入依赖
  - 没有硬编码值；所有常量均引用 `assets/data/`
  - 文件头包含 ADR 引用：`# ADR: docs/architecture/adr-004-health.md`
  - 被引用 ADR 的状态为 `Status: Accepted`

**输入：** `/code-review src/gameplay/health_component.gd`

**预期行为：**
1. 技能读取源文件
2. 技能检查所有编码标准：文档注释、DI、数据驱动、ADR 状态
3. 所有检查均通过
4. 技能输出发现摘要，所有检查均为 PASS
5. 结论为 APPROVED

**断言：**
- [ ] 输出列出每项编码标准检查
- [ ] 符合标准时，所有检查均显示 PASS
- [ ] 技能读取被引用的 ADR 以确认其状态
- [ ] 结论为 APPROVED
- [ ] 不编辑任何文件

---

### 用例 2：需要修改——缺少文档注释且使用单例

**测试夹具：**
- `src/ui/inventory_ui.gd` has:
  - 2 个公共方法没有文档注释
  - 使用 `GameManager.instance`（单例模式）
  - 符合其他所有标准

**输入：** `/code-review src/ui/inventory_ui.gd`

**预期行为：**
1. 技能读取源文件
2. 技能检测到 2 个公共方法缺少文档注释
3. 技能检测到特定行使用单例（例如第 42、87 行）
4. 发现列出确切的方法名和行号
5. 结论为 NEEDS CHANGES

**断言：**
- [ ] 列出缺少文档注释的方法名
- [ ] 标记单例用法并给出文件和行号
- [ ] 存在 BLOCKING 级标准违规时，结论为 NEEDS CHANGES
- [ ] 技能不编辑文件，发现由开发者处理
- [ ] 输出建议用依赖注入替代单例

---

### 用例 3：架构风险——引用的 ADR 为 Proposed 而非 Accepted

**测试夹具：**
- `src/core/save_system.gd` 的文件头注释为：`# ADR: docs/architecture/adr-010-save.md`
- `adr-010-save.md` 存在，但状态为 `Status: Proposed`
- 代码本身符合其他所有编码标准

**输入：** `/code-review src/core/save_system.gd`

**预期行为：**
1. 技能读取源文件
2. 技能读取被引用的 ADR，发现 `Status: Proposed`
3. 技能将其标记为 ARCHITECTURE RISK（代码正在实现尚未接受的 ADR）
4. 其他编码标准检查通过
5. 结论为 CONCERNS（风险标记仅供建议，并非强制 NEEDS CHANGES）

**断言：**
- [ ] 技能读取被引用的 ADR 文件以检查其状态
- [ ] ADR 状态为 Proposed 时标记 ARCHITECTURE RISK
- [ ] ADR 风险的结论为 CONCERNS（而非 NEEDS CHANGES），属于建议级严重程度
- [ ] 输出建议在代码进入生产环境前解决 ADR

---

### 用例 4：边界情况——指定路径下未找到源文件

**测试夹具：**
- 用户调用 `/code-review src/networking/`
- `src/networking/` 目录不存在

**输入：** `/code-review src/networking/`

**预期行为：**
1. 技能尝试读取 `src/networking/` 中的文件
2. 未找到目录或文件
3. 技能输出错误：“在 `src/networking/` 未找到源文件”
4. 技能建议检查 `src/` 中的有效目录
5. 不输出结论（没有可审查内容）

**断言：**
- [ ] 路径不存在时技能不会崩溃
- [ ] 错误消息中指出尝试访问的路径
- [ ] 输出建议检查 `src/` 中的有效文件路径
- [ ] 没有可审查内容时不输出结论

---

### 用例 5：门禁合规——不调用门禁；可另行咨询 LP

**测试夹具：**
- 源文件符合大多数标准，但有 1 个 CONCERNS 级发现（魔法数字）
- `review-mode.txt` 包含 `full`

**输入：** `/code-review src/gameplay/loot_system.gd`

**预期行为：**
1. 技能读取并审查源文件
2. 不调用总监门禁（代码审查发现仅供建议）
3. 技能展示发现，结论为 CONCERNS
4. 输出说明：“如有架构顾虑，建议请求首席程序员审查”
5. 技能不自动调用任何代理

**断言：**
- [ ] 任何审查模式下均不调用总监门禁
- [ ] 输出建议（而非强制）咨询 LP
- [ ] 不编辑代码
- [ ] 建议级发现的结论为 CONCERNS

---

## 协议合规性

- [ ] 审查前读取源文件和编码标准
- [ ] 在发现输出中列出每项编码标准检查
- [ ] 不编辑任何源文件（只读技能）
- [ ] 不调用总监门禁
- [ ] 结论为 APPROVED、CONCERNS、NEEDS CHANGES 之一

---

## 覆盖说明

- 此处未明确测试批量审查目录中的所有文件；假定其行为是逐文件应用相同检查并汇总结论。
- 测试覆盖率检查（验证对应测试文件是否存在）是此处未测试的扩展目标，主要属于
  `/test-evidence-review` 的职责范围。
