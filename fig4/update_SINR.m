% function [ gr,grt,f0 ] = update_SINR( H,W,K,omega )
% gr=zeros(1,K);
% He=abs(H*W).^2;
%  %% update gr (SINR) and grt
%  for k0=1:K
%      tmp=He(k0,:);
%      gr(k0)=tmp(k0)/(sum(tmp)-tmp(k0)+1);
%  end
%  f0=sum(omega.*log(1+gr));
%  grt=omega.*(1+gr);
% end
% 

%%
function [SINR,grt,f] = update_SINR(H,W,K,omega)

% ==================================================
% Compute SINR and weighted sum rate
% H : K × M
% W : M × K
% ==================================================

%% ensure omega is column
omega = omega(:);

%% effective channel gain
He = abs(H * W).^2;      % K × K

SINR = zeros(K,1);

for k = 1:K

    signal = He(k,k);

    interf = sum(He(k,:)) - signal;

    noise = 1;

    SINR(k) = signal / (interf + noise);

end

%% weighted sum rate
f = sum(omega .* log2(1 + SINR));

%% grt used in WMMSE update
grt = omega .* (1 + SINR);

end