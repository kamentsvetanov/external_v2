%   Shift DC component to center of spectrum
%
%   Move zeroth lag to center of spectrum. Shift FFT.  For vectors
%   MTLB_FFTSHIFT(X) returns a vector with the left and right halves
%   swapped.  For matrices, MTLB_FFTSHIFT(X) swaps the upper and the lower
%   halves.
%
%   1.  Usage
%
%   ______________________________________________________________________
%   y = mtlb_fftshift(x) ;
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  x : Real or complex valued matrix [rx,cx]
%
%   1.2.  Output parameters
%
%   o  y : Real or complex valued matrix [rx,cx]
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