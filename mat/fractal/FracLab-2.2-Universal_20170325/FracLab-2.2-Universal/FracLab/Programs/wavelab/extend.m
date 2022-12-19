function y = extend(x, par1, par2)
% extend -- perform various kinds of symmetric extension

% Author Thomas P.Y. Yu, 1996
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if par1==1 & par2==1,
    y = [x x((length(x)-1):-1:2)];
elseif par1==1 & par2==2,
    y = [x x((length(x)-1):-1:1)];
elseif par1==2 & par2==1,
    y = [x x(length(x):-1:2)];
elseif par1==2 & par2==2,
    y = [x reverse(x)];
end
