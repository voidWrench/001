%把计算好的结果画图
close all
clear all

%baseline1：无IRS
line=1.1;%设置画线粗细
it=1e4;%设置一个最大迭代上限
%初始化

load('down_without_IRS.mat','snr_w','rate_w','M','K','omega');
rate=rate_w(1);%从文件里加载加权和速率（WSR），取第一个数，这是无IRS时的WSR
figure
plot(0:it,rate.*ones(1,it+1),'k-','LineWidth',line);
%without IRS = 一条水平直线
%rate_w(1)是一个固定数，rate.*ones(1,it+1)把这个数复制很多次
%不随迭代变化
%“传统系统”，没有IRS，没有迭代优化
grid on
hold on


%baseline2：随机相位IRS
load('down_IRS_phaserand.mat','snr_w','rate_w','M','K','N','omega');
rate=rate_w(1);
plot(0:it,rate.*ones(1,it+1),'k--','LineWidth',line);
%逻辑一样，有IRS，但IRS相位随机，没有优化
%有IRS，但是随机相位，没有优化，所以还是一条水平线
%有IRS但不优化，性能相比于无IRS好一点，但远不如优化之后的系统。


%%
%Algorithm 2，完美CSI
load('converge_A2_manopt_WMMSE_n5.mat','it','rate_w','M','K','N','omega');
rate_w(1)
plot(0:it,rate_w,'b-','LineWidth',line);
%rate_w是一个向量，每个元素 = 一次AO外层迭代后的WSR，画出来是一条上升曲线
%AO-based方法，在完美CSI下的收敛过程


%AO，另一种相位更新方法
load('converge_speed_step_phi_CG_n5.mat','it','rate_w','M','K','N','omega');
rate_w(1)
plot(0:it,rate_w,'r--','LineWidth',line);
%同样是AO，但是相位优化方法不同，收敛速度/终值略有差异
%比较不同优化策略的收敛行为


%Imperfect CSI，鲁棒性对比
load('converge_stochastic_phi_rho_01_v3.mat','it','rate_w','M','K','N','omega','rho');
plot(0:it,rate_w,'m-','LineWidth',line);
load('converge_stochastic_phi_rho_05_v3.mat','it','rate_w','M','K','N','omega','rho');
plot(0:it,rate_w,'m-.','LineWidth',1.5);
%rho = 0.1/0.5 = CSI误差程度
%CSI越差，性能越低
%这两条曲线是鲁棒性分析
%这里假设信道估计有误差，误差越大，性能越低，验证算法在CSI不完美时的鲁棒性

%结论：完美CSI+AO/Algorithm 2的最终收敛值最高

%%
xlim([0,8e1]);%横轴 = 外层迭代次数
ylim([0.55,0.95]);%纵轴 = 加权和速率
%只显示前80次迭代，0.55~0.95区间
ylabel('WSR'); xlabel('$I_O$','Interpreter','latex');
%这里的$I_O$是Outer Iteration，外层迭代次数
%一次外层迭代：1.固定IRS，优化beamforming；2.beamforming，优化IRS，完成之后计算一次迭代
it=100;
ht=plot(0:it,-1.*ones(1,it+1),'r--',0:it,-1.*ones(1,it+1),'b-',...
    0:it,-1.*ones(1,it+1),'m-',0:it,-1.*ones(1,it+1),'m-.',...
    0:it,-1.*ones(1,it+1),'k--',0:it,-1.*ones(1,it+1),'k-',...
    'linewidth',1.3);
g=legend(ht,'Perfect, Algorithm 2','Perfect, AO', 'Imperfect, $\varrho=0.1$',...
    'Imperfect, $\varrho=0.5$','Random Phase', 'Without RIS');%图例
set(g,'Interpreter','latex','Location','southeast','FontSize',10) ;