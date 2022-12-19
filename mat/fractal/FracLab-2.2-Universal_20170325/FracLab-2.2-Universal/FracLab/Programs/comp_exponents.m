function [ap,al]=comp_exponents(frontier);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N=length(frontier);

i0=floor(N*1.25/2);
if abs(frontier(i0)-frontier(i0+1))<0.06
al=0.5*(frontier(i0)+frontier(i0+1));
end;

if abs(frontier(i0)-frontier(i0+1))>0.06
al=frontier(i0);
end;


index=1;
sprime=-1.25+2*index/N;

while(sprime<-frontier(index))&(index<N+1)
index=index+1;
sprime=-1.25+2*index/N;
end;

index=min(index,N);
index=max(index,1);

if abs(frontier(index)-frontier(index-1))<0.06
ap=0.5*(frontier(index)+frontier(index-1));
end;

if abs(frontier(index)-frontier(index-1))>0.06
ap=frontier(index-1);
end;