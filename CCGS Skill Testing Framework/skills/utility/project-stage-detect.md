# 技能测试规范：/project-stage-detect

## 技能摘要

`/project-stage-detect` 自动分析项目产物以确定当前开发阶段。它运行在 Haiku 模型上（只读），检查 `production/stage.txt`（如存在）、`design/` 中的设计文档、`src/` 中的源代码、`production/` 中的迭代和里程碑文件，以及引擎配置是否存在，将项目归类为七个阶段之一：Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish 或 Release。

该技能仅提供建议，绝不写入 `stage.txt`。只有 `/gate-check` 通过且用户确认推进时才更新该文件。技能报告置信度：直接读取 stage.txt 时为 HIGH，根据产物推断时为 MEDIUM，发现信号冲突时为 LOW。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含全部七个阶段名称：Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish、Release
- [ ] 不包含“May I write”措辞（该技能仅用于检测）
- [ ] 包含下一步交接（例如使用 `/gate-check` 正式推进阶段）

---

## 导演门禁检查

无。`/project-stage-detect` 是只读检测工具，不适用导演门禁。

---

## 测试用例

### 用例 1：存在 stage.txt——直接读取并交叉检查产物

**测试夹具：**
- `production/stage.txt` 包含 `Production`
- `design/gdd/` 有 4 个 GDD 文件
- `src/` 有源代码文件
- `production/sprints/sprint-002.md` 存在

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能读取 `production/stage.txt`，检测到阶段 `Production`
2. 技能交叉检查产物：存在 GDD、源代码和迭代文件
3. 产物与 Production 阶段一致
4. 技能报告：Stage = Production，Confidence = HIGH（来自 stage.txt，并由产物确认）
5. 下一步：继续使用 `/sprint-plan` 或 `/dev-story`

**断言：**
- [ ] 检测阶段为 Production
- [ ] 存在 stage.txt 时置信度为 HIGH
- [ ] 记录交叉检查结果（一致或不一致）
- [ ] 不写入文件
- [ ] Verdict 清楚说明检测到的阶段

---

### 用例 2：没有 stage.txt 但存在 GDD 和史诗——推断为 Production

**测试夹具：**
- 没有 `production/stage.txt`
- `design/gdd/` 有 3 个 GDD 文件
- `production/epics/` 有 2 个史诗文件
- `src/` 有源代码文件
- `production/sprints/sprint-001.md` 存在

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能找不到 stage.txt，切换到产物推断模式
2. 技能找到 GDD（Systems Design 完成）、史诗（Pre-Production 完成）、源代码和迭代（Production 活跃）
3. 技能推断：Stage = Production
4. 置信度为 MEDIUM（根据产物推断，而非来自 stage.txt）
5. 建议运行 `/gate-check` 以正式确认并写入 stage.txt

**断言：**
- [ ] 推断阶段为 Production
- [ ] 置信度为 MEDIUM（stage.txt 缺失时不是 HIGH）
- [ ] 包含运行 `/gate-check` 的建议
- [ ] 本技能不写入 stage.txt

---

### 用例 3：没有 stage.txt、文档和源代码——推断为 Concept

**测试夹具：**
- 没有 `production/stage.txt`
- `design/` 目录存在但为空
- `src/` 存在但不含代码文件
- `technical-preferences.md` 只有占位符

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能找不到 stage.txt
2. 产物扫描结果：没有 GDD、源代码、史诗或迭代，引擎未配置
3. 技能推断：Stage = Concept
4. 置信度为 MEDIUM
5. 建议使用 `/start` 开始入职工作流

**断言：**
- [ ] 推断阶段为 Concept
- [ ] 输出列出已检查且确认缺失的产物
- [ ] 建议下一步使用 `/start`
- [ ] 不写入文件

---

### 用例 4：不一致——stage.txt 写的是 Production 但没有源代码

**测试夹具：**
- `production/stage.txt` 包含 `Production`
- `design/gdd/` 有 GDD 文件
- `src/` 存在但不含源代码文件
- 不存在迭代文件

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能读取 stage.txt，检测到 `Production`
2. 交叉检查发现没有源代码和迭代，与 Production 不一致
3. 技能标记不一致：“stage.txt 显示为 Production，但未找到源代码或迭代”
4. 技能遵循 stage.txt，将检测阶段报告为 Production，但因产物不匹配将置信度降为 LOW
5. 建议手动检查 stage.txt 或运行 `/gate-check`

**断言：**
- [ ] 在输出中明确标记不一致
- [ ] 产物与 stage.txt 矛盾时置信度为 LOW
- [ ] 不静默覆盖 stage.txt 的值
- [ ] 建议用户手动核实不一致

---

### 用例 5：导演门禁检查——无门禁；检测仅提供建议

**测试夹具：**
- 有或没有 stage.txt 的任意项目状态

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能完成完整阶段检测
2. 任意时刻都不启动导演代理
3. 输出中不出现门禁 ID
4. 不调用写入工具

**断言：**
- [ ] 不调用导演门禁
- [ ] 不调用写入工具
- [ ] 检测输出纯粹提供建议
- [ ] Verdict 指明检测阶段，但不触发任何门禁

---

## 协议合规性

- [ ] stage.txt 存在时读取；缺失时回退到产物推断
- [ ] 始终报告置信度（HIGH / MEDIUM / LOW）
- [ ] 将 stage.txt 与产物交叉检查并标记不一致
- [ ] 不写入 stage.txt（这是 `/gate-check` 的职责）
- [ ] 以适合检测阶段的下一步建议结束

## 覆盖说明

- Technical Setup 阶段（引擎已配置但尚无 GDD）和 Pre-Production 阶段（GDD 已完成但尚无史诗）遵循与用例 2、3 相同的产物推断模式，未单独设置测试夹具。
- Polish 和 Release 阶段未设置测试夹具；它们遵循存在 stage.txt 时高置信度、否则进行推断的逻辑。
- 置信度仅供参考；技能不会根据置信度触发任何门禁操作。
