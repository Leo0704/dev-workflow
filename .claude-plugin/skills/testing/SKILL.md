---
name: testing
description: |
  测试验证技能 - 设计和执行测试用例。

  触发场景：用户说"测试"、"写测试"、"测试用例"、"单元测试"、"集成测试"、
  "E2E测试"、"测试计划"、"验证功能"、"测试覆盖"。

  当需要编写测试用例、执行测试验证、生成测试报告时，使用此技能。
  支持单元测试、集成测试、E2E测试等多种测试类型。
user-invokable: true
---

老板好！这是测试验证技能。

---

## 执行流程

### 步骤 1: 制定测试计划

```bash
# 读取实施计划，了解需要测试的功能
cat task/{当前任务}/plan-report.md

# 使用模板生成测试计划
cat skills/testing/templates/test-plan.md
```

### 步骤 2: 编写测试用例

使用模板: `templates/test-cases.md`

为每个功能点编写测试用例：
- 正常流程测试
- 边界条件测试
- 异常流程测试

### 步骤 3: 执行测试

```bash
# 运行单元测试
npm test / yarn test / pnpm test

# 运行集成测试
npm run test:integration

# 运行 E2E 测试
npm run test:e2e
```

### 步骤 4: 生成测试报告

使用模板: `templates/test-report.md`

```bash
# 读取模板
cat skills/testing/templates/test-report.md

# 填充后保存到
task/{当前任务}/test-report.md
```

---

## 测试类型

1. **单元测试** - 函数/方法级别
2. **集成测试** - 模块间交互
3. **E2E 测试** - 完整业务流程
4. **边界测试** - 极端输入、并发场景

---

## 输出文件

生成文件到 `task/{任务名}/`:
- `test-plan.md` - 测试计划
- `test-cases.md` - 测试用例
- `test-report.md` - 测试报告

---

## 核心原则

- 覆盖率优先：确保核心逻辑覆盖
- 边界优先：重点关注边界条件
- 独立性：测试用例相互独立
- 可重复：测试结果稳定可重复
