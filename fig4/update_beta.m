function beta = update_beta(H,W,K,grt)
% H: M x K
% W: M x K
% grt: 1 x K (from update_SINR)
% beta: 1 x K

beta = zeros(1,K);

for k = 1:K
    hk = H(:,k);           % M x 1
    signal = hk' * W(:,k); % 1 x 1
    interf  = 0;
    for j = 1:K
        interf = interf + abs(hk' * W(:,j))^2;
    end
    beta(k) = sqrt(grt(k)) * signal / (interf + 1); % σ^2 = 1
end
end