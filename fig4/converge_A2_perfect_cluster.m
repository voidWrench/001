%在理想条件下基于交替优化（AO）最大化加权和速率（WSR）
%包含多次随机信道实现（Monte Carlo）；外层迭代优化IRS相位；每轮计算WSR最后取平均
close all
clear all

%% system parameters
load('user_channel_cluster.mat','K','N','M','ite','pd','ps','Hd_w','theta_init','AP_angle','IRS_angle',...
    'G_sig','User_angle','Hr_sig','eb1','eb2','path_d','path_i');etai=1;
weight=1./((path_d));
weight=weight./sum(weight);
omega=weight;
%%
snr=0;
Pt=10.^(snr/10); 
it=1e2;
rate_w=zeros(ite,it);
start=zeros(1,ite);
error_Ellipsoid=0;
beamforming_error=0;
armijo_w=zeros(ite,it);
parfor t0=1:ite%随机生成ite组信道，每组信道跑一次优化，最后对结果取平均
    rate_tmp=zeros(1,it);
    W_old=zeros(M,K);
    beta=zeros(1,K);
    %%
    Hd=pd.*Hd_w(:,:,t0);
    theta=theta_init(:,:,t0);
    Theta=diag(theta');
    %%
    G=channel_G(AP_angle,IRS_angle,G_sig(:,:,t0),eb1,eb2,N,M);
    Hr=ps.*channel_Hr(User_angle,Hr_sig(:,:,t0),eb1,eb2,K,N);
    %%
    H=Hd+Hr*Theta*G;%等效信道 = 直射信道 + 反射信道

    C = 3;   % cluster number
    cluster_id = user_clustering(H,C);
    H_cluster = build_cluster_channel(H,cluster_id);
    H = H_cluster;   % 用cluster信道替换

    Kc = C;
    %% init
    %[ W,grt,f0 ] = init_W( H,M,K,Pt,omega );%初始化BS beamforming，计算初始WSR（f0）
    [W,grt,f0] = init_W(H,M,Kc,Pt,omega);
     start(t0)=f0;
     f1=0;
     %%
     W_span=W;
     W_last=W;
     [ ~,L_last ] = Proxlinear_beam_para( H,Kc,M,beta );
     %%
     flag=0;
     t_old=1;
     [ beta ] = upadte_beta( H,W,Kc,grt);%这是WMMSE里的辅助变量，把WSR转化为可优化形式
     for con0=1:it%这里是AO的核心，内层循环 = 交替优化迭代
        [ Qx,qx,theta ] = surface_U_v_direct( W,Hd,Hr,Theta,G,N,Kc,grt,beta );
        %把IRS优化问题写成一个二次形式
        theta_old=theta;
        %%
        U=-Qx;v=qx;
        x0=theta_old;
        phi0=angle(x0);
        grad=real((2*U*x0-2*v).*(-1j.*conj(x0)));
        dir=-grad;
        %上面两行是计算梯度方向
        [ Ltheta ] = SCA_phi_step_para( -Qx,qx,N, theta );
        [ theta,t3,armijo_w(t0,con0) ] = armijo_theta( Ltheta,dir,f0,phi0, grad,grt,W,W_span,t_old,L_last,K,M,Pt,omega,Hd,Hr,G);
        %用Armijo线搜索，沿梯度方向更新IRS相位
        %这是一个流形优化（Manifold optimization）
        %%
        [f1,grt,beta,W,W_span,t_old,L_last,H,Theta ] = fun_theta_package(grt,theta,W,W_span,t_old,L_last,K,M,Pt,omega,Hd,Hr,G);
        %用新的theta重新更新H, 更新beamforming, ，重新计算WSR
         %%
         rate_tmp(con0)=f1;%记录每次迭代的WSR
         f0=f1;             
     end
     rate_w(t0,:)=rate_tmp;
end
rate_w=mean(rate_w);%对所有信道实现取平均，然后画收敛曲线
start=mean(start);
rate_w=[start rate_w];
%%
fprintf('error Ellipsoid=%d\n',error_Ellipsoid);
fprintf('error beamforming=%d\n',beamforming_error);
%%
figure
plot(0:it,rate_w,'r-');
save('converge_speed_step_phi_CG_n5.mat','it','rate_w','M','K','N','omega');
 %%
 armijo_w=mean(armijo_w);
 figure
 plot(1:it, armijo_w,'r-');
 grid on
 
 
 
 