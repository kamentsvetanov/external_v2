function lag3=lagr3(mu,m2,s,nn,n,r,dl,ot,o)
% No help found

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

lag3=dl-ot;
for j=1:n-nn
      lag3=lag3+o(j)*log2(1+m2(s,j)*sqrt(1-2*mu/r(j)));
   end;   