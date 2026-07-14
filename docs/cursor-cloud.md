# Cursor Cloud 简介与使用指南

面向：在医学院 Mac（有 UMHS VPN、不便远程）与家里电脑之间，用个人 GitHub 仓库同步科研脚本。

## 1. Cursor Cloud 是什么？

Cursor Cloud Agent 是跑在 **云端虚拟机** 上的编程助手：

- 绑定你的 GitHub 仓库（这里是 `LiAngYao-l/lalala`）
- 按你的自然语言任务：改代码、写文档、开 PR、跑测试
- 不占用医学院电脑；也不需要你开着 Mac

本地 Cursor Desktop 则直接改本机文件夹；两者都可以，**以 GitHub 为唯一真相来源（source of truth）**。

## 2. 和「共享实验室 GitHub」怎么配合？

| 仓库 | 角色 | 本策略 |
|------|------|--------|
| HeemskerkLab（共享） | 实验室公共代码 | **只读参考；禁止 push / 禁止改远程** |
| `LiAngYao-l/lalala`（个人） | 你的可复用工具 + 项目脚本 | Agent 与你日常提交的目标仓库 |

推荐工作流：

```
医学院 Mac 本地脚本
        │  复制（cp），不是 fork-push 实验室
        ▼
   LiAngYao-l/lalala (GitHub)
        │  git pull / Cursor Cloud PR
        ▼
   家里电脑 / 云端 Agent
```

## 3. 推荐日常操作

### 在医学院 Mac

1. 只在 `lalala` 里提交个人代码。
2. 从实验室文件夹 **复制** 需要带走的 `.m` / `.R` / `.py` / notebook。
3. 不要把 raw 图像、大矩阵推进 Git。
4. 每天离开前：`git push`。

### 在家里电脑

1. `git pull`
2. 用 Cursor Desktop 打开 `lalala`
3. 需要云端代劳时：到 Agents 发任务（例如「给 segmentation 写一个批量入口」）

### 对 Cloud Agent 下任务时，尽量写清

- **目标目录**（如 `imaging/quantification/`）
- **语言**（MATLAB / Python / R）
- **输入输出**（CSV？图？Seurat 对象？）
- **不要动什么**（始终写：不要改 HeemskerkLab）

示例：

> 在 `stats_figures/boxplots/` 里整理我贴的 ggplot 代码，做成可复用函数；不要改任何实验室共享仓库。

## 4. 环境与 VPN

- Cloud **不连** UMHS VPN，也 **读不到** `/Users/liangyao/...`
- 依赖 GitHub 上的代码与你上传/提交的小样本数据
- 需要医学院内网数据时：在 Mac 上算完，只把 **脚本 + 汇总表** 推进 `lalala`

## 5. 安全与学术规范

- 不要提交密码、VPN 配置、未公开的人类样本标识信息
- 引用实验室公共方法时在 README 注明来源；个人改动的脚本写明作者与日期
- 论文代码：在 `projects/<论文名>/` 固定版本（可用 git tag）

## 6. 常见问题

**Q: 为什么 Agent 说拷不过代码？**  
A: 云端没有你的 Mac 磁盘。请在本机跑 `scripts/migrate_from_lab_mac.sh` 后 push。

**Q: LiAng 分支要不要 Publish 到实验室？**  
A: **不需要。** 个人代码走 `lalala`。未 publish 的实验室分支正好避免误推共享仓库。

**Q: 家里 MATLAB / R 版本不一致？**  
A: 在各模块 README 记录依赖（MATLAB toolbox、`sessionInfo()`、`requirements.txt`）。
