# 技能测试规范：/art-bible

## 技能摘要

`/art-bible` 是按章节引导编写美术圣经的技能。它生成完整的视觉方向文档，涵盖视觉风格概述、调色板、字体排印、角色设计规则、环境风格和 UI 视觉语言。该技能采用先建骨架模式：立即创建包含所有章节标题的文件，再通过讨论填写各章节，并在用户批准后逐章写入磁盘。

在 `full` 审查模式下，草稿完成后、写入任何章节前运行 AD-ART-BIBLE 主管门禁（art-director）。在 `lean` 和 `solo` 模式下跳过 AD-ART-BIBLE，只需用户批准。所有章节写入后，结论为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：COMPLETE
- [ ] 每个章节包含 "May I write" 措辞
- [ ] 记录 AD-ART-BIBLE 主管门禁及其模式行为
- [ ] 包含下一步移交（例如 `/asset-spec` 或 `/design-system`）

---

## 主管门禁检查

| 门禁 ID | 触发条件 | 模式限制 |
|---------|----------|----------|
| AD-ART-BIBLE | 草稿完成后 | 仅 full（不适用于 lean/solo） |

---

## 测试用例

### 用例 1：正常路径，full 模式，美术圣经草稿完成，AD-ART-BIBLE 批准

**夹具：**
- `design/art-bible.md` 不存在
- `production/session-state/review-mode.txt` 包含 `full`
- `design/gdd/game-concept.md` 存在并描述了视觉基调

**输入：** `/art-bible`

**预期行为：**
1. 技能创建骨架 `design/art-bible.md`，包含所有章节标题
2. 技能与用户协作讨论并起草每个章节
3. 所有章节起草完成后，调用 AD-ART-BIBLE 门禁（art-director 审查）
4. AD-ART-BIBLE 返回 APPROVED
5. 技能逐章询问 "May I write section [N] to `design/art-bible.md`?"
6. 获批后写入所有章节；结论为 COMPLETE

**断言：**
- [ ] 首先创建骨架文件（早于写入任何章节内容）
- [ ] 草稿完成后，在 full 模式下调用 AD-ART-BIBLE 门禁
- [ ] 门禁批准早于 "May I write" 章节询问
- [ ] 最终文件中包含所有章节
- [ ] 结论为 COMPLETE

---

### 用例 2：AD-ART-BIBLE 返回 CONCERNS，写入前修订章节

**夹具：**
- 美术圣经草稿已完成
- `production/session-state/review-mode.txt` 包含 `full`
- AD-ART-BIBLE 门禁返回 CONCERNS："调色板与游戏概念中描述的黑暗氛围基调冲突"

**输入：** `/art-bible`

**预期行为：**
1. AD-ART-BIBLE 门禁返回 CONCERNS 和关于调色板的具体反馈
2. 技能向用户展示反馈："美术主管对调色板有疑虑"
3. 技能返回调色板章节进行修订
4. 用户和技能修订调色板，使其与游戏概念基调一致
5. 不再次调用 AD-ART-BIBLE（修订后由用户决定是否继续）
6. 询问 "May I write" 并获批后写入修订章节；结论为 COMPLETE

**断言：**
- [ ] 写入任何章节前向用户展示 CONCERNS
- [ ] 技能返回受影响的章节进行修订（而非所有章节）
- [ ] 将修订后的内容（而非原内容）写入文件
- [ ] 修订并获批后，结论为 COMPLETE

---

### 用例 3：Lean 模式，跳过 AD-ART-BIBLE，仅凭用户批准写入

**夹具：**
- 没有现有美术圣经
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/art-bible`

**预期行为：**
1. 技能读取审查模式，并确定为 `lean`
2. 技能与用户协作起草所有章节
3. 跳过 AD-ART-BIBLE 门禁：输出注明 "[AD-ART-BIBLE] skipped — lean mode"
4. 技能请求用户直接批准每个章节
5. 用户确认后写入章节；结论为 COMPLETE

**断言：**
- [ ] lean 模式下不调用 AD-ART-BIBLE 门禁
- [ ] 明确注明跳过："[AD-ART-BIBLE] skipped — lean mode"
- [ ] 每个章节仍需要用户批准（跳过门禁不等于跳过批准）
- [ ] 结论为 COMPLETE

---

### 用例 4：现有美术圣经，改造模式

**夹具：**
- `design/art-bible.md` 已存在，且所有章节均已填写
- 用户想更新角色设计规则章节

**输入：** `/art-bible`

**预期行为：**
1. 技能读取现有美术圣经，并检测到所有章节均已填写
2. 技能提供改造选项："美术圣经已存在，要更新哪个章节？"
3. 用户选择角色设计规则
4. 技能起草更新内容；在 full 模式下，写入前针对修订章节调用 AD-ART-BIBLE
5. 技能询问 "May I write Character Design Rules to `design/art-bible.md`?"
6. 只更新该章节，保留其他章节；结论为 COMPLETE

**断言：**
- [ ] 检测到现有美术圣经并提供改造选项
- [ ] 只更新所选章节
- [ ] 在 full 模式下，即使只改造单个章节也运行 AD-ART-BIBLE 门禁
- [ ] 保留其他章节
- [ ] 结论为 COMPLETE

---

### 用例 5：Solo 模式，跳过 AD-ART-BIBLE 并在输出中注明

**夹具：**
- 没有现有美术圣经
- `production/session-state/review-mode.txt` 包含 `solo`

**输入：** `/art-bible`

**预期行为：**
1. 技能读取审查模式，并确定为 `solo`
2. 仅凭用户批准起草并写入美术圣经
3. 跳过 AD-ART-BIBLE 门禁：输出注明 "[AD-ART-BIBLE] skipped — solo mode"
4. 不生成主管代理
5. 结论为 COMPLETE

**断言：**
- [ ] solo 模式下不调用 AD-ART-BIBLE 门禁
- [ ] 使用 "solo mode" 标签明确注明跳过
- [ ] 不生成任何主管代理
- [ ] 结论为 COMPLETE

---

## 协议合规性

- [ ] 立即创建包含所有章节标题的骨架文件
- [ ] 每次讨论并起草一个章节
- [ ] 所有章节起草完成后，在 full 模式下运行 AD-ART-BIBLE 门禁
- [ ] 在 lean 和 solo 模式下跳过 AD-ART-BIBLE，并按名称注明
- [ ] 每个章节询问 "May I write section [N]"
- [ ] 所有章节写入后，结论为 COMPLETE

---

## 覆盖说明

- 未单独测试 AD-ART-BIBLE 返回 REJECT（而不只是 CONCERNS）的情况；技能会阻止写入，并询问用户如何继续（修订或覆盖）。
- 字体排印章节被列为美术圣经的必需章节，但此处不测试其具体内容要求。
- 美术圣经会作为 `/asset-spec` 的输入；移交中注明了该关系，但不作为此技能规格的一部分进行测试。
