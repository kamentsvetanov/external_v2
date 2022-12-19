function [a,f]=MFAG_epsilon_eta(mu_n,N,s,e,norm_type);
% function [a,f]=MFAG_epsilon_eta(mu_n,N,s,e,norm_type)
%
% Computes a matrix of the norm of the difference 
% of computed Continuous Large Deviation spectrum 
% of a 1d pre-multifractal measure
% with varying scale: eta(i) (related to the scale factor (s: eta=s*eta_n)
% and varying precision epsilon: e(j) (e)
%
% inputs : 	mu_n: input 1d pre-multifractal measure
%		(normalized strictly positive vector)
%		N: # of hoelder exponents
%		(strictly positive integer scalar)
%		s: scale factor 
%		(strictly positive vector)
%		e: set the precision epsilon of the pdf 
%		(strictly positive scalar)
%		norm_type: type of the Lp norm
%		(1,2,inf,-inf,P)
%
% outputs :     uses matlab facilities (image and surf)
%		to plot the Lp norm of the difference:
%		lp_norm=Lp(fg_eta(i)^epsilon(j)-fg_eta(i-1)^epsilon(k))
%		with 1<=i<=n;1<=j,k<=m
%
% lp_norm matrix is [n-1,m*m]
% where [height,n]=size(s) and [height,m]=size(e)

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% set nu_n, eta_n, m, n, lp_norm, f1, f2, f1
[height,width]=size(mu_n);
nu_n=max(height,width);
eta_n=1./nu_n;
[height,m]=size(e);
[height,n]=size(s);
lp_norm=zeros(n-1,m*m);
f1=zeros(m,N);
f2=zeros(m,N);
f=zeros(n,N);
% compute lp_norm
for j=1:m
  [a,f1(j,:)]=mcfge(mu_n,N,2,s(1),e(j));
end
for i=2:n
  for j=1:m
    [a,f2(j,:)]=mcfge(mu_n,N,2,s(i),e(j));
    for k=1:m
      diff=abs(f2(j,:)-f1(k,:));
      lp_norm(i-1,m*(j-1)+k)=norm(diff,norm_type);
    end
  end
  f1=f2;	
end

% find index j of min of lp_norm
start_j=ceil(find(lp_norm(1,:)==min(lp_norm(1,:))));
block_j=m*(start_j/m-1)+1;
first_j=start_j-block_j;
extract_lp_norm=lp_norm(:,block_j:block_j+m-1);
for i=1:n-1
  for j=1:m
    other_j(i)=find(extract_lp_norm(i,:)==min(extract_lp_norm(i,:)));
  end
end
j=[first_j other_j];
for i=1:n
  [a,f(i,:)]=mcfge(mu_n,N,2,s(i),e(j(i)));
end
  
% plot spectra
eval('gui_fl_tmp_plot');
plot(a,f);
title('Multifractal Spectra');
xlabel('Hoelder exponents: \alpha');
ylabel('spectra: f_{g,\eta}^{c,\epsilon}(\alpha)');

% plot lp_norm with image
eval('gui_fl_tmp_plot');
eta_i=eta_n.*s(2:n);
epsilon=e;
image(epsilon,eta_i,lp_norm);
title('L^1(f_{g,\eta_i}^{c,\epsilon_j}-f_{g,\eta_{i-1}}^{c,\epsilon_k})');
xlabel('precision: \epsilon_j');
ylabel('scales: \eta_i');

% plot lp_norm with surf
eval('gui_fl_tmp_plot');
surf(flipud(lp_norm));
title('L^1(f_{g,\eta_i}^{c,\epsilon_j}-f_{g,\eta_{i-1}}^{c,\epsilon_k})');
xlabel('precision: \epsilon_j');
ylabel('scales: \eta_i');
view(-20,30);

% return results
return;


