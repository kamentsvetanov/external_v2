%cat_vbdist Voxel-based euclidean distance calculation.
%  Calculates the euclidean distance without partial volume effect to an 
%  object in P with a boundary of 0.5.
% 
%  [D,I,L] = cat_vbdist(P[,R])
%  
%  D (single)  .. distance image
%  I (uint32)  .. index of nearest point
%  L (uint8)   .. label map
%  P (single)  .. input image 
%  R (logical) .. range for distance calculation (to speedup processing)
%
%  See also bwdist, cat_vol_eidist, compile.
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
%  $Id: cat_vbdist.m 1791 2021-04-06 09:15:54Z gaser $
