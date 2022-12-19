function row = ShapeAsRow(sig)
% ShapeAsRow -- Make signal a row vector
%  Usage
%    row = ShapeAsRow(sig)
%  Inputs
%    sig     a row or column vector
%  Outputs
%    row     a row vector
%
%  See Also
%    ShapeLike

% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

row = sig(:)';    
    