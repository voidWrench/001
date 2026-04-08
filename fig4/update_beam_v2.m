function [Wopt] = update_beam_v2(H,K,M,grt,Pt,beta,omega)

% ==================================================
% Stable beamforming update (WMMSE step)
% H : K × M
% W : M × K
% ==================================================

%% ---------- Dimension protection ----------
if size(H,1) ~= K
    H = H.';
end

%% ---------- Build matrix A ----------

A = zeros(M,M);

for k0 = 1:K

    hk = H(k0,:)';            % M × 1

    tmp = abs(beta(k0))^2 * (hk * hk');   % M × M

    A = A + tmp;

end

%% ---------- Lambda search ----------

lambda_min = 0;
lambda_max = real(sum(sum(A)));

flag = 0;

while 1

    Wn = downbeam_lambda(A,H,K,M,grt,beta,lambda_max);

    power = power_W(Wn);

    if power > Pt

        lambda_min = lambda_max;
        lambda_max = lambda_max * 2;

    elseif abs(power-Pt) < 1e-10

        flag = 1;
        break

    else
        break
    end

end

%% ---------- Power normalization ----------

if flag ~= 1

    rho = Pt / power;

    Wopt = Wn * sqrt(rho);

    [~,~,f0] = update_SINR(H,Wopt,K,omega);

    while 1

        [lambda,lambda_min] = update_lambda_v2(lambda_min,lambda_max,A,M);

        Wn = downbeam_lambda(A,H,K,M,grt,beta,lambda);

        power = power_W(Wn);

        rho = Pt / power;

        Wn = Wn * sqrt(rho);

        [~,~,f1] = update_SINR(H,Wn,K,omega);

        if power > Pt
            lambda_min = lambda;
        else
            lambda_max = lambda;
        end

        if f1 > f0
            Wopt = Wn;
        end

        f0 = f1;

        if abs(lambda_max-lambda_min) < 1e-3 && ...
           abs(power-Pt) < 1e-5
            break
        end

    end

else

    Wopt = Wn;

end

end