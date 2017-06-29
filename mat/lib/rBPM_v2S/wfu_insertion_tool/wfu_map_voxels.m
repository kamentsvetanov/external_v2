function [S,XYZ,sliceIndex] = wfu_map_voxels(img)

%   Finds xyz coordinates of InMask voxels
%   FORMAT  [S,XYZ] = wfu_map_voxels(img)
%
%   S           - number of non-zero voxels
%   XYZ         - [3 x S double] voxel coordinates
%   img         - file handle of analyze image
%
%   ## v1.2, Aaron Baer, Wake Forest University ##
%   ## based on code from spm_spm.m (v2.66)     ##
%______________________________________________________________

SCCSid = '1.3';
SPMid  = spm('SFnBanner',mfilename,SCCSid);

nScan       =   100;                        %arbitrary, but 100 is fastest

V           =   spm_vol(img);
M           =   V.mat;
DIM         =   V.dim(1:3);
xdim        =   DIM(1); 
ydim        =   DIM(2); 
zdim        =   DIM(3);

xords       =   [1:xdim]'*ones(1,ydim); 
xords       =   xords(:)';                  %-plane X coordinates
yords       =   ones(xdim,1)*[1:ydim];  
yords       =   yords(:)';                  %-plane Y coordinates

MAXMEM      =   2^20;
blksz       =   ceil(MAXMEM/8/nScan);	    %-block size
nbch        =   ceil(xdim*ydim/blksz);      %-# blocks

S           =   0;                          %-volume (voxels)
VOX         =   xdim*ydim*zdim;             %-total volume (voxels)
XYZ         =   zeros(3,VOX);               %-voxel coordinates
sliceIndex  =   [];
sliceCount  =   0; 

fprintf('\t%-32s: %30s\n','Mapping coordinates of image',wfu_str_fix(img,'rp'));
fprintf('\t%-32s: %30s\n','Reading slice number','...');
for z = 1:zdim
    
    fprintf('%s%9s',sprintf('\b')*ones(1,9),[sprintf('%02d',z),' of ',sprintf('%02d',zdim),' '])
    zords       =   z*ones(xdim*ydim,1)';	            %-plane Z coordinates
    
    for bch = 1:nbch			                    %-loop over blocks
        
        I       =   [1:blksz] + (bch - 1)*blksz;    %-voxel indices
        I       =   I(I <= xdim*ydim);			    %-truncate
        xyz     =   [xords(I); yords(I); zords(I)]; %-voxel coordinates
        nVox    =   size(xyz,2);				    %-number of voxels
        Cm      =   logical(ones(1,nVox));			%-current mask
        
        
        %-Find InMask coordinates of voxels for each slice
        %---------------------------------------------------------------   
        j       =   V.mat\M*[xyz;ones(1,nVox)];
        slice   =   spm_get_data(V,j(:,Cm));
        Cm(Cm)  =   (slice~=0 & ~isnan(slice));
        CrS     =   sum(Cm);				        %-# current voxels
        
        %-Append new voxel locations and volumes
        %---------------------------------------------------------------
        XYZ(:,S+[1:CrS])    = xyz(:,Cm);		    %-InMask XYZ voxel coords
        S                   = S + CrS;		        %-InMask volume (voxels)
        sliceCount          = sliceCount+CrS; 
     
    end %-(bch)
    
    %-Append sliceIndex if slice has nonzero voxels
    %---------------------------------------------------------------
    sliceIndex(end+1) = sliceCount;                 %-XYZ index for each slice
    
    
end %-(z)
fprintf('%s%20s\n',sprintf('\b')*ones(1,20),[sprintf(' ...done (%02d of %02d) ',z,zdim)])
fprintf('\t%-32s: %30s\n','InMask voxel count',sprintf('%s of %s',num2str(S),num2str(VOX)))

XYZ =   XYZ(:,1:S); %-InMask voxel coordinates
fprintf('\t%-32s\n\n','----------------------------------------------------------------')
return
