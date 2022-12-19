function XYZmm = voxel2mm(XYZ,m)
%function XYZmm = voxel2mm(XYZ,m)
% XYZ is 3 vector point list (3 rows, n columns)
% m is SPM mat - 4 x 4 affine transform
% (what's stored in the .mat file)
%
% Verified that this works 10/27/01.
% Tor Wager, 10/27/01
%
% Example:
% XYZmm = voxel2mm([x y z]',V.mat);

if isempty(XYZ), XYZmm = [];, return, end

% add one to multiply by the constant shift (offset from edge) in mat
% -------------------------------------------------------------------
XYZ(4,:) = 1;	

XYZmm = m * XYZ;

XYZmm = XYZmm(1:3,:);

return