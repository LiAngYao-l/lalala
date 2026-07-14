# 项目管理约定（个人科研 GitHub）

目标：脚本可复用、项目可追溯、家里/医学院/Cloud 三端一致。

## 1. 仓库分层

```
通用工具（长期复用）     → imaging/  scrnaseq/  molecular/  stats_figures/
具体实验或论文（短中期） → projects/<name>/
Agent 可调用说明         → skills/
文档                     → docs/
示例小数据               → data/examples/   （大文件永不入库）
```

**规则：** 若一段代码在两个以上项目会用到 → 升到通用模块；若只服务一篇图/一次实验 → 留在 `projects/`。

## 2. 新项目模板

```bash
cp -r projects/_template projects/2026-micropattern-XYZ
```

每个项目保持：

- `README.md` — 科学问题、数据位置（本机路径可写在本地未跟踪的 `paths.local.md`）、主要脚本入口
- `scripts/` — 薄封装，调用上层通用模块
- `notes.md` — 实验记录要点（可选）

## 3. 分支策略（个人仓库）

| 分支 | 用途 |
|------|------|
| `master` | 稳定可跑的工具与已整理项目 |
| `cursor/<topic>-xxxx` | Cloud Agent 工作分支（自动 PR） |
| `project/<name>` | 某论文/课题进行中的改动 |
| `import/...` | 从实验室本地一次性导入 |

小改动可直接 PR 进 `master`；大整理用 Agent 分支。

## 4. 提交信息建议

```
feat(imaging): add batch quantification entry
fix(qpcr): correct delta-Ct column mapping
docs: Chinese Cursor Cloud guide
chore: gitignore raw imaging formats
```

## 5. 版本与论文可复现

发文章前：

```bash
git tag -a paper-2026-xxx-v1 -m "Code freeze for submission"
git push origin paper-2026-xxx-v1
```

在论文 Methods / Code availability 写：`https://github.com/LiAngYao-l/lalala` + tag。

## 6. 与 Cursor Cloud 的分工

| 你来做 | Agent 来做 |
|--------|------------|
| 本机拷贝脚本、判断哪些是「个人常用」 | 去重、重构、补文档、统一接口 |
| 决定科学参数与质控标准 | 实现批处理、画图模板、测试小样例 |
| 保管 raw 数据 | 只处理仓库内脚本与示例表 |

## 7. 不要做的事

- 向 HeemskerkLab **publish / push** 个人分支
- 把整仓实验室历史无筛选地 mirror 进个人仓库（体积大且权属不清）
- 提交含患者/样本可识别信息的表
- 在脚本里写死只有医学院才有的绝对路径（改用 `config` / 相对路径 / 环境变量）
