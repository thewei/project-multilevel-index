---
description: 手动更新项目索引系统
---

# /update-index - 更新索引

手动触发项目索引的增量或全量更新。

## 功能说明

这将执行以下操作：
1. **检测文件变更** - 识别自上次更新以来的代码变化
2. **重新分析依赖** - 解析变更文件的 import/export 关系
3. **更新文件头** - 刷新受影响文件的 Input/Output 注释
4. **更新文件夹索引** - 同步 FOLDER_INDEX.md
5. **刷新根索引** - 必要时重新生成 PROJECT_INDEX.md 和依赖图

## 使用方法

### 基本用法（增量更新）
```
/update-index
```
自动检测变更并仅更新受影响的文件。

### 全量更新
```
/update-index --full
```
重新扫描整个项目，等同于 `/init-index --force`。

### 指定文件更新
```
/update-index src/services/auth.ts
/update-index src/models/**/*.py
```

## 参数说明

| 参数 | 说明 | 默认值 | 示例 |
|------|------|--------|------|
| `--full` | 全量更新整个项目 | false | `--full` |
| `--file <path>` | 仅更新指定文件 | 全部变更 | `--file src/user.ts` |
| `--folder <path>` | 仅更新指定文件夹 | 全部变更 | `--folder src/models` |
| `--skip-deps` | 跳过依赖图重新生成 | false | `--skip-deps` |
| `--verbose` | 显示详细处理日志 | false | `--verbose` |

## 更新策略

### 智能检测变更类型

| 变更内容 | 变更类型 | 更新范围 |
|---------|---------|---------|
| 新增/删除文件 | Structural | 文件夹索引 + 根索引 |
| Import 语句变化 | Structural | 文件头 + 文件夹索引 + 根索引 |
| Export 声明变化 | Structural | 文件头 + 文件夹索引 |
| 函数签名改变 | Signature | 文件头 + 文件夹索引 |
| 仅文件头注释修改 | Header | 仅文件头 |
| 函数内部实现 | Implementation | **不更新** |

### 批量优化

如果短时间内多个文件变更：
- 收集所有变更，批量处理
- 每个文件夹的 FOLDER_INDEX 只更新一次
- PROJECT_INDEX 仅在最后更新一次

## 示例输出

### 增量更新
```
检测到 3 个文件变更:
  ✓ src/services/auth.ts (新增 import bcrypt)
  ✓ src/models/User.ts (修改 export)
  ✓ src/utils/validator.ts (仅内部实现)

已更新:
  - 2 个文件头注释
  - 2 个 FOLDER_INDEX.md
  - 1 个 PROJECT_INDEX.md (更新依赖图)

耗时: 1.2 秒
```

### 全量更新
```
正在全量扫描项目...
发现 57 个代码文件

已更新:
  - 57 个文件头注释
  - 8 个 FOLDER_INDEX.md
  - 1 个 PROJECT_INDEX.md

耗时: 8.5 秒
```

## 使用场景

### 场景 1: 日常开发后同步
```
# 修改了几个文件后
/update-index
```

### 场景 2: 大规模重构后
```
# 重构了整个模块
/update-index --full
```

### 场景 3: 仅更新特定模块
```
# 只想更新某个文件夹
/update-index --folder src/auth
```

### 场景 4: 验证单个文件
```
# 检查某个文件的依赖是否正确
/update-index --file src/index.ts --verbose
```

## 注意事项

- ✅ 更新会**保留用户手动添加的注释**
- ✅ 仅在确实有变化时才写入文件
- ✅ 自动跳过索引文件本身（防止循环）
- ⚠️ 全量更新可能需要较长时间

## 与 Hook 自动更新的区别

| 特性 | Hook 自动更新 | 手动 /update-index |
|-----|--------------|-------------------|
| 触发方式 | 文件修改后自动 | 用户手动执行 |
| 处理范围 | 单个文件 | 可指定范围 |
| 输出详情 | 简短提示 | 详细报告 |
| 性能 | 快速 | 较慢（全面扫描） |
| 适用场景 | 日常编码 | 重构、验证 |

---

遵循 `skills/project-multilevel-index/SKILL.md` 中的"命令 2: 更新索引"流程执行。
