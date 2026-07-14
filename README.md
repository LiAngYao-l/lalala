# lalala — LiAng Yao 个人科研脚本库

个人可复用分析代码仓库（成像 / 追踪 / scRNA-seq / 统计作图 / 分子实验）。
**不修改、不推送到共享 HeemskerkLab 仓库。**

---

## Cursor Cloud 能做什么？（简要）

Cursor Cloud Agent 在云端虚拟机里跑，直接连你的 **GitHub 个人仓库**，可以：

| 能力 | 说明 |
|------|------|
| 改代码 / 开 PR | 按你的描述整理脚本、修 bug、写文档，并提交 PR |
| 跑命令 / 测试 | 在云端装依赖、跑脚本（需环境配置好） |
| 跨设备同步 | 医学院 Mac ↔ 家里电脑：只要 `git pull` 同一仓库即可 |
| 不依赖 VPN | 云端访问 GitHub，不需要 UMHS VPN |

**不能直接做的：**

- 读你本机路径（如 `/Users/liangyao/Documents/...`）——云端看不到医学院 Mac 磁盘
- 改共享实验室私有仓库（本仓库策略：**只读参考，零写入 HeemskerkLab**）
- 访问未授权的私有数据 / VPN 内网资源

---

## 你常用的功能 → 本仓库目录

你已说明常用流程，对应结构如下：

| 你的工作 | 目录 |
|----------|------|
| Imaging overview | `imaging/overview/` |
| Segmentation | `imaging/segmentation/` |
| Quantification | `imaging/quantification/` |
| Micropattern（如 scatterMicropattern.m） | `imaging/micropattern/` |
| Video / cell tracking | `imaging/video_tracking/` |
| scRNA-seq 整合与分析 | `scrnaseq/integration/`, `scrnaseq/analysis/` |
| 统计 + 作图（boxplot 等） | `stats_figures/` |
| qPCR 等分子分析 | `molecular/qpcr/` |
| 某个具体实验/论文项目 | `projects/<项目名>/` |
| 给 Cursor Agent 复用的技能说明 | `skills/` |

---

## 快速开始（医学院 Mac → 家里电脑）

### 1. 在医学院 Mac 上：把个人脚本拷进本仓库（不碰共享 repo）

```bash
# 克隆个人仓库（若尚未克隆）
cd ~/Documents
git clone https://github.com/LiAngYao-l/lalala.git
cd lalala
git checkout cursor/research-lab-scaffold-010b   # 或合并后的 master

# 从本地 HeemskerkLab 工作副本 *复制*（不 push 到实验室）
bash scripts/migrate_from_lab_mac.sh \
  "/Users/liangyao/Documents/Data/00 HeemskerkLab"
```

然后检查、提交、推送到 **lalala**：

```bash
git status
git add imaging scrnaseq molecular stats_figures projects
git commit -m "Import personal analysis scripts from local lab workspace"
git push -u origin HEAD
```

### 2. 在家里电脑上

```bash
git clone https://github.com/LiAngYao-l/lalala.git
cd lalala
# 需要时：git pull
```

### 3. 用 Cursor Cloud

在 [cursor.com/agents](https://cursor.com/agents) 把 Agent 绑到 `LiAngYao-l/lalala`，即可让云端帮你改脚本、画图模板、整理项目——结果以 PR 形式回写 GitHub，两边电脑都能拉。

更完整说明见：

- [docs/cursor-cloud.md](docs/cursor-cloud.md) — Cursor Cloud 指南
- [docs/migration.md](docs/migration.md) — 从 HeemskerkLab 迁移
- [docs/project-management.md](docs/project-management.md) — 项目管理约定

---

## 重要原则

1. **共享 HeemskerkLab：只读，不 push、不改远程。**
2. **大文件不进 Git**（`.tif` / `.h5ad` / raw fastq 等已在 `.gitignore`）。
3. **通用工具放模块目录；具体实验放 `projects/`。**
4. **数据路径用配置文件 / 环境变量，不要写死医学院绝对路径。**

---

## 当前状态（Cloud Agent 说明）

云端环境 **无法读取** 你的 Mac 本地目录，也 **无法访问** 私有共享 HeemskerkLab。
因此本 PR 先搭好结构、文档与迁移脚本；请你在医学院 Mac 上跑一次 `migrate_from_lab_mac.sh`，把脚本导入后再告诉 Agent「继续整理 / 去重 / 加 README」。

若你有另一段对话里的 boxplot 代码，可直接粘贴到本 Agent，或在 Mac 上放进 `stats_figures/boxplots/` 后 push。
