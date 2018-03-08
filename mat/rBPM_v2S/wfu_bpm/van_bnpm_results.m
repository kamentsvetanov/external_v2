function van_bnpm_results

SCCSid = '1.5';
SPMid  = spm('SFnBanner',mfilename,SCCSid);
%-----------------------------------------%
      
%========== set parameters via GUI ==============================% 
%clear all;
H = spm('FnUIsetup','BnPM Results',0);
% Loading the BPM structure
if exist('spm_get')
    BnPMstr_fname  = spm_get(1,'*','Select the BnPMstr.mat file ...', pwd);
else
    BnPMstr_fname  = spm_select(1, 'mat', 'Select the BnPMstr.mat file ...', [], pwd, '.*');
end
[path,name,ext] = fileparts(BnPMstr_fname);
load(BnPMstr_fname);  
% Uncorrected p value or Corrected p value
ptype = spm_input('P value', '+1', 'Uncorrected|Corrected',[],1);
% if strcmp(ptype,'Corrected')
    psign = spm_input('T-sign', '+1', '+|-',[],1);
% end

if spm_input('Clear contrast history? ','+1','y/n',[1 0],2)         
    for i = 1:BnPMstr.nContrasts
	            mapname = char(BnPMstr.Stat);
	            delete(mapname);
	            delete(strrep(mapname, '.img', '.hdr'));
	            delete(strrep(mapname, '.img', '.mat'));
                delete(fullfile(BnPMstr.result_dir, sprintf('spmF_%04d.img',i)));
                delete(fullfile(BnPMstr.result_dir, sprintf('spmF_%04d.hdr',i)));
                delete(fullfile(BnPMstr.result_dir, sprintf('spmF_%04d.mat',i)));
                delete(fullfile(BnPMstr.result_dir, sprintf('spmT_%04d.img',i)));
                delete(fullfile(BnPMstr.result_dir, sprintf('spmT_%04d.hdr',i)));
                delete(fullfile(BnPMstr.result_dir, sprintf('spmT_%04d.mat',i)));
     end
            delete(fullfile(BnPMstr.result_dir, 'SPM.mat'));
            BnPMstr.nContrasts = 0;
end

close(H)

BnPMstr.nContrasts = BnPMstr.nContrasts + 1;
        
if strcmp(BnPMstr.Type_STAT,'F')
       Smap_fname = sprintf('Fmap%d.img',BnPMstr.nContrasts);
else
       Smap_fname = sprintf('Tmap%d.img',BnPMstr.nContrasts);
end


cd(BnPMstr.result_dir);

tol = 1e-4;

nPiCond = BnPMstr.nPiCond;
npicon = ceil((nPiCond-1)/BnPMstr.njob);
nRows = BnPMstr.dim(1);
nCols = BnPMstr.dim(2);
nSlices = BnPMstr.dim(3);
nPtmpwhole = zeros(nRows,nCols,nSlices);
MaxTwhole = zeros(nPiCond,2);


Vt   = spm_vol(BnPMstr.Tmap0);
T0 = spm_read_vols(Vt);
Vmask = spm_vol(BnPMstr.mask);
brain_mask_vol = spm_read_vols(Vmask);
MaxTwhole(1,1) = max(T0(:));
MaxTwhole(1,2) = -min(T0(:));

for job = 1:BnPMstr.njob
    rfolder = [BnPMstr.result_dir,'Result_Job',num2str(job)];
    if strcmp(psign,'+')
        ptmpname = fullfile(rfolder,'nPtmp');
        [fid, message] = fopen(ptmpname, 'r', 'b');
        if fid == -1
            error(message);
        end
        [nPtmp, count] = fread(fid, 'double');
        if fid ~= -1
            fclose(fid);
        end
        nPtmp = reshape(nPtmp,nRows,nCols,nSlices);
        nPtmpwhole = nPtmpwhole + nPtmp;
    else   
        ptmpnegname = fullfile(rfolder,'nPtmp_neg');
        [fid, message] = fopen(ptmpnegname, 'r', 'b');
        if fid == -1
            error(message);
        end
        [nPtmp_neg, count] = fread(fid, 'double');
        if fid ~= -1
            fclose(fid);
        end
        nPtmp_neg = reshape(nPtmp_neg,nRows,nCols,nSlices);
        nPtmpwhole = nPtmpwhole + nPtmp_neg;
    end
    
    
    maxtname = fullfile(rfolder,'MaxT');
    [fid, message] = fopen(maxtname, 'r', 'b');
    if fid == -1
        error(message);
    end
    [MaxT, count] = fread(fid, 'double');
    if fid ~= -1
        fclose(fid);
    end
    startperm = 2+npicon*(job-1);
    endperm = min((startperm+npicon-1),nPiCond);    
    MaxT = reshape(MaxT,npicon,2);
    MaxTwhole(startperm:endperm,:) = MaxT;
end

MaxT_pos = MaxTwhole(:,1);
MaxT_neg = MaxTwhole(:,2);

if strcmp(BnPMstr.Tmap0,[BnPMstr.result_dir,'Tmap1.img'])
    system(sprintf('mv Tmap1.hdr T0.hdr'));
    system(sprintf('mv Tmap1.img T0.img'));
    BnPMstr.Tmap0 = fullfile(BnPMstr.result_dir,'T0.img');
end

if strcmp(ptype,'Uncorrected')
    punc = (nPtmpwhole+1)/nPiCond;
else
    Pc_pos = zeros(size(T0));
    Pc_neg = zeros(nRows,nCols,nSlices);
    if strcmp(psign,'+')
        for t = MaxT_pos'
        %-FEW-corrected p is proportion of randomisation greater or
        % equal to statistic.
        %-Use a > b -tol rather than a >= b to avoid comparing
        % two reals for equality.
        Pc_pos = Pc_pos + (t > T0 -tol);
        end
        Pc_pos = reshape(Pc_pos,nRows,nCols,nSlices);
        Pc_pos = Pc_pos/nPiCond;
%         p1 = reshape(Pc_pos,1,[]);
%         xrange = (max(p1)-min(p1))/length(p1);
%         x = min(p1):xrange:max(p1);
%         if x(leng(x))~=max(p1);
%             x(leng(x)) = max(p1);
%         end
%         tol = 1e-4;
%         yrange = (1-2*tol)/length(p1);
%         y = tol:yrange:1-tol;
%         pval = interp1(x,y,p1);
%         Pc_pos = reshape(pval,nRows,nCols,nSlices);
        
%         maxtpos = sort(MaxT_pos);
%         Tthred_pos = maxtpos(nPiCond - floor(0.05*nPiCond))
%         tname = fullfile(BnPMstr.result_dir,'Tthred_pos');
%         save(tname,'Tthred_pos');
    else
        for t = MaxT_neg'
        %-FEW-corrected p is proportion of randomisation greater or
        % equal to statistic.
        %-Use a > b -tol rather than a >= b to avoid comparing
        % two reals for equality.
        Pc_neg = Pc_neg + (t > -T0 -tol);
        end 
        Pc_neg = reshape(Pc_neg,nRows,nCols,nSlices);
        Pc_neg = Pc_neg/nPiCond;
%         maxtneg = sort(MaxT_neg);
%         Tthred_neg = maxtneg(nPiCond - floor(0.05*nPiCond))
%         tname = fullfile(BnPMstr.result_dir,'Tthred_neg');
%         save(tname,'Tthred_neg');
    end
end

statmap = zeros(size(T0));

for slice_no = 1:nSlices 
    
    brain_mask = brain_mask_vol(:,:,slice_no);
    if sum(sum(brain_mask)) > 0              
        % Computing the Statistical maps 
        if strcmp(ptype,'Uncorrected')
             pvalue = punc(:,:,slice_no);
                
        else
           if strcmp(psign,'+')
               pvalue = Pc_pos(:,:,slice_no);
           else
               pvalue = Pc_neg(:,:,slice_no);  
           end
        end
        if strcmp(BnPMstr.Type_STAT,'T')
            statmap(:,:,slice_no) = Compute_Nonp_Tmap(pvalue,BnPMstr.dof,brain_mask,statmap(:,:,slice_no),nRows,nCols);
        else
            statmap(:,:,slice_no) = Compute_Nonp_Fmap(pvalue,BnPMstr.dof,brain_mask,statmap(:,:,slice_no),nRows,nCols);
        end    
    end

            
end


file_name = sprintf('%s',BnPMstr.fname);
Vtemp = spm_vol(file_name);
Vtemp = wfu_bpm_hdr_struct(Vtemp);

Vtemp.fname = fullfile(pwd,Smap_fname);   
spm_write_vol(Vtemp, statmap) ;

% save BnPM structure
fname = fullfile(BnPMstr.result_dir,'BnPMstr');   
save(fname, 'BnPMstr');

load('BPM.mat');
BPM.Stat{end+1} = Vtemp.fname;
bpmname = fullfile(BnPMstr.result_dir,'BPM');   
save(bpmname, 'BPM');
wfu_insert_map(BPM);

end
