tfce = tfceMex_pthread(t, dh, E, H, calc_neg, single_threaded)
% FORMAT tfce = tfceMex(t, dh, E, H, calc_neg, single_threaded)
% Estimate TFCE
% t         - T map 
% dh        - step size (e.g. dh = max(abs(t))/100)
% E         - TFCE parameter for extent
% H         - TFCE parameter for height
% calc_neg  - also calc neg. TFCE values (default)
% single_threaded - use single thread only
%
% Christian Gaser
% $Id: tfceMex_pthread.m 125 2017-08-23 14:59:44Z gaser $

rev = '$Rev: 125 $';

disp('Compiling tfceMex_pthread.c')

pth = fileparts(which(mfilename));
p_path = pwd;
cd(pth);
mex -O tfceMex_pthread.c
cd(p_path);

tfce = tfceMex_pthread(t, dh, E, H, calc_neg, single_threaded);

return
