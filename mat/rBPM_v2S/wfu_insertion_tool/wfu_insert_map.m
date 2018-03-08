   function  wfu_insert_map(BPM)

%   Insert foreign map of 'T' or 'F' values into SPM.mat 
%   FORMAT  SPM = wfu_insert_map
%
%   SPM -   structure written to SPM.mat in spm working dir
%
%   ## v1.5, Aaron Baer, Wake Forest University ##
%______________________________________________________________

SCCSid = '1.5';
SPMid  = spm('SFnBanner',mfilename,SCCSid);
%-----------------------------------------%

if nargin < 1      
    %========== set parameters via GUI ==============================% 
    %clear all;
    H = spm('FnUIsetup','WFU SPM Insert Tool',0);
    % Loading the BPM structure
    if exist('spm_get')
        BPM_fname  = spm_get(1,'*','Select the BPM.mat file ...', pwd);
    else
        BPM_fname  = spm_select(1, 'mat', 'Select the BPM.mat file ...', [], pwd, '.*');
    end
    [path,name,ext] = fileparts(BPM_fname);
    load(BPM_fname);    
    BPM = wfu_bpm_path_in_struct(BPM_fname, BPM);
    close(H)
end

map.V = spm_vol(BPM.Stat);
map.name = BPM.Stat ;
H1 = spm('FnUIsetup','Input map parameters...',0);
% if (nargin <1) && (strcmp(BPM.type,'CORR') || strcmp(BPM.type,'PCORR') )    
%     BPM.Inf_Type = spm_input('Select type of analysis','1','m', ...
%         'Homologous Correlation Field|T-Field', ...
%         ['HCF' ; ...      
%             'TF ']);
% end
% ------- Allowing both kind of inference ------------------%
if (strcmp(BPM.type,'CORR')&& strcmp(BPM.corr_type,'V-V') ) || strcmp(BPM.type,'PCORR') 
    if nargin < 1
        BPM.Inf_Type = spm_input('Select type of analysis','1','m', ...
            'Homologous Correlation Field|T-Field', ...
            ['HCF' ; ...      
                'TF ']);
    end
    if strcmp(BPM.Inf_Type,'TF')
        BPM.Stat{1} = BPM.Tmap{1};
        BPM.Stat{2} = BPM.Tmap{2};
    end
end
for i = 1:length(BPM.Stat)
    [path,name,ext]     = fileparts(BPM.Stat{i}); 
    
    if ( (strcmp(BPM.type,'CORR') && strcmp(BPM.corr_type,'V-V')) || strcmp(BPM.type,'PCORR') ) && strcmp(BPM.Inf_Type,'HCF') 
        map.stat{i}         = 'Corr';   
    else
        map.stat{i}         = 'T-values';
    end
    if strcmp(BPM.type,'REGRESSION')
        if strcmp(name(1),'F') || strcmp(name(1),'S')
            map.stat{i}         = 'F-values';    
        else
            map.stat{i}         = 'T-values';
        end
    end 
    if nargin < 1
        map.title{i}        = spm_input('map title:','+1','s',name); 
    else        
%         map.title{i}     = BPM.maptitles{i}; 
        map.title{i}     = name; 
    end
end
map.dir  = path; 
map.fwhm = BPM.fwhm;
map.flist = BPM.flist; % get file names
map.erdf = BPM.dof(length(BPM.dof));
% if ( (strcmp(BPM.type,'CORR') && strcmp(BPM.corr_type,'V-V')) || strcmp(BPM.type,'PCORR') ) && strcmp(BPM.Inf_Type,'HCF') 
%     map.erdf = BPM.dof(length(BPM.dof)) + 2;    
% else
%     map.erdf = BPM.dof(length(BPM.dof));   
% end
map.dof  = BPM.dof;
% if (nargin <1) && (strcmp(BPM.type,'CORR') || strcmp(BPM.type,'PCORR') )
close(H1);
% end

%----- check before overwriting or appending SPM.mat -----%
if ~exist(fullfile(map.dir,'SPM.mat'),'file')
    map.scratch = 1; 
    SPM = wfu_SPM_template;
else 
    oldSPM = load(fullfile(map.dir,'SPM.mat'));
    if isfield(oldSPM.SPM,'SPMid') & strcmp(oldSPM.SPM.SPMid,'WFU')
     
        str = { 'SPM working directory already contains SPM.mat:', ...
                sprintf('swd = %s',map.dir),''};
        warnButton = questdlg(str,'WARNING', ...
            'Stop','Append with new map','Overwrite','Stop');
        
        switch warnButton
            
            case 'Stop'
                warning(sprintf('%s cancelled.',mfilename)); 
                SPM = []; 
                return
                
            case 'Append with new map'
                map.scratch = 0; 
                SPM = oldSPM.SPM;
                
            case 'Overwrite'
                fprintf('\tOverwriting SPM.mat:\n\t%s\n\n',fullfile(map.dir,'SPM.mat'))
                map.scratch = 1;
                SPM = wfu_SPM_template;      
        end 
    end
end

%----- build SPM from map -----% 
[SPM,copyIndex] = wfu_build_SPM(SPM,map);
SPM.VM          = spm_vol(BPM.mask);

%----- copy and rename new spmT-files -----%
for i = 1:length(copyIndex)
    
    imgFrom     = BPM.Stat{i};
    [p1,n1,e1]  = fileparts(imgFrom); 
    imgDest     = fullfile(SPM.swd,SPM.xCon(copyIndex{i}).Vspm.fname);
    [p2,n2,e2]  = fileparts(imgDest); 
    hdrFrom     = fullfile(p1,[n1,'.hdr']); 
    matFrom     = fullfile(p1,[n1,'.mat']);
    hdrDest     = fullfile(p2,[n2,'.hdr']);
    matDest     = fullfile(p2,[n2,'.mat']);
    fprintf('\n\tSaving new SPM image:\n\t%s\n',imgDest); 
    
    if exist(imgDest,'file')
        fprintf('\tFile name already exists... erasing existing img, hdr\n\n');
        delete(imgDest);
        delete(hdrDest);
    end
    [iS,iM,iID] = copyfile(imgFrom,imgDest);
    [hS,hM,hID] = copyfile(hdrFrom,hdrDest);
	if exist(matFrom,'file'), [mS,mM,mID] = copyfile(matFrom,matDest); end;
end

%----- save SPM.mat -----%
%SPM_file = strcat(path,sprintf('/SPM.mat')); 
SPM_file = fullfile(path,'SPM.mat'); 
save(SPM_file,'SPM');
% save SPM.mat SPM; 

fprintf('\tDONE (%s) ------------------------------------------\n',mfilename);
return
