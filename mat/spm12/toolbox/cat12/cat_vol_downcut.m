%cat_vol_downcut Intensity limited region-growing 
%  Region growing of integer objects in O depending on a distance map that  
%  is created on the path distance to the object and the intensity in L.  
%  The region growing for the intensity map is limited by the lim where a 
%  neighbor value have fit for the following equation:
%    L(neigbor(x)) + limit <= L(x)
%  But not only the intensity of L is important, also the object distance  
%  can be used. You can set up the relation of both with the dd value, 
%  where dd(1) is used for the distance component and dd(2) for the 
%  intensity component. This regions growing was orignialy used for skull-
%  stripping. 
% 
%  [D,I] = cat_vol_downcut(O,L,lim,vx,dd)
%  
%  O   (3d single)  .. initial object (integer values for different objects)
%  L   (3d single)  .. intensity image 
%  lim (1x1 double) .. limit for the neighbor intensity in the regions 
%                      growing L(neigbor(x)) + limit <= L(x)
%  vx  (1x3 double) .. voxel size
%  dd  (1x2 double) .. distance weighting for the path length of the regions 
%                      growing (dd(1)) and the intensity (dd(2))
%                      (default [0.1 10])
%  
%  See also cat_vol_simgrow, compile.
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
%  $Id: cat_vol_downcut.m 1791 2021-04-06 09:15:54Z gaser $
