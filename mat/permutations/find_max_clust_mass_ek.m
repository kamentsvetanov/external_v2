function [max_clust_mass, clust_mass,ccc]=find_max_clust_mass_ek(data,thresh)

%% Function called by permutation_cluster_test_2dtfr_func.m
%
% data is matrix of t-values, thresh is t-value (or other test statistic)
%
% Written by A.Ghuman (2009), adapted by Alex C (07/09)

%% Finds elements in data above threshold
clear clust_mass ccc
bwmatrix = zeros(size(data));

if thresh>0
    bwmatrix(find(data>thresh)) = 1;
elseif thresh<=0 %(Ece K)
    bwmatrix(find(data<thresh)) = 1;
end


% Numbers clusters
%if length(size(data))>2
    %clusters_matrix = bwlabeln(bwmatrix);
    ccc=bwconncomp(bwmatrix); % this works faster than bwlabeln (EK)
    clusters_matrix = labelmatrix(ccc);
%elseif length(size(data))==2
    %clusters_matrix = bwlabel(bwmatrix);
%end

% Determines extent of each cluster

if max(clusters_matrix(:))~=0%length(size(data))>2 && 
    for i = 1:max(clusters_matrix(:))
        pixs(i)=size(ccc.PixelIdxList{1,i},1);
    end
    ind=find(pixs==max(pixs));
    for j=1:length(ind)
        clust_mass(j,:) = abs(sum(data(find(clusters_matrix==ind(j)))));
    end
% elseif length(size(data))==2 && max(clusters_matrix(:))~=0
%     for j=1:max(clusters_matrix(:))
%         clust_mass(j) = sum(data(find(clusters_matrix==j)));
%     end
elseif length(size(data))>2 && max(clusters_matrix(:))==0
    clust_mass(1)=0;
elseif length(size(data))==2 && max(clusters_matrix(:))==0
    clust_mass(1)=0;
end

clear ind pixs clusters_matrix

% Only takes max cluster
if ~isempty(find(bwmatrix==1))
    max_clust_mass=max(clust_mass);
else
    clust_mass=0;
    max_clust_mass=0;
end
clear bwmatrix
