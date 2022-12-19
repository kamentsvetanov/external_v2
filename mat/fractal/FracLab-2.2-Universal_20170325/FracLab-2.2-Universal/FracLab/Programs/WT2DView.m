function WT2DView(wt,c)
% No help found

% Author Bertrand Guiheneuf, 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if (nargin<2), c='w'; end;

NbScales = WT2DNbScales(wt);
[wti, wtl] = WT2DStruct(wt);

TotalWidth = 0;
TotalHeight = 0;


for Sc=1:NbScales;
  TotalHeight = TotalHeight + wtl(Sc,1); 
  TotalWidth = TotalWidth +wtl(Sc,2); 
end;
TotalHeight = TotalHeight + wtl(NbScales,1);
TotalWidth = TotalWidth +wtl(NbScales,2);
	      
V=zeros(TotalHeight,TotalWidth);

m=TotalHeight;
n=TotalWidth;

for Sc=1:NbScales;
  
  h=wtl(Sc,1);
  w=wtl(Sc,2);
  sz=h*w;
  
  m=m-h;
  n=n-w;
  line(n*ones(1,2*m),1:2*m,'LineWidth',2,'Color',c);
  line(1:2*n,m*ones(1,2*n),'LineWidth',2,'Color',c);
  
  
  
end;
