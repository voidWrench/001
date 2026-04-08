clear
clc

%% system parameters

M = 4;      % AP antennas
N = 16;     % IRS elements
K = 12;     % 用户数量（聚类必须多一点）
ite = 50;   % Monte Carlo channel realizations

%% path loss

path_d = rand(1,K)+0.5;
path_i = rand(1,K)+0.5;

%% direct channel

Hd_w = (randn(M,K,ite) + 1i*randn(M,K,ite))/sqrt(2);

pd = repmat(path_d,M,1);

%% IRS-user channel

Hr_sig = (randn(K,N,ite) + 1i*randn(K,N,ite))/sqrt(2);

ps = repmat(path_i',1,N);

%% AP-IRS channel

G_sig = (randn(N,M,ite) + 1i*randn(N,M,ite))/sqrt(2);

%% angles (simplified)

AP_angle = rand(M,1);
IRS_angle = rand(N,1);
User_angle = rand(K,1);

%% IRS initial phase

theta_init = exp(1i*2*pi*rand(N,1,ite));

%% channel error parameters

eb1 = 0;
eb2 = 0;

%% save file

save('user_channel_cluster.mat',...
    'K','N','M','ite','pd','ps','Hd_w','theta_init',...
    'AP_angle','IRS_angle','G_sig','User_angle',...
    'Hr_sig','eb1','eb2','path_d','path_i');

disp('user_channel_cluster.mat generated')