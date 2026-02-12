# docs_OC

本仓库包含 Codex 文档与流程说明。

## Skill: `push-docs-oc-submodule`

该 skill 用于一键执行以下流程：
1. 把 `docs_OC` 子仓库改动推送到 `git@github.com:ShengNW/docs_OC.git`（SSH）。
2. 在父仓库中只更新 `docs_OC` 子模块指针并推送。

Skill 文件位置：`.agents/skills/push-docs-oc-submodule/SKILL.md`

### 在 Codex 中使用

1. 查看可用 skill：

```bash
/skills
```

2. 显式调用：

```text
$push-docs-oc-submodule 把当前 docs_OC 改动推到 docs_OC.git，并更新父仓库子模块指针
```

### 脚本直跑（等价 fast path）

```bash
./.agents/skills/push-docs-oc-submodule/scripts/push_docs_oc_and_parent.sh \
  --submodule-dir /home/snw/SnwHist/docs_OC \
  --parent-dir /home/snw/SnwHist \
  --submodule-commit-msg "docs: update README for push skill usage" \
  --parent-commit-msg "chore: update docs_OC submodule pointer"
```

### 这个流程会做什么

- 校验子仓库 `origin` 必须是 `git@github.com:ShengNW/docs_OC.git`
- 子仓库有改动则自动提交并推送
- 父仓库只 `git add docs_OC`，避免误提交其它文件
- 父仓库指针有变化才提交并推送
