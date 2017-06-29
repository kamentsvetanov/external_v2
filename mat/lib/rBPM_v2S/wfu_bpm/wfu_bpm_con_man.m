function [BPM] = wfu_bpm_con_man(BPM)

if nargin < 1      
    %-------------- set parameters via GUI --------------------------% 
    %clear all;
    H = spm('FnUIsetup','WFU BPM Contrast Manager',0);
    % Loading the BPM structure
    if exist('spm_get')
        BPM_fname  = spm_get(1,'*','Select the BPM.mat file ...', pwd);
    else
        BPM_fname  = spm_select(1, 'mat', 'Select the BPM.mat file ...', [], pwd, '.*');
    end
    cd(fileparts(BPM_fname));
    load(BPM_fname);
    BPM = wfu_bpm_path_in_struct(BPM_fname, BPM);
    
    if strcmp(BPM.type,'CORR') || strcmp(BPM.type,'PCORR')
        disp('Go to the insertion tool option...')
        close(H)
        return
    end
    %---------------------------    
    % list contrast components
    nPar = length(BPM.titles) ;
    
    %disp(nPar);
    %axes('Position',[0.55 .35 0.42 (nPar+1)*.05],...
    axes('Position',[0.55 .25 0.42 .6],...
        'Tag','ConAx','Visible','on')
    set(gca,'Tag','ConAx',...
        'Box','on','TickDir','out',...
        'XTick',[],...
        'XLim',	[0,nPar],...
        'YTick',[],...
        'YLim',	[0,nPar] ...
        )
    for i = 1:nPar
        
        str = ['  ' upper(BPM.titles{i})];        
        text(i-.75, .5, str, ...
            'FontSize',spm('FontSize',12),...
            'FontAngle','Normal',...
            'HorizontalAlignment','Left',...
            'VerticalAlignment','Middle', ...
            'Rotation', 90)   
    end
    %---------------------------
 
    if strcmp(BPM.type,'REGRESSION')
        % Generating or requesting the contrast for regression
        tt = spm_input('Contrast Type', '+1', 'F|T',[],1);
        if strcmp(tt, 'F')
            BPM.Type_STAT = 'F';
            sr = spm_input(sprintf('Select the regressors (1/0)'),'12','e'); 
%             sr = [0 sr];
%             c  = eye(length(sr));
%             IndReg = find(sr>0);
%             c = c(:,IndReg);
            c = sr(:);
        else
            ts = spm_input('T-sign', '+1', '+|-',[],1);
            BPM.Type_STAT = 'T';
            c = spm_input(sprintf('Enter new contrast '),'12','e');   
            c=c(:);
%             c = [0;c];
            if strcmp(ts,'-')
                c = -c;
            end
        end
        %-Ask about variance smoothing & volumetric computation
        %-----------------------------------------------------------------------
        BPM.vFWHM=[0,0,0];	% FWHM for variance smoothing
        BPM.bVarSm=0;	% Flag for variance smoothing
        
%%
%can not use variance smoothing for parametric regression, assign FWHM to 0
%         BPM.vFWHM = spm_input('FWHM(mm) for Variance smooth','+1','e',0);
%         if length(BPM.vFWHM)==1
%             BPM.vFWHM = BPM.vFWHM * ones(1,3);
%         elseif length(BPM.vFWHM)==2
%             BPM.vFWHM = [BPM.vFWHM, 0];
%         else
%             BPM.vFWHM = reshape(BPM.vFWHM(1:3),1,3);
%         end
%         if ~all(BPM.vFWHM==0), BPM.bVarSm=1; end
%%
        if spm_input('Clear contrast history? ','+1','y/n',[1 0],2)
            nContrasts = size(BPM.contrast,2);          
            for i = 1:nContrasts
	            mapname = char(BPM.Stat{i});
	            delete(mapname);
	            delete(strrep(mapname, '.img', '.hdr'));
	            delete(strrep(mapname, '.img', '.mat'));
                delete(fullfile(BPM.result_dir, sprintf('spmF_%04d.img',i)));
                delete(fullfile(BPM.result_dir, sprintf('spmF_%04d.hdr',i)));
                delete(fullfile(BPM.result_dir, sprintf('spmF_%04d.mat',i)));
                delete(fullfile(BPM.result_dir, sprintf('spmT_%04d.img',i)));
                delete(fullfile(BPM.result_dir, sprintf('spmT_%04d.hdr',i)));
                delete(fullfile(BPM.result_dir, sprintf('spmT_%04d.mat',i)));
            end
            delete(fullfile(BPM.result_dir, 'SPM.mat'));
            BPM.contrast = [];
            BPM.Stat = [];
            BPM.Type_Stat = '';
        end
        if isempty(BPM.contrast)
            BPM.contrast    = cell(1);
            BPM.contrast{1} = c;            
        else 
            BPM.contrast{length(BPM.contrast)+1} = c;
        end   
    else
       % Requesting the contrast for ANCOVA or ANOVA
        c = spm_input(sprintf('Enter new contrast '),'12','e'); 
        
        BPM.vFWHM=[0,0,0];	% FWHM for variance smoothing
        BPM.bVarSm=0;	% Flag for variance smoothing
        
        if spm_input('Clear contrast history? ','+1','y/n',[1 0],2)
            nContrasts = size(BPM.contrast,1);          
            for i = 1:nContrasts
	            mapname = char(BPM.Stat{i});
	            delete(mapname);
	            delete(strrep(mapname, '.img', '.hdr'));
	            delete(strrep(mapname, '.img', '.mat'));
                delete(fullfile(BPM.result_dir, sprintf('spmT_%04d.img',i)));
                delete(fullfile(BPM.result_dir, sprintf('spmT_%04d.hdr',i)));
                delete(fullfile(BPM.result_dir, sprintf('spmT_%04d.mat',i)));
            end
            delete(fullfile(BPM.result_dir, 'SPM.mat'));
            BPM.contrast = [];
            BPM.Stat = [];
            BPM.Type_Stat = '';
        end
        c=c(:);
        c = [0;c]; % 0 for the mean column
        if isempty(BPM.contrast)
            BPM.contrast = [];
        end
        BPM.contrast = [BPM.contrast; c'];
        BPM.Type_STAT = 'T';
    end
    close(H);       
else
    % Command line branch of execution
    H = spm('FnUIsetup','WFU BPM Contrast Manager',0); 
    if strcmp(BPM.type,'REGRESSION')
       c = BPM.contrast{1};
%        BPM.Type_STAT = STAT;
    else
       c = BPM.contrast(:);
    end
end

Vb = spm_vol(BPM.beta);

% % read robustfit sigma value
% Vsig = spm_vol(BPM.sig);

% read sig2 header
Vs = spm_vol(BPM.sig2);
%-voxel size
M=Vs.mat(1:3, 1:3);
VOX=sqrt(diag(M'*M))';

% read mask header if present
if ~isempty(BPM.mask)
    Vm   = spm_vol(BPM.mask);
    cube = spm_read_vols(Vm);
    brain_mask_vol = cube >0;
end

% create Tmap or Fmap header for writing by slice
[path,name,ext] = fileparts(BPM.sig2);
if strcmp(BPM.type,'REGRESSION')
    nContrasts = size(BPM.contrast,2);
    if strcmp(BPM.Type_STAT,'F')
       Smap_fname = sprintf('Fmap%d.img',nContrasts);
    else
       Smap_fname = sprintf('Tmap%d.img',nContrasts);
    end
else
    nContrasts = size(BPM.contrast,1);
    Smap_fname = sprintf('Tmap%d.img',nContrasts);
end

Vstat = wfu_bpm_hdr_struct(Vs);
Vstat.fname = fullfile(path,Smap_fname);
BPM.Stat{nContrasts} = Vstat.fname;
Vstat = spm_create_vol(Vstat);

% get dimensions from sig2 header
M = Vs.dim(1);
N = Vs.dim(2);
L = Vs.dim(3);

% for ANCOVA and REGRESSION, XtX design matrices will be read
% from a binary file;
% otherwise, X will be loaded from X.mat specified in BPM.X

if strcmp(BPM.type, 'ANCOVA')  | strcmp(BPM.type, 'REGRESSION')
  
    % set XtX dimensions for reshaping
    if strcmp(BPM.type, 'ANCOVA')
        nr = size(BPM.contrast,2);
    else 
        % REGRESSION
        nr = sum(BPM.DMS);
    end
    nx = M*N*nr*nr;        
    XtX = zeros(M,N,nr*nr);
    %
    % open design matrix file for reading by slice
    [fid, message] = fopen(BPM.XtX, 'r', 'b');
    if fid == -1
        error(message);
    end
end
%
if strcmp(BPM.type, 'ANCOVA')  | strcmp(BPM.type, 'ANOVA') | strcmp(BPM.type, 'ANCOVA_ROI')
    caption = 'Generating Tmap';
else 
    % REGRESSION
    if strcmp(BPM.Type_STAT,'F')
        Rc = rank(c);
        BPM.dof = [Rc BPM.dof];
        caption = 'Generating Fmap';
    else 
        caption = 'Generating Tmap';
    end
end

H = spm('FnUIsetup', caption,0);
spm_progress_bar('Init' ,L, caption, 'slices completed');
BETA_slice = zeros(M,N,length(BPM.beta));
%-Variance smoothing.
% Blurred mask is used to truncate kernal to brain; if not
% used variance at edges would be underestimated due to
% convolution with zero activity out side the brain.
%-----------------------------------------------------------------
ResSS = spm_read_vols(Vs);
vFWHM = BPM.vFWHM;
if BPM.bVarSm
    SmResSS   = zeros(M,N,L);
	SmMask    = zeros(M,N,L);
	TmpVol    = zeros(M,N,L);
    sig2par   = zeros(M,N,L);
	TmpVol    = brain_mask_vol;
    TmpVol    = double(TmpVol);
	spm_smooth(TmpVol,SmMask,vFWHM./VOX);
	TmpVol    = ResSS;
	spm_smooth(TmpVol,SmResSS,vFWHM./VOX);
    sig2par(find(SmMask)) = SmResSS(find(SmMask))./SmMask(find(SmMask));
else
    sig2par = ResSS;
end

% compute and write out the map slice by slice
Smap = zeros(M,N,L);
for slice_no = 1:L 
    
    brain_mask = brain_mask_vol(:,:,slice_no);
    if sum(sum(brain_mask)) > 0      

        % computing conimages and reading sig2
        ConImage = zeros(M,N);
        for k = 1:length(BPM.beta)
            BETA_slice(:,:,k) = spm_slice_vol(Vb{k}, spm_matrix([0 0 slice_no]), Vb{k}.dim(1:2), 0);
            ConImage = ConImage + BETA_slice(:,:,k) * c(k);
        end
%         sig = spm_slice_vol(Vsig, spm_matrix([0 0 slice_no]), Vsig.dim(1:2), 0); % read sig       
%         sig2 = spm_slice_vol(Vs, spm_matrix([0 0 slice_no]), Vs.dim(1:2), 0); % read sig2
        sig2 = sig2par(:,:,slice_no);
        
        % Computing the Statistical maps
        if strcmp(BPM.type, 'ANCOVA') | strcmp(BPM.type, 'REGRESSION')
            % read design matrices for slice
            [XtX, count] = fread(fid, nx, 'double');
            if count ~= nx
                error(sprintf('error reading design matrix file on slice %d', slice_no));
            end            
            XtX = reshape(XtX, M, N, nr*nr);
            
            if strcmp(BPM.type, 'ANCOVA')
                Smap(:,:,slice_no) = wfu_bpm_compute_Tmap(ConImage, XtX, c, brain_mask, sig2, Smap(:,:,slice_no),M,N,nr); 
%                  Smap(:,:,slice_no) = compute_Robust_Tmap(ConImage, XtX, c, brain_mask, sig, Smap(:,:,slice_no),M,N,nr);
            else    
                % regression 
                if strcmp(BPM.Type_STAT,'F')
                    Smap(:,:,slice_no) = wfu_bpm_compute_Fmap(BETA_slice,XtX, c, Rc, brain_mask, sig2, Smap(:,:,slice_no),M,N,nr); 
%                     Smap(:,:,slice_no) = compute_Robust_Fmap(BETA_slice,XtX, c, Rc, brain_mask, sig, Smap(:,:,slice_no),M,N,nr);                              
                else
                    Smap(:,:,slice_no) = wfu_bpm_compute_Tmap(ConImage, XtX, c, brain_mask, sig2, Smap(:,:,slice_no),M,N,nr);
%                     Smap(:,:,slice_no) = compute_Robust_Tmap(ConImage, XtX, c, brain_mask, sig, Smap(:,:,slice_no),M,N,nr);               
                end
            end
        else
            % anova & ancova with ROI
            load(BPM.X);
            Smap(:,:,slice_no) = wfu_bpm_compute_Tmap2(ConImage, X, c,brain_mask, sig2, Smap(:,:,slice_no),M,N);          
        end
    else  
        if strcmp(BPM.type, 'ANCOVA') | strcmp(BPM.type, 'REGRESSION')
            status = fseek(fid,nx*8,0);
        end      
    end
    Vstat = spm_write_plane(Vstat,Smap(:,:,slice_no),slice_no);
    spm_progress_bar('Set',slice_no);
end

% close all input and output files
if strcmp(BPM.type, 'ANCOVA') | strcmp(BPM.type, 'REGRESSION')
    fclose(fid);
end
for k = 1:length(BPM.beta)
    if exist('spm_close_vol')
        spm_close_vol(Vb{k});
    end
end
% if exist('spm_close_vol')
%     spm_close_vol(Vsig);
% end
if exist('spm_close_vol')
    spm_close_vol(Vs);
end
if exist('Vm', 'var')
    if exist('spm_close_vol')
        spm_close_vol(Vm);
    end
end
if exist('spm_close_vol')
    spm_close_vol(Vstat);
end
% % ------------- Update BPM file -------------------------- %
if nargin < 1
   save(BPM_fname, 'BPM');
   % close SPM figure
   spm_figure('Clear','Interactive'); 
   close(H) 
else    
   save BPM BPM
end

