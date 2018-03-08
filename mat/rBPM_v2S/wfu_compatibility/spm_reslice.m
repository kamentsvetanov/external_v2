function spm_reslice(P,flags,wfu_MT)


version=spm('Ver');
switch version
	case 'SPM99' 
		if nargin == 1,
			spm_reslice99(P);
		elseif nargin == 2,
			spm_reslice99(P,flags);
		elseif nargin == 3,
			wfu_spm_reslice(P,flags,wfu_MT);
		end;
	otherwise
		if nargin == 1,
			wfu_spm_reslice(P);
		elseif nargin == 2,
			wfu_spm_reslice(P,flags);
		elseif nargin == 3,
			wfu_spm_reslice(P,flags,wfu_MT);
		end;
end
return
