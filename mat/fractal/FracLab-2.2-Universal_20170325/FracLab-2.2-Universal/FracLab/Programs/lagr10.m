function lag10=lagr10(mu,m2,s,nn,n,r,dl,ot,o,a)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

lag10=dl-ot;
for j=1:nn
      lag10=lag10+o(j)*log2(1+m2(s,j)*sqrt(1-mu/(a(j)*r(j))));
   end;   