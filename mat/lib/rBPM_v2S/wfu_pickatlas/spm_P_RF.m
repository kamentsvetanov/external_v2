function [P,p,Em,En,EN] = spm_P_RF(c,k,Z,df,STAT,R,n)
%spmversion=spm('Ver');
spmversion = wfu_get_ver;
switch spmversion
    case 'SPM99' 
        [P,p,Em,En,EN] = wfu_spm_P_RF99(c,k,Z,df,STAT,R,n);
    case 'SPM2'
        [P,p,Em,En,EN] = wfu_spm_P_RF2(c,k,Z,df,STAT,R,n);
    otherwise
        [P,p,Em,En,EN] = wfu_spm_P_RF5(c,k,Z,df,STAT,R,n);
end
return
