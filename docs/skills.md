# 一起创建与使用 Skills（中文指南）

## Skills 是什么？

Skills 是 Cursor 的可复用指令包。每个 skill 是一个文件夹：

```text
.cursor/skills/figure-boxplot/SKILL.md
```

Agent 启动时会扫描仓库里的 `.cursor/skills/`。因此：**skill 跟代码一起进 Git，就能在 Mac / 笔记本 / Cloud 共用。**

这正好解决你的目标——医学院电脑不能远程，但家里只要 `git pull` 就能用同一套分析习惯。

## 和「脚本」的分工

| 东西 | 作用 | 位置 |
|------|------|------|
| Skill | 告诉 Agent 按什么流程做 | `.cursor/skills/*/SKILL.md` |
| 可复用脚本 | 真正计算 | `imaging/` `scrnaseq/` `molecular/` `stats_figures/` |
| 项目包装 | 某次实验/某篇图 | `projects/<name>/` |

没有脚本时，skill 仍能指导 Agent 写新代码；脚本到位后，再把 skill 补成「调用哪个入口文件」。

## 当前技能库

- `imaging-batch` — 成像流水线
- `video-tracking` — 追踪
- `scrnaseq-integrate` — 单细胞整合
- `figure-boxplot` — 统计作图
- `qpcr-analysis` — qPCR
- `new-analysis-project` — 开新项目目录

## 日常用法

**显式调用：** 聊天输入 `/imaging-batch`  
**隐式调用：** 直接说「帮我做 micropattern quantification」，Agent 会匹配 description

**跨设备：**

```bash
# 在一台机器上创建/更新 skill 后
git add .cursor/skills
git commit -m "skills: add or update ..."
git push

# 另一台机器
git pull
# 重新打开 Cursor 或新开 Agent，即可看到 skill
```

## 我们一起迭代的约定

当你说类似下面的话时，我会更新 skill（而不是只改一次对话）：

- 「把这个 boxplot 流程固化成 skill」
- 「以后做 qPCR 都按这次的参数」
- 「imaging 默认先 overview 再 seg」

每个 skill 必须包含：

1. `name` + `description`（给 Agent 自动匹配用）
2. 默认目录
3. 禁止事项（含：不碰 HeemskerkLab）
4. 检查清单 / 交付物

## 旧的 `skills/*.md` 草稿

早期占位文件已改为索引；**请以 `.cursor/skills/` 为准。**
