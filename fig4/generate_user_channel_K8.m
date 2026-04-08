%% generate_user_channel_K8_correct.m
close all;
clear all;

%% 原系统参数保持
M = 4;
N = 100;
K = 8;
ite = 100;

eb1 = 0.9535;
eb2 = 0.3015;

%% 角度（保持原结构）
AP_angle = rand();
IRS_angle = rand();
User_angle = rand(1,K);

%% 小尺度信道
Hd_w = (randn(M,K,ite) + 1j*randn(M,K,ite))/sqrt(2);   % 4x8x100
Hr_sig = (randn(K,N,ite) + 1j*randn(K,N,ite))/sqrt(2); % 8x100x100
G_sig  = (randn(N,M,ite) + 1j*randn(N,M,ite))/sqrt(2); % 100x4x100

%% 大尺度矩阵（关键修正）
pd = rand(M,K);     % 4x8
ps = rand(K,N);     % 8x100

%% IRS 初始相位（保持原维度）
theta_init = exp(1j*2*pi*rand(N,1,ite));  % 100x1x100

%% 路径损耗（用于weight）
path_d = rand(1,K)+0.5;
path_i = 1e-4*rand(1,K);

save('user_channel_K8.mat', ...
    'K','N','M','ite','pd','ps','Hd_w','theta_init',...
    'AP_angle','IRS_angle','G_sig','User_angle','Hr_sig',...
    'eb1','eb2','path_d','path_i');

disp('生成完成，检查维度：');
whos