% function Hc = build_cluster_channel(H,cluster_id,C)
% 
% % 构造cluster等效信道
% 
% [~,M] = size(H);
% 
% Hc = zeros(C,M);
% 
% for c = 1:C
% 
%     idx = find(cluster_id==c);
% 
%     Hc(c,:) = mean(H(idx,:),1);
% 
% end
% 
% end
% 
% % 把多个用户信道合成一个 cluster 信道

function Hc = build_cluster_channel(H,cluster_id)

[K,M] = size(H);

C = max(cluster_id);

Hc = zeros(C,M);

for c = 1:C
    
    idx = find(cluster_id==c);
    
    Hc(c,:) = mean(H(idx,:),1);
    
end

end