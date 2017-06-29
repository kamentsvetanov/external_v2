function van_bnpm_analysis(result_dir,conf,contrast,STAT,title,mask,thr,vFWHM,bAproxTst,nPiCond,spm_dir,bnpm_dir,njob,walltime)

SCCSid = '1.4';
SPMid  = spm('SFnBanner','bnpm toolbox','SCCSid');
warning('off')
H = spm('FnUIsetup','VAN BnPM Analysis',0);
error = 0;

if nargin < 1  
    %========== set parameters via GUI ==============================% 
    [BnPMstr error H] = van_bnpm_setup;
    if error > 0
        close(H)
        return
    end
    
    if ~spm_input('Run BnPM analysis now? ','+1','y/n',[1,0],1)
        spm_figure('clear','Interactive');
        fprintf('\tDone.'); 
        close(H)
        return
    end 
    nPiCond = BnPMstr.nPiCond;
    bAproxTst = BnPMstr.bAproxTst;
    spm_dir = BnPMstr.spm_dir;
    bnpm_dir = BnPMstr.bnpm_dir;
    walltime = BnPMstr.walltime;
    
else
    %========== set parameters via commend line ========================%
%     BnPMstr.DMS(1) = size(textread('file_mod1.txt', '%s', 'delimiter', '\n', 'whitespace', '', 'headerlines', 0),1);
    BnPMstr.DMS(1) = 1;
    
    if ~isempty(result_dir)
        master_name = fullfile(result_dir,'master_flist.txt');
    else
        master_name = 'master_flist.txt';
    end
    file_names = wfu_bpm_read_flist(master_name);
    BnPMstr.DMS(3) = size(file_names,1)-1;
    BnPMstr.flist = master_name;     
    
    if isempty(result_dir)
        BnPMstr.result_dir = pwd;
    else
        BnPMstr.result_dir = result_dir;
    end
    
    if strcmp(STAT,'F')
            sr = contrast;
            c  = eye(length(sr));
            IndReg = find(sr>0);
            c = c(:,IndReg);
            BnPMstr.Type_STAT = 'F';
    else 
            c = contrast;
            c = c(:);
            BnPMstr.Type_STAT = 'T';
    end
    if ~isfield(BnPMstr,'contrast')
            BnPMstr.contrast    = cell(1);
            BnPMstr.contrast{1} = c;
            if ~isempty(title)
                BnPMstr.titles{1} = title;
            else
                BnPMstr.titles{1} = strcat(BnPMstr.Type_STAT,'map','1');
            end
    else 
            BnPMstr.contrast{length(BnPMstr.contrast)+1} = c;
            BnPMstr.titles{length(BnPMstr.contrast)+1}   = strcat(BnPMstr.STAT,'map',num2str(length(BnPMstr.contrast)+1));
    end
    
        %----- brain mask -----% 
    if isempty(mask)
        BnPMstr.mask = [];      
    else        
        BnPMstr.mask = mask;         
    end    
    %----- non-imaging confounds -----% 
    if isempty(conf)
        BnPMstr.conf   = [];    
        BnPMstr.DMS(2) = 0;
    else
        load(conf)
        BnPMstr.DMS(2) = size(conf,2);
        BnPMstr.conf   = conf ;
    end
    
    %---------- threshold for building the brain mask ----%
    if isempty(thr)
        BnPMstr.mask_pthr = 0.1 ;
    else
        if thr(1) == 1
            BnPMstr.mask_pthr = thr(2);
        else
            BnPMstr.mask_athr = thr(2);
        end        
    end
    
    %---------- vFWHM for smooth ---%
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
    
    BnPMstr.nPiCond = nPiCond;
    BnPMstr.bAproxTst = bAproxTst;
    BnPMstr.spm_dir = spm_dir;
    BnPMstr.bnpm_dir = bnpm_dir;
    BnPMstr.njob = njob;
    BnPMstr.walltime = walltime;
end

if nargin < 1  
    master_name = fullfile(BnPMstr.result_dir,'master_flist.txt');
    file_names = wfu_bpm_read_flist(master_name);
end
file_names_mod = wfu_bpm_read_flist(master_name);                     
[file_names_subjs,no_grp] = wfu_bpm_get_file_names( file_names_mod(1,:) ); 
nsubj = size(file_names_subjs{1},1);

%-Compute permutations of conditions
%=======================================================================

if bAproxTst
	%-Approximate test :
	% Build up random subset of all (within nSubj) permutations
	%===============================================================
	rand('seed',sum(100*clock))	%-Initialise random number generator
	PiCond      = zeros(nPiCond,nsubj);
	PiCond(1,:) = 1+rem([0:nsubj-1],nsubj);
	for i = 2:nPiCond
		%-Generate a new random permutation - see randperm
		[null,p] = sort(rand(nsubj,1)); p = p(:)';
		%-Check it's not already in PiCond
		while any(all((meshgrid(p,1:i-1)==PiCond(1:i-1,:))'))
			[null,p] = sort(rand(nsubj,1)); p = p(:)';
		end
		PiCond(i,:) = p;
	end
	clear p

else
	%-Full permutation test :
	% Build up exhaustive matrix of permutations
	%===============================================================
	%-Compute permutations for a single exchangability block
	%---------------------------------------------------------------
	%-Initialise XblkPiCond & remaining numbers
	XblkPiCond = [];
	lef = [1:nsubj]';
	%-Loop through numbers left to add to permutations, accumulating PiCond
	for i = nsubj:-1:1
		%-Expand XblkPiCond & lef
		tmp = round(exp(gammaln(nsubj+1)-gammaln(i+1)));
		Exp = meshgrid(1:tmp,1:i); Exp = Exp(:)';
		if ~isempty(XblkPiCond), XblkPiCond = XblkPiCond(:,Exp); end
		lef = lef(:,Exp);
		%-Work out sampling for lef
		tmp1 = round(exp(gammaln(nsubj+1)-gammaln(i+1)));
		tmp2 = round(exp(gammaln(nsubj+1)-gammaln(i)));
		sam = 1+rem(0:i*tmp1-1,i) + ([1:tmp2]-1)*i;
		%-Add samplings from lef to XblkPiCond
		XblkPiCond   = [XblkPiCond; lef(sam)];
		%-Delete sampled items from lef & condition size
		lef(sam) = [];
		tmp = round(exp(gammaln(nsubj+1)-gammaln((i-1)+1)));
		lef = reshape(lef,(i-1),tmp);
		%NB:gamma(nSubj+1)/gamma((i-1)+1) == size(XblkPiCond,2);
	end
	clear lef Exp sam i
	%-Reorientate so permutations are in rows
	XblkPiCond = XblkPiCond';
	PiCond=XblkPiCond;
end

%-Check, condition and randomise PiCond
%-----------------------------------------------------------------------
%-Check PiConds sum within Xblks to sum to 1
if ~all(all(sum(PiCond,2)== (nsubj+1)*nsubj/2 ))
	error('Invalid PiCond computed!'), end
%-Convert to full permutations from permutations within blocks
nPiCond = size(PiCond,1);
%-Randomise order of PiConds (except first) to allow interim analysis
rand('seed',sum(100*clock))	%-Initialise random number generator
PiCond=[PiCond(1,:);PiCond(randperm(nPiCond-1)+1,:)];
%-Check first permutation is null permutation
if ~all(PiCond(1,:)==[1:nsubj])
	error('PiCond(1,:)~=[1:nsubj]'); end

%=======================================================================
% - C O R R E C T   P E R M U T A T I O N
%=======================================================================
% Work out correct permuation completely. Separating the first
BPM.type = 'REGRESSION';
BPM.result_dir = BnPMstr.result_dir;
BPM.titles = BnPMstr.titles;
BPM.robust = 0;
BPM.DMS = BnPMstr.DMS;
BPM.flist = BnPMstr.flist;
BPM.conf = BnPMstr.conf;
BPM.mask = BnPMstr.mask;
nr = BPM.DMS(3);
if isfield(BnPMstr,'mask_pthr')
    BPM.mask_pthr = BnPMstr.mask_pthr;
end

if isfield(BnPMstr,'mask_athr')
    BPM.mask_athr = BnPMstr.mask_athr;
end


% ----- Treatment of the mask ----------------%

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

% save mask name
BnPMstr.mask = BPM.mask;

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
BPM.Nonpf = 1;
[results] = wfu_bpm_execute(BPM);
results.V = wfu_bpm_hdr_struct(results.V);
% ---------- storing the beta coefficients file names ------------ %

%------ writing the results ------%        
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
    
%%%%%%%%%%%%% t statistic
BPM.contrast{1} = BnPMstr.contrast{1};

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
BPM.Type_STAT = BnPMstr.STAT;
BPM.vFWHM = BnPMstr.vFWHM;
BPM.bVarSm = BnPMstr.bVarSm;
BPM = wfu_bpm_con_man(BPM);    
Tmap0 = BPM.Stat{1};
BnPMstr.Tmap0 = Tmap0;
BnPMstr.dof = BPM.dof;


% if BnPMstr.njob == 1
%     % save PiCond
%     [fid, message] = fopen([BnPMstr.result_dir,'PiCond'], 'w', 'b');
%     if fid == -1
%         disp(message);
%     end
%     if fid ~= -1
%         count = fwrite(fid, PiCond, 'double');
%         if count ~= prod(size(PiCond))
%             str = sprintf('error writing permutation order matrices at slice');
%             disp(str);
%         end
%     end
%     % close file
%     if fid ~= -1
%         fclose(fid);
%     end
%     van_bnpm('REGRESSION','master_flist.txt',[0 1],'T',[], [], [1 0.1], BnPMstr.result_dir,[], [],11, ...
%         [BnPMstr.result_dir,'Picond'], [8 8 8], Tmap0);
%     % read nPtmp and MaxT
%     [fid, message] = fopen([BnPMstr.result_dir,'nPtmp'], 'r', 'b');
%     if fid == -1
%         error(message);
%     end
%     [nPtmp, count] = fread(fid, 'double');
%     if fid ~= -1
%         fclose(fid);
%     end
%     nPtmp = reshape(nPtmp,nRows,nCols,nSlices);
%     
%     [fid, message] = fopen([BnPMstr.result_dir,'MaxT'], 'r', 'b');
%     if fid == -1
%         error(message);
%     end
%     [MaxT, count] = fread(fid, 'double');
%     if fid ~= -1
%         fclose(fid);
%     end
%     MaxT = reshape(MaxT,nPiCond,2);
%     punc = nPtmp/nPiCond;
%     
%     % corrected p value
%     Vt   = spm_vol(Tmap0);
%     T0 = spm_read_vols(Vt);
%     tol = 1e-4;	% Tolerance for comparing real numbers
%     Pc_pos = zeros(nRows,nCols,nSlices);
%     MaxT_pos=MaxT(:,1);
%     for t = MaxT_pos'
%         %-FEW-corrected p is proportion of randomisation greater or
%         % equal to statistic.
%         %-Use a > b -tol rather than a >= b to avoid comparing
%         % two reals for equality.
%         Pc_pos = Pc_pos + (t > T0 -tol);
%     end
%     Pc_pos = Pc_pos./nPiCond;
%     
%     Pc_neg = zeros(nRows,nCols,nSlices);
%     MaxT_neg=MaxT(:,2);
%     for t = MaxT_neg'
%         %-FEW-corrected p is proportion of randomisation greater or
%         % equal to statistic.
%         %-Use a > b -tol rather than a >= b to avoid comparing
%         % two reals for equality.
%         Pc_neg = Pc_neg + (t > -T0 -tol);
%     end
%     Pc_neg = Pc_neg./nPiCond;
%     % Tmax = sort(MaxT_pos);
%     % Threshold = Tmax(nPiCond-round(0.05*nPiCond));
% end


% ------ Create jobs ------%
npicon = ceil((nPiCond-1)/BnPMstr.njob);
picon = PiCond;
clear PiCond

flisty = wfu_bpm_read_flist(file_names(1,:));
flistx = wfu_bpm_read_flist(file_names(2,:));

for job = 1:BnPMstr.njob
    % For results
    pwd;
    rfolder = ['Result_Job',num2str(job)];
    mkdir(rfolder);
    cd(rfolder); 
    % master file
    fid = fopen('master_flist.txt','w');
    numfmod = nr+1;
    fprintf(fid,'%d\n',numfmod);            
    for m = 1:nr+1
        fmod{m} = [...
            pwd,'//file_mod',num2str(m),'.txt'];
        fprintf(fid,'%s\n',fmod{m});
    end
    fclose(fid);
    % fmod file for y
    fid = fopen('file_mod1.txt','w');
    fprintf(fid,'%s',flisty);
    fclose(fid);
    % fmod file for x
    for m = 2:BnPMstr.DMS(3)+1                                                    
        fid = fopen(['file_mod',num2str(m),'.txt'],'w');
        fprintf(fid,'%s',flistx);
        fclose(fid);
    end
    % PiCond
    startperm = 2+npicon*(job-1);
    endperm = min((startperm+npicon-1),nPiCond);
    PiCond = picon(startperm:endperm,:);
    % save
    piname = fullfile(pwd, 'PiCond');
    [fid, message] = fopen(piname, 'w', 'b');
    if fid == -1
        disp(message);
    end
    if fid ~= -1
        count = fwrite(fid, PiCond, 'double');
        if count ~= prod(size(PiCond))
            str = sprintf('error writing permutation order matrices at slice');
            disp(str);
        end
    end
    % close file
    if fid ~= -1
        fclose(fid);
    end
    cd ..
    
    % ------ write matlab command file ------%
    fid = fopen(['bnpm_cluster',num2str(job),'.m'],'w');
    path = ['addpath ',spm_dir,' ',bnpm_dir];
    fprintf(fid,'%s\n',path);
    fprintf(fid,'%s\n','bnpm_startup;');
    % Replace the default stream at MATLAB startup, using a stream whose
    % seed is based on clock, so that rand will return different values in
    % different MATLAB sessions. 
%     randinit = 'RandStream.setDefaultStream(RandStream(''mt19937ar'',''seed'',sum(100*clock)))';
%     fprintf(fid,'%s\n',randinit);
    
%     if isempty(mask) % no mask
%         if isempty(conf) % no nonimage
%             commend = ['van_bnpm(''REGRESSION'',''master_flist.txt'',[',num2str(c(1)),' ',num2str(c(2)),'],''',STAT,...
%                 ''',[],[],[',num2str(fthr),' ',num2str(thr),'],''',BnPMstr.result_dir,'Result_Job',num2str(job),''',[],[],',num2str(npicon),...
%                 ',''',piname,''',[',num2str(vFWHM(1)),' ',num2str(vFWHM(2)),' ',num2str(vFWHM(3)),'],''',Tmap0,''')'];
%         else % nonimage covariate
%             commend = ['van_bnpm(''REGRESSION'',''master_flist.txt'',[',num2str(c(1)),' ',num2str(c(2)),'],''',STAT,...
%                 ''',[],''',conf,''',[',num2str(fthr),' ',num2str(thr),'],''',BnPMstr.result_dir,'Result_Job',num2str(job),''',[],[],',num2str(npicon),...
%                 ',''',piname,''',[',num2str(vFWHM(1)),' ',num2str(vFWHM(2)),' ',num2str(vFWHM(3)),'],''',Tmap0,''')'];
%         end
%     else % mask
        if isempty(BnPMstr.conf) % no nonimage
            commend = ['van_bnpm(''REGRESSION'',''master_flist.txt'',[',num2str(BnPMstr.contrast{1}(1)),' ',num2str(BnPMstr.contrast{1}(2)),'],''',...
                BnPMstr.Type_STAT,''',''',BnPMstr.mask,''',[],[],''',BnPMstr.result_dir,'Result_Job',num2str(job),''',[],[],',...
                num2str(npicon),',''',piname,''',[',num2str(BnPMstr.vFWHM(1)),' ',num2str(BnPMstr.vFWHM(2)),' ',num2str(BnPMstr.vFWHM(3)),'],''',Tmap0,''')'];
        else
            commend = ['van_bnpm(''REGRESSION'',''master_flist.txt'',[',num2str(BnPMstr.contrast{1}(1)),' ',num2str(BnPMstr.contrast{1}(2)),'],''',...
                BnPMstr.Type_STAT,''',''',BnPMstr.mask,''',''',BnPMstr.conf,''',''',BnPMstr.result_dir,'Result_Job',BnPMstr.num2str(job),...
                ''',[],[],',num2str(npicon),',''',piname,''',[',num2str(BnPMstr.vFWHM(1)),' ',num2str(BnPMstr.vFWHM(2)),' ',num2str(BnPMstr.vFWHM(3)),'],''',Tmap0,''')'];
        end
%     end
    fprintf(fid,'%s',commend);
    fclose(fid);
end

% save BnPM structure
BnPMstr.nContrasts = 0;
fname = fullfile(BnPMstr.result_dir,'BnPMstr');   
save(fname, 'BnPMstr');

% FOR loop here to create and submit all jobs
for part = 1:BnPMstr.njob
    fp = fopen(['MTbnpm',num2str(part),'.pbs'],'wt');

    donefile = sprintf([BnPMstr.result_dir,'job%.0f.done'],rand()*100000);

    fprintf(fp,'%s\n','#!/bin/bash');
    fprintf(fp,'%s\n','#PBS -M xue.yang@vanderbilt.edu');
    fprintf(fp,'%s\n','#PBS -l nodes=1:ppn=1:x86');
    fprintf(fp,'#PBS -l walltime=%s\n',walltime);
    fprintf(fp,'%s\n','#PBS -l mem=2000mb');
    fprintf(fp,'%s\n','#PBS -o xue-cluster.txt');
    fprintf(fp,'%s\n','#PBS -j oe');

    fprintf(fp,'%s\n',['matlab -nodesktop < ',BnPMstr.result_dir,'bnpm_cluster',num2str(part),'.m >matlab.output']);
    fprintf(fp,'touch %s\n',donefile);
    fclose(fp);
    
    system(sprintf('qsub %s',['-m a MTbnpm',num2str(part),'.pbs']));

%     if part==1
%         system(sprintf('qsub %s','-m ba MTbnpm1.pbs'));
%     else
%         if part == BnPMstr.njob
%             system(sprintf('qsub %s',['-m e MTbnpm',num2str(part),'.pbs']));
%         else
%             system(sprintf('qsub %s',['MTbnpm',num2str(part),'.pbs']));
%         end
%     end
    
end

% CLOSE FOR LOOP 

% NEW FOR LOOP - wait fro all jobs to finish
while(length(dir(donefile))<1)
    disp('Looking...');
    pause(10);
end
% END FOR LOOP
close(H);
return
end

