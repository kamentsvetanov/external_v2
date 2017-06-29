function V = spm_create_vol(V,varargin)

version=spm('Ver');
switch version
	case 'SPM2'
		if nargin>1,
			V = spm_create_vol2(V,varargin{1:end});
		else,
			V = spm_create_vol2(V);
		end;
	otherwise
		if nargin>1,
			V = spm_create_vol5(V,varargin{1:end});
		else,
			V = spm_create_vol5(V);
		end;

end
return
