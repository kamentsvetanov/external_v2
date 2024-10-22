%cat_vol_localstat Local mean, minimum, maximum, SD, and peak estimation.
%  Estimates specific functions volume V in a mask region M.  For every 
%  voxel vEM the values of the neigbors of v within a distance nb that 
%  also belong to M were used. 
% 
%  Vo = cat_vol_localstat(V,M,nb,stat)
%  
%  Vo   (sinlge)  .. output volume 
%  V    (single)  .. input volume
%  M    (logical) .. mask volume
%  nb   (double)  .. neigbhour distance (1 .. 10)
%  stat (double)  .. 1-mean, 2-min, 3-max, 4-std 
%                    5-peak1, 6-peak2, 7-peak3, 8-median
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
%  $Id: cat_vol_localstat.m 1791 2021-04-06 09:15:54Z gaser $
