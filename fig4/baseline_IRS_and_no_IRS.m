clc;
clear;
close all;

M = 4;
K = 4;
N = 16;

SNR_dB = -10:5:30;
num_iter = 100;

sum_rate_RIS = zeros(length(SNR_dB),1);
sum_rate_noRIS = zeros(length(SNR_dB),1);

for snr_idx = 1:length(SNR_dB)

    Pt = 10^(SNR_dB(snr_idx)/10);
    noise = 1;

    rate_RIS = 0;
    rate_noRIS = 0;

    for iter = 1:num_iter
        
        Hd = (randn(K,M) + 1j*randn(K,M))/sqrt(2);
        G = (randn(N,M) + 1j*randn(N,M))/sqrt(2);
        Hr = (randn(K,N) + 1j*randn(K,N))/sqrt(2);

        theta = 2*pi*rand(N,1);
        Phi = diag(exp(1j*theta));

        %% ========== WITH IRS ==========
        H = Hd + Hr * Phi * G;

        W = zeros(M,K);
        for k = 1:K
            hk = H(k,:).';
            W(:,k) = hk / norm(hk);
        end
        W = W / norm(W,'fro') * sqrt(Pt);

        SINR = zeros(K,1);
        for k = 1:K
            hk = H(k,:);
            signal = abs(hk * W(:,k))^2;
            interf = 0;
            for j = 1:K
                if j ~= k
                    interf = interf + abs(hk * W(:,j))^2;
                end
            end
            SINR(k) = signal/(interf + noise);
        end
        rate_RIS = rate_RIS + sum(log2(1+SINR));

        %% ========== NO IRS ==========
        H = Hd;   % ← 关键：关闭IRS

        W = zeros(M,K);
        for k = 1:K
            hk = H(k,:).';
            W(:,k) = hk / norm(hk);
        end
        W = W / norm(W,'fro') * sqrt(Pt);

        SINR = zeros(K,1);
        for k = 1:K
            hk = H(k,:);
            signal = abs(hk * W(:,k))^2;
            interf = 0;
            for j = 1:K
                if j ~= k
                    interf = interf + abs(hk * W(:,j))^2;
                end
            end
            SINR(k) = signal/(interf + noise);
        end
        rate_noRIS = rate_noRIS + sum(log2(1+SINR));

    end

    sum_rate_RIS(snr_idx) = rate_RIS/num_iter;
    sum_rate_noRIS(snr_idx) = rate_noRIS/num_iter;

end

figure;
plot(SNR_dB,sum_rate_RIS,'-o','LineWidth',2); hold on;
plot(SNR_dB,sum_rate_noRIS,'-s','LineWidth',2);
grid on;
legend('Random IRS','No IRS');
xlabel('SNR (dB)');
ylabel('Sum Rate (bit/s/Hz)');
title('RIS vs No RIS Baseline');