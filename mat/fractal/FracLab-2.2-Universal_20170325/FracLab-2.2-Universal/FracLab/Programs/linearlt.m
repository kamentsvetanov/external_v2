%   linear time legendre transform
%
%   This C_LAB routine the Legendre transform of a function using the lin-
%   ear time Legendre transform algorithm.
%
%   1.  Usage
%
%   [s,u_star_s]=linearlt(x,u_x)
%
%   1.1.  Input parameters
%
%   o  x : real vector [1,N] or [N,1]
%      Contains the abscissa.
%
%   o  y : real vector [1,N] or [N,1]
%      Contains the function to be transformed.
%
%   1.2.  Output parameters
%
%   o  s : real vector [1,M]
%      Contains the abscissa of the regularized function.
%
%   o  u_star_s : real vector [1,M]
%      Contains the Legendre conjugate function.
%
%   2.  Description
%
%   2.1.  Parameters
%
%   The abscissa x and the function u_x  to be transformed must be of the
%   same size [1,N] or [N,1].
%
%   The abscissa s and the Legendre conjugate function u_star_s are of the
%   same size [1,M] with M<=N.
%
%   2.2.  Algorithm details
%
%   The linear time Legendre transform algorithm is based on  the use of a
%   concave regularization before slopes' computation.
%
%   3.  Examples
%
%   3.1.  Matlab
%
%   ______________________________________________________________________
%   x=linspace(-5.,5.,1024);
%   u_x=-1+log(6+x);
%   plot(x,u_x);
%   % looks like a Reyni exponents function, isn't it ?
%   [s,u_star_s]=linearlt(x,u_x);
%   plot(s,u_star_s);
%   ______________________________________________________________________
%
%   3.2.  Scilab
%
%   ______________________________________________________________________
%   //
%   ______________________________________________________________________
%
%   4.  References
%
%   None.
%
%   5.  See Also
%
%   bbch (C_LAB routine).

% Author Christophe Canus, March 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------