function Y = strfbm(x,y,H)
%   Structure Function of a Brownian Field
%
%   Creates the structure function of an isotropic fBm
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [Y] = strfbm(x,y,H)
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o   x  : Real vector [1,N]
%      vertical coordinate
%
%   o   y  : Real scalar [1,M]
%      horizontal coordinate
%
%   o   H  : Real in [0,1]
%      Hurst parameter
%
%   1.2.  Output parameters
%
%   o   Y  : Matrix  [N,M]
%      Matrix containing the values of the structure function
%
%   2.  See also:
%
%   synth2
%
%   3.  Example:
%
%   4.  Examples
%
%   % creation of the coordinates system : 128 x 128
%   x = 1:128 ;
%   y = 1:128 ;
%   % Computation of the structure functions of an isotropic fBm field
%   [Y] = strfbm(x,y,0.8) ;
%   % Visualization of the structure functions (logarithmic dynamic - pseudo color)
%   clf ;
%   viewmat(abs(Y),x,y,[1 1 12 0]) ;

% Author B. Pesquet-Popescu, ENS-Cachan, February 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

Y = (x.^2 + y.^2).^H;
