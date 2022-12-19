%   Hilbert transform
%
%   Mtlb_Hilbert transform of a signal. mtlb_hilbert(x) is the Hilbert
%   transform of the real part of vector X.  The real part of the result
%   is the original real data; the imaginary part is the actual Hilbert
%   transform.
%
%   1.  Usage
%
%   ______________________________________________________________________
%   y = mtlb_hilbert(x) ;
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  x : Real or complex valued vector [1,N]
%
%   1.2.  Output parameters
%
%   o  y : Complex valued vector [1,N]
%      Analytic signal corresponding to the real part of the input x.
%
%   2.  See also:
%
%   fft
%
%   3.  Examples

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------