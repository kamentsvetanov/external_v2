%cat_vol_median3 Median filter for label maps.
%  Median Filter for a 3D single image D. Bi is used to mask voxels for the 
%  filter process, whereas Bn is used to mask voxels that are used as 
%  neighbors in the filter process. Both mask can changed by intensity 
%  threshold (Bi_low,Bi_high,Bn_low,Bn_high) for D.
% 
%   M = cat_vol_median3(D[, Bi, Bn, sf, Bi_low, Bi_high, Bn_low, Bn_high])
% 
%   D      (single)  .. 3d matrix for filter process 
%   Bi     (logical) .. 3d matrix that marks voxels that should be filtered
%   Bn     (logical) .. 3d matrix that marks voxels that are used to filter
%   sf     (double)  .. threshold that is used to filter the result
%                          sf=0: no filter
%                          sf<0: only smaller changes
%                          sf>0: only bigger changes
%   Bi_low  (double) .. low  threshold in D for filtering (add to Bi)
%   Bi_high (double) .. high threshold in D for filtering (add to Bi)
%   Bn_low  (double) .. low  threshold in D for neighbors (add to Bn)
%   Bn_high (double) .. high threshold in D for neighbors (add to Bn)
% 
%  Used slower quicksort for median calculation, because the faster median 
%  of the median application implementation leads to wrong results. 
% 
%  See also cat_vol_median3c, compile.
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
%  $Id: cat_vol_median3.m 1791 2021-04-06 09:15:54Z gaser $
