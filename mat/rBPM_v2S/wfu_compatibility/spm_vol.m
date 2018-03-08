function V = spm_vol(P)


version=spm('Ver');
switch version
	case 'SPM99' 
		V = spm_vol99(P);
	case 'SPM2'
		V = spm_vol2(P);
    otherwise
        V = spm_vol5(P);
end
return
