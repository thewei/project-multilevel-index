# 快速开始 (5 分钟上手)

## 1️⃣ 安装插件

```bash
# 复制到 Claude Code 插件目录
cp -r project-multilevel-index ~/.claude/plugins/
```

## 2️⃣ 启用插件

在 Claude Code 中运行：
```
/plugins enable project-multilevel-index
```

## 3️⃣ 初始化索引

进入您的项目目录：
```
cd your-project/
```

运行初始化命令：
```
/init-index
```

Claude 会询问确认，输入 `是的` 后自动：
- 扫描所有代码文件
- 添加文件头注释
- 生成文件夹索引
- 生成项目索引
- 创建依赖关系图

## 4️⃣ 查看结果

打开生成的文件：
- `PROJECT_INDEX.md` - 项目全局视图
- `src/FOLDER_INDEX.md` - 每个文件夹的索引
- 每个代码文件顶部 - Input/Output/Pos 注释

## 5️⃣ 自动更新

现在每次修改代码文件时，索引会自动更新！✨

---

## 核心命令

| 命令 | 用途 |
|------|------|
| `/init-index` | 初始化索引系统 |
| `/update-index` | 手动更新索引 |
| `/check-index` | 检查一致性 |

---

## 文件头注释示例

### JavaScript/TypeScript
```typescript
/**
 * Input: express, bcrypt, ./models/User
 * Output: router, POST /login, POST /register
 * Pos: API层-认证路由
 *
 * 本注释在文件修改时自动更新
 */
```

### Python
```python
"""
Input: flask, sqlalchemy, .models.User
Output: UserController, /api/users 路由
Pos: API层-用户控制器

本注释在文件修改时自动更新
"""
```

### 其他语言
查看 `skills/project-multilevel-index/templates/` 目录

---

## 常见问题

**Q: 索引没有自动更新？**
A: 检查是否为结构性变更（仅修改函数内部不会触发）

**Q: 如何禁用自动更新？**
A: 编辑 `hooks/hooks.json`，移除 PostToolUse 配置

**Q: 如何自定义排除规则？**
A: 创建 `.claude/index-config.json`（见 README）

---

## 支持的语言

✅ JavaScript/TypeScript
✅ Python
✅ Java/Kotlin
✅ Rust
✅ Go
✅ C/C++

---

## 下一步

- 查看 [README.md](README.md) 了解详细功能
- 查看 [SKILL.md](skills/project-multilevel-index/SKILL.md) 了解工作原理
- 运行 `/check-index` 验证索引完整性

---

**开始体验分形文档系统！** 🚀
