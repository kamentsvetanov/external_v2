function  M = spm_get_space(imagename, mat)

version=spm('Ver');
switch version
	case 'SPM99'
		if nargin>1,
			M = spm_get_space99(imagename,mat);
		else,
			M = spm_get_space99(imagename);
		end;
	case 'SPM2'
		if nargin>1,
			M = spm_get_space2(imagename,mat);
		else,
			M = spm_get_space2(imagename);
		end;
	case 'SPM5'
		if nargin>1,
			M = spm_get_space5(imagename,mat);
		else,
			M = spm_get_space5(imagename);
		end;
	otherwise
		current = pwd;
		if ~strcmp('/',imagename(1)), imagename = fullfile(pwd,imagename); end;
		cd(spm('dir'));
		if nargin>1,
			M = spm_get_space(imagename,mat);
		else,
			M = spm_get_space(imagename);
		end;
		cd(current);
end
return
