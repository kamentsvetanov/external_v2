function res=convex(v);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N=length(v);

%On va appliquer deux fois la meme procedure pour obtenir qqc de
%vraiment convexe.

%%%%%%%%%%%%%% et de un
for i=1:(N-1)
for j=(i+2):N
for k=1:(j-i-1)

v(i+k)=max([v(i+k) (v(j)*k+v(i)*(j-i-k))/(j-i) ]);

end;
end;
end;

for i=1:(N-1)
if v(N-i+1)>v(N-i) v(N-i)=v(N-i+1);
end;
end;

%%%%%%%%%%% et de deux

for i=1:(N-1)
for j=(i+2):N
for k=1:(j-i-1)

v(i+k)=max([v(i+k) (v(j)*k+v(i)*(j-i-k))/(j-i) ]);

end;
end;
end;

for i=1:(N-1)
if v(N-i+1)>v(N-i) v(N-i)=v(N-i+1);
end;
end;

res=v;


