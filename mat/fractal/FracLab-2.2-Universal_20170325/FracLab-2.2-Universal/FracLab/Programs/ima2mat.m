function [mat]=ima2mat(ima)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

sz=size(ima);
mat=zeros(sz(1),sz(2));
dim=size(sz);
nbdim=dim(2);

if ( nbdim==3 )
  for i=1:sz(3),
    mat=mat+(double(ima(:,:,i)));
  end;
  mat=mat/sz(3);
else,
  mat=double(ima);
end;

mat=abs(mat);
m=max(max(mat));

if (m>0)
  mat=mat/m;
end;

