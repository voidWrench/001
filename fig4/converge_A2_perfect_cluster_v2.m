% ==========================================================
% Cluster-based AO optimization (Stable Thesis Version)
% ==========================================================

close all
clear

%% load channel data
load('user_channel_cluster.mat')  
% 需要包含：
% K, M, N
% Hd_w, Hr_sig
% pd, ps
% theta_init
% G_sig
% path_d
% AP_angle IRS_angle User_angle
% eb1 eb2
% ite

%% system parameters
C = 3;                  % cluster number
snr = 0;
Pt = 10^(snr/10);       % transmit power
it = 100;               % AO iterations

rate_w = zeros(ite,it);
start  = zeros(1,ite);

%% weight initialization
weight = 1./(path_d);
weight = weight./sum(weight);
omega  = weight;

%% Monte Carlo simulation
for t0 = 1:ite

    rate_tmp = zeros(1,it);

    %% -------------------------
    % Channel construction
    % -------------------------
    Hd = pd .* Hd_w(:,:,t0);     % M × K

    theta = theta_init(:,:,t0);
    Theta = diag(theta');

    G = channel_G(AP_angle,IRS_angle,G_sig(:,:,t0),eb1,eb2,N,M); % N × M

    Hr = channel_Hr(User_angle,Hr_sig(:,:,t0),eb1,eb2,K,N);      % K × N
    Hr = ps .* Hr;

    %% -------------------------
    % USER CLUSTERING
    % -------------------------

    % Full effective channel
    H_full = Hd + (Hr*Theta*G).';    % M × K

    cluster_id = kmeans(abs(H_full.'), C);

    rep_user = zeros(1,C);

    for c = 1:C

        idx = find(cluster_id == c);

        if isempty(idx)
            rep_user(c) = randi(K);
        else
            rep_user(c) = idx(1);
        end

    end

    %% -------------------------
    % Reduced system
    % -------------------------

    Hd_c = Hd(:,rep_user);      % M × C
    Hr_c = Hr(rep_user,:);      % C × N
    G_c  = G;                   % N × M

    omega_c = omega(rep_user);  % 1 × C
    Kc = C;

    %% -------------------------
    % Cluster channel
    % -------------------------

    H_cluster = (Hd_c + (Hr_c*Theta*G_c).').';   % C × M

    %% -------------------------
    % Debug (维度检查)
    % -------------------------

    fprintf('----- Iteration %d -----\n',t0);
    disp(['H_cluster size: ', mat2str(size(H_cluster))])
    disp(['omega_c size: ', mat2str(size(omega_c))])

    %% -------------------------
    % Initialization
    % -------------------------

    W = zeros(M,Kc);
    beta = zeros(1,Kc);

    [W,grt,f0] = init_W(H_cluster,M,Kc,Pt,omega_c);

    start(t0) = f0;

    f1 = 0;

    W_span = W;
    W_last = W;

    [~,L_last] = Proxlinear_beam_para(H_cluster,Kc,M,beta);

    t_old = 1;

    beta = update_beta(H_cluster,W,Kc,grt);

    %% -------------------------
    % AO Iteration
    % -------------------------

    for con0 = 1:it

        [Qx,qx,theta] = surface_U_v_direct(W,Hd_c,Hr_c,Theta,G_c,N,Kc,grt,beta);

        theta_old = theta;

        U = -Qx;
        v = qx;

        x0 = theta_old;

        phi0 = angle(x0);

        grad = real((2*U*x0-2*v).*(-1j.*conj(x0)));

        dir = -grad;

        Ltheta = SCA_phi_step_para(-Qx,qx,N,theta);

        [theta,~,~] = armijo_theta(...
            Ltheta,dir,f0,phi0,grad,grt,...
            W,W_span,t_old,L_last,Kc,M,Pt,omega_c,Hd_c,Hr_c,G_c);

        [f1,grt,beta,W,W_span,t_old,L_last,~,Theta] = ...
            fun_theta_package(...
            grt,theta,W,W_span,t_old,L_last,...
            Kc,M,Pt,omega_c,Hd_c,Hr_c,G_c);

        rate_tmp(con0) = f1;

        f0 = f1;

    end

    rate_w(t0,:) = rate_tmp;

end

%% -------------------------
% Average results
%% -------------------------

rate_w = mean(rate_w);

start  = mean(start);

rate_w = [start rate_w];

%% -------------------------
% Plot
%% -------------------------

figure

plot(0:it,rate_w,'r-','LineWidth',2)

xlabel('Iteration')

ylabel('Weighted Sum Rate')

title('Cluster-based AO Optimization')

grid on