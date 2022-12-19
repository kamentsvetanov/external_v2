function [V]=WT2DVisu(wt)
%   Visualise a 2D Multiresolution
%
%   This routine constructs a matrix that shows all the wavelet coeffi-
%   cients of a 2D matrix.
%
%   1.  Usage
%
%   [V]=WT2DVisu(wt)
%
%   1.1.  Input parameter
%
%   o  wt : real unidimensional matrix [m,n]
%      Contains the wavelet transform (obtained with FWT2D).
%
%   1.2.  Output parameter
%
%   o  V : real matrix [m,n]
%      Contains a matrix to be visualized directly
%
%   2.  See Also
%
%   FWT2D, IWT2D, WT2Dext,

% Author Bertrand Guiheneuf, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

NbScales = WT2DNbScales(wt);
[wti, wtl] = WT2DStruct(wt);

TotalWidth = 0;
TotalHeight = 0;

bigger = max(max(abs(wt(wti(1,1):(wti(NbScales,4)-1)))));

for Sc=1:NbScales;
  TotalHeight = TotalHeight + wtl(Sc,1); 
  TotalWidth = TotalWidth +wtl(Sc,2); 
end;
TotalHeight = TotalHeight + wtl(NbScales,1);
TotalWidth = TotalWidth +wtl(NbScales,2);
	      
V=zeros(TotalHeight,TotalWidth);

m=TotalHeight;
n=TotalWidth;

%wti,wtl,NbScales,
long=length(wt);
%(wti(1,NbScales-1):wti(1,NbScales)-1);%c(1)={[wt(wti(n,1):wti(n,n-nn))]};
%wti(1,1):wti(1,2)
[x,y]=size(wti);%wti,wtl,floor((sqrt(long-wti(1)+1))/2^(NbScales)),-wti(x,y)+length(wt)
[xl,yl]=size(wtl);
%V(1:floor((sqrt(long-wti(1)+1))/2^(NbScales)) , 1:floor((sqrt(long-wti(1)+1))/2^(NbScales))) = reshape(abs(wt(wti(x,y):length(wt))), floor((sqrt(long-wti(1)+1))/2^(NbScales)),floor((sqrt(long-wti(1)+1))/2^(NbScales)));
V(1:wtl(xl,1) , 1:wtl(xl,2)) = reshape(abs(wt(wti(x,y):length(wt))),wtl(xl,1),wtl(xl,2) );
for Sc=1:NbScales;
  
  h=wtl(Sc,1);
  w=wtl(Sc,2);
  sz=h*w;
  
  m=m-h;
  n=n-w;
  
  
  V(m:(m+h-1) , 1:(1+w-1)) = reshape(abs(wt(wti(Sc,1) : ...
      (wti(Sc,1)+sz-1) )), h,w);
  V(m:(m+h-1) , n:(n+w-1)) = reshape(abs(wt(wti(Sc,2) : ...
      (wti(Sc,2)+sz-1) )), h,w);
  V(1:(1+h-1) , n:(n+w-1)) = reshape(abs(wt(wti(Sc,3) : ...
      (wti(Sc,3)+sz-1) )), h,w);
  
  
  %index=0;
  %for i=0:(wtl(Sc,1)-1);
  %for j=0:(wtl(Sc,2)-1);
  
  %V(n+i,1+j) = wt(wti(Sc,1)+index);
  %V(n+i,n+j) = wt(wti(Sc,2)+index);
  %V(1+i,n+j) = wt(wti(Sc,3)+index);
  %index=index+1;
  %end;
  %end;
  
end;

%index=0;
%Sc=NbScales;
%for i=0:(wtl(Sc,1)-1);
%for j=0:(wtl(Sc,2)-1);

%V(1+i,1+j) = wt(wti(Sc,4)+index);
%index=index+1;
%end;
%end;
%V

