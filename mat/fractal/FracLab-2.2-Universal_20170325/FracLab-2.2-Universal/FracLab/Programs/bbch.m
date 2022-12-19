%   beneath-beyond concave hull
%
%   This C_LAB routine determines the concave hull of a function graph
%   using the beneath-beyond algorithm.
%
%   1.  Usage
%
%   [rx,ru_x]=bbch(x,u_x)
%
%   1.1.  Input parameters
%
%   o  x : real vector [1,N] or [N,1]
%      Contains the abscissa.
%
%   o  u_x : real vector [1,N] or [N,1]
%      Contains the function to be regularized.
%
%   1.2.  Output parameters
%
%   o  rx : real vector [1,M]
%      Contains the abscissa of the regularized function.
%
%   o  ru_x : real vector [1,M]
%      Contains the regularized function.
%
%   2.  Description
%
%   2.1.  Parameters
%
%   The abscissa x and the function u_x  to be regularized must be of the
%   same size [1,N] or [N,1].
%
%   The abscissa rx and the concave regularized function ru_x are of the
%   same size [1,M] with M<=N.
%
%   2.2.  Algorithm details
%
%   Standard beneath-beyond algorithm.
%
%   3.  Examples
%
%   3.1.  Matlab
%
%   ______________________________________________________________________
%   h=.3;beta=3;
%   N=1000;
%   % chirp singularity (h,beta)
%   x=linspace(0.,1.,N);
%   u_x=abs(x).^h.*sin(abs(x).^(-beta));
%   plot(x,u_x);
%   hold on;
%   [rx,ru_x]=bbch(x,u_x);
%   plot(rx,ru_x,'rd');
%   plot(x,abs(x).^h,'k');
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
%   None
%
%   5.  See Also
%
%   linearlt (C_LAB routine).

% Author Christophe Canus, March 1998

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------