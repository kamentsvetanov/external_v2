function [a,f]=sum2s(a1,f1,a2,f2,N)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

a_min=min(min(a1),min(a2));
a_max=min(max(a1),max(a2));
a=linspace(a_min,a_max,N);
if min(a1)<min(a2)
  msf=interp1(a1,f1,a);
  lsf=interp1(a2,f2,a);
else
  lsf=interp1(a1,f1,a);
  msf=interp1(a2,f2,a);
end
i=1;
while a(i)<max(min(a1),min(a2))
  lsf(i)=0;
  i=i+1;
end

for i=1:N
  f(i)=max(msf(i),lsf(i));
end
i=1;
while msf(i)>=lsf(i)
  i=i+1;
end
index=i;
for i=index:N
  f(i)=lsf(i);
end
return;
