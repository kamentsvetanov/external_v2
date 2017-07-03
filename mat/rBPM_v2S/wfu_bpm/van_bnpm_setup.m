function [BnPMstr, error, H] = van_bnpm_setup
%----------------------------------------------%
%                  BPM GUI                     %
%----------------------------------------------%

H = spm('FnUIsetup','VAN BnPM Analysis',0);
error = 0;

%----- Result directory ---------%
if exist('spm_get')
    BnPMstr.result_dir  = spm_str_manip(spm_get(-1,'*','Results directory',pwd),'r');
else
    BnPMstr.result_dir  = spm_str_manip(spm_select(1, 'dir', 'Results directory', [], pwd), '.*');
end
wdir = BnPMstr.result_dir ;
disp(['Results directory:  ' wdir]);
cd(wdir);

%------ Only do regression, BPM.type = 'REGRESSION' ------%
swd = pwd;        
[flist{1}{1}, swd] = wfu_bpm_get_any_file(sprintf('Dependent modality file list for %s',  'REGRESSION'), swd);
title_group{1}{1}  = spm_input('Name of the main modality ','+2','s');

% ------ Reading the main modality files ------%
yfile_names = wfu_bpm_read_flist(flist{1}{1});
nsubj = size(yfile_names,1); % number of subjects
for k = 1:nsubj
    yfile_names_subjs{k} = yfile_names(k,:); % name of each main modality image file
    index = find(yfile_names_subjs{k}==' ');
    if ~isempty(index)
        yfile_names_subjs{k} = [yfile_names(k,1:index-1),yfile_names(k,index+1:size(yfile_names(k)))];
    end
end
BnPMstr.fname = yfile_names_subjs{1};

% ------- determining the size of the images ---------------------------%
Vtemp = spm_vol(yfile_names_subjs{1});
nRows      = Vtemp.dim(1);
nCols      = Vtemp.dim(2);
nSlices = Vtemp.dim(3);
BnPMstr.dim = Vtemp.dim;

% ------ imageing covariates ------ %        
nModalities = spm_input('How many imaging covariates? ','+1');
for cv = 1:nModalities
    title_img_cov{cv} = spm_input(sprintf('Name of imaging covariate#%d ',cv),'+1','s');
end
       
for m = 2:nModalities+1                
    [flist{m}{1}, swd] = wfu_bpm_get_any_file(sprintf('Modality %d file list ', m), swd);                                     
end
% ------ Reading the regressors files ------%
nr = nModalities; % number of regressors
xfile_names = cell(1,nr);
for m = 1:nr
    xfile_names{m} = wfu_bpm_read_flist(flist{m+1}{1});
    for k = 1:nsubj
        xfile_names_subjs{m}{k} = xfile_names{m}(k,:);
        index = find(xfile_names_subjs{m}{k}==' ');
        if ~isempty(index)
            xfile_names_subjs{m}{k} = [xfile_names{m}(k,1:index-1),xfile_names{m}(k,index+1:size(xfile_names{m}(k)))];
        end
    end
end

BnPMstr.flist = wfu_bpm_write_flist_gen(wdir,flist,nModalities+1);

% ------ non-imaging covariates ------ %         
niCov = spm_input('Any non-imaging covariates? ','+1','y/n',[1,0],2);
        
% ----- No regressors error ---------------------%
if (nModalities == 0) & (niCov == 0)
    display('Regression requires at least one covariate')
    error = 1;
    return
end
        
% --- Selecting the file with non-imaging covariates information--%       
% conf is no-image covariates        
if niCov > 0
    [conf, swd] = wfu_bpm_get_any_file(sprintf('Non-imaging covariates file for %s', 'REGRESSION'), swd);
    col_cof = load(conf);
    nIC = size(col_cof,2);
    for cv = 1:nIC
        title_ni_cov{cv} = spm_input(sprintf('Name of non-imaging covariates#%d ',cv),'+1','s');
    end
else
    conf = [];
end
BnPMstr.conf = conf;
        
%----- brain mask -----% 
if spm_input('Apply a predefined brain mask? ','+1','y/n',[1 0],0)
 %   ---------- Enter the mask ----------------%
    [BnPMstr.mask, swd]  = wfu_bpm_get_image_file('Select mask', swd);
    
else
    tt = spm_input('Threshold type', '+1', 'Proportional|Absolute',[],1);
    if strcmp(tt, 'Proportional')
        Pthr = spm_input('threshold ','+1','e',0.1);   
        BnPMstr.mask_pthr = Pthr ;
    else
        Athr = spm_input('threshold ','+1','e',0.1);   
        BnPMstr.mask_athr = Athr ;
    end
    BnPMstr.mask       = ''   ;
end

%-Ask about variance smoothing & volumetric computation
%-----------------------------------------------------------------------
vFWHM=[0,0,0];	% FWHM for variance smoothing
bVarSm=0;	% Flag for variance smoothing

vFWHM = spm_input('FWHM(mm) for Variance smooth','+1','e',0);
if length(vFWHM)==1
	vFWHM = vFWHM * ones(1,3);
elseif length(vFWHM)==2
	vFWHM = [vFWHM, 0];
else
	vFWHM = reshape(vFWHM(1:3),1,3);
end
if ~all(vFWHM==0), bVarSm=1; end

BnPMstr.vFWHM = vFWHM;
BnPMstr.bVarSm = bVarSm;

% ------ input permutation times ------ %
nPiCond = gamma(nsubj+1);
bAproxTst = spm_input(sprintf('%d Perms. Use approx. test?',nPiCond),...
							'+1','y/n')=='y';
if bAproxTst
      tmp = 0;
      while ((tmp>nPiCond) | (tmp==0) )
      tmp = spm_input(sprintf('# perms. to use? (Max %d)',nPiCond),'+0');
      tmp = floor(max([0,tmp]));
      end
      if (tmp==nPiCond), bAproxTst=0; else nPiCond=tmp; end
end
BnPMstr.nPiCond = nPiCond;
BnPMstr.bAproxTst = bAproxTst;

% ------ Contrast parameter ------ %
tt = spm_input('Contrast Type', '+1', 'F|T',[],1);
if strcmp(tt, 'F') 
    STAT = 'F';
    sr = spm_input(sprintf('Select the regressors (1/0)'),'+1','e'); 
    c = sr(:);
else
    STAT = 'T';
    c = spm_input(sprintf('Enter new contrast '),'+1','e');   
    c=c(:);
end
BnPMstr.Stat = STAT;
BnPMstr.contrast{1} = c;

% ------ SPM, BnPM directory ------%
spm_dir  = spm_str_manip(spm_select(1, 'dir', 'SPM directory', [], pwd), '.*');
bnpm_dir  = spm_str_manip(spm_select(1, 'dir', 'BnPM directory', [], pwd), '.*');
BnPMstr.spm_dir = spm_dir;
BnPMstr.bnpm_dir = bnpm_dir;

% ------ Number of jobs ------%
BnPMstr.njob = spm_input(sprintf('Enter # of jobs '),'+1','e'); 

% input walltime
walltime = spm_input(sprintf('Enter walltime hour:minute:second'),'+1','s');
BnPMstr.walltime = walltime;

% ----title----%
% BnPMstr.titles{1} = title_group{1}{k};
BnPMstr.DMS(1) = 1;
if niCov > 0
        BnPMstr.DMS(2) = size(col_cof,2);
        
        for k = 1:BnPMstr.DMS(2)
            BnPMstr.titles{k+BnPMstr.DMS(1)} = title_ni_cov{k};
        end
else
        BnPMstr.DMS(2) = 0;
end
if nModalities > 0
        BnPMstr.DMS(3) = nModalities;
        for k = 1:BnPMstr.DMS(3)
            BnPMstr.titles{1} = 'mean'; % add mean to contrast
            BnPMstr.titles{k+BnPMstr.DMS(1)+BnPMstr.DMS(2)} = title_img_cov{k};
        end
else
        BnPMstr.DMS(3) = 0;
end


end

%
function [fileh, swd, name] = wfu_bpm_get_any_file(title, dir)
if exist('spm_get')
    fileh = spm_get(1, '*', title);
else
    fileh = spm_select(1, 'any', title, [], dir, '.*');
end
[swd, name] = fileparts(fileh);
end


%
function [fileh, swd, name] = wfu_bpm_get_image_file(title, dir)
if exist('spm_get')
    fileh = spm_get(1, '*.img', title);
else
    fileh = spm_select(1, 'IMAGE', title, [], dir, '.*');
end
[swd, name] = fileparts(fileh);
end

