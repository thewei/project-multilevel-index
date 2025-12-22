---
description: 初始化项目的分形多级索引系统
---

# /init-index - 初始化索引系统

初始化项目的多级索引系统，为整个代码库建立分形文档结构。

> **📌 当前版本 (v1.0)**: 基本功能已实现，高级参数将在 v2.0 实现
>
> 当前支持：基本初始化流程
> 计划中 (v2.0)：`--force`, `--lang`, `--max-depth`, `--dry-run`, `--exclude`, `--include-tests` 等参数

## 功能说明

这将执行以下操作：
1. **扫描项目结构** - 识别所有代码文件（支持 10 种语言）
2. **生成文件头注释** - 为每个文件添加 Input/Output/Pos 注释
3. **创建文件夹索引** - 在每个代码文件夹生成 FOLDER_INDEX.md
4. **生成根索引** - 创建 PROJECT_INDEX.md 和 Mermaid 依赖关系图

## 使用方法

### 基本用法
```
/init-index
```

### 带参数用法
```
/init-index --force              # 强制覆盖现有索引
/init-index --lang ts,py         # 仅处理 TypeScript 和 Python
/init-index --max-depth 3        # 限制目录深度为 3 层
/init-index --dry-run            # 预览将生成的内容，不实际写入
```

## 参数说明

| 参数 | 说明 | 默认值 | 示例 |
|------|------|--------|------|
| `--force` | 强制覆盖现有的索引文件 | false | `--force` |
| `--lang <languages>` | 限定处理的语言（逗号分隔） | 全部 | `--lang js,ts,py` |
| `--max-depth <number>` | 限制扫描的目录深度 | 无限制 | `--max-depth 5` |
| `--dry-run` | 预览模式，不实际写入文件 | false | `--dry-run` |
| `--exclude <patterns>` | 额外的排除模式 | 见配置 | `--exclude "test/**,docs/**"` |
| `--include-tests` | 包含测试文件 | false | `--include-tests` |

## 支持的语言

- JavaScript/TypeScript (`.js`, `.jsx`, `.ts`, `.tsx`)
- Python (`.py`)
- Java/Kotlin (`.java`, `.kt`)
- Rust (`.rs`)
- Go (`.go`)
- C/C++ (`.c`, `.cpp`, `.h`, `.hpp`)
- PHP (`.php`)
- Ruby (`.rb`)
- Swift (`.swift`)
- C# (`.cs`)

## 执行流程

1. **确认项目根目录** - 询问用户确认当前目录
2. **扫描代码文件** - 使用 Glob 工具快速扫描
3. **分析依赖关系** - 解析每个文件的 import/export
4. **生成文件头** - 智能插入或更新注释（保留用户自定义内容）
5. **创建索引文件** - 从叶子文件夹到根目录逐级生成
6. **生成依赖图** - 创建 Mermaid 可视化图表
7. **输出报告** - 显示处理统计和后续建议

## 示例输出

```
✅ 索引系统初始化完成!

已生成:
- 57 个文件头注释
- 8 个 FOLDER_INDEX.md
- 1 个 PROJECT_INDEX.md
- 依赖关系图包含 25 个节点、38 条边

下一步:
- 查看 PROJECT_INDEX.md 了解整体架构
- 使用 /update-index 手动更新索引
- 使用 /check-index 检查一致性
```

## 注意事项

- ⚠️ 如果文件已有头注释，将**智能合并**而非覆盖
- ⚠️ 建议在初始化前**提交当前代码**到 Git
- ⚠️ 大型项目（1000+ 文件）可能需要数分钟
- ⚠️ 使用 `--dry-run` 可以先预览效果

## 故障排除

**问题**: 初始化卡住不动
**解决**: 可能遇到大文件，使用 `--exclude` 排除大文件目录

**问题**: 某些文件的依赖分析不准确
**解决**: 检查文件语法是否正确，或手动调整文件头注释

**问题**: 想重新生成所有索引
**解决**: 使用 `--force` 参数强制覆盖

---

遵循 `skills/project-multilevel-index/SKILL.md` 中的"命令 1: 初始化索引"流程执行。
