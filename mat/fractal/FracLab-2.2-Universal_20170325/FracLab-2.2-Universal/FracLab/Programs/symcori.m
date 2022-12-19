function Ss = symcori(S)
%   Symmetrization of a periodic 2D correlation field
%
%   1.  Usage
%
%   ______________________________________________________________________
%   Ss = symcori(S) ;
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o   S  : Matrix [N/2+1 , N]
%      Periodic 2D correlation field S(1:N/2+1,1:N) of a complex 2D NxN
%      field. Values of S(1,N/2+2:N) may be arbitrary.
%
%   1.2.  Output parameters
%
%   o   Ss  :  Matrix [N , N]
%      Symetrized correlation field
%
%   2.  See also:
%
%   synth2, strfbm
%
%   3.  Example:
%
%   4.  Examples

% Author B. Pesquet-Popescu, ENS-Cachan, February 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N = size(S,2);
if size(S,1) ~= N/2+1
   error('Incorrect dimensions of original field')
end

Ss = S;
% Checking for the symmetries in the original field
ind = N/2+1:N-1;
Ss(1,ind+1) = (conj(Ss(1,N-ind+1))+Ss(1,ind+1))/2;
Ss(1,N-ind+1) = conj(Ss(1,ind+1));
Ss(N/2+1,ind+1) = (conj(Ss(N/2+1,N-ind+1))+Ss(N/2+1,ind+1))/2;
Ss(N/2+1,N-ind+1) = conj(Ss(N/2+1,ind+1));

% Symmetrization
Ss(ind+1,1) = conj(S(N-ind+1,1));
ind2 = 1:N-1;
Ss(ind+1,ind2+1) = conj(S(N-ind+1,N-ind2+1));

