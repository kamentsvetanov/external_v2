function wfu_bpm_analysis(type,flist,contrast,STAT,mask, conf, thr, result_dir,title, Inf_Type, bRobust, r_wfun, p_MaxOut) 
%--------------------------------------------------------------------------
%                                wfu_bpm 
%--------------------------------------------------------------------------  
%   Format: 
%   wfu_bpm(type,flist,contrast,STAT,mask,conf,result_dir,title, Inf_Type)
%--------------------------------------------------------------------------
%   Examples:
%    >> wfu_bpm; %-launches GUI  
%    >> wfu_bpm('CORR','flist.txt',[],[],'mask.img',[],[],[],[],'HCF');
%    >> wfu_bpm('ANCOVA','master_flist.txt',[ 1 -1 0],'T',[],[],[ 1 0.1],[],[],[]);%           
%--------------------------------------------------------------------------
%             wfu_bpm can be executed from the command line 
%
%  Input Parameters:
%   type      - Type of analysis to be performed. Possible values are:
%               'ANOVA'         =   Anova 
%               'ANCOVA'        =   BPM Ancova              
%               'CORR'          =   Correlation
%               'PCORR'         =   Partial Correlation
%               'REGRESSION'    =   BPM Regression
%
%   flist     - The master file. It contains a list of txt files. One per
%               each modality involved in the analysis.
%             
%   contrast  - a given contrast 
%
%   STAT      - Statistic type ('T','F')
%   
%   mask      - (optional) path and file name of the file containing the brain 
%                mask. If the user does not supply one BPM will build one by
%                default. The user must check the resulting mask.img file.%
%             
%   conf      - path and name of the file containing the not imaging confounds 
%    
%    thr      - threshold to build the default brain mask whebn the user
%               does not supply one. thr is a vector with 2 elements. The
%               first one indicates the type of the threshold (1 is 
%               proportional 2 absolute). The second element is the value of
%               the threshold.
%
% result_dir  - the path and name of the directory where results will be
%               stored.
%
% title       - name assigned to the contrast 
%
% Inf_Type    - specify the type of inference to use with the correlation
%              option
%              'HCF'  = Homologous Correlation Field
%              'TF'   = T-fields
%
% bRobust    - 1: use robust regression, 0: use non robust regression
%
% r_wfun     - weight function for robust regression
%--------------------------------------------------------------------------

SCCSid = '1.4';
SPMid  = spm('SFnBanner','wfu_bpm toolbox','SCCSid');
warning('off')

if nargin < 1  
    %========== set parameters via GUI ==============================% 
    [BPM error H] = wfu_bpm_setup;
    if error > 0
        close(H)
        return
    end
    
    if ~spm_input('Run BPM analysis now? ','+1','y/n',[1,0],1)
        spm_figure('clear','Interactive');
        fprintf('\tDone.'); 
        close(H)
        return
    end    
    
else   
    
    if nargin < 3 & type ~= 'CORR'        
        warning('Not enough input arguments');
        return      
    end
    if strcmp(type,'CORR_V-V')
        type      = 'CORR';
        BPM.corr_type = 'V-V';
        if ~isempty(Inf_Type)
            BPM.Inf_Type = Inf_Type;
        else
            warning(sprintf('Inference type is not defined'));
            return  
        end
    end
    if strcmp(type,'PCORR')        
        BPM.corr_type = '';
        BPM.pc_control_var = conf;
        if ~isempty(Inf_Type)
            BPM.Inf_Type = Inf_Type;
        else
            warning(sprintf('Inference type is not defined'));
            return  
        end
    end

    %========== set parameters via COMMAND LINE arguments ===========% 
    if any(strcmp(type,{'CORR','ANCOVA','REGRESSION','ANOVA','PCORR'}))
        BPM.type = type;
    else
        warning(sprintf('Calculation type (%s) is invalid',type));
        return
    end 
    % ----- Number of groups and imaging covariates ------ %
    if ~(strcmp(BPM.type,'CORR') | strcmp(BPM.type,'CORR') | strcmp(BPM.type,'REGRESSION'))
        BPM.DMS(1) = size(textread('file_mod1.txt', '%s', 'delimiter', '\n', 'whitespace', '', 'headerlines', 0),1);
    else
        BPM.DMS(1) = 1;
    end
    if ~isempty(result_dir)
        master_name = fullfile(result_dir,'master_flist.txt');
    else
        master_name = 'master_flist.txt';
    end
    file_names = wfu_bpm_read_flist(master_name);
    
    if (strcmp(BPM.type,'ANOVA'))
        BPM.DMS(3) = 0;
    else
        BPM.DMS(3) = size(file_names,1)-1;
    end
    
    %----- image list -----%        
    
    BPM.flist = master_name; 
    if any(strcmp(type,{'ANOVA','ANCOVA'}))   
        BPM.STAT = 'T';   
        c = contrast(:);        
        c = [0;c];        
        if ~isfield(BPM,'contrast')
            BPM.contrast = c';
            if ~isempty(title)
                BPM.maptitles{1} = title;
            else
                BPM.maptitles{1} = strcat(BPM.STAT,'map','1');
            end
        else   
            BPM.contrast = [BPM.contrast; c'];             
            BPM.maptitles{size(BPM.contrast,2)}   = strcat(BPM.STAT,'map',num2str(size(BPM.contrast,2)));
        end   
    end    
    if any(strcmp(type,{'REGRESSION'})) 
        if strcmp(STAT,'F')
            sr = contrast;
            c  = eye(length(sr));
            IndReg = find(sr>0);
            c = c(:,IndReg);
            BPM.Type_STAT = 'F';
        else 
            c = contrast;
            c = c(:);
            BPM.Type_STAT = 'T';
        end
        if ~isfield(BPM,'contrast')
            BPM.contrast    = cell(1);
            BPM.contrast{1} = c;
            if ~isempty(title)
                BPM.maptitles{1} = title;
            else
                BPM.maptitles{1} = strcat(BPM.Type_STAT,'map','1');
            end
        else 
            BPM.contrast{length(BPM.contrast)+1} = c;
            BPM.maptitles{length(BPM.contrast)+1}   = strcat(BPM.STAT,'map',num2str(length(BPM.contrast)+1));
        end           
    end
    
    %----- brain mask -----% 
    if nargin < 5 | isempty(mask)
        BPM.mask = [];      
    else        
        BPM.mask = mask;         
    end    
    %----- non-imaging confounds -----% 
    if nargin < 6 | isempty(conf)
        BPM.conf   = [];    
        BPM.DMS(2) = 0;
    else
        load(conf)
        BPM.DMS(2) = size(conf,2);
        BPM.conf   = conf ;
    end
    
    %---------- threshold for building the brain mask ----%
    if nargin < 7 | isempty(thr)
        BPM.mask_pthr = 0.1 ;
    else
        if thr(1) == 1
            BPM.mask_pthr = thr(2);
        else
            BPM.mask_athr = thr(2);
        end        
    end
    
    if nargin < 8 | isempty(result_dir)
        BPM.result_dir = pwd;
    else
        BPM.result_dir = result_dir;
    end
    
    % robust regression
    if nargin < 11 | isempty(bRobust)
        BPM.robust = 0;
    else
        if bRobust ==1
            BPM.robust = 1;
        else
            BPM.robust = 0;
        end
    end
    
    % weight function
    if nargin < 12 | isempty(r_wfun)
        BPM.rwfun = 'huber';
    else
        BPM.rwfun = r_wfun;
    end
    
    % proportional maximun outlier
    if nargin <13 | isempty(pMaxOut)
        BPM.pMaxOut = 1;
    else
        BPM.pMaxOut = p_MaxOut;
    end
    
    H = spm('FnUIsetup','WFU BPM Analysis',0); 
end

% ----- Treatment of the mask ----------------%
if nargin < 1  
    master_name = fullfile(BPM.result_dir,'master_flist.txt');
end    
file_names_mod = wfu_bpm_read_flist(master_name);                     
[file_names_subjs,no_grp] = wfu_bpm_get_file_names( file_names_mod(1,:) ); 

if isempty(BPM.mask)
    %  ---- Generating the default mask ------------- %    
%     if nargin < 1  
%         master_name = fullfile(BPM.result_dir,'master_flist.txt');
%     end    
%     file_names_mod = wfu_bpm_read_flist(master_name) ;                     
%     [file_names_subjs,no_grp] = wfu_bpm_get_file_names( file_names_mod(1,:) ); 
    k = 1;        
    for m = 1:no_grp
        for n = 1:size(file_names_subjs{m},1)
            CP1{k} = file_names_subjs{m}(n,:);
            k = k + 1;
        end
    end    
    P1 = strvcat(CP1);
    [inter_mask1] = wfu_bpm_mask(P1, BPM);
    BPM.mask      = fullfile(BPM.result_dir,'mask.img')    ;
else
    % ----- mask provided by the user ----------%
    Vmask  = spm_vol(BPM.mask);
    Vsubj1 = spm_vol(file_names_subjs{1}(1,:));
    if ~isequal(Vmask.dim(1:3),Vsubj1.dim(1:3))   
        C{1}       = file_names_subjs{1}(1,:);
        C{2}       = BPM.mask;
        P          = strvcat(C);    
        flag.mean  = 0;
        flag.which = 1;
        spm_reslice(P,flag);  
        [filepath,fname,ext]  = fileparts(BPM.mask);
        rfname                = strcat('r',fname);
        BPM.mask              = fullfile(filepath,strcat(rfname,ext));
    end
end

% ------ Reslicing the ROI mask -----------------------------%

if isfield(BPM,'mask_ROI') | isfield(BPM,'mask_ancova_ROI')
    Vmask      = spm_vol(BPM.mask);
    C{1}       = BPM.mask;
    if isfield(BPM,'mask_ROI') 
        Vmask_ROI                = spm_vol(BPM.mask_ROI);
        C{2}                     = BPM.mask_ROI;   
    else
        Vmask_ROI                = spm_vol(BPM.mask_ancova_ROI);
        C{2}                     = BPM.mask_ancova_ROI;
    end
    
    if ~isequal(Vmask.dim(1:3),Vmask_ROI.dim(1:3))              
        P          = strvcat(C);    
        flag.mean  = 0;
        flag.which = 1;
        spm_reslice(P,flag);
        if isfield(BPM,'mask_ROI') 
            [filepath,fname,ext]     = fileparts(BPM.mask_ROI);
            rfname                   = strcat('r',fname);
            BPM.mask_ROI             = fullfile(filepath,strcat(rfname,ext));
        else
            [filepath,fname,ext]     = fileparts(BPM.mask_ancova_ROI);
            rfname                   = strcat('r',fname);
            BPM.mask_ancova_ROI      = fullfile(filepath,strcat(rfname,ext));
        end
        
    end
end

%  ------------ Reslicing the imaging modalities -------------%

[BPM] = wfu_bpm_reslice_newflists(BPM);   

% set file name for design matrix information file
BPM.XtX = fullfile(BPM.result_dir, 'XtX');
warning off MATLAB:divideByZero;

% ---- deleting the content of the result directory ----------%

ddir = pwd;
cd(BPM.result_dir);

delete('S*.img');delete('S*.hdr'); delete('S*.mat');
delete('R*.img');delete('R*.hdr'); delete('R*.mat');
delete('T*.img');delete('T*.hdr'); delete('T*.mat');
delete('b*.img');delete('b*.hdr'); delete('b*.mat');
delete('s*.img');delete('s*.hdr'); delete('s*.mat');
delete('X.mat') ; delete('*PM.mat'); delete('X*.*');

% -----execute after result dir files deleted----- %

[results] = wfu_bpm_execute(BPM);
results.V = wfu_bpm_hdr_struct(results.V);

%------ writing the results ------%

switch BPM.type
    
    case{'ANOVA' , 'ANCOVA', 'REGRESSION', 'ANCOVA_ROI'} 
        
        % ---------- storing the beta coefficients file names ------------ %
        
        for k = 1:results.nr
            BPM.beta{k} = fullfile(BPM.result_dir,sprintf('beta%03d.img', k));           
        end
%         % ---------- storing the sig in an img file ---------------------- %
%         results.V.fname = fullfile(BPM.result_dir,'sig.img');   
%         BPM.sig    =  results.V.fname ;
%         spm_write_vol(results.V, results.sig) ;                         
        % --------- storing the residuals file names -------------------- % 
        for k = 1:results.nsubj
            BPM.E{k} = fullfile(BPM.result_dir,sprintf('Res%03d.img', k));           
        end 
        P = strvcat(BPM.E);
        % ---------- storing the sig2 in an img file ---------------------- %
        results.V.fname = fullfile(BPM.result_dir,'sig2.img');   
        BPM.sig2    =  results.V.fname ;
        spm_write_vol(results.V, results.sig2) ;
        % ----------- storing X file -------------------------------------- %
        Xfname = fullfile(BPM.result_dir,'X');   
        X = results.X;
        save(Xfname, 'X')  ; 
        % ----------- filling other BPM fields ----------------------------- %
        BPM.X = Xfname     ;
        BPM.dof = results.dof      ;
        if nargin < 1
            BPM.contrast = []  ; 
        end
        
    case{'CORR', 'PCORR'}
        % ---------  residuals file names -------------------- % 
        for k = 1:results.nsubj
            BPM.E{k} = fullfile(BPM.result_dir,sprintf('Res%03d.img', k));           
        end 
        P = strvcat(BPM.E);
        if  strcmp(BPM.corr_type,'V-V') || strcmp(BPM.type,'PCORR')
            % -------storing both Tmaps and Cmaps when voxel to voxel-----%
            %        Correlation or Partial Correlation                   %
            % ------- storing positive correlation map -------------------%
            results.V.fname = fullfile(BPM.result_dir,'Corr_pos.img');   
            spm_write_vol(results.V,results.C) ;
            BPM.Stat{1}    = results.V.fname   ;
            
            % ------- storing negative correlation map -------------------%
            results.V.fname = fullfile(BPM.result_dir,'Corr_neg.img');  
            spm_write_vol(results.V,-results.C) ;
            BPM.Stat{2}    = results.V.fname;
            % ------- storing the Tmap ------------------------%
            results.V.fname =  fullfile(BPM.result_dir,'Tmap.img');   
            spm_write_vol(results.V,results.Stats) ;    
            results.V.fname = fullfile(BPM.result_dir,'Tmap_plus.img');   
            spm_write_vol(results.V,results.Stats) ;
            BPM.Tmap{1}    = results.V.fname ;
            
            % ------- storing Tmap for testing negative correlations------%
            results.V.fname = fullfile(BPM.result_dir,'Tmap_minus.img');  
            spm_write_vol(results.V,-results.Stats) ;
            BPM.Tmap{2}    = results.V.fname;
        else
            % ------- storing Tmap for testing positive correlations-----%
            results.V.fname = fullfile(BPM.result_dir,'Tmap_plus.img');   
            spm_write_vol(results.V,results.Stats) ;
            BPM.Stat{1}    = results.V.fname ;
            
            % ------- storing Tmap for testing negative correlations------%
            results.V.fname = fullfile(BPM.result_dir,'Tmap_minus.img');  
            spm_write_vol(results.V,-results.Stats) ;
            BPM.Stat{2}    = results.V.fname;
            % ------- storing the Correlation map ------------------------%
            results.V.fname =  fullfile(BPM.result_dir,'Corr_map.img');   
            spm_write_vol(results.V,results.C) ;       
        end
        
        BPM.dof = results.dof      ;        
end

% --------------- Estimating the smoothness ------------------- %

Infx = [];
Infy = [];
Infz = [];
if nargout('spm_est_smoothness') == 2
    [BPM.fwhm, VRpv] = spm_est_smoothness(P,BPM.mask); 
elseif nargout('spm_est_smoothness') == 5    
    [BPM.fwhm, VRpv, Infx, Infy, Infz] = spm_est_smoothness(P,BPM.mask); 
end
if length(Infx) >= 1
    BPM.maskInfx = Infx;
    BPM.maskInfy = Infy;
    BPM.maskInfz = Infz;
    BPM.maskInf  = fullfile(BPM.result_dir, 'maskInf.img');
    wfu_bpm_maskInf(Infx, Infy, Infz, BPM.mask, BPM.maskInf);
end

% ---------- Deleting the residual files -------------------------%
ddir = pwd ;
cd(BPM.result_dir);
delete('R*.img');
delete('R*.hdr');
delete('R*.mat');
% ---------- Calling the Contrast Manager in command line regime ----%
if nargin > 0 
    fname = fullfile(BPM.result_dir,'BPM');   
    save(fname, 'BPM');
    if ~any(strcmp(BPM.type,{'CORR','PCORR'}))                
        BPM = wfu_bpm_con_man(BPM);           
        save BPM
    end        
    wfu_insert_map(BPM);
%    spm fmri
else
    % ---------- Updating BPM ----------------------------%
    fname = fullfile(BPM.result_dir,'BPM');   
    save(fname, 'BPM');
    close(H)
    cd(BPM.result_dir);
end
return



