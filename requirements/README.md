# 需求文档目录

将需求文档放在此目录，工作流会自动识别。

## 目录结构

```
requirements/
├── 2026-03-03-功能名称/    ← 按日期+功能命名
│   ├── prd.pdf            ← 需求文档
│   └── 设计图.png          ← 设计稿
└── README.md              ← 本文件
```

## 使用方式

1. 创建需求目录：
   ```bash
   mkdir -p requirements/$(date +%Y-%m-%d)-功能名称
   ```

2. 放入需求文档

3. 切换到该任务：
   ```bash
   echo "$(date +%Y-%m-%d)-功能名称" > task/.current-task
   ```

4. 启动工作流：`/dev-workflow`
