function x = spm_list(varargin)
%spmversion=spm('Ver');
spmversion = wfu_get_ver;
switch spmversion
    case 'SPM99' 
        x = wfu_spm_list99(varargin{1:end});
    case 'SPM2'
        x = wfu_spm_list2(varargin{1:end});
    otherwise
        x = wfu_spm_list5(varargin{1:end});
end
return
