function Rank=ks(X)
%+++ Employ the K-S algorithm for selecting the representative samples;
%+++ Hongdong Li, May 10,2008.

tic;
[Mx,Nx]=size(X);
Rank=zeros(1,Mx);
out=1:Mx;
D=distli(X);
[i j]=find(D==max(max(D)));
Rank(1)=i(1);Rank(2)=j(1);
out([i(1) j(1)])=[];
%+++ Iteration of  K-S algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iter=3;
while iter<=Mx
   in=Rank(find(Rank>0));
   Dsub=D(in,out);   
   [minD,indexmin]=min(Dsub);
   [maxD,indexmax]=max(minD);
   Vadd=out(indexmax);
   Rank(iter)=Vadd;
   out(find(out==Vadd))=[];
   iter=iter+1;
end
toc;
%+++ Iteration ended %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%% END OF SUB
function D=distli(X)
X=X';
[D,N] = size(X);
X2 = sum(X.^2,1);
D = repmat(X2,N,1)+repmat(X2',1,N)-2*X'*X;