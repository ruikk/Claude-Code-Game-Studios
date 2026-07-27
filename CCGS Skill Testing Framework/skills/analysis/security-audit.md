# 技能测试规范：/security-audit

## 技能摘要

`/security-audit` 审计存档完整性、网络通信、反作弊暴露面和数据隐私。
读取 `src/` 中的源文件检查安全模式和敏感数据处理。
不调用总监门禁，不写入文件（仅输出发现报告）。
结论：SECURE、CONCERNS 或 VULNERABILITIES FOUND。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键字：SECURE、CONCERNS、VULNERABILITIES FOUND
- [ ] 不要求 "May I write"（只读；仅生成发现报告）
- [ ] 包含下一步交接

---

## 总监门禁检查

无。安全审计是只读建议技能，不调用门禁。

---

## 测试用例

### 用例 1：正常路径——存档已加密且没有硬编码凭据

**测试夹具：**
- `src/core/save_system.gd` 使用 `Crypto` 类在写入前加密存档数据
- `src/` 中没有硬编码 API 密钥、密码或凭据
- 面向玩家的输出没有暴露版本号或内部构建 ID

**输入：** `/security-audit`

**预期行为：**
1. 扫描 `src/` 的加密、硬编码凭据和内部信息暴露模式
2. 存档已加密、未找到凭据且没有内部信息暴露
3. 发现报告显示所有检查为 PASS
4. 结论为 SECURE

**断言：**
- [ ] 检查存档处理是否使用加密
- [ ] 扫描硬编码凭据（API 密钥、密码、令牌）
- [ ] 检查暴露给玩家的版本/构建编号
- [ ] 发现报告显示所有检查
- [ ] 全部检查通过时结论为 SECURE

---

### 用例 2：发现漏洞——未加密存档且暴露版本

**测试夹具：**
- `src/core/save_system.gd` 将存档写为普通 JSON（未加密）
- `src/ui/debug_overlay.gd` 包含：`label.text = "Build: " + ProjectSettings.get("application/config/version")`
  （向玩家暴露内部构建版本）

**输入：** `/security-audit`

**预期行为：**
1. 扫描 `src/`，发现 `save_system.gd` 写入未加密存档
2. 在 `debug_overlay.gd` 发现暴露的版本字符串
3. 两项发现均标记为 VULNERABILITIES
4. 结论为 VULNERABILITIES FOUND
5. 为每项漏洞提供修复建议

**断言：**
- [ ] 将未加密存档标记为漏洞，并给出文件和大致行号
- [ ] 将暴露版本字符串标记为漏洞
- [ ] 为每项漏洞给出修复建议
- [ ] 检测到任一漏洞时结论为 VULNERABILITIES FOUND
- [ ] 不写入或修改文件

---

### 用例 3：在线功能无身份验证——CONCERNS

**测试夹具：**
- `src/networking/lobby.gd` 存在函数：`join_lobby()`、`send_chat()`
- `send_chat()` 前没有身份验证检查，玩家可在未验证时调用
- 根据文件存在可推断游戏有在线多人功能

**输入：** `/security-audit`

**预期行为：**
1. 扫描 `src/networking/` 并检测在线功能代码
2. 检查网络调用前的身份验证保护，发现 `send_chat()` 没有保护
3. 标记：“在线功能缺少身份验证检查——CONCERNS”
4. 结论为 CONCERNS（这是控制缺失而非漏洞利用）

**断言：**
- [ ] 通过扫描网络源文件检测在线功能
- [ ] 标记网络操作前缺失的身份验证检查
- [ ] 缺少身份验证保护时结论为 CONCERNS
- [ ] 输出建议在网络调用前添加身份验证

---

### 用例 4：边界情况——没有可分析的源文件

**测试夹具：** `src/` 目录不存在或完全为空。

**输入：** `/security-audit`

**预期行为：**
1. 尝试扫描 `src/`，未找到文件
2. 输出错误：“在 `src/` 中未找到源文件，没有可审计内容”
3. 不生成发现报告
4. 不输出结论

**断言：**
- [ ] `src/` 为空或不存在时不崩溃
- [ ] 输出明确说明未找到源文件
- [ ] 不输出结论
- [ ] 建议确认 `src/` 目录路径

---

### 用例 5：门禁合规——不调用门禁；可另行咨询 security-engineer

**测试夹具：** 
- 存在源文件；发现 1 个 CONCERNS 级问题（发布构建启用了调试日志）；
- `review-mode.txt` 包含 `full`。

**输入：** `/security-audit`

**预期行为：**
1. 扫描源文件，发现发布路径启用了调试日志
2. 无论审查模式为何，均不调用总监门禁
3. 结论为 CONCERNS
4. 输出说明：“如需正式安全审查，建议请 security-engineer 代理参与”
5. 以只读报告展示发现，不写入文件

**断言：**
- [ ] 任何审查模式下均不调用总监门禁
- [ ] 建议（而非强制）咨询 security-engineer
- [ ] 不写入文件
- [ ] 建议级安全发现的结论为 CONCERNS

---

## 协议合规性

- [ ] 审计前读取 `src/` 中的源文件
- [ ] 检查存档加密、硬编码凭据、内部信息暴露和身份验证保护
- [ ] 为每项发现提供修复建议
- [ ] 不写入任何文件（只读技能）
- [ ] 不调用总监门禁
- [ ] 结论为 SECURE、CONCERNS、VULNERABILITIES FOUND 之一

---

## 覆盖说明

- 反作弊分析（客户端数值验证、服务器权威）未在此处明确测试，依据严重程度遵循 CONCERNS 或 VULNERABILITIES 模式。
- 数据隐私合规（GDPR、COPPA）不在此规范范围内，需要法律审查。
