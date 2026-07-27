# 技能测试规范：/asset-spec

## 技能摘要

`/asset-spec` 根据设计需求为每项资产生成视觉规格文档。它读取相关 GDD、美术圣经和设计
系统，生成结构化的资产规格表，其中定义：尺寸、动画状态（如适用）、色板引用、风格
说明、技术限制（格式、文件大小预算）以及交付清单。

规格表会在询问 "May I write" 后写入 `assets/specs/[asset-name]-spec.md`。如果规格表已
存在，技能会提供更新选项。一次调用请求多项资产时，会逐项询问 "May I write"。不适用
总监门禁。所有请求的规格表写入后，结论为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE
- [ ] 包含按资产使用的 "May I write" 协作协议语言
- [ ] 包含下一步交接（例如交给美术师，或稍后运行 `/asset-audit`）

---

## 总监门禁检查

无。`/asset-spec` 是设计文档工具。技术美术可以另行审核规格，但这不属于此技能内的门禁。

---

## 测试用例

### 用例 1：正常路径——具备完整 GDD 和美术圣经的敌人精灵规格

**测试夹具：**
- `design/gdd/enemies.md` 存在并定义了敌人变体
- `design/art-bible.md` 存在并包含色板和风格说明
- 不存在 "goblin-enemy" 的现有资产规格

**输入：** `/asset-spec goblin-enemy`

**预期行为：**
1. 技能读取敌人 GDD 和美术圣经
2. 技能为哥布林敌人精灵生成规格：
   - 尺寸：根据引擎默认值推断，或明确取自 GDD
   - 动画状态：idle、walk、attack、hurt、death
   - 色板引用：链接到美术圣经的色板章节
   - 风格说明：来自美术圣经中的角色设计规则
   - 技术限制：格式（PNG）、大小预算
   - 交付清单
3. 技能询问 "May I write to `assets/specs/goblin-enemy-spec.md`?"
4. 获得批准后写入文件；结论为 COMPLETE

**断言：**
- [ ] 6 个规格组件均存在（尺寸、动画、色板、风格、技术、清单）
- [ ] 色板引用链接到美术圣经（而不是重复内容）
- [ ] 动画状态取自 GDD（不是自行编造）
- [ ] 使用正确路径询问 "May I write"
- [ ] 结论为 COMPLETE

---

### 用例 2：未找到美术圣经——使用占位风格说明并标记依赖缺口

**测试夹具：**
- `design/gdd/player.md` 存在
- `design/art-bible.md` 不存在

**输入：** `/asset-spec player-sprite`

**预期行为：**
1. 技能读取玩家 GDD，但找不到美术圣经
2. 技能生成带占位风格说明的规格："DEPENDENCY GAP: art bible
   not found — style notes are placeholders"
3. 色板章节使用："TBD — see art bible when created"
4. 技能询问 "May I write to `assets/specs/player-sprite-spec.md`?"
5. 写入带占位内容和依赖标记的文件；结论为 COMPLETE，并附带建议

**断言：**
- [ ] 为缺失的美术圣经标记 DEPENDENCY GAP
- [ ] 规格仍会生成（不被阻塞）
- [ ] 风格说明包含占位标记，而不是编造风格
- [ ] 结论为 COMPLETE，并包含建议说明

---

### 用例 3：资产规格已存在——提供更新选项

**测试夹具：**
- `assets/specs/goblin-enemy-spec.md` 已存在
- 规格写入后 GDD 已更新（新增攻击动画）

**输入：** `/asset-spec goblin-enemy`

**预期行为：**
1. 技能检测到现有规格文件
2. 技能报告：“goblin-enemy 的资产规格已存在，正在检查更新”
3. 技能将 GDD 与现有规格进行差异比较，并识别出：GDD 新增了规格中没有的 "charge-attack" 动画状态
4. 技能展示差异："1 new animation state found — offering to update spec"
5. 技能询问 "May I update `assets/specs/goblin-enemy-spec.md`?"（不是覆盖）
6. 更新规格；结论为 COMPLETE

**断言：**
- [ ] 检测到现有规格，并提供 "update" 路径
- [ ] 展示 GDD 与现有规格之间的差异
- [ ] 使用 "May I update" 语言（而不是 "May I write"）
- [ ] 保留现有规格内容，只应用差异
- [ ] 结论为 COMPLETE

---

### 用例 4：请求多项资产——每项资产单独询问 May-I-Write

**测试夹具：**
- GDD 和美术圣经存在
- 用户请求 3 项资产的规格：goblin-enemy、orc-enemy、treasure-chest

**输入：** `/asset-spec goblin-enemy orc-enemy treasure-chest`

**预期行为：**
1. 技能依次生成全部 3 份规格
2. 对每项资产，技能展示草稿并单独询问 "May I write to
   `assets/specs/[name]-spec.md`?"
3. 用户可以批准全部 3 项，也可以跳过单项资产
4. 写入所有获批准的规格；结论为 COMPLETE

**断言：**
- [ ] "May I write" 被询问 3 次（每项资产一次），而不是全部只问一次
- [ ] 用户可以拒绝一项资产而不阻塞其他资产
- [ ] 为获批准的资产写入全部 3 份规格文件
- [ ] 所有获批准的规格写入后，结论为 COMPLETE

---

### 用例 5：总监门禁检查——无门禁；asset-spec 是设计工具

**测试夹具：**
- GDD 和美术圣经存在

**输入：** `/asset-spec goblin-enemy`

**预期行为：**
1. 技能生成并写入资产规格
2. 不启动总监代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用总监门禁
- [ ] 不出现门禁跳过消息
- [ ] 无需门禁检查即可得出 COMPLETE 结论

---

## 协议合规性

- [ ] 生成规格前读取 GDD、美术圣经和设计系统
- [ ] 包含全部 6 个规格组件（尺寸、动画、色板、风格、技术、清单）
- [ ] 用 DEPENDENCY GAP 说明标记缺失依赖（美术圣经、GDD）
- [ ] 每项资产询问 "May I write"（或 "May I update"）
- [ ] 对多项资产分别处理写入确认
- [ ] 所有获批准的规格写入后，结论为 COMPLETE

---

## 覆盖说明

- 音频资产规格（音效、音乐）遵循相同结构，但使用不同字段（时长、采样率、循环），未单独测试。
- UI 资产规格（图标、按钮状态）遵循相同流程，交互状态要求与 UX 规格保持一致。
- GDD 也缺失的情况（GDD 和美术圣经均不存在）未单独测试；此时会生成规格，并标记两个依赖缺口。
