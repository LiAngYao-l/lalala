# 从 HeemskerkLab 本地副本迁移到 lalala

## 目标

把你在医学院 Mac 上使用的 **个人/常用** 分析脚本，整理进个人仓库 `LiAngYao-l/lalala`，以便家里电脑和 Cursor Cloud 使用。

## 硬性约束

- **不修改**共享 HeemskerkLab 远程仓库（不 commit、不 push、不 publish 实验室分支）。
- 只从本地目录 **复制文件**。
- 默认源路径：`/Users/liangyao/Documents/Data/00 HeemskerkLab`

## 为什么 Cloud Agent 没法直接拷？

当前 Agent 跑在云端，绑定的是 `lalala`：

1. 无法访问 `/Users/liangyao/...`
2. 无法读取私有共享 HeemskerkLab（无权限且策略禁止写入）

因此迁移分两步：**本机复制 → push 到 lalala →（可选）再让 Agent 整理**。

## 推荐步骤（医学院 Mac）

### A. 准备个人仓库

```bash
cd ~/Documents
git clone https://github.com/LiAngYao-l/lalala.git
cd lalala
git pull
```

### B. 运行迁移脚本（复制，不碰远程实验室）

```bash
bash scripts/migrate_from_lab_mac.sh \
  "/Users/liangyao/Documents/Data/00 HeemskerkLab"
```

脚本会：

- 按文件名/文件夹启发式分类到 `imaging/`、`scrnaseq/`、`molecular/`、`stats_figures/`
- 生成 `MIGRATION_REPORT.md` 列出复制了什么
- **不会**对 HeemskerkLab 执行任何 git 写操作

### C. 人工检查（重要）

打开报告，确认：

- 只要你的常用脚本，不要整仓实验室无关大目录
- 去掉含敏感路径/密码的文件
- 把「只属于某个实验」的脚本移到 `projects/<实验名>/`

### D. 提交到个人 GitHub

```bash
git checkout -b import/lab-scripts-$(date +%Y%m%d)
git add imaging scrnaseq molecular stats_figures projects MIGRATION_REPORT.md
git status   # 再看一眼
git commit -m "Import personal scripts from local HeemskerkLab workspace (copy-only)"
git push -u origin HEAD
```

然后在 GitHub 开 PR 合并进 `master`（或让 Cursor Cloud 继续整理后合并）。

## 你已确认的功能清单（导入优先级）

按优先级建议先拷：

1. **Imaging**：overview / segmentation / quantification / micropattern  
2. **Video + cell tracking**  
3. **scRNA-seq** integration & analysis  
4. **Stats + figures**（boxplot 等；若在另一聊天里，请粘贴或本机放入 `stats_figures/boxplots/`）  
5. **qPCR 等 molecular**  

## 手动映射参考（截图中的例子）

| 本地相对路径（示例） | 目标 |
|----------------------|------|
| `micropattern/scatterMicropattern.m` | `imaging/micropattern/scatterMicropattern.m` |
| `segmentation/*.m` | `imaging/segmentation/` |
| `quantification/*.m` | `imaging/quantification/` |
| `tracking/*` | `imaging/video_tracking/` |
| `*qpcr*` / `*qPCR*` | `molecular/qpcr/` |
| `*boxplot*` / ggplot 脚本 | `stats_figures/boxplots/` |
| Seurat / scanpy 脚本 | `scrnaseq/` |

## 导入后请告诉 Agent 的下一句话（模板）

> 我已经把脚本 push 到 lalala。请根据 MIGRATION_REPORT.md 去重、补各目录 README、把硬编码路径改成可配置，并检查 MATLAB/R/Python 入口是否清晰。不要碰 HeemskerkLab。
