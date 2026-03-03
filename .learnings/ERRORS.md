# Errors

命令失败、异常和意外行为记录。

---

## 记录格式

```markdown
## [ERR-YYYYMMDD-XXX] command_or_operation

**Logged**: ISO-8601 timestamp
**Priority**: high
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary
简要描述什么失败了

### Error
```
实际错误信息
```

### Context
- 尝试的命令/操作
- 使用的输入或参数
- 环境详情（如相关）

### Suggested Fix
如果可识别，可能的解决方案

### Metadata
- Reproducible: yes | no | unknown
- Related Files: path/to/file.ext
- See Also: ERR-20250110-001 (如重复出现)
```

---
