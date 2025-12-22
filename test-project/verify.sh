#!/bin/bash
# 索引系统验证脚本

echo "======================================="
echo "项目多级索引系统 - 验证脚本"
echo "======================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

# 检查函数
check_file() {
  if [ -f "$1" ]; then
    echo -e "${GREEN}✓${NC} 文件存在: $1"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} 文件缺失: $1"
    ((FAILED++))
    return 1
  fi
}

check_content() {
  if grep -q "$2" "$1" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} 包含内容: $1 -> $2"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} 缺少内容: $1 -> $2"
    ((FAILED++))
    return 1
  fi
}

echo "1. 检查文件头注释"
echo "-----------------------------------"
check_file "src/models/User.ts"
check_content "src/models/User.ts" "Input:"
check_content "src/models/User.ts" "Output:"
check_content "src/models/User.ts" "Pos:"

check_file "src/utils/logger.ts"
check_content "src/utils/logger.ts" "Input:"
check_content "src/utils/logger.ts" "Output:"

check_file "src/services/user.service.ts"
check_content "src/services/user.service.ts" "Input:"
check_content "src/services/user.service.ts" "Output:"

check_file "src/services/auth.service.ts"
check_content "src/services/auth.service.ts" "Input:"

check_file "src/controllers/user.controller.ts"
check_content "src/controllers/user.controller.ts" "Input:"

check_file "src/controllers/auth.controller.ts"
check_content "src/controllers/auth.controller.ts" "Input:"

echo ""
echo "2. 检查文件夹索引"
echo "-----------------------------------"
check_file "src/models/FOLDER_INDEX.md"
check_content "src/models/FOLDER_INDEX.md" "User.ts"

check_file "src/utils/FOLDER_INDEX.md"
check_content "src/utils/FOLDER_INDEX.md" "logger.ts"

check_file "src/services/FOLDER_INDEX.md"
check_content "src/services/FOLDER_INDEX.md" "user.service.ts"
check_content "src/services/FOLDER_INDEX.md" "auth.service.ts"

check_file "src/controllers/FOLDER_INDEX.md"
check_content "src/controllers/FOLDER_INDEX.md" "user.controller.ts"
check_content "src/controllers/FOLDER_INDEX.md" "auth.controller.ts"

echo ""
echo "3. 检查根索引"
echo "-----------------------------------"
check_file "PROJECT_INDEX.md"
check_content "PROJECT_INDEX.md" "项目概览"
check_content "PROJECT_INDEX.md" "架构说明"
check_content "PROJECT_INDEX.md" "依赖关系图"
check_content "PROJECT_INDEX.md" "```mermaid"

echo ""
echo "4. 检查依赖关系"
echo "-----------------------------------"
if [ -f "PROJECT_INDEX.md" ]; then
  if grep -q "UserService" "PROJECT_INDEX.md"; then
    echo -e "${GREEN}✓${NC} 依赖图包含 UserService"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} 依赖图缺少 UserService"
    ((FAILED++))
  fi

  if grep -q "AuthService" "PROJECT_INDEX.md"; then
    echo -e "${GREEN}✓${NC} 依赖图包含 AuthService"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} 依赖图缺少 AuthService"
    ((FAILED++))
  fi

  if grep -q "Logger" "PROJECT_INDEX.md"; then
    echo -e "${GREEN}✓${NC} 依赖图包含 Logger"
    ((PASSED++))
  else
    echo -e "${YELLOW}⚠${NC}  依赖图可能缺少 Logger (可选)"
  fi
fi

echo ""
echo "======================================="
echo "验证完成"
echo "======================================="
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 所有检查通过！索引系统工作正常。${NC}"
  exit 0
else
  echo -e "${RED}❌ 发现 $FAILED 个问题，请检查索引生成。${NC}"
  echo ""
  echo "建议操作:"
  echo "  1. 运行 /init-index 重新生成索引"
  echo "  2. 运行 /check-index 查看详细报告"
  exit 1
fi
