# 技能测试规范：/propagate-design-change

## 技能摘要

`/propagate-design-change` 处理 GDD 修订的级联影响。GDD 更新后，该技能会追踪所有引用它的下游产物：ADR、TR-registry 条目、故事和史诗。它会生成结构化影响报告，说明需要更改的内容及原因。该技能不会自动应用更改，而是为每个受影响产物提出编辑建议，并在修改前逐项询问 "May I write"。

该技能在分析期间只读，在更新阶段则对每项产物设置写入门禁。它没有主管门禁，因为分析本身属于机械式追踪，而非创意评审。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：COMPLETE、BLOCKED、NO IMPACT
- [ ] 包含 "May I write" 协作协议用语（逐项产物审批）
- [ ] 末尾包含下一步交接
- [ ] 说明更改仅会被提出，而不会自动应用

---

## 主管门禁检查

没有主管门禁。该技能在分析期间不会生成任何主管门禁代理。影响报告属于机械式追踪操作，分析阶段不需要创意或技术主管评审。

---

## 测试用例

### 用例 1：正常路径——GDD 修订影响 2 个故事和 1 个史诗

**测试夹具：**
- `design/gdd/[system].md` 存在且最近已修订（git diff 显示更改）
- `production/epics/[layer]/EPIC-[system].md` 引用了该 GDD
- 2 个故事文件引用了该 GDD 中的 TR-ID
- 更改后的 GDD 章节影响两个故事的验收标准

**输入：** `/propagate-design-change design/gdd/[system].md`

**预期行为：**
1. 技能读取修订后的 GDD，并识别更改内容（通过 git diff 或内容比较）
2. 技能扫描 ADR、TR-registry、史诗和故事，查找对该 GDD 的引用
3. 技能生成影响报告：1 个史诗受影响，2 个故事受影响
4. 技能显示每项产物的拟议更改
5. 对每项产物分别询问 "May I update [filepath]?"
6. 仅在逐项产物获得批准后应用更改

**断言：**
- [ ] 影响报告识别出全部 3 项受影响产物（1 个史诗 + 2 个故事）
- [ ] 每项受影响产物的拟议更改都在询问写入前显示
- [ ] 对每项产物分别询问 "May I write"（而不是一次询问全部产物）
- [ ] 未经逐项产物批准，技能不会应用任何更改
- [ ] 所有获批更改应用后，结论为 COMPLETE

---

### 用例 2：无影响——更改后的 GDD 没有下游引用

**测试夹具：**
- `design/gdd/[system].md` 存在且已修订
- 没有 ADR、故事或史诗引用该 GDD 的 TR-ID 或 GDD 路径

**输入：** `/propagate-design-change design/gdd/[system].md`

**预期行为：**
1. 技能读取修订后的 GDD
2. 技能扫描所有 ADR、故事和史诗以查找引用
3. 未找到引用
4. 技能输出："No downstream impact found for [system].md — no artifacts reference this GDD."
5. 不执行写入操作

**断言：**
- [ ] 技能输出 "No downstream impact found" 消息
- [ ] 结论为 NO IMPACT
- [ ] 不发出 "May I write" 询问（没有需要更新的内容）
- [ ] 未找到引用时，技能不会报错或崩溃

---

### 用例 3：进行中故事警告——被引用故事当前正在开发

**测试夹具：**
- 引用该 GDD 的故事带有 `Status: In Progress`
- 开发者已经开始实现该故事

**输入：** `/propagate-design-change design/gdd/[system].md`

**预期行为：**
1. 技能将 In Progress 故事识别为受影响产物
2. 技能输出显著警告："CAUTION: [story-file] is currently In Progress — a developer may be working on this. Coordinate before updating."
3. 该警告在影响报告中显示于该故事的 "May I write" 询问之前
4. 用户仍可批准或跳过该故事的更新

**断言：**
- [ ] In Progress 故事带有显著警告（区别于常规的受影响产物条目）
- [ ] 警告显示于该故事的 "May I write" 询问之前
- [ ] 技能仍会提供更新该故事的选项，警告不会阻止该选项
- [ ] 其他非 In Progress 产物不受该警告影响

---

### 用例 4：边界情况——未提供参数

**测试夹具：**
- `design/gdd/` 中存在多个 GDD

**输入：** `/propagate-design-change`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 技能输出用法错误："No GDD specified. Usage: /propagate-design-change design/gdd/[system].md"
3. 技能将最近修改的 GDD 列为建议（git log）
4. 不执行分析

**断言：**
- [ ] 未提供参数时，技能输出用法错误
- [ ] 显示采用正确路径格式的用法示例
- [ ] 没有目标 GDD 时，不执行影响分析
- [ ] 技能不会在没有用户输入时擅自选择 GDD

---

### 用例 5：主管门禁——无论评审模式如何都不生成门禁

**测试夹具：**
- 一个 GDD 已修订且存在下游引用
- `production/session-state/review-mode.txt` 存在且内容为 `full`

**输入：** `/propagate-design-change design/gdd/[system].md`

**预期行为：**
1. 技能读取 GDD 并追踪下游引用
2. 技能不读取 `production/session-state/review-mode.txt`
3. 任何阶段都不生成主管门禁代理
4. 正常生成影响报告并进行逐项产物审批

**断言：**
- [ ] 不生成主管门禁代理（没有带 CD-、TD-、PR-、AD- 前缀的门禁）
- [ ] 技能不读取 `production/session-state/review-mode.txt`
- [ ] 输出不包含 "Gate: [GATE-ID]" 或跳过门禁条目
- [ ] 评审模式不影响该技能的行为

---

## 协议合规性

- [ ] 生成影响报告前，读取修订后的 GDD 和所有可能受影响的产物
- [ ] 在任何 "May I write" 询问前完整显示影响报告
- [ ] 对每项产物分别询问 "May I write"，绝不一次询问整个集合
- [ ] 在审批询问前，对 In Progress 故事显示显著警告
- [ ] 没有主管门禁，不读取 review-mode.txt
- [ ] 以适合结论（COMPLETE 或 NO IMPACT）的下一步交接结束

---

## 覆盖说明

- ADR 影响（GDD 更改要求更新或新增 ADR 时）遵循与故事/史诗更新相同的逐项产物审批模式，未单独使用夹具测试。
- TR-registry 影响（更改后的 GDD 要求新增或更新 TR-ID 时）属于分析阶段，但未单独使用夹具测试。
- git diff 比较方法（检测 GDD 中的更改）属于运行时事项，夹具使用预先安排的内容差异。
