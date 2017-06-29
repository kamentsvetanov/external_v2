function [results] = wfu_bpm_execute(BPM)
% ------------------------------------------%

%----- in case of early return -----% 
dof     = []; 
mask    = [];
Fvals   = []; 

%----- analysis type -----% 

switch BPM.type 
    case {'ANOVA', 'ANCOVA_ROI'}         
            if strcmp(BPM.type,'ANCOVA_ROI')
                BPM.ancova_ROI_reg = wfu_bpm_comp_ancova_ROI_reg(BPM);    
            end
           
            [X,dof,sig2,mask,nsubj,nr,Vtemp] = wfu_bpm_anova(BPM);
            results.X     = X;
            results.dof   = dof;
            results.sig2  = sig2;
%             results.sig   = sig;
            results.nsubj = nsubj;
            results.nr    = nr;
            results.mask  = mask;        
            results.V     = Vtemp;
            
        case {'ANCOVA', 'REGRESSION'}  
       
            [X,dof,sig2,mask,nsubj,nr,Vtemp] = wfu_bpm_ancova(BPM);   
            dof= dof(:);
            indx = mask(:) > 0;
            dof = min(dof(indx));
            results.X    = X;
            results.dof  = dof;
            results.sig2 = sig2;
%             results.sig  = sig;
            results.nsubj= nsubj;
            results.nr   = nr;
            results.mask = mask;
            results.V    = Vtemp;
            
        case 'CORR'
            if strcmp(BPM.corr_type,'V-ROI')
                BPM.ROI_reg = wfu_bpm_comp_corr_ROI_reg(BPM);    
                [Stats,dof,C, mask,nsubj, Vtemp]   = wfu_bpm_correlation_ROI(BPM);     
                
            else          
                [Stats,dof,C, mask,nsubj, Vtemp]   = wfu_bpm_correlation(BPM);                 
            end
            results.Stats = Stats;
            results.dof   = dof;
            results.nsubj = nsubj;
            results.C     = C;
            results.mask  = mask ;
            results.V     = Vtemp;           
            %         results.ROI_reg = BPM.ROI_reg;
        case 'PCORR'
            
            [Stats, C, dof,mask,nsubj, Vtemp]   = wfu_bpm_partial_correlation(BPM);               
            
            results.Stats = Stats;
            results.dof   = dof;
            results.nsubj = nsubj;
            results.C     = C;
            results.mask  = mask ;
            results.V     = Vtemp;       
        otherwise
            warning(sprintf('Analysis type (%s) is invalid',BPM.type));
            return
end
    
    spm('FnUIsetup','Done.',0);
    return
    
    
    
