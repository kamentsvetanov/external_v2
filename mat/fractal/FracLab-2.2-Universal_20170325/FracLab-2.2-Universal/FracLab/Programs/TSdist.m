function d = TSdist(a1,b1,a2,b2)
% Time-Scale (LOBACHEVSKY) Distance in the affine L^2(R+) half plane.
%
% Input:      - a1,b1,a2,b2 the scale and time coordinates of
%               the two points
%
% Output:     - distance between [a1,b1] and [a2,b2]
%
% Example:
%
% See also:

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

d = acosh(1+((a2-a1).^2+(b2-b1).^2)./(2*a1.*a2)) ;
