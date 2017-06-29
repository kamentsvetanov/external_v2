function [fwhm,VRpv,Infx,Infy,Infz] = spm_est_smoothness(varargin)

version=spm('Ver');
switch version
% 	case 'SPM2'
% 		if nargin>0,
% 		 [fwhm,VRpv] = spm_est_smoothness2(varargin{1:end});
% 		else 
% 		 [fwhm,VRpv] = spm_est_smoothness2;
% 		end
% 	otherwise
% 		if nargin>0,
% 	 	 [fwhm,VRpv] = spm_est_smoothness5(varargin{1:end});
% 		else 
% 		 [fwhm,VRpv] = spm_est_smoothness5;
% 		end
%
% ---------------------------------------------------------------------
% KLP 04/13/06
% return the indices of any Inf values removed from SPM's estimation of
% smoothness
% ---------------------------------------------------------------------
%
	case 'SPM2'
		if nargin>0,
		 [fwhm,VRpv,Infx,Infy,Infz] = spm_est_smoothness2(varargin{1:end-1});
		else 
		 [fwhm,VRpv,Infx,Infy,Infz] = spm_est_smoothness2;
		end
    otherwise 'SPM5'
		if nargin>0,
	 	 [fwhm,VRpv,Infx,Infy,Infz] = spm_est_smoothness5(varargin{1:end-1},varargin{end});
		else 
		 [fwhm,VRpv,Infx,Infy,Infz] = spm_est_smoothness5;
        end

end
return
