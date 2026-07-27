# 技能测试规范：/asset-audit

## 技能摘要

`/asset-audit` 审计 `assets/` 目录中的命名规范合规性、元数据缺失以及格式/大小问题。
它依据 `technical-preferences.md` 中定义的规范和预算检查资产文件。不调用总监门禁。
未经用户批准，该技能不会写入。结论为：COMPLIANT、WARNINGS 或 NON-COMPLIANT。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：COMPLIANT、WARNINGS、NON-COMPLIANT
- [ ] 不要求使用 "May I write" 措辞（只读；可选报告需要批准）
- [ ] 包含下一步交接（获得审计结果后要做什么）

---

## 总监门禁检查

无。资产审计是只读分析技能，不调用任何门禁。

---

## 测试用例

### 用例 1：正常路径——所有资产均遵循命名规范

**测试夹具：**
- `technical-preferences.md` 指定命名规范为 `snake_case`，例如 `enemy_grunt_idle.png`
- `assets/art/characters/` 包含：`enemy_grunt_idle.png`、`enemy_sniper_run.png`
- `assets/audio/sfx/` 包含：`sfx_jump_land.ogg`、`sfx_item_pickup.ogg`
- 所有文件均未超出大小预算（纹理 ≤2MB，音频 ≤500KB）

**输入：** `/asset-audit`

**预期行为：**
1. 技能从 `technical-preferences.md` 读取命名规范和大小预算
2. 技能递归扫描 `assets/`
3. 所有文件均符合 `snake_case` 规范且未超出预算
4. 审计表中所有行均显示 PASS
5. 结论为 COMPLIANT

**断言：**
- [ ] 审计同时覆盖美术和音频资产目录
- [ ] 按命名规范和大小预算检查每个文件
- [ ] 合规时所有行均显示 PASS
- [ ] 结论为 COMPLIANT
- [ ] 不写入任何文件

---

### 用例 2：不合规——纹理超出大小预算

**测试夹具：**
- `assets/art/environment/` 包含 5 个纹理文件
- 其中 3 个纹理文件各为 4MB（预算：≤2MB）
- 另外 2 个纹理文件未超出预算

**输入：** `/asset-audit`

**预期行为：**
1. 技能从 `technical-preferences.md` 读取大小预算（纹理为 2MB）
2. 技能扫描 `assets/art/environment/`，发现 3 个过大的纹理
3. 审计表列出每个过大文件的实际大小和预算
4. 结论为 NON-COMPLIANT
5. 技能建议压缩被标记的文件或降低其分辨率

**断言：**
- [ ] 按名称列出全部 3 个过大文件及其实际大小和预算大小
- [ ] 任一文件超出预算时，结论为 NON-COMPLIANT
- [ ] 为过大文件给出优化建议
- [ ] 为保证完整性，也列出预算内文件（显示 PASS）

---

### 用例 3：格式问题——音频格式错误

**测试夹具：**
- `technical-preferences.md` 指定音频格式为 OGG
- 存在 `assets/audio/music/theme_main.wav`（WAV 格式）
- 存在 `assets/audio/sfx/sfx_footstep.ogg`（正确的 OGG 格式）

**输入：** `/asset-audit`

**预期行为：**
1. 技能读取音频格式要求：OGG
2. 技能扫描 `assets/audio/`，发现 `theme_main.wav` 格式错误
3. 审计表将 `theme_main.wav` 标记为 FORMAT ISSUE（预期 OGG，实际 WAV）
4. `sfx_footstep.ogg` 显示 PASS
5. 结论为 WARNINGS（格式问题可以修正）

**断言：**
- [ ] 将 `theme_main.wav` 标记为 FORMAT ISSUE，并注明预期和实际格式
- [ ] 对可修正的格式问题，结论为 WARNINGS（而非 NON-COMPLIANT）
- [ ] 格式正确的资产显示为 PASS
- [ ] 技能不修改或转换任何资产文件

---

### 用例 4：资产缺失——GDD 引用的资产未出现在 assets/ 中

**测试夹具：**
- `design/gdd/enemies.md` 引用了 `enemy_boss_idle.png`
- `assets/art/characters/boss/` 目录为空，该文件不存在

**输入：** `/asset-audit`

**预期行为：**
1. 技能读取 GDD 引用以查找预期资产（与 `/content-audit` 的范围交叉引用）
2. 技能扫描 `assets/art/characters/boss/`，未找到文件
3. 审计表将 `enemy_boss_idle.png` 标记为 MISSING ASSET
4. 结论为 NON-COMPLIANT（缺少关键美术资产）

**断言：**
- [ ] 技能检查 GDD 引用以识别预期资产
- [ ] 将缺失资产标记为 MISSING ASSET，并注明 GDD 引用
- [ ] 缺少关键资产时，结论为 NON-COMPLIANT
- [ ] 技能不创建或添加占位资产

---

### 用例 5：门禁合规——不调用门禁；可另行咨询 technical-artist

**测试夹具：**
- 2 个文件违反命名规范（使用 CamelCase 而非 snake_case）
- `review-mode.txt` 包含 `full`

**输入：** `/asset-audit`

**预期行为：**
1. 技能扫描资产并发现 2 处命名违规
2. 无论审查模式为何，均不调用总监门禁
3. 结论为 WARNINGS
4. 输出说明：“建议请技术美术审查命名规范”
5. 技能展示发现，并询问是否写入可选审计报告
6. 如果用户选择写入，则询问："May I write to `production/qa/asset-audit-[date].md`?"

**断言：**
- [ ] 任何审查模式下均不调用总监门禁
- [ ] 建议（而非强制）咨询技术美术
- [ ] 在任何写入提示前展示发现表
- [ ] 写入可选审计报告前询问 "May I write"

---

## 协议合规性

- [ ] 从 `technical-preferences.md` 读取命名规范、格式和大小预算
- [ ] 递归扫描 `assets/` 目录
- [ ] 审计表显示文件名、检查类型、预期值、实际值和结果
- [ ] 不修改任何资产文件
- [ ] 不调用总监门禁
- [ ] 结论为 COMPLIANT、WARNINGS、NON-COMPLIANT 之一

---

## 覆盖说明

- 此处未明确测试元数据检查（例如 Godot `.import` 文件中缺少纹理导入设置）；
  它们遵循相同的 FORMAT ISSUE 标记模式。
- `/asset-audit` 与 `/content-audit` 的交互（两者都检查 GDD 引用与资产的对应关系）
  是有意的范围重叠；`/asset-audit` 侧重合规性，`/content-audit` 侧重完整性。
