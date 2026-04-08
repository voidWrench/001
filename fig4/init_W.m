% function [ W,grt,fint ] = init_W( H,M,K,Pt,omega )
%     %ZF≥ı ºªØ
%     %W=H'/(H*H');
%     W = H / (H' * H);
%     W=W./sqrt(power_W( W ));
%     for k0=1:K
%         W(:,k0)=W(:,k0).*sqrt(Pt);
%     end
%     %%
%     K = size(H,2);
%     [~,grt,f0] = update_SINR(H,W,K,omega);
%     %%
%     while(1)
%         %% update w£¨ beta 
%         [ beta ] =upadte_beta( H,W,K,grt);
%         [ W ] =update_beam_v2( H,K,M,grt,Pt,beta,omega );
%         [ ~,grt,fint ] = update_SINR( H,W,K,omega );
%         if abs(f0-fint)<1e-3
%             break
%         end
%         f0=fint;
%     end
% end
% 

%%
function [W,grt,fint] = init_W(H,M,K,Pt,omega)
% ==================================================
% Stable initialization for WMMSE beamforming
% H : K °¡ M
% W : M °¡ K
% ==================================================

%% ---------- ZF Initialization ----------

W = H' * pinv(H * H');      % M °¡ K

% power normalization
W = W / sqrt(trace(W*W'));
W = W * sqrt(Pt);

%% ---------- Initial SINR ----------

[~,grt,f0] = update_SINR(H,W,K,omega);

%% ---------- Iterative WMMSE ----------

while 1

    % update beta
    beta = update_beta(H,W,K,grt);

    % update beamformer
    W = update_beam_v2(H,K,M,grt,Pt,beta,omega);

    % update SINR
    [~,grt,fint] = update_SINR(H,W,K,omega);

    % convergence
    if abs(f0 - fint) < 1e-3
        break
    end

    f0 = fint;

end

end