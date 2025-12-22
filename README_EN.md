# Project Multi-level Index System

<div align="center">

> A Fractal Self-Referential Documentation System Inspired by "Gödel, Escher, Bach"
>
> Making code projects self-referential, self-maintaining, and harmoniously elegant like a fugue

[![Version](https://img.shields.io/badge/version-1.0.2-blue)](https://github.com/Claudate/project-multilevel-index/releases)
[![I18N](https://img.shields.io/badge/i18n-zh--CN%20%7C%20en--US-orange)](I18N_GUIDE.md)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-purple)](https://claude.ai/code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**🔧 Claude Code Plugin** | [English](#) | [简体中文](README.md)

</div>

---

## 🎯 What is This?

This is a **Claude Code plugin** that automatically maintains a three-level fractal documentation system for your codebase:

```
PROJECT_INDEX.md (Root Index)
  ├─ Project overview & architecture
  ├─ Directory structure navigation
  └─ Mermaid dependency graph

Each Folder/
  └─ FOLDER_INDEX.md (Folder Index)
       ├─ 3-line architecture description
       ├─ File manifest
       └─ "Update me when this folder changes"

Each File
  └─ File Header Comment
       ├─ Input: What it depends on
       ├─ Output: What it provides
       ├─ Pos: Position in the system
       └─ "Update me and my indices when I change"
```

### Three Core Principles

- **🔄 Self-Similarity**: Each level has the same index structure
- **🪞 Self-Reference**: Each document declares "update me when I change"
- **🎼 Polyphony**: Code and documentation echo each other; local changes affect the whole

---

## ⚡ Quick Start

### Prerequisites

**You must have Claude Code installed first!**

- Download: https://claude.ai/code
- This is a **Claude Code plugin**, not a standalone tool
- Does NOT work with Cursor, Windsurf, or VSCode (yet)

### 1. Install the Plugin

**From GitHub** (Recommended):

```bash
git clone https://github.com/Claudate/project-multilevel-index.git
cd project-multilevel-index

# Windows (PowerShell)
Copy-Item -Path . -Destination "$env:USERPROFILE\.claude\plugins\project-multilevel-index" -Recurse

# macOS/Linux
cp -r . ~/.claude/plugins/project-multilevel-index
```

**Plugin Directory Locations**:
- Windows: `%USERPROFILE%\.claude\plugins\`
- macOS/Linux: `~/.claude/plugins/`

### 2. Enable the Plugin

In Claude Code, run:

```
/plugins enable project-multilevel-index
```

### 3. Initialize Your Project

In your project root directory:

```
/init-index
```

That's it! The plugin will:
- ✅ Scan all code files (10 languages supported)
- ✅ Generate file header comments with Input/Output/Pos
- ✅ Create FOLDER_INDEX.md in each directory
- ✅ Generate PROJECT_INDEX.md with dependency graph
- ✅ Auto-update on file changes (via Hook)

---

## 🌟 Features

### Automatic Updates

Once initialized, the index auto-updates whenever you modify code files (via PostToolUse Hook).

**No manual work needed!**

### 10 Programming Languages

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

### Smart Dependency Analysis

Automatically detects:
- Import statements (`import`, `require`, `use`, `#include`)
- Export declarations (`export`, `public`, `class`, `function`)
- Circular dependencies (with warnings)

### Mermaid Visualization

Generated dependency graphs render beautifully on:
- GitHub
- VSCode (with Mermaid extension)
- Obsidian
- Any Markdown viewer with Mermaid support

---

## 🚀 Commands

### `/init-index` - Initialize Index System

First-time setup or full rebuild.

```
/init-index
```

**What it does**:
1. Scans project structure
2. Generates file header comments
3. Creates FOLDER_INDEX.md files
4. Generates PROJECT_INDEX.md with Mermaid graph
5. Outputs summary report

### `/update-index` - Update Index

Manual refresh after changes.

```
/update-index
```

**What it does**:
1. Detects file changes
2. Re-analyzes dependencies
3. Updates affected indices
4. Reports what changed

### `/check-index` - Consistency Check

Verify index integrity.

```
/check-index
```

**What it checks**:
1. ✅ File header completeness
2. ✅ Folder index consistency
3. ✅ Circular dependencies
4. ✅ Missing or orphaned files
5. ✅ Structural compliance

### `/set-language` - Switch UI Language

Change interface language.

```
/set-language
```

Choose between:
- 简体中文 (zh-CN)
- English (en-US)

---

## 📖 Example Output

### File Header Comment (TypeScript)

```typescript
/**
 * Input: bcrypt, ./models/User, ./utils/logger
 * Output: createUser(), authenticateUser(), UserService class
 * Pos: Business Layer - User Authentication Service
 *
 * This comment auto-updates when the file is modified, triggering
 * FOLDER_INDEX and PROJECT_INDEX updates.
 */

import bcrypt from 'bcrypt';
import { User } from './models/User';
import { logger } from './utils/logger';

export class UserService {
  // ...
}
```

### FOLDER_INDEX.md Example

```markdown
# src/services Folder Index

## Architecture

Business logic layer encapsulating core business rules and data access.
Uses service pattern with each service corresponding to a business domain.

## File Manifest

### userService.ts
- **Role**: Core user management service
- **Function**: User CRUD, authentication, authorization
- **Dependencies**: database, logger, User model
- **Used By**: userController, authMiddleware

### authService.ts
- **Role**: Authentication & authorization service
- **Function**: JWT generation, token validation, login/logout
- **Dependencies**: userService, config, bcrypt
- **Used By**: authController, authMiddleware

---
⚠️ **Self-Reference**: Update this index when folder contents change
```

---

## 🔧 Configuration

### Disable Auto-Update

Edit `hooks/hooks.json` and remove the `PostToolUse` Hook configuration.

### Customize Exclude Patterns

Currently excludes:
- `node_modules`, `.git`, `dist`, `build`, `.next`
- `target`, `vendor`, `__pycache__`, `.cache`
- `coverage`, `.turbo`, `.venv`, `pnpm-store`, `.yarn`

**Note**: Custom exclude patterns will be supported in v2.0 via `.claude/index-config.json`

---

## 🌍 Internationalization

Full i18n support with dynamic language switching:

**Switch Language**:
```
/set-language
```

**Or manually** create `.claude/locale-config.json`:
```json
{
  "language": "en-US",
  "fallback": "zh-CN"
}
```

**Supported Languages**:
- 🇨🇳 简体中文 (zh-CN) - Default
- 🇺🇸 English (en-US)

📖 Full guide: [I18N_GUIDE.md](I18N_GUIDE.md)

---

## 📚 Documentation

- [**Installation Guide**](INSTALL_GUIDE.md) - Detailed setup instructions
- [**Quick Start**](QUICKSTART.md) - Get up and running in 5 minutes
- [**I18N Guide**](I18N_GUIDE.md) - Language configuration
- [**Contributing**](CONTRIBUTING.md) - How to contribute
- [**Changelog**](CHANGELOG.md) - Version history
- [**Bug Fixes**](BUG_FIXES_v1.0.2.md) - v1.0.2 fixes

---

## 🐛 Troubleshooting

### Hook Not Triggering?

1. Check Hook is enabled: `cat ~/.claude/plugins/project-multilevel-index/hooks/hooks.json`
2. Verify file extension is supported (must be a code file)
3. Ensure file is not in excluded directory

### Index Out of Sync?

Run a manual update:
```
/update-index
```

Or full rebuild:
```
/init-index
```

### Language Not Switching?

1. Check `.claude/locale-config.json` exists
2. Verify JSON syntax is valid
3. Restart Claude Code

---

## 🗺️ Roadmap

### v2.0 (Planned)
- [ ] Command-line parameters (`--force`, `--lang`, `--exclude`)
- [ ] Configuration file support (`.claude/index-config.json`)
- [ ] Auto-fix feature (`--fix`)
- [ ] Report export (`--report json/md`)

### v2.1 (Future)
- [ ] VSCode extension (may work with Cursor)
- [ ] More languages (Dart, Elixir, Scala)
- [ ] Standalone CLI tool
- [ ] LSP integration

### v3.0 (Vision)
- [ ] AI-powered refactoring suggestions
- [ ] Interactive dependency browser
- [ ] Architecture evolution timeline
- [ ] Team collaboration features

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code of Conduct
- Development setup
- Pull request process
- Coding standards

**Quick Links**:
- [Issue Tracker](https://github.com/Claudate/project-multilevel-index/issues)
- [Discussions](https://github.com/Claudate/project-multilevel-index/discussions)

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

**Summary**: You can use, modify, and distribute this plugin freely, even commercially.

---

## 🙏 Acknowledgments

- **Inspiration**: "Gödel, Escher, Bach: An Eternal Golden Braid" by Douglas Hofstadter
- **Platform**: Claude Code by Anthropic
- **Community**: Early adopters and contributors

---

## ⚠️ Important Notes

### Platform Requirements

- ✅ **Claude Code CLI** - Full support
- ❌ **Cursor** - Not supported
- ❌ **Windsurf** - Not supported
- ❌ **VSCode** - Not supported (planned for v2.1)

This plugin requires Claude Code's Hook and Skill systems.

### Performance

| Project Size | Init Time | Update Time |
|-------------|-----------|-------------|
| Small (<100 files) | <10s | <2s |
| Medium (100-500) | <30s | <5s |
| Large (500-1000) | <2min | <10s |
| Huge (1000+) | <5min | <30s |

### File Size Limit

Files >500KB are skipped for performance. Adjust in future versions via config.

---

## 📞 Support

- **Bug Reports**: [GitHub Issues](https://github.com/Claudate/project-multilevel-index/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/Claudate/project-multilevel-index/discussions)
- **Questions**: Open a discussion or issue

---

<div align="center">

**Made with ❤️ by the Claude Code Community**

**⭐ Star us on [GitHub](https://github.com/Claudate/project-multilevel-index) if you find this useful!**

</div>

---

**Let your code projects become like fugues – self-referential, self-maintaining, elegantly harmonious!** 🎼
