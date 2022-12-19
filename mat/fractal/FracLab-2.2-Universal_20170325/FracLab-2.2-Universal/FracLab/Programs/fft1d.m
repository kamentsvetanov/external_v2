%   1-D Fast Fourier Transform
%
%   Operates a column-wise direct or inverse FFT on a matrix
%
%   1.  Usage
%
%   ______________________________________________________________________
%   Y = fft1d(X,DirInv) ;
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  X : Real or complex valued matrix [rx,cx]
%
%   o  DirInv : +1 / -1 flag
%      -1  Direct Fast Fourier Transform
%      +1  Inverse Fast Fourier Transform
%
%   1.2.  Output parameters
%
%   o  Y : Real or complex valued matrix [rx,cx]
%      Each column of Y contains the FFT (resp IFFT) of the corresponding
%      column of X
%
%   2.  See also:
%
%   fft
%
%   3.  Examples

% Author Paulo Goncalves, July 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------