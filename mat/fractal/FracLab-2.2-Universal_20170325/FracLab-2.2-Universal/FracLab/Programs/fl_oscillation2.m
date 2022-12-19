function v = fl_oscillation2(f,Nepsilonmax,a,b)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

s=size(f);
N=s(1);
pas=abs(a-b)/N;
%Nepsilon=epsilon/pas;
v=zeros(N,Nepsilonmax);
vsup=zeros(N,Nepsilonmax);
vinf=zeros(N,Nepsilonmax);


h_waitbar = fl_waitbar('init');
for(i=1:N)
    fl_waitbar('view',h_waitbar,i,N);
 %cas j=1
 
    borneinf=max(1,i-1);
    bornesup=min(N,i+1);
    
    vsup(i,1)=max(f(borneinf),f(bornesup));
    vinf(i,1)=min(f(borneinf),f(bornesup));
    v(i,1)=vsup(i,1)-vinf(i,1);
     
	for(j=2:Nepsilonmax)
	j;
	
	    borneinf=max(1,i-j);
	    bornesup=min(N,i+j);
	    
	    vsup(i,j)=max([f(borneinf),f(bornesup),vsup(i,j-1)]);
	    vinf(i,j)=min([f(borneinf),f(bornesup),vinf(i,j-1)]);
	    v(i,j)=vsup(i,j)-vinf(i,j);
	end

end

fl_waitbar('close',h_waitbar);

v;