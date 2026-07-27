# 设置要求 / Setup Requirements

此模板需要安装少量工具才能获得完整功能。
如果缺少工具，所有 hooks 都会优雅降级并安全失败 —— 不会导致任何功能损坏，但你会失去验证能力。

## 必需项 / Required

| Tool | Purpose | Install |
| ---- | ---- | ---- |
| **Git** | 版本控制、分支管理 | [git-scm.com](https://git-scm.com/) |
| **Claude Code** | AI agent CLI | `npm install -g @anthropic-ai/claude-code` |

## 推荐项 / Recommended

| Tool | Used By | Purpose | Install |
| ---- | ---- | ---- | ---- |
| **jq** | Hooks (4 of 8) | 在 commit/push/asset/agent hooks 中解析 JSON | See below |
| **Python 3** | Hooks (2 of 8) | 对数据文件进行 JSON 校验 | [python.org](https://www.python.org/) |
| **Bash** | All hooks | 执行 shell 脚本 | Git for Windows 自带 |

### 安装 jq / Installing jq

**Windows**（任选其一）：
```
winget install jqlang.jq
choco install jq
scoop install jq
```

**macOS**：
```
brew install jq
```

**Linux**：
```
sudo apt install jq     # Debian/Ubuntu
sudo dnf install jq     # Fedora
sudo pacman -S jq       # Arch
```

## 平台说明 / Platform Notes

### Windows
- Git for Windows 内置 **Git Bash**，可提供 `settings.json` 中所有 hooks 需要的 `bash` 命令
- 请确保 Git Bash 已加入 PATH（通过 Git 安装器默认安装时通常会自动配置）
- hooks 使用 `bash .claude/hooks/[name].sh` —— 这在 Windows 上可用，因为 Claude Code 会通过能够找到 `bash.exe` 的 shell 调用命令

### macOS / Linux
- Bash 原生可用
- 为获得完整 hook 支持，请通过你的包管理器安装 `jq`

## 验证你的环境 / Verifying Your Setup

运行以下命令检查前置条件：

```bash
git --version          # Should show git version
bash --version         # Should show bash version
jq --version           # Should show jq version (optional)
python3 --version      # Should show python version (optional)
```

## 缺少可选工具时会发生什么 / What Happens Without Optional Tools

| Missing Tool | Effect |
| ---- | ---- |
| **jq** | Commit 验证、push 保护、asset 验证以及 agent 审计 hooks 会静默跳过检查。Commits 和 pushes 仍可正常执行。 |
| **Python 3** | commit 和 asset hooks 中的 JSON 数据文件校验会被跳过。无效 JSON 可能在无告警情况下被提交。 |
| **Both** | 所有 hooks 仍会无错误执行（exit 0），但不提供任何验证能力。你将失去安全网保障。 |

## 推荐 IDE / Recommended IDE

Claude Code 可搭配任意编辑器使用，但此模板已针对以下环境优化：
- **VS Code** + Claude Code extension
- **Cursor**（兼容 Claude Code）
- 基于终端的 Claude Code CLI
