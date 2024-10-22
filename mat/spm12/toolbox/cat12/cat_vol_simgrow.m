%cat_vol_simgrow Volumetric region-growing.
%  
%  [SLAB,DIST] = cat_vol_simgrow(ALAB,SEG[,d,dims,dd]);
%  
%  SLAB (3D  single) .. output label map  
%  DIST (3D  single) .. distance map from region-growing
%  ALAB (3D  single) .. input label map
%  SEG  (3D  single) .. input tissue map
%  d    (1x1 double) .. growing treshhold paramter (max local gradient)
%                       in SEG
%  dims (1x3 double) .. voxel dimensions (default [1,1,1])
%  dd   (1x2 double) .. general growing limits in SEG 
%
%  See also cat_vol_downcut.
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
%  $Id: cat_vol_simgrow.m 1791 2021-04-06 09:15:54Z gaser $
