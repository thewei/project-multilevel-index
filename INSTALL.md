# 安装指南

## 方法 1: 手动安装（推荐）

### Windows

```powershell
# 1. 复制插件到 Claude Code 插件目录
cp -r h:\Project\Claud_skill\project-multilevel-index "$env:USERPROFILE\.claude\plugins\"

# 2. 重启 Claude Code（如果已运行）

# 3. 启用插件
# 在 Claude Code 中运行:
# /plugins enable project-multilevel-index
```

### macOS/Linux

```bash
# 1. 复制插件到 Claude Code 插件目录
cp -r /path/to/project-multilevel-index ~/.claude/plugins/

# 2. 设置权限
chmod -R 755 ~/.claude/plugins/project-multilevel-index

# 3. 启用插件
# 在 Claude Code 中运行:
# /plugins enable project-multilevel-index
```

---

## 方法 2: 符号链接（开发模式）

如果您想继续修改插件，使用符号链接：

### Windows（需要管理员权限）

```powershell
# 以管理员身份运行 PowerShell
New-Item -ItemType SymbolicLink `
  -Path "$env:USERPROFILE\.claude\plugins\project-multilevel-index" `
  -Target "h:\Project\Claud_skill\project-multilevel-index"
```

### macOS/Linux

```bash
ln -s /path/to/project-multilevel-index ~/.claude/plugins/project-multilevel-index
```

---

## 验证安装

### 1. 检查插件是否被识别

在 Claude Code 中运行：

```
/plugins list
```

您应该看到 `project-multilevel-index` 在列表中。

### 2. 启用插件

```
/plugins enable project-multilevel-index
```

### 3. 测试命令

```
/init-index --help
```

如果显示帮助信息，说明安装成功！

---

## 故障排除

### 问题 1: 插件未出现在列表中

**检查**：
1. 确认文件路径正确
2. 确认 `.claude-plugin/plugin.json` 存在
3. 检查文件权限（Linux/macOS）

**解决**：
```bash
# 重新复制插件
rm -rf ~/.claude/plugins/project-multilevel-index
cp -r /path/to/project-multilevel-index ~/.claude/plugins/

# 重启 Claude Code
```

### 问题 2: 命令无法识别

**检查**：
1. 插件是否已启用？运行 `/plugins list` 确认
2. 命令文件是否存在？检查 `commands/` 目录

**解决**：
```
/plugins disable project-multilevel-index
/plugins enable project-multilevel-index
```

### 问题 3: Hook 未触发

**检查**：
1. `hooks/hooks.json` 文件是否存在
2. JSON 格式是否正确

**解决**：
运行 JSON 验证器：
```bash
cat hooks/hooks.json | jq .
```

---

## 卸载插件

### 完全卸载

```bash
# Windows (PowerShell)
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\plugins\project-multilevel-index"

# macOS/Linux
rm -rf ~/.claude/plugins/project-multilevel-index
```

### 仅禁用（保留插件文件）

```
/plugins disable project-multilevel-index
```

---

## 更新插件

### 手动更新

```bash
# 1. 删除旧版本
rm -rf ~/.claude/plugins/project-multilevel-index

# 2. 复制新版本
cp -r /path/to/new-version/project-multilevel-index ~/.claude/plugins/

# 3. 重启 Claude Code
```

### 符号链接更新

如果使用符号链接，直接在源目录更新文件即可，无需重新安装。

---

## 下一步

安装完成后，查看 [README.md](README.md) 了解使用方法，或直接运行：

```
/init-index
```

开始体验分形文档系统！🚀
