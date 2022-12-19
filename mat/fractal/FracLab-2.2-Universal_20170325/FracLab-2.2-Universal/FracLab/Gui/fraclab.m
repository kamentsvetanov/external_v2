function []=fraclab()
% Launch FracLab toolbox, fltool

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if ~verLessThan('matlab', '8.4')
  warning('off', 'MATLAB:Figure:Pointer'); %Full crosshair pointer is no longer supported, from R2014b
end

if ~verLessThan('matlab', '9.0')
    warning('off', 'MATLAB:nargchk:deprecated');  %NARGCHK will be removed, warns from R2016a
end

fltool