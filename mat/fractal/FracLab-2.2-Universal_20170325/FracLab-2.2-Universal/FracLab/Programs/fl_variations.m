function aire = fl_variations(f,Nepsilon,oscillation,a,b)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

s=size(f);
N=s(1);
pas=abs(a-b)/N;
%Nepsilon=epsilon/pas;

%osc=oscillation(f,epsilon,a,b);

aire=0;

for(i=1:N-1)
    daire=((oscillation(i+1,Nepsilon)+oscillation(i,Nepsilon))/2)*pas;
    aire=aire+daire;
end

aire;