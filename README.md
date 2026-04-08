# 001

这是一个 MATLAB 仿真仓库，内容更像论文/毕业设计实验代码，而不是业务应用。
核心主题是多用户下行 RIS/IRS 辅助通信系统中的加权和速率优化、基线对比和收敛曲线绘制，主要实验集中在 `fig4/` 目录。

## 仓库在做什么

`fig4/` 里的代码大致分成四类：

- 数据准备脚本：生成用户位置、路径损耗和信道样本。
- 基线脚本：比较无 RIS、随机 RIS、简化 MRT 等方案。
- 主算法脚本：在完美 CSI / 不完美 CSI / 聚类 / K=8 等场景下跑 AO 或 WMMSE 相关优化。
- 绘图脚本：读取已有 `.mat` 结果文件，画出论文图。

主流程通常是：

1. 运行 `generate_location.m`
2. 运行 `generate_pathloss.m`
3. 运行 `generate_channel.m`
4. 运行基线或主算法脚本
5. 运行 `converge_plot.m` 或其他绘图脚本

## 本次冒烟说明

- 测试时间：2026-04-08
- MATLAB 版本：R2025a
- 工作目录：`D:\001\fig4`
- 测试方式：用 `matlab -batch` 逐个启动脚本
- 判定口径：能直接运行结束记为“通过”；抛异常记为“失败”；超过约 180 秒未结束记为“超时”
- 说明：本次只记录功能和缺陷，不修改 bug

## 脚本级冒烟结果

下表只统计可直接执行的脚本文件，不单独逐个罗列函数文件。函数文件会在对应脚本运行时被间接覆盖到。

| 脚本 | 主要功能 | 结果 | 主要问题 / 备注 |
| --- | --- | --- | --- |
| `generate_location.m` | 生成 4 个用户位置并保存 `user_location.mat` | 通过，约 36s | 会覆盖已有 `user_location.mat` |
| `generate_pathloss.m` | 根据用户位置生成路径损耗并保存 `user_pathloss.mat` | 通过，约 19s | 控制台会额外打印 `Lu-Ld`，日志不够干净 |
| `generate_channel.m` | 生成 Monte Carlo 信道样本并保存 `user_channel.mat` | 通过，约 16s | 会覆盖已有 `user_channel.mat` |
| `without_RIS.m` | 跑“无 RIS”主基线并保存 `down_without_IRS.mat` | 通过，约 45s | 会覆盖已有结果文件 |
| `RIS_phaserand.m` | 跑“随机 RIS 相位”基线并保存 `down_IRS_phaserand.mat` | 超时，180s 内未完成 | 计算较重，不适合作为快速烟测入口 |
| `baseline_no_IRS.m` | 用简化 Rayleigh 信道做无 RIS 基线 | 通过，约 31s | `fig4/baseline_no_IRS.m` 里的 `H = Hd` 缺少分号，控制台会刷出大量矩阵输出 |
| `baseline_RIS_simple.m` | 用简化 Rayleigh 信道做随机 RIS + MRT 基线 | 通过，约 27s | 功能正常 |
| `baseline_IRS_and_no_IRS.m` | 同时比较随机 IRS 和无 IRS 两条基线曲线 | 通过，约 32s | 功能正常 |
| `converge_AO_perfect.m` | 完美 CSI 下，基于 Manopt 的 AO/WMMSE 收敛实验 | 失败，约 14s | 缺少 `complexcirclefactory`，说明依赖 Manopt，当前仓库未自带该依赖 |
| `converge_A2_perfect.m` | 完美 CSI 下的主算法收敛实验 | 超时，180s 内未完成 | 脚本可启动，但作为烟测入口过重，短时间内无法确认最终是否稳定结束 |
| `converge_A2_imperfect.m` | 不完美 CSI 下的鲁棒收敛实验 | 通过，约 161s | 输出 `error Ellipsoid=0`、`error beamforming=0`，但耗时较长 |
| `converge_plot.m` | 读取已有 `.mat` 结果并画总收敛图 | 通过，约 29s | 依赖仓库里已有结果文件，不代表生成链路已全打通；脚本里有裸露的 `rate_w(1)`，会打印 `ans` |
| `generate_user_channel_cluster.m` | 生成聚类实验用信道并保存 `user_channel_cluster.mat` | 通过，约 14s | 会覆盖已有 `user_channel_cluster.mat` |
| `converge_A2_perfect_cluster.m` | 聚类版本的主算法实验 | 失败，约 13s | 出现“Arrays have incompatible sizes”，核心原因是信道矩阵维度约定不一致，`Hd` 与 `Hr*Theta*G` 的方向对不上 |
| `converge_A2_perfect_cluster_v2.m` | 聚类版本的修订实验 | 失败，约 13s | 调用 `kmeans` 时报“Undefined function”，需要 Statistics and Machine Learning Toolbox |
| `generate_user_channel_K8.m` | 生成 K=8 场景信道并保存 `user_channel_K8.mat` | 通过，约 11s | 会覆盖已有 `user_channel_K8.mat` |
| `converge_A2_perfect_K8.m` | K=8 版本主算法实验 | 失败，约 13s | 在 `fig4/update_SINR.m` 越界，说明传入的 `H` 维度与 `init_W/update_SINR` 的 `K x M` 约定不一致 |
| `converge_plot_K8.m` | K=8 绘图脚本 | 通过，约 37s | 该文件内容实际上与 `converge_plot.m` 基本相同，仍在读取普通场景结果，并不是真正的 K=8 专用绘图 |
| `untitled.m` | 草稿备注文件 | 通过，约 10s | 只有注释，没有实际逻辑，相当于 no-op |

## 当前明确暴露出的缺陷

- 依赖缺失：
  `converge_AO_perfect.m` 依赖 Manopt。
  `converge_A2_perfect_cluster_v2.m` 依赖 `kmeans`，即 Statistics and Machine Learning Toolbox。
- 维度约定不统一：
  一部分函数按 `H = K x M` 写，另一部分脚本又按 `H = M x K` 在传，导致聚类版和 K=8 版直接崩溃。
- 部分脚本不适合快速回归：
  `RIS_phaserand.m` 和 `converge_A2_perfect.m` 在烟测窗口内未结束，后续如果要做自动化测试，建议先降迭代次数。
- 日志输出不干净：
  缺分号导致控制台打印大量中间矩阵，最明显的是 `baseline_no_IRS.m`。
- 绘图脚本对结果文件依赖很重：
  `converge_plot.m` 和 `converge_plot_K8.m` 主要是在消费现成 `.mat`，并没有证明对应实验脚本能重新生成这些结果。
- `converge_plot_K8.m` 命名与内容不一致：
  当前更像复制自普通绘图脚本，容易误导使用者。

## 建议的后续排查顺序

1. 先统一所有主算法脚本中的信道矩阵维度约定，明确 `H` 到底是 `K x M` 还是 `M x K`
2. 再补齐外部依赖说明：Manopt、Statistics Toolbox、Parallel Computing Toolbox
3. 给重型脚本增加“快速模式”参数，例如缩小 `ite`、`it`、`num_iter`
4. 最后再修正绘图脚本和控制台输出问题
