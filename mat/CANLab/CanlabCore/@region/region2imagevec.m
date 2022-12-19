function [ivecobj, orig_cluster_indx]  = region2imagevec(cl)
% [ivecobj, orig_cluster_indx]  = region2imagevec(cl)
%
% Convert a region object to an image_vector object, replacing the voxels
% and reconstructing as much info as possible.
%
% The .dat field of the new "ivecobj" is made from the cl.all_data field.
% if this is empty, uses cl.val field, then cl.Z as a backup.
% Mask information is available in ivecobj.volInfo.
%
% ivecobj = region2imagevec(cl)
% NEEDS SOME ADDITIONAL WORK/CHECKING

ivecobj = image_vector;
ivecobj.volInfo.mat = cl(1).M;
ivecobj.volInfo.dim = cl(1).dim;

% no, will be reordered
%ivecobj.volInfo.xyzlist = cat(2, cl.XYZ)';

mask = clusters2mask2011(cl, cl(1).dim);

n = sum(mask(:) ~= 0);

% add data.  all_data if we have it, or .val or .Z
ivecobj.dat = cat(2, cl.all_data)';
if isempty(ivecobj.dat) || all(ivecobj.dat == 0), ivecobj.dat = cat(1, cl.val); end
if isempty(ivecobj.dat) || all(ivecobj.dat == 0), ivecobj.dat = cat(2, cl.Z)'; end

% Wani added the following 5 lines to get a correct data alignment
xyz = cat(2,cl.XYZ)';
[dummy, idx1] = sort(xyz(:,1));
[dummy, idx2] = sort(xyz(idx1,2));
[dummy, idx3] = sort(xyz(idx1(idx2),3));
ivecobj.dat = ivecobj.dat(idx1(idx2(idx3)),:);

% tor changed april 28 2011 to be all voxels
ivecobj.removed_voxels = mask(:) == 0 | isnan(mask(:)); %false(n, 1);

ivecobj.volInfo.image_indx = mask(:) ~= 0;
ivecobj.volInfo.n_inmask = n;

ivecobj.volInfo.wh_inmask = find(ivecobj.volInfo.image_indx);

% re-get continguity; don't just assume
orig_cluster_indx = mask(:);
orig_cluster_indx = orig_cluster_indx(ivecobj.volInfo.wh_inmask);

%ivecobj.volInfo.cluster = mask(:);
%ivecobj.volInfo.cluster = ivecobj.volInfo.cluster(ivecobj.volInfo.wh_inmask);

ivecobj.volInfo.nvox = prod(cl(1).dim);

[i, j, k] = ind2sub(cl(1).dim, ivecobj.volInfo.wh_inmask);
ivecobj.volInfo.xyzlist = [i j k];

if ivecobj.volInfo.n_inmask < 50000
    ivecobj.volInfo.cluster = spm_clusters(ivecobj.volInfo.xyzlist')';
else
    ivecobj.volInfo.cluster = ones(ivecobj.volInfo.n_inmask, 1);
end

ivecobj.volInfo.dt = [16 0]; % for reslicing compatibility
ivecobj.volInfo.fname = 'Reconstructed from clusters';
% 
% ivecobj.dat = cat(2, cl.all_data)';
% ivecobj.removed_voxels = mask(:) == 0;
% ivecobj.volInfo.image_indx = true(size(ivecobj.removed_voxels));
% ivecobj.volInfo.n_inmask = length(ivecobj.removed_voxels);
% ivecobj.volInfo.wh_inmask = [1:ivecobj.volInfo.n_inmask ]';
% ivecobj.volInfo.cluster = mask(:);
% ivecobj.volInfo.nvox = prod(size(cl(1).dim));

end
