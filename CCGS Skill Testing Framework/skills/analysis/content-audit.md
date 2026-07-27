# 技能测试规范：/content-audit

## 技能摘要

`/content-audit` 读取 `design/gdd/` 中的 GDD，检查其中指定的所有内容项（敌人、物品、
关卡等）是否都已在 `assets/` 中登记。它生成缺口表：内容类型 → 指定数量 → 找到数量
→ 缺失项。不调用总监门禁。未经用户批准，技能不会写入。结论为：COMPLETE、GAPS FOUND
或 MISSING CRITICAL CONTENT。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：COMPLETE、GAPS FOUND、MISSING CRITICAL CONTENT
- [ ] 不要求使用 "May I write" 措辞（只读输出；写入报告是可选操作）
- [ ] 包含下一步交接（审查缺口表后要做什么）

---

## 总监门禁检查

无。内容审计是只读分析技能，不调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——所有指定内容均存在

**测试夹具：**
- `design/gdd/enemies.md` 指定 4 种敌人：Grunt、Sniper、Tank、Boss
- `assets/art/characters/` 包含目录：`grunt/`、`sniper/`、`tank/`、`boss/`
- `design/gdd/items.md` 指定 3 种物品；全部 3 种均在 `assets/data/items/` 中找到

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 `design/gdd/` 中的所有 GDD
2. 技能在 `assets/` 中扫描每项指定内容
3. 找到全部 4 种敌人和 3 种物品
4. 缺口表显示所有行的找到数量 = 指定数量，且没有缺失项
5. 结论为 COMPLETE

**断言：**
- [ ] 缺口表覆盖 GDD 中找到的所有内容类型
- [ ] 每行显示指定数量和找到数量
- [ ] 数量相等时没有缺失项
- [ ] 结论为 COMPLETE
- [ ] 不写入任何文件

---

### 用例 2：发现缺口——assets 中缺少一种敌人

**测试夹具：**
- `design/gdd/enemies.md` 指定 3 种敌人：Grunt、Sniper、Boss
- `assets/art/characters/` 仅包含 `grunt/`、`sniper/`（缺少 Boss 目录）

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 GDD，发现指定了 3 种敌人
2. 技能扫描 `assets/art/characters/`，仅找到 2 种
3. 敌人行显示：指定 3，找到 2，缺失：Boss
4. 结论为 GAPS FOUND

**断言：**
- [ ] 缺口表按名称指出缺失项 "Boss"
- [ ] 同时显示指定数量（3）和找到数量（2）
- [ ] 缺少任一内容项时，结论为 GAPS FOUND
- [ ] 技能不假定资产以后会添加，而是立即标记

---

### 用例 3：未找到 GDD 内容规范——提供指引

**测试夹具：**
- `design/gdd/` 仅包含 `core-loop.md`，且没有内容清单章节
- 没有其他包含内容规范的 GDD

**输入：** `/content-audit`

**预期行为：**
1. 技能读取所有 GDD，未找到内容清单章节
2. 技能输出：“GDD 中未找到内容规范，请先运行 `/design-system` 定义内容列表”
3. 不生成缺口表
4. 结论为 GAPS FOUND（没有规范就无法确认完整性）

**断言：**
- [ ] 不存在 GDD 内容规范时，技能不生成缺口表
- [ ] 输出建议运行 `/design-system`
- [ ] 结论反映无法确认完整性

---

### 用例 4：边界情况——资产格式不符合目标平台

**测试夹具：**
- `design/gdd/audio.md` 指定音频资产格式为 OGG
- 存在 `assets/audio/sfx/jump.wav`（WAV 格式，而非 OGG）
- 存在 `assets/audio/sfx/land.ogg`（格式正确）
- `technical-preferences.md` 指定音频格式为 OGG

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 GDD 音频规范和技术偏好中的格式要求
2. 技能找到 `jump.wav`，文件存在但格式错误
3. 音频行显示：指定 2，找到 2（按名称），但将 `jump.wav` 标记为 FORMAT ISSUE
4. 结论为 GAPS FOUND（格式合规是内容完整性的一部分）

**断言：**
- [ ] 指定格式时，技能依据 GDD 或技术偏好检查资产格式
- [ ] 将 `jump.wav` 标记为 FORMAT ISSUE，并注明预期格式（OGG）
- [ ] 缺口表将格式问题与内容缺失区分开
- [ ] 存在格式问题时，结论为 GAPS FOUND

---

### 用例 5：门禁合规——只读；不调用门禁；缺口表供人工审查

**测试夹具：**
- GDD 指定 10 项内容；assets 中找到 9 项，缺失 1 项
- `review-mode.txt` 包含 `full`

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 GDD 并扫描资产，生成缺口表
2. 无论审查模式为何，均不调用总监门禁
3. 技能以只读输出形式向用户展示缺口表
4. 结论为 GAPS FOUND
5. 技能提供写入审计报告的选项，但不自动写入

**断言：**
- [ ] 任何审查模式下均不调用总监门禁
- [ ] 展示缺口表且不自动写入文件
- [ ] 提供但不强制写入可选报告
- [ ] 技能不修改任何资产文件

---

## 协议合规性

- [ ] 生成缺口表前读取 GDD 和资产目录
- [ ] 缺口表显示内容类型、指定数量、找到数量、缺失项
- [ ] 未经用户明确批准不写入文件
- [ ] 不调用总监门禁
- [ ] 结论为 COMPLETE、GAPS FOUND、MISSING CRITICAL CONTENT 之一

---

## 覆盖说明

- 当缺失项在 GDD 中标记为 critical 时，结论为 MISSING CRITICAL CONTENT（而非 GAPS FOUND）；
  此处未明确测试，但遵循相同的检测路径。
- 此处未测试 `assets/` 目录不存在的情况；技能会对所有指定项给出 MISSING CRITICAL CONTENT。
