function [SPM,copyIndex] = wfu_build_SPM(SPM,map)

%   Create SPM.mat from a foreign T-map alone
%   FORMAT SPM = wfu_build_SPM(varargin)
%   
%   SPM(out)    - structure to be stored in SPM.mat
%   copyIndex   - 
%   SPM(in)     - 
%   map         - structure
%
%   ## v1.6, Aaron Baer, Wake Forest University ##
%______________________________________________________________
global defaults; spm_defaults;

%----- params -----%
TH = ones(1,1)*(100*defaults.mask.thresh);
imgDT = [];
if map.scratch | isempty(SPM.xX.erdf)
    FWHM        =   map.fwhm; 
    erdf        =   map.erdf;
    [S,XYZ]     =   wfu_map_voxels(map.name{1});   
    R           =   spm_resels(FWHM,map.V{1},'I');
    imgDims     =   map.V{1}.dim(1:3);
    imgM        =   map.V{1}.mat; 
    if isfield(map.V{1}, 'dt')
        imgDT   =   map.V{1}.dt;
    end
else
    FWHM        =   SPM.xVol.FWHM;
    erdf        =   SPM.xX.erdf;
    [S,XYZ,R]   =   deal(SPM.xVol.S,SPM.xVol.XYZ,SPM.xVol.R);
    imgDims     =   SPM.xVol.DIM';
    imgM        =   SPM.xVol.M; 
    if isfield(SPM.xVol.V, 'dt')
        imgDT   =   SPM.xVol.V.dt;
    end
end

currCon = length(SPM.xCon);
nNew    = length(map.name);
if map.scratch
    firstNew    =   1;
    lastNew     =   nNew;
else
    firstNew    =   currCon+1; 
    lastNew     =   currCon+nNew;
end

%   Reading the modality files from the master file 
file_names = wfu_bpm_read_flist(map.flist);
file_names_mod = file_names(1,:);  
[file_names_subjs,no_grp] = wfu_bpm_get_file_names( file_names_mod );

Nscans = size(file_names_subjs{1},1);

for k = 1:Nscans
    file_name = sprintf('%s', file_names_subjs{1}(k,:));
    SPM.xY.P{k} = file_name;
    SPM.xY.VY(k) = spm_vol(file_name);
end

% Assume i.i.d
V = speye(Nscans,Nscans);
[u s] = spm_svd(V);
s     = spdiags(1./sqrt(diag(s)),0,length(s),length(s));
W     = u*s*u';
W     = W.*(abs(W) > 1e-6);
SPM.xX.W  = sparse(W);

SPM.xX.K = 1; % default

%----- define SPM fields -----%
SPM.xX.X                =   zeros(1,1);         %-vols x vols (double)
% SPM.xX.W                =   speye(1,1);         %-vols x vols (double)
SPM.xX.xKXs.X           =   zeros(1,1);         %-vols x conds (double) 
SPM.xX.xKXs.tol         =   1;                  %-float [trying 1] 9.7842e-13
SPM.xX.xKXs.ds          =   ones(1,1);          %-conds x 1 (double)
SPM.xX.xKXs.u           =   zeros(1,1);         %-vols x conds (double)
SPM.xX.xKXs.v           =   ones(1,1);          %-conds x conds [ie. 1x1 w/value '1'] 
SPM.xX.xKXs.rk          =   1;                  %-conds (int) 
SPM.xX.erdf             =   erdf;               %-rough approximation without RT/1/variance
SPM.xVi.V               =   speye(1,1);         %-sparse matrix (ones)
SPM.xM.T                =   ones(1,1);          %-vols x 1 (ones)
SPM.xM.TH               =   TH;                 %-default heigh threshold
SPM.xM.I                =   0;                  %-no implicit mask  
SPM.swd                 =   map.dir;            %-SPM working directory
SPM.xVol.XYZ            =   XYZ;                %-[3x#InMaskVoxels] voxel coordinates
SPM.xVol.M              =   imgM;               %-standard MNI transformation matrix
SPM.xVol.DIM            =   imgDims';           %-standard MNI transposed
SPM.xVol.FWHM           =   FWHM;               %-small error if fake [5 5 5]
SPM.xVol.R              =   R;                  %-estimated based on fake FWHM
SPM.xVol.S              =   S;                  %-number of InMask voxels(volume)
if ~isempty(imgDT)
    SPM.xVols.DT        =   imgDT;
end

%----- define contrast-specific SPM fields -----%
currMap = 0; 
for i = firstNew:lastNew
    currMap             =   currMap+1; 
    copyIndex{currMap}  =   i;
    conTitle            =   sprintf('%s_%02d',map.title{i},i);
    
    switch map.stat{i}
        case 'Corr'
            statType    =   'C';
            conImgName  =   sprintf('con_%04d.img',i);
            spmImgName  =   sprintf('spmC_%04d.img',i);
            dfNumerator =   1; 
        case 'T-values'
            statType    =   'T';
            conImgName  =   sprintf('con_%04d.img',i);
            spmImgName  =   sprintf('spmT_%04d.img',i);
            dfNumerator =   1; 
        case 'F-values'
            statType    =   'F'; 
            conImgName  =   sprintf('ess_%04d.img',i);
            spmImgName  =   sprintf('spmF_%04d.img',i);
            dfNumerator =   map.dof(1);
    end

    SPM.xCon(i).name        =   conTitle;           %-contrast title
    SPM.xCon(i).STAT        =   statType;           %-stat type
    SPM.xCon(i).c           =   ones(1,1);          %-friendly error if fake
    SPM.xCon(i).eidf        =   dfNumerator;        %-effective interest degrees of freedom
    SPM.xCon(i).Vcon.fname  =   conImgName;         %-contrast filename ('con_0001.img')
    SPM.xCon(i).Vcon.dim    =   map.V{i}.dim;       %-image dimensions ([91 109 91 16]) 
    SPM.xCon(i).Vcon.mat    =   imgM;               %-transformation matrix
    if ~isempty(imgDT)
        SPM.xCon(i).Vcon.dt =    imgDT;
    end
    SPM.xCon(i).Vspm.fname  =   spmImgName;         %-SPM image filename ('spmT_0001.img')      
    SPM.xCon(i).Vspm.dim    =   map.V{i}.dim;       %-image dimensions ([91 109 91 16])
    SPM.xCon(i).Vspm.mat    =   imgM;               %-transformation matrix 
    SPM.xCon(i).Vspm.pinfo  =   [1 0 0]';           %-[1 0 0]'
    if ~isempty(imgDT)
        SPM.xCon(i).Vspm.dt =   imgDT;
    end
end

return

