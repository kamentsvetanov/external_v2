function line=lineC(n,h,sigma,tmax,m)
% ------------------------------------------------------------------------
%
% Input   :
%                       n : length of the discretized sample path 
%                       h : Hurst parameter, 0<h<1.
%                       m : power of two larger than 2*(n-1)
%
%
% Output  :
%
%           First line of the circulant matrix C built with covariances
%           of the fGn. 
%
%
% Example :  line= lineC( 1000 , 0.3, 2048 )
%
% References : 
%
%       1 - Wood and Chan (1994)
%       2 - Phd Thesis Coeurjolly (2000), Appendix A p.132 
%
% ------------------------------------------------------------------------

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

k=tmax*(0:m-1);
h2=2*h;
v=0.5*sigma^2* ( abs(k-tmax).^h2 - 2* k.^h2 + (k+tmax).^h2 );
ind=[0:(m/2-1) (m/2):-1:1];
line=v(ind+1)/n^h2;
