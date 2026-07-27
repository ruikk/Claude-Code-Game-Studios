# 技能测试规范：/ux-review

## 技能摘要

`/ux-review` 根据无障碍和交互标准验证现有 UX 规格或 HUD 设计文档。它检查必需章节（用户流程、交互状态、线框图说明、无障碍说明）、交互状态定义的完整性（悬停、聚焦、禁用、错误）、无障碍合规性（键盘导航、颜色对比度说明、屏幕阅读器注意事项），以及与美术圣经或设计系统的一致性（如果这些文档存在）。

该技能只读，不写入任何文件。结论包括：APPROVED（所有检查均通过）、NEEDS REVISION（发现可修复问题）或 MAJOR REVISION NEEDED（存在结构或无障碍问题）。无需主管门禁，`/ux-review` 本身就是 UX 规格的审查门禁。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 包含至少 2 个阶段标题
- [ ] 包含结论关键字：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 不包含 "May I write" 措辞（该技能只读）
- [ ] 包含下一步移交（例如返回 `/ux-design` 修订，或继续实现）

---

## 主管门禁检查

无。`/ux-review` 本身就是 UX 规格的审查门禁，不会在该技能内调用其他主管门禁。

---

## 测试用例

### 用例 1：正常路径，完整 UX 规格包含所有必需章节，APPROVED

**夹具：**
- `design/ux/hud.md` 存在，且所有必需章节均已填写：
  - 用户流程：完整的玩家流程图
  - 交互状态：已定义正常、悬停、聚焦、禁用、错误
  - 线框图说明：已描述布局
  - 无障碍说明：包含键盘导航、对比度和屏幕阅读器说明

**输入：** `/ux-review hud`

**预期行为：**
1. 技能读取 `design/ux/hud.md`
2. 技能检查全部 4 个必需章节，均存在且非空
3. 技能检查交互状态，全部 5 种状态均已定义
4. 技能检查无障碍说明，已涵盖键盘、对比度和屏幕阅读器
5. 技能输出所有已通过检查的清单
6. 结论为 APPROVED

**断言：**
- [ ] 检查全部 4 个必需章节
- [ ] 验证全部 5 种交互状态均存在
- [ ] 结论为 APPROVED
- [ ] 不写入任何文件

---

### 用例 2：缺少无障碍章节，NEEDS REVISION

**夹具：**
- `design/ux/hud.md` 存在，但无障碍说明章节为空
- 其他所有章节均已完整填写

**输入：** `/ux-review hud`

**预期行为：**
1. 技能读取文件并检查所有章节
2. 无障碍说明章节为空，检查失败
3. 技能输出："NEEDS REVISION，无障碍说明章节为空"
4. 技能列出需要添加的具体项目：键盘导航、颜色对比度、屏幕阅读器标签
5. 结论为 NEEDS REVISION
6. 移交建议返回 `/ux-design hud` 填写该章节

**断言：**
- [ ] 返回 NEEDS REVISION 结论（而非 APPROVED 或 MAJOR REVISION NEEDED）
- [ ] 列出具体缺失的内容项
- [ ] 移交指向 `/ux-design hud` 进行修订
- [ ] 不写入任何文件

---

### 用例 3：交互状态不完整，NEEDS REVISION

**夹具：**
- `design/ux/settings-menu.md` 存在
- 交互状态章节仅定义正常和悬停
- 缺少聚焦、禁用和错误状态

**输入：** `/ux-review settings-menu`

**预期行为：**
1. 技能读取文件并检查交互状态
2. 5 种必需状态中仅定义了 2 种
3. 技能报告："NEEDS REVISION，交互状态不完整：缺少聚焦、禁用、错误"
4. 结论为 NEEDS REVISION，并明确指出缺失状态

**断言：**
- [ ] 返回 NEEDS REVISION 结论
- [ ] 输出中明确指出全部 3 种缺失状态
- [ ] 技能不会因可修复缺口返回 MAJOR REVISION NEEDED
- [ ] 移交建议返回 `/ux-design settings-menu`

---

### 用例 4：文件不存在，返回错误和修复建议

**夹具：**
- `design/ux/inventory-screen.md` 不存在

**输入：** `/ux-review inventory-screen`

**预期行为：**
1. 技能尝试读取 `design/ux/inventory-screen.md`，但文件不存在
2. 技能输出："未找到 UX 规格：design/ux/inventory-screen.md"
3. 技能建议先运行 `/ux-design inventory-screen` 创建规格
4. 不执行审查，也不发布结论

**断言：**
- [ ] 错误消息使用完整路径指出缺失文件
- [ ] 建议以 `/ux-design inventory-screen` 作为修复方式
- [ ] 不生成审查清单
- [ ] 不发布结论（这是错误状态，不是 APPROVED/NEEDS REVISION）

---

### 用例 5：主管门禁检查，无额外门禁；ux-review 本身就是审查

**夹具：**
- 有效的 UX 规格文件

**输入：** `/ux-review hud`

**预期行为：**
1. 技能执行审查并发布结论
2. 不生成其他主管代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用主管门禁
- [ ] 不出现门禁跳过消息
- [ ] 结论为 APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED，不使用门禁结论

---

## 协议合规性

- [ ] 检查全部 4 个必需章节（用户流程、交互状态、线框图、无障碍说明）
- [ ] 检查全部 5 种交互状态（正常、悬停、聚焦、禁用、错误）
- [ ] 检查无障碍覆盖范围（键盘导航、对比度、屏幕阅读器）
- [ ] 不写入任何文件
- [ ] 当结论不是 APPROVED 时，给出具体且可执行的反馈
- [ ] 最后将下一步移交给 `/ux-design` 修订或继续实现

---

## 覆盖说明

- 当结构章节完全缺失（不只是为空），或基础交互流程完全缺失时，会触发 MAJOR REVISION NEEDED；此处没有使用单独夹具进行测试。
- 美术圣经/设计系统一致性检查（调色板一致性）已作为能力提及，但未使用单独夹具测试。
- 未测试现有规格对应的界面后来被重命名的情况；无论名称如何，该技能都会按路径审查文件。
