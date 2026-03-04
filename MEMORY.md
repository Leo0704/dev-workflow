# Dev-Workflow 项目记忆

> 详细规范见 CLAUDE.md

## 关键约定（跨会话）

- **提交规范**: 不添加 Co-Authored-By 标识
- **需求原则**: 需求不清晰不写代码
- **工作流**: 步骤通过 `.workflow-step` 文件跟踪

## 记忆层次

| 文件 | 作用 | Git 跟踪 |
|------|------|----------|
| `MEMORY.md` | 关键约定（本文件） | ✓ |
| `~/.claude/projects/.../memory/` | 用户级自动记忆 | 独立 |
| `learnings/` | 学习日志 | ✓ |
| `CLAUDE.md` | 项目规范 | ✓ |
