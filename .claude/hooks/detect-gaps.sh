#!/bin/bash
# 钩子: detect-gaps.sh
# 事件: SessionStart
# 用途: 当代码/原型存在时检测缺失的文档
# 跨平台: 兼容 Windows Git Bash (使用 grep -E, 而非 -P)

# 出错时不退出 (但不要阻断会话)
set +e

echo "=== 正在检查文档缺口 ==="

# --- 检查 0: 新项目检测 (建议运行 /start) ---
FRESH_PROJECT=true

# 检查引擎是否已配置
if [ -f ".claude/docs/technical-preferences.md" ]; then
  ENGINE_LINE=$(grep -E "^\- \*\*Engine\*\*:" .claude/docs/technical-preferences.md 2>/dev/null)
  if [ -n "$ENGINE_LINE" ] && ! echo "$ENGINE_LINE" | grep -q "TO BE CONFIGURED" 2>/dev/null; then
    FRESH_PROJECT=false
  fi
fi

# 检查游戏概念是否存在
if [ -f "design/gdd/game-concept.md" ]; then
  FRESH_PROJECT=false
fi

# 检查源代码是否存在
if [ -d "src" ]; then
  SRC_CHECK=$(find src -type f \( -name "*.gd" -o -name "*.cs" -o -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.rs" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -1)
  if [ -n "$SRC_CHECK" ]; then
    FRESH_PROJECT=false
  fi
fi

if [ "$FRESH_PROJECT" = true ]; then
  echo ""
  echo "🚀 新项目: 未配置引擎，没有游戏概念，没有源代码。"
  echo "   看起来是一个全新的开始！请运行: /start"
  echo ""
  echo "💡 要获取全面的项目分析，请运行: /project-stage-detect"
  echo "==================================="
  exit 0
fi

# --- 检查 1: 大量代码但设计文档稀少 ---
if [ -d "src" ]; then
  # Count source files (cross-platform, handles Windows paths)
  SRC_FILES=$(find src -type f \( -name "*.gd" -o -name "*.cs" -o -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.rs" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | wc -l)
else
  SRC_FILES=0
fi

if [ -d "design/gdd" ]; then
  DESIGN_FILES=$(find design/gdd -type f -name "*.md" 2>/dev/null | wc -l)
else
  DESIGN_FILES=0
fi

# Normalize whitespace from wc output
SRC_FILES=$(echo "$SRC_FILES" | tr -d ' ')
DESIGN_FILES=$(echo "$DESIGN_FILES" | tr -d ' ')

if [ "$SRC_FILES" -gt 50 ] && [ "$DESIGN_FILES" -lt 5 ]; then
  echo "⚠️  缺口: 大量代码库 ($SRC_FILES 个源文件) 但设计文档稀少 ($DESIGN_FILES 个文件)"
  echo "    建议操作: /reverse-document design src/[system]"
  echo "    或运行: /project-stage-detect 获取完整分析"
fi

# --- 检查 2: 没有文档的原型 ---
if [ -d "prototypes" ]; then
  PROTOTYPE_DIRS=$(find prototypes -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  UNDOCUMENTED_PROTOS=()

  if [ -n "$PROTOTYPE_DIRS" ]; then
    while IFS= read -r proto_dir; do
      # Normalize path separators for Windows
      proto_dir=$(echo "$proto_dir" | sed 's|\\|/|g')

      # Check for README.md or CONCEPT.md
      if [ ! -f "${proto_dir}/README.md" ] && [ ! -f "${proto_dir}/CONCEPT.md" ]; then
        proto_name=$(basename "$proto_dir")
        UNDOCUMENTED_PROTOS+=("$proto_name")
      fi
    done <<< "$PROTOTYPE_DIRS"

    if [ ${#UNDOCUMENTED_PROTOS[@]} -gt 0 ]; then
      echo "⚠️  缺口: 发现 ${#UNDOCUMENTED_PROTOS[@]} 个未记录文档的原型:"
      for proto in "${UNDOCUMENTED_PROTOS[@]}"; do
        echo "    - prototypes/$proto/ (没有 README 或 CONCEPT 文档)"
      done
      echo "    建议操作: /reverse-document concept prototypes/[name]"
    fi
  fi
fi

# --- 检查 3: 核心系统缺少架构文档 ---
if [ -d "src/core" ] || [ -d "src/engine" ]; then
  if [ ! -d "docs/architecture" ]; then
    echo "⚠️  缺口: 核心引擎/系统已存在但没有 docs/architecture/ 目录"
    echo "    建议操作: 创建 docs/architecture/ 并运行 /architecture-decision"
  else
    ADR_COUNT=$(find docs/architecture -type f -name "*.md" 2>/dev/null | wc -l)
    ADR_COUNT=$(echo "$ADR_COUNT" | tr -d ' ')

    if [ "$ADR_COUNT" -lt 3 ]; then
      echo "⚠️  缺口: 核心系统已存在但仅记录了 $ADR_COUNT 个 ADR"
      echo "    建议操作: /reverse-document architecture src/core/[system]"
    fi
  fi
fi

# --- 检查 4: 游戏系统缺少设计文档 ---
if [ -d "src/gameplay" ]; then
  # Find major gameplay subdirectories (those with 5+ files)
  GAMEPLAY_SYSTEMS=$(find src/gameplay -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

  if [ -n "$GAMEPLAY_SYSTEMS" ]; then
    while IFS= read -r system_dir; do
      system_dir=$(echo "$system_dir" | sed 's|\\|/|g')
      system_name=$(basename "$system_dir")
      file_count=$(find "$system_dir" -type f 2>/dev/null | wc -l)
      file_count=$(echo "$file_count" | tr -d ' ')

      # If system has 5+ files, check for corresponding design doc
      if [ "$file_count" -ge 5 ]; then
        # Check for design doc (allow variations: combat-system.md, combat.md)
        design_doc_1="design/gdd/${system_name}-system.md"
        design_doc_2="design/gdd/${system_name}.md"

        if [ ! -f "$design_doc_1" ] && [ ! -f "$design_doc_2" ]; then
          echo "⚠️  缺口: 游戏系统 src/gameplay/$system_name/ ($file_count 个文件) 没有设计文档"
          echo "    预期: design/gdd/${system_name}-system.md 或 design/gdd/${system_name}.md"
          echo "    建议操作: /reverse-document design src/gameplay/$system_name"
        fi
      fi
    done <<< "$GAMEPLAY_SYSTEMS"
  fi
fi

# --- 检查 5: 生产规划 ---
if [ "$SRC_FILES" -gt 100 ]; then
  # For projects with substantial code, check for production planning
  if [ ! -d "production/sprints" ] && [ ! -d "production/milestones" ]; then
    echo "⚠️  缺口: 大型代码库 ($SRC_FILES 个文件) 但未找到生产规划"
    echo "    建议操作: /sprint-plan 或创建 production/ 目录"
  fi
fi

# --- Summary ---
echo ""
echo "💡 要获取全面的项目分析，请运行: /project-stage-detect"
echo "==================================="

exit 0
