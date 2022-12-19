function epsilon(s,e);
% function MFAG_epsilon(s,e)
%
% Computes a vector of Continuous Large Deviation spectrum 
% with varying precision epsilon (e) 
% and fixed scale eta (related to the scale factor (s: eta=s*eta_n)
%
% inputs : 	mu: input 1d pre-multifractal measure
%		(normalized strictly positive vector)
%		s: scale factor 
%		(strictly positive vector)
%		e: set the precision epsilon of the pdf 
%		(strictly positive scalar)
% outputs : 

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

m=bm1d(10,.4);
[ta,tf]=bm1ds(200,.4);
color=['r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c'] ;
figure(3);
clf;
grid on;
hold on;
plot(ta,tf);
figure(4);
clf;
grid on;
hold on;
[height,n_e]=size(e);
[height,n_s]=size(s);
norm_diff=zeros(n_e);
for i=1:n_e
	[a,f]=mcfge(m,200,2,s,e(i));
	diff=f-tf;
	figure(5)
	plot(a,f,color(i));
	tf=f;
	norm_diff(i)=norm(diff,1);
end
figure(6);
plot(norm_diff,'-');

