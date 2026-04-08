function [cluster_id,center] = user_clustering(H,C)

% 基于信道的用户聚类
% H : K × M channel matrix
% C : number of clusters

[K,~] = size(H);

% 使用信道向量做K-means
feature = abs(H);

[cluster_id,center] = kmeans(feature,C);

end

% 输入  H(K×M)
% 输出  cluster_id (每个用户属于哪个cluster)