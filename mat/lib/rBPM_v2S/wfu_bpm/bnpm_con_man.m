function [BnPM] = bnpm_con_man(BnPM)

if nargin < 1      
    %-------------- set parameters via GUI --------------------------% 
    %clear all;
    H = spm('FnUIsetup','BnPM Contrast Manager',0);
    % Loading the BnPM structure
    if exist('spm_get')
        BnPM_fname  = spm_get(1,'*','Select the BnPM.mat file ...', pwd);
    else
        BnPM_fname  = spm_select(1, 'mat', 'Select the BnPM.mat file ...', [], pwd, '.*');
    end
    cd(fileparts(BnPM_fname));
    load(BnPM_fname);
    BnPM = bnpm_path_in_struct(BnPM_fname, BnPM);
    
    if strcmp(BnPM.type,'CORR') || strcmp(BnPM.type,'PCORR')
        disp('Go to the insertion tool option...')
        close(H)
        return
    end
    %---------------------------    
    % list contrast components
    nPar = length(BnPM.titles) ;
    
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
        
        str = ['  ' upper(BnPM.titles{i})];        
        text(i-.75, .5, str, ...
            'FontSize',spm('FontSize',12),...
            'FontAngle','Normal',...
            'HorizontalAlignment','Left',...
            'VerticalAlignment','Middle', ...
            'Rotation', 90)   
    end
    
    pt = spm_input('P Value', '+1', 'Corrected|Uncorrected',[],1);
    if strcmp(pt, 'Uncorrected')
        % nonparametric mapping  read uncorrected p value
        Vp = spm_vol(BnPM.pval);
        BnPM.ptype = 'Uncorrected';
        BnPM.psign = [];
    else
        BnPM.ptype = 'Corrected';
        if strcmp(BnPM.psign,'+')
            % read corrected positive p value
            Vp = spm_vol(BnPM.pc_pos);
        else
            % read corrected negative p value
            Vp = spm_vol(BnPM.pc_neg);
        end
    end
    %---------------------------
 
%     if strcmp(BnPM.type,'REGRESSION')
        % Generating or requesting the contrast for parametric regression
%         tt = spm_input('Contrast Type', '+1', 'F|T',[],1);
%         if strcmp(tt, 'F') 
%             BnPM.Type_STAT = 'F';
%             sr = spm_input(sprintf('Select the regressors (1/0)'),'12','e'); 
% %             sr = [0 sr];
% %             c  = eye(length(sr));
% %             IndReg = find(sr>0);
% %             c = c(:,IndReg);
%             c = sr(:);
%         else
%         ts = spm_input('T-sign', '+1', '+|-',[],1);
%         BnPM.Type_STAT = 'T';
%         c = spm_input(sprintf('Enter new contrast '),'12','e');   
%         c=c(:);
% %             c = [0;c];
%             if strcmp(ts,'-')
%                 c = -c;
%             end
%         end

        if spm_input('Clear contrast history? ','+1','y/n',[1 0],2)
            nContrasts = size(BnPM.contrast,2);          
            for i = 1:nContrasts
	            mapname = char(BnPM.Stat{i});
	            delete(mapname);
	            delete(strrep(mapname, '.img', '.hdr'));
	            delete(strrep(mapname, '.img', '.mat'));
                delete(fullfile(BnPM.result_dir, sprintf('spmF_%04d.img',i)));
                delete(fullfile(BnPM.result_dir, sprintf('spmF_%04d.hdr',i)));
                delete(fullfile(BnPM.result_dir, sprintf('spmF_%04d.mat',i)));
                delete(fullfile(BnPM.result_dir, sprintf('spmT_%04d.img',i)));
                delete(fullfile(BnPM.result_dir, sprintf('spmT_%04d.hdr',i)));
                delete(fullfile(BnPM.result_dir, sprintf('spmT_%04d.mat',i)));
            end
            delete(fullfile(BnPM.result_dir, 'SPM.mat'));
            BnPM.contrast = [];
            BnPM.Stat = [];
            BnPM.Type_Stat = '';
        end
%         if isempty(BnPM.contrast)
%             BnPM.contrast    = cell(1);
%             BnPM.contrast{1} = c;            
%         else 
%             BnPM.contrast{length(BnPM.contrast)+1} = c;
%         end   
%     else
%        % Requesting the contrast for ANCOVA or ANOVA 
%         c = spm_input(sprintf('Enter new contrast '),'12','e');        
%         if spm_input('Clear contrast history? ','+1','y/n',[1 0],2)
%             nContrasts = size(BnPM.contrast,1);          
%             for i = 1:nContrasts
% 	            mapname = char(BnPM.Stat{i});
% 	            delete(mapname);
% 	            delete(strrep(mapname, '.img', '.hdr'));
% 	            delete(strrep(mapname, '.img', '.mat'));
%                 delete(fullfile(BnPM.result_dir, sprintf('spmT_%04d.img',i)));
%                 delete(fullfile(BnPM.result_dir, sprintf('spmT_%04d.hdr',i)));
%                 delete(fullfile(BnPM.result_dir, sprintf('spmT_%04d.mat',i)));
%             end
%             delete(fullfile(BnPM.result_dir, 'SPM.mat'));
%             BnPM.contrast = [];
%             BnPM.Stat = [];
%             BnPM.Type_Stat = '';
%         end
%         c=c(:);
%         c = [0;c];
%         if isempty(BnPM.contrast)
%             BnPM.contrast = [];
%         end
%         BnPM.contrast = [BnPM.contrast; c'];
%         BnPM.Type_STAT = 'T';
%     end
    close(H);       
else
    % Command line branch of execution
    H = spm('FnUIsetup','BnPM Contrast Manager',0); 
    if strcmp(BnPM.type,'REGRESSION')
       c = BnPM.contrast{1};
    %        BnPM.Type_STAT = STAT;
        if strcmp(BnPM.ptype, 'Uncorrected')
            % nonparametric mapping  read uncorrected p value
            Vp = spm_vol(BnPM.pval);
        else           
            if strcmp(BnPM.psign,'+')
                % read corrected positive p value
                Vp = spm_vol(BnPM.pc_pos);
            else
                % read corrected negative p value
                Vp = spm_vol(BnPM.pc_neg);
            end
        end
    else
       c = BnPM.contrast(:);
    end
end

Vb = spm_vol(BnPM.beta);

% % read robustfit sigma value
% Vsig = spm_vol(BnPM.sig);

% read mask header if present
if ~isempty(BnPM.mask)
    Vm   = spm_vol(BnPM.mask);
    cube = spm_read_vols(Vm);
    brain_mask_vol = cube >0;
end

% create Tmap header for writing by slice
[path,name,ext] = fileparts(BnPM.pval);
if strcmp(BnPM.type,'REGRESSION')
    nContrasts = size(BnPM.contrast,2);
    if strcmp(BnPM.Type_STAT,'F')
       Smap_fname = sprintf('Fmap%d.img',nContrasts);
    else
       Smap_fname = sprintf('Tmap%d.img',nContrasts);
    end
else
    nContrasts = size(BnPM.contrast,1);
    Smap_fname = sprintf('Tmap%d.img',nContrasts);
end

Vstat = bnpm_hdr_struct(Vp);
Vstat.fname = fullfile(path,Smap_fname);
BnPM.Stat{nContrasts} = Vstat.fname;
Vstat = spm_create_vol(Vstat);

% get dimensions from p-value header
M = Vp.dim(1);
N = Vp.dim(2);
L = Vp.dim(3);

% for ANCOVA and REGRESSION, XtX design matrices will be read
% from a binary file;
% otherwise, X will be loaded from X.mat specified in BnPM.X

if strcmp(BnPM.type, 'ANCOVA')  | strcmp(BnPM.type, 'REGRESSION')
  
    % set XtX dimensions for reshaping
    if strcmp(BnPM.type, 'ANCOVA')
        nr = size(BnPM.contrast,2);
    else 
        % REGRESSION
        nr = sum(BnPM.DMS);
    end
    nx = M*N*nr*nr;        
    XtX = zeros(M,N,nr*nr);
    %
    % open design matrix file for reading by slice
    [fid, message] = fopen(BnPM.XtX, 'r', 'b');
    if fid == -1
        error(message);
    end
end
%
if strcmp(BnPM.type, 'ANCOVA')  | strcmp(BnPM.type, 'ANOVA') | strcmp(BnPM.type, 'ANCOVA_ROI')
    caption = 'Generating Tmap';
else 
    % REGRESSION
    if strcmp(BnPM.Type_STAT,'F')
        Rc = rank(c);
        BnPM.dof = [Rc BnPM.dof];
        caption = 'Generating Fmap';
    else 
        caption = 'Generating Tmap';
    end
end

H = spm('FnUIsetup', caption,0);
spm_progress_bar('Init' ,L, caption, 'slices completed');
BETA_slice = zeros(M,N,length(BnPM.beta));
p_value = zeros(M,N,length(BnPM.pval));
% compute and write out the map slice by slice
Smap = zeros(M,N,L);
for slice_no = 1:L  
    
    brain_mask = brain_mask_vol(:,:,slice_no);
    if sum(sum(brain_mask)) > 0      

        % computing conimages
        ConImage = zeros(M,N);
        for k = 1:length(BnPM.beta)
            BETA_slice(:,:,k) = spm_slice_vol(Vb{k}, spm_matrix([0 0 slice_no]), Vb{k}.dim(1:2), 0);
            ConImage = ConImage + BETA_slice(:,:,k) * c(k);
        end
%         sig = spm_slice_vol(Vsig, spm_matrix([0 0 slice_no]), Vsig.dim(1:2), 0); % read sig
        p_value = spm_slice_vol(Vp, spm_matrix([0 0 slice_no]), Vp.dim(1:2), 0);
        
        % Computing the Statistical maps
        if strcmp(BnPM.type, 'ANCOVA') | strcmp(BnPM.type, 'REGRESSION')
            % read design matrices for slice
            [XtX, count] = fread(fid, nx, 'double');
            if count ~= nx
                error(sprintf('error reading design matrix file on slice %d', slice_no));
            end            
            XtX = reshape(XtX, M, N, nr*nr);
            
            if strcmp(BnPM.type, 'ANCOVA')
                Smap(:,:,slice_no) = bnpm_compute_Tmap(ConImage, XtX, c, brain_mask, sig2, Smap(:,:,slice_no),M,N,nr); 
%                  Smap(:,:,slice_no) = compute_Robust_Tmap(ConImage, XtX, c, brain_mask, sig, Smap(:,:,slice_no),M,N,nr);
            else    
                % regression
                dof = BnPM.dof;
                if strcmp(BnPM.Type_STAT,'F')
                    Smap(:,:,slice_no) = Compute_Nonp_Fmap(p_value,dof,brain_mask,Smap(:,:,slice_no),M,N);
                else
                    Smap(:,:,slice_no) = Compute_Nonp_Tmap(p_value,dof,brain_mask,Smap(:,:,slice_no),M,N);
                end
            end
        else
            % anova & ancova with ROI
            load(BnPM.X);
            Smap(:,:,slice_no) = bnpm_compute_Tmap2(ConImage, X, c,brain_mask, sig2, Smap(:,:,slice_no),M,N);          
        end
    else  
        if strcmp(BnPM.type, 'ANCOVA') | strcmp(BnPM.type, 'REGRESSION')
            status = fseek(fid,nx*8,0);
        end      
    end
    Vstat = spm_write_plane(Vstat,Smap(:,:,slice_no),slice_no);
    spm_progress_bar('Set',slice_no);
end

% close all input and output files
if strcmp(BnPM.type, 'ANCOVA') | strcmp(BnPM.type, 'REGRESSION')
    fclose(fid);
end
for k = 1:length(BnPM.beta)
    if exist('spm_close_vol')
        spm_close_vol(Vb{k});
    end
end
% if exist('spm_close_vol')
%     spm_close_vol(Vsig);
% end
if exist('spm_close_vol')
    spm_close_vol(Vp);
end
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
% % ------------- Update BnPM file -------------------------- %
if nargin < 1
   save(BnPM_fname, 'BnPM');
   % close SPM figure
   spm_figure('Clear','Interactive'); 
   close(H) 
else 
   save BnPM BnPM
end

