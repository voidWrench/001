% function [W]=downbeam_lambda(A,H,K,M,grt,beta,lambda)
%     W=zeros(M,K);
%     A=A+lambda.*eye(M);
%     A=A^(-1);
%     for k0=1:K
%         W(:,k0)=sqrt(grt(k0))*beta(k0)*A*H(k0,:)';
%     end
% end
% 


%%
function W = downbeam_lambda(A,H,K,M,grt,beta,lambda)

% ==================================================
% Beamforming update with given lambda
% H : K × M
% W : M × K
% ==================================================

%% dimension protection
if size(H,1) ~= K
    H = H.';
end

%% regularized matrix
A_reg = A + lambda * eye(M);

W = zeros(M,K);

for k = 1:K

    hk = H(k,:)';        % M × 1

    % stable solve instead of inverse
    W(:,k) = sqrt(grt(k)) * beta(k) * (A_reg \ hk);

end

end