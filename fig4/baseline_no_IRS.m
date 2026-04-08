clc;
clear;
close all;

%% ================== System Parameters ==================
M = 4;          % Number of BS antennas
K = 4;          % Number of users
N = 16;         % Number of IRS elements

SNR_dB = -10:5:30;      % SNR range
num_iter = 100;         % Monte Carlo runs

sum_rate = zeros(length(SNR_dB),1);

%% ================== Simulation ==================
for snr_idx = 1:length(SNR_dB)

    Pt = 10^(SNR_dB(snr_idx)/10);   % transmit power (linear)
    noise = 1;                     % noise power
    
    rate_temp = 0;

    for iter = 1:num_iter
        
        %% ----- Channel Generation (Rayleigh fading) -----
        
        % Direct BS-user channel
        Hd = (randn(K,M) + 1j*randn(K,M))/sqrt(2);
        
        % BS-IRS channel
        G = (randn(N,M) + 1j*randn(N,M))/sqrt(2);
        
        % IRS-user channel
        Hr = (randn(K,N) + 1j*randn(K,N))/sqrt(2);
        
        %% ----- Random IRS phase -----
        theta = 2*pi*rand(N,1);
        Phi = diag(exp(1j*theta));
        
        %% ----- Effective channel -----
        % H_k = direct + reflected
        H = Hd
        
        %% ----- MRT Beamforming -----
        W = zeros(M,K);
        for k = 1:K
            hk = H(k,:).';
            W(:,k) = hk / norm(hk);    % normalize
        end
        
        % Normalize total power
        W = W / norm(W,'fro') * sqrt(Pt);
        
        %% ----- SINR Calculation -----
        SINR = zeros(K,1);
        
        for k = 1:K
            
            hk = H(k,:);
            
            signal = abs(hk * W(:,k))^2;
            
            interference = 0;
            for j = 1:K
                if j ~= k
                    interference = interference + abs(hk * W(:,j))^2;
                end
            end
            
            SINR(k) = signal / (interference + noise);
        end
        
        %% ----- Achievable Rate -----
        R = log2(1 + SINR);
        rate_temp = rate_temp + sum(R);
        
    end
    
    sum_rate(snr_idx) = rate_temp / num_iter;
    
end

%% ================== Plot ==================
figure;
plot(SNR_dB, sum_rate,'-o','LineWidth',2);
grid on;
xlabel('SNR (dB)');
ylabel('Sum Rate (bit/s/Hz)');
title('RIS-assisted System Baseline (Random IRS + MRT)');