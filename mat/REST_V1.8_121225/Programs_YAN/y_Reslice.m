function y_Reslice(PI,PO,NewVoxSize,hld, TargetSpace)
% FORMAT y_Reslice(PI,PO,NewVoxSize,hld, TargetSpace)
%   PI - input filename
%   PO - output filename
%   NewVoxSize - 1x3 matrix of new vox size.
%   hld - interpolation method. 0: Nearest Neighbour. 1: Trilinear.
%   TargetSpace - Define the target space. 'ImageItself': defined by the image itself (corresponds  to the new voxel size); 'XXX.img': defined by a target image 'XXX.img' (the NewVoxSize parameter will be discarded in such a case).
%   Example: y_Reslice('D:\Temp\mean.img','D:\Temp\mean3x3x3.img',[3 3 3],1,'ImageItself')
%       This was used to reslice the source image 'D:\Temp\mean.img' to a
%       resolution as 3mm*3mm*3mm by trilinear interpolation and save as 'D:\Temp\mean3x3x3.img'.
%__________________________________________________________________________
% Written by YAN Chao-Gan 090302 for DPARSF. Referenced from SPM5.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com
%__________________________________________________________________________
% Last Revised by YAN Chao-Gan 100401. Fixed a bug while calculating the new dimension.

if nargin<=4
    TargetSpace='ImageItself';
end


if ~strcmpi(TargetSpace,'ImageItself')
    [dataIN, headIN]   = rest_ReadNiftiImage(TargetSpace);
    mat=headIN.mat;
    dim=headIN.dim;
else
    [dataIN, headIN]   = rest_ReadNiftiImage(PI);
    origin=headIN.mat(1:3,4);
    origin=origin+[headIN.mat(1,1);headIN.mat(2,2);headIN.mat(3,3)]-[NewVoxSize(1)*sign(headIN.mat(1,1));NewVoxSize(2)*sign(headIN.mat(2,2));NewVoxSize(3)*sign(headIN.mat(3,3))];
    origin=round(origin./NewVoxSize').*NewVoxSize';
    mat = [NewVoxSize(1)*sign(headIN.mat(1,1))                 0                                   0                       origin(1)
        0                         NewVoxSize(2)*sign(headIN.mat(2,2))              0                       origin(2)
        0                                      0                      NewVoxSize(3)*sign(headIN.mat(3,3))  origin(3)
        0                                      0                                   0                          1      ];
    %dim=(headIN.dim).*diag(headIN.mat(1:3,1:3))';
    %dim=ceil(abs(dim./NewVoxSize)); %dim=abs(round(dim./NewVoxSize));
    % Revised by YAN Chao-Gan, 100401.
    dim=(headIN.dim-1).*diag(headIN.mat(1:3,1:3))';
    dim=floor(abs(dim./NewVoxSize))+1;
end


VI          = spm_vol(PI);
VO          = VI;
VO.fname    = deblank(PO);
VO.mat      = mat;
VO.dim(1:3) = dim;

% VO = spm_create_vol(VO);
% for x3 = 1:VO.dim(3),
%         M  = inv(spm_matrix([0 0 -x3 0 0 0 1 1 1])*inv(VO.mat)*VI.mat);
%         v  = spm_slice_vol(VI,M,VO.dim(1:2),hld);
%         VO = spm_write_plane(VO,v,x3);
% end;


[x1,x2] = ndgrid(1:dim(1),1:dim(2));
d     = [hld*[1 1 1]' [1 1 0]'];
C = spm_bsplinc(VI, d);
v = zeros(dim);
for x3 = 1:dim(3),
    [tmp,y1,y2,y3] = getmask(inv(mat\VI.mat),x1,x2,x3,VI.dim(1:3),[1 1 0]');
    v(:,:,x3)      = spm_bsplins(C, y1,y2,y3, d);
end;
VO = spm_write_vol(VO,v);



%_______________________________________________________________________
function [Mask,y1,y2,y3] = getmask(M,x1,x2,x3,dim,wrp)
tiny = 5e-2; % From spm_vol_utils.c
y1   = M(1,1)*x1+M(1,2)*x2+(M(1,3)*x3+M(1,4));
y2   = M(2,1)*x1+M(2,2)*x2+(M(2,3)*x3+M(2,4));
y3   = M(3,1)*x1+M(3,2)*x2+(M(3,3)*x3+M(3,4));
Mask = logical(ones(size(y1)));
if ~wrp(1), Mask = Mask & (y1 >= (1-tiny) & y1 <= (dim(1)+tiny)); end;
if ~wrp(2), Mask = Mask & (y2 >= (1-tiny) & y2 <= (dim(2)+tiny)); end;
if ~wrp(3), Mask = Mask & (y3 >= (1-tiny) & y3 <= (dim(3)+tiny)); end;
return;
%_______________________________________________________________________
