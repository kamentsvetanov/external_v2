function [a,f]=MFAG_eta(mu_n,N,s,e,norm_type);
% function MFAG_eta(mu_n,N,s,e,norm_type)
%
% Computes a vector of Continuous Large Deviation spectrum 
% with fixed precision epsilon (e) 
% and varying scale eta (related to the scale factor (s: eta=s*eta_n)
%
% inputs : 	mu_n: input 1d pre-multifractal measure
%		(normalized strictly positive vector)
%		s: scale factor 
%		(strictly positive vector)
%		e: set the precision epsilon of the pdf 
%		(strictly positive scalar)
%		norm_type: type of the Lp norm
%		(1,2,inf,-inf,P)
% outputs : 

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% set color, nu_n, eta_n, eta_i, n, m, f
color=['r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c';'r';'g';'b';'y';'m';'c'] ;
[height,width]=size(mu_n);
nu_n=max([height,width]);
eta_n=1./nu_n;
eta_i=eta_n.*s;
[height,n]=size(s);
[height m]=size(e);
f=zeros(n,N);

% compute first spectrum 
i=1;
[a,f(i,:),p,e_star]=mcfge(mu_n,N,2,s(i),e);

% plot first spectrum
figure;
grid on;
hold on;
plot(a,f(i,:),color(i));
if e~=0.
	title(['Continuous Large Deviation Spectrum with fixed precision: \epsilon=',num2str(e),' and varying scale: \eta_i=',num2str(eta_i(i))]);
else
	title(['Continuous Large Deviation Spectrum with varying optimal precision: \epsilon=',num2str(e_star),' and varying scale: \eta_i=',num2str(eta_i(i))]);
end
xlabel('Hoelder exponents: \alpha');
ylabel('f_{g,\eta_i}^{c,\epsilon}(\alpha)');

% compute other spectra 
for i=2:n
	[a,f(i,:),p,e_star]=mcfge(mu_n,N,2,s(i),e);
	plot(a,f(i,:),color(i)); 
	title(['Continuous Large Deviation Spectrum with varying scale: \eta_i=',num2str(eta_i(i))]);
	lp_norm(i)=norm(f(i,:)-f(i-1,:),norm_type);
end

% last title
if e~=0
	title(['Continuous Large Deviation Spectrum with fixed precision: \epsilon=',num2str(e)]);
else
	title(['Continuous Large Deviation Spectrum with optimal precision: \epsilon=',num2str(e_star)]');
end;

% plot lp_norm
figure;
plot(eta_i(2:n),lp_norm(2:n),'-');
title(['L^p(f_{g,\eta_i}^{c,\epsilon}-f_{g,\eta_{i-1}}^{c,\epsilon}) with fixed precision: \epsilon=',num2str(e_star),' and varying scale: ',num2str(eta_i(1)),'\leq \eta_i \leq', num2str(eta_i(n))]);
xlabel('scales: \eta_i');
ylabel('L^p(f_{g,\eta_i}^{c,\epsilon}-f_{g,\eta_{i-1}}^{c,\epsilon})'); 

% plot spectra
figure;
mesh(a,eta_i,f);
title(['Continuous Large Deviation Spectrum with fixed precision \epsilon=',num2str(e_star)]);
xlabel('Hoelder exponents: \alpha');
ylabel('scales: \eta_i');
zlabel('spectrum: f_{g,\eta_i}^{c,\epsilon}(\alpha)');
view(20,30);

% return results
return;
