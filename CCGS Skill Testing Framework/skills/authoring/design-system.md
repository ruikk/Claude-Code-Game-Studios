# 技能测试规范：/design-system

## 技能摘要

`/design-system` 引导用户按章节为单个游戏系统编写游戏设计文档（GDD）。必须编写全部 8 个必需章节：概述、玩家幻想、详细规则、公式、边界情况、依赖项、调优参数和验收标准。该技能采用先建骨架方法，在填写任何内容前创建包含全部 8 个章节标题的 GDD 文件，并在批准后逐章写入。

CD-GDD-ALIGN 门禁（creative-director）在 `full` 和 `lean` 模式下都会运行，仅在 `solo` 模式下跳过。如果发现现有 GDD 文件，该技能会提供改造模式，以更新特定章节，而不是重写整个文档。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：APPROVED、NEEDS REVISION、MAJOR REVISION
- [ ] 包含 "May I write" 协作协议措辞（逐章批准）
- [ ] 最后包含下一步移交
- [ ] 记录先建骨架方法（先创建包含标题的文件，再写入内容）
- [ ] 记录 CD-GDD-ALIGN 门禁：在 full 和 lean 模式下启用，仅在 solo 下跳过
- [ ] 记录现有 GDD 文件的改造模式

---

## 主管门禁检查

在 `full` 模式下：每个章节起草后、写入前运行 CD-GDD-ALIGN（creative-director）门禁。如果返回 MAJOR REVISION，必须重写该章节才能继续。

在 `lean` 模式下：CD-GDD-ALIGN 仍会运行（该门禁不会在 lean 模式下跳过，而是在 full 和 lean 模式下均运行）。只有 solo 模式会跳过。

在 `solo` 模式下：跳过 CD-GDD-ALIGN。输出注明："CD-GDD-ALIGN skipped — solo mode"。各章节只需用户批准即可写入。

---

## 测试用例

### 用例 1：正常路径，新 GDD、先建骨架、lean 模式下运行 CD-GDD-ALIGN

**夹具：**
- `design/gdd/` 中没有目标系统的现有 GDD
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/design-system [system-name]`

**预期行为：**
1. 技能创建骨架文件 `design/gdd/[system-name].md`，包含全部 8 个章节标题（正文为空）
2. 对每个章节：与用户讨论、起草内容、显示草稿
3. 对每个章节草稿运行 CD-GDD-ALIGN 门禁（lean 模式下门禁启用）
4. 门禁对每个章节返回 APPROVED
5. 门禁批准后询问 "May I write [section]?"
6. 用户批准后将章节写入文件
7. 对全部 8 个章节重复此过程

**断言：**
- [ ] 写入任何内容前，创建包含全部 8 个章节标题的骨架文件
- [ ] CD-GDD-ALIGN 在 lean 模式下对每个章节运行（不跳过）
- [ ] 每个章节都询问 "May I write"（而非对所有章节只询问一次）
- [ ] 每个章节在门禁和用户批准后单独写入
- [ ] 最终 GDD 文件包含全部 8 个章节

---

### 用例 2：改造模式，更新现有 GDD 的特定章节

**夹具：**
- `design/gdd/[system-name].md` 已存在，且全部 8 个章节均已填写

**输入：** `/design-system [system-name]`

**预期行为：**
1. 技能检测现有 GDD 文件并读取其当前内容
2. 技能提供改造模式："GDD 已存在。要更新哪个章节？"
3. 用户选择特定章节（例如公式）
4. 技能只编写该章节、运行 CD-GDD-ALIGN，并询问 "May I write?"
5. 只更新所选章节，不修改其他章节

**断言：**
- [ ] 技能在提供改造模式前检测并读取现有 GDD
- [ ] 询问用户要更新哪个章节，而不是要求重写整个文档
- [ ] 只重写所选章节，其他章节保持不变
- [ ] CD-GDD-ALIGN 仍会对更新的章节运行
- [ ] 更新章节前询问 "May I write"

---

### 用例 3：主管门禁，CD-GDD-ALIGN 返回 MAJOR REVISION

**夹具：**
- 正在编写新 GDD
- `production/session-state/review-mode.txt` 包含 `lean`
- CD-GDD-ALIGN 门禁对玩家幻想章节返回 MAJOR REVISION

**输入：** `/design-system [system-name]`

**预期行为：**
1. 起草玩家幻想章节
2. CD-GDD-ALIGN 门禁运行并返回 MAJOR REVISION 和具体反馈
3. 技能向用户展示反馈
4. MAJOR REVISION 未解决时，不将该章节写入文件
5. 用户与技能协作重写该章节
6. CD-GDD-ALIGN 对修订后的章节再次运行
7. 如果修订后的章节通过，则询问 "May I write?" 并写入章节

**断言：**
- [ ] CD-GDD-ALIGN 返回 MAJOR REVISION 时不写入章节
- [ ] 请求修订前向用户显示门禁反馈
- [ ] 修订章节后再次运行 CD-GDD-ALIGN
- [ ] MAJOR REVISION 未解决时，技能不会自动进入下一章节

---

### 用例 4：Solo 模式，跳过 CD-GDD-ALIGN；仅凭用户批准写入章节

**夹具：**
- 正在编写新 GDD
- `production/session-state/review-mode.txt` 包含 `solo`

**输入：** `/design-system [system-name]`

**预期行为：**
1. 创建包含 8 个章节标题的骨架文件
2. 对每个章节：起草并展示给用户
3. 跳过 CD-GDD-ALIGN，每章注明："CD-GDD-ALIGN skipped — solo mode"
4. 用户审阅草稿后询问 "May I write [section]?"
5. 用户批准后写入章节
6. 所有阶段都不执行门禁审查

**断言：**
- [ ] 每个章节均注明 "CD-GDD-ALIGN skipped — solo mode"
- [ ] 仅凭用户批准写入章节（无需门禁）
- [ ] 技能在 solo 模式下不生成任何 CD-GDD-ALIGN 门禁
- [ ] solo 模式下，仅凭用户批准写入完整 GDD

---

### 用例 5：主管门禁，不将空章节写入文件

**夹具：**
- GDD 编写正在进行
- 用户和技能讨论某章节，但未产生任何获批内容（例如讨论结束但未作决定，或用户说“暂时跳过”）

**输入：** `/design-system [system-name]`

**预期行为：**
1. 章节讨论未产生获批内容
2. 技能不向该章节写入空正文或占位正文
3. 章节标题保留在骨架文件中，但正文保持为空
4. 技能不写入空章节并转到下一章节
5. 最后列出未完成章节，并提醒用户之后返回处理

**断言：**
- [ ] 不将空章节或未批准章节写入文件
- [ ] 保留骨架章节标题（维持结构）
- [ ] 技能在会话结束时跟踪并列出未完成章节
- [ ] 未经用户批准，技能不写入 "TBD" 或占位内容

---

## 协议合规性

- [ ] 写入任何内容前，创建包含全部 8 个标题的骨架文件
- [ ] CD-GDD-ALIGN 在 full 和 lean 模式下均运行（不只在 full 下运行）
- [ ] 仅在 solo 模式下跳过 CD-GDD-ALIGN，并逐章注明
- [ ] 每个章节询问 "May I write [section]?"（而非对整个文档只询问一次）
- [ ] CD-GDD-ALIGN 返回 MAJOR REVISION 时阻止写入章节，直至问题解决
- [ ] 只向文件写入已批准的非空章节
- [ ] 最后移交给 `/review-all-gdds` 或 `/map-systems next`

---

## 覆盖说明

- 8 个必需章节根据 `CLAUDE.md` 中定义的项目设计文档标准验证，此处不再枚举。
- 不单独测试技能内部的章节排序逻辑（先编写哪个章节）；顺序遵循标准 GDD 模板。
- CD-GDD-ALIGN 内的支柱一致性检查由门禁代理整体评估；此处不使用夹具测试具体支柱检查。
