# 技能测试规范：/localize

## 技能摘要

`/localize` 管理完整的本地化管线：从源文件提取所有面向玩家的字符串，管理 `assets/localization/` 中的翻译文件，并验证所有 locale 文件的完整性。对于新语言，它创建以当前所有字符串为键、值为空的 locale 文件骨架。对于已有 locale 文件，它生成差异，显示新增、删除和变更的键。

询问“May I write”后，将翻译文件写入 `assets/localization/[locale-code].csv`（或引擎适用的格式）。不适用导演门禁。Verdict：LOCALIZATION COMPLETE（所有 locale 均完整）或 GAPS FOUND（至少一个 locale 缺少字符串键）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含 verdict 关键字：LOCALIZATION COMPLETE、GAPS FOUND
- [ ] 写入 locale 文件前包含“May I write”协作协议措辞
- [ ] 包含下一步交接（例如将 locale 骨架发送给译者）

---

## 导演门禁检查

无。`/localize` 是管线工具，不适用导演门禁。本地化负责人代理可以另行审查，但不会在本技能中调用。

---

## 测试用例

### 用例 1：新语言——提取字符串并创建 locale 骨架

**测试夹具：**
- `src/` 中的源代码包含面向玩家的字符串（UI 文本、教程消息）
- 已有 locale：`assets/localization/en.csv`
- 不存在法语 locale

**输入：** `/localize fr`

**预期行为：**
1. 技能从源文件提取所有面向玩家的字符串
2. 技能在 `en.csv` 中找到相同字符串作为参考
3. 技能生成包含所有字符串键且值为空的 `fr.csv` 骨架
4. 技能询问“May I write to `assets/localization/fr.csv`?”
5. 获批后写入文件；verdict 为 GAPS FOUND（文件已创建但值为空）
6. 技能记录：“fr.csv 已创建——发送给译者填写值”

**断言：**
- [ ] `en.csv` 中的所有字符串键都存在于 `fr.csv`
- [ ] `fr.csv` 中所有值均为空（没有从英文复制）
- [ ] 创建文件前询问“May I write”
- [ ] Verdict 为 GAPS FOUND（文件已创建但未翻译）

---

### 用例 2：已有 locale 差异——列出新增、删除和变更

**测试夹具：**
- `assets/localization/fr.csv` 存在，且已翻译 20 个字符串键
- 源代码已变更：新增 3 个字符串，删除 1 个字符串，2 个字符串的英文源文本发生变化

**输入：** `/localize fr`

**预期行为：**
1. 技能从源代码提取当前字符串
2. 技能与已有 `fr.csv` 进行差异比较
3. 技能生成差异报告：
   - 3 个新键（需要翻译，在 fr.csv 中列为空）
   - 1 个删除的键（标记为过时，建议删除）
    - 2 个变更的键（英文源文本发生变化，标记为法文可能需要更新）
4. 技能询问“May I update `assets/localization/fr.csv`?”
5. 更新文件，添加新的空键并标记过时键；verdict 为 GAPS FOUND

**断言：**
- [ ] 新键在更新后的文件中为空（不自动翻译）
- [ ] 删除的键标记为过时（不静默删除）
- [ ] 变更的源字符串标记为需要译者审查
- [ ] Verdict 为 GAPS FOUND（存在新的空键）

---

### 用例 3：一个 locale 缺少字符串——GAPS FOUND 并列出缺失键

**测试夹具：**
- 存在 3 个 locale 文件：`en.csv`、`fr.csv`、`de.csv`
- `de.csv` 缺少同时存在于 `en.csv` 和 `fr.csv` 的 4 个键

**输入：** `/localize`

**预期行为：**
1. 技能读取全部 3 个 locale 文件并交叉引用键
2. `de.csv` 缺少 4 个键
3. 技能生成 GAPS FOUND 报告，按 locale 列出 4 个缺失键：“de.csv 缺少：[key1]、[key2]、[key3]、[key4]”
4. 技能提议将缺失键以空值添加到 `de.csv`
5. 获批后更新文件；verdict 仍为 GAPS FOUND（值仍为空）

**断言：**
- [ ] 明确列出缺失键（不只是数量）
- [ ] 将缺失键归属于具体 locale 文件
- [ ] Verdict 为 GAPS FOUND（不是 LOCALIZATION COMPLETE）
- [ ] 缺失键以空值添加（不从英文自动翻译）

---

### 用例 4：翻译文件存在语法错误——错误信息包含行号

**测试夹具：**
- `assets/localization/fr.csv` 第 47 行格式错误（缺少引号闭合）

**输入：** `/localize fr`

**预期行为：**
1. 技能读取 `fr.csv`，在第 47 行遇到解析错误
2. 技能输出：“fr.csv 第 47 行解析错误：[错误详情]”
3. 错误修复前，技能无法比较或验证文件
4. 技能不会尝试覆盖或自动修复格式错误的文件
5. 技能建议手动修复文件后重新运行 `/localize`

**断言：**
- [ ] 错误消息包含行号（第 47 行）
- [ ] 错误详情说明解析错误的性质
- [ ] 技能不会覆盖或修改格式错误的文件
- [ ] 建议手动修复后重新运行作为补救措施

---

### 用例 5：导演门禁检查——无门禁；`localize` 是管线工具

**测试夹具：**
- 包含面向玩家字符串的源代码

**输入：** `/localize fr`

**预期行为：**
1. 技能提取字符串并管理 locale 文件
2. 不启动导演代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用导演门禁
- [ ] 不出现跳过门禁的消息
- [ ] Verdict 为 LOCALIZATION COMPLETE 或 GAPS FOUND，不是门禁 verdict

---

## 协议合规性

- [ ] 操作 locale 文件前先从源代码提取字符串
- [ ] 创建新 locale 文件时所有键的值为空（不自动翻译）
- [ ] 将已有 locale 文件与当前源字符串进行差异比较
- [ ] 按 locale 和键名标记缺失键
- [ ] 创建或更新 locale 文件前询问“May I write”
- [ ] Verdict 为 LOCALIZATION COMPLETE（所有 locale 已完整翻译）或 GAPS FOUND

---

## 覆盖说明

- 只有所有 locale 文件包含全部键且值非空时，才能达到 LOCALIZATION COMPLETE；创建新语言骨架总是得到 GAPS FOUND。
- 引擎专用 locale 格式（Godot `.translation`、Unity `.po` 文件）由技能正文处理；测试中使用 `.csv` 作为规范格式。
- 源字符串高频变化（持续集成新增 UI 文本）的情况未测试；差异逻辑可以处理该情况。
