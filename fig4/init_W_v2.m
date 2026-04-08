function [ W,grt,fint ] = init_W_v2(H,M,K,Pt,omega)
% Stable AO initialization for cluster-based WMMSE

% --- ZF initialization ---
W = H * pinv(H'*H);      % M×K × K×K → M×K
W = W / sqrt(power_W(W));
W = W * sqrt(Pt);

% --- initial SINR ---
[~,grt,f0] = update_SINR(H,W,K,omega);

% --- iterative WMMSE update ---
while 1
    % update beta
    beta = update_beta_v2(H,W,K,grt);

    % update beamforming
    W = update_beam_v2(H,K,M,grt,Pt,beta,omega);

    % update SINR
    [~,grt,fint] = update_SINR(H,W,K,omega);

    % convergence check
    if abs(f0 - fint) < 1e-3
        break
    end
    f0 = fint;
end
end