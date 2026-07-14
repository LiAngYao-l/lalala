# Skills（我们一起沉淀的可复用能力）

Skills 是给 Cursor Agent 的「标准作业程序」。写进 Git 后，**医学院 Mac、家里电脑、Cursor Cloud** 都会自动读到同一套。

## 存放位置（重要）

Cursor 只会自动发现：

```text
.cursor/skills/<skill-name>/SKILL.md
```

本目录 `skills/` 只做人读的索引；真正生效的是 `.cursor/skills/`。

## 已创建的 skills

| Skill | 调用方式 | 用途 |
|-------|----------|------|
| `imaging-batch` | `/imaging-batch` 或描述成像分析 | overview → seg → quant / micropattern |
| `video-tracking` | `/video-tracking` | 视频与细胞追踪 |
| `scrnaseq-integrate` | `/scrnaseq-integrate` | scRNA-seq 整合与下游分析 |
| `figure-boxplot` | `/figure-boxplot` | 统计检验 + box/violin 图 |
| `qpcr-analysis` | `/qpcr-analysis` | qPCR ΔCt / ΔΔCt |
| `new-analysis-project` | `/new-analysis-project` | 新建 `projects/<name>/` |

## 怎么用（家里 / 医学院 / Cloud 一样）

1. 打开本仓库（`lalala`）
2. 在聊天里输入 `/` 选 skill，或直接说需求（Agent 会按 description 自动匹配）
3. 例：`/figure-boxplot 用这张 CSV 按 Genotype 画 boxplot，做 Wilcoxon`

## 我们怎么一起「继续创建」skills

当你发现某一类对话要反复解释时，就该沉淀成 skill：

1. 告诉 Agent：「把刚才的流程做成 skill：`xxx-name`」
2. Agent 写入 `.cursor/skills/xxx-name/SKILL.md` 并 commit
3. `git push` 后，另一台电脑 `git pull` 即可用

Skill 要写清：**何时触发、改哪些目录、禁止事项（尤其不要碰 HeemskerkLab）、交付物是什么**。

## 与脚本的关系

- **Skill** = 怎么做（流程 + 约定）
- **模块代码** = 真正跑的 `.m` / `.R` / `.py`（在 `imaging/` 等目录）
- 导入实验室脚本后，我们会回头在 skill 里补上「实际入口命令」

详见：`docs/skills.md`
