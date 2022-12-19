function index=MFAG_min_lp(lp_norm)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

color = ['r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c'] ;
[n,m]=size(lp_norm);
index=zeros(n:2);
for i=1:n
	for j=1:m
		index(i,1)=i;
		index(i,2)=find(lp_norm(i,:)==min(lp_norm(i,:)))
	end
end
load /a/user/canus/toronto/flegoland/nfl2;
I_n=nfl2(:,1);
mu_n=nfl2(:,2);
s=[1.25:.25:5];
e=[.05:.01:.15];
f=zeros(n,200);
epsilon=zeros(n,1);
figure(3);
clf;
hold on;
for i=1:n
	epsilon(i,1)=e(index(i,2));
	[a,f(i,:)]=mcfge(mu_n',200,2,s(i),epsilon(i,1));
	figure(3);
	plot(a,f(i,:),color(i));
end
