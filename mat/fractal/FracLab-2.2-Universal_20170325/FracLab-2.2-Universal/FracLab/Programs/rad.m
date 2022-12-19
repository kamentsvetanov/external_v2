function [vectech,vectlog]=rad(c,point,ra,prof)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

vectech=[];
vectlog=[];
k0=floor((1+point)/2);
[n,n1]=size(c);
start=n;
while start>0
   x1=max(1,k0-ra);
   x2=min(2^(start-1),k0+ra);
   vectmax=[];
   lieumax=[];
   for k=1:min(start,prof+1);
      j=start-k+1;
      [a,b]=max(abs(c(j,x1:x2)));
      vectmax=[vectmax a];
      lieumax=[lieumax b+x1-1];
      x1=ceil(x1/2);
      x2=ceil(x2/2);
   end;
   [a,b]=max(vectmax);
  if length(vectech)>=1 
    if start-b+1~=vectech(length(vectech));
       vectech=[vectech start-b+1];
       vectlog=[vectlog log2(abs(c(start-b+1,lieumax(b))))];
    end;
  else 
    vectech=[vectech start-b+1];
    vectlog=[vectlog log2(abs(c(start-b+1,lieumax(b))))];
  end;
     
   if b==1 & k0==lieumax(b);
      start=start-1;
      k0=ceil(k0/2);
   else
      start=start-b+1;
      k0=lieumax(b);
   end;
end;  
vectech=vectech(end:-1:1);
vectlog=vectlog(end:-1:1);