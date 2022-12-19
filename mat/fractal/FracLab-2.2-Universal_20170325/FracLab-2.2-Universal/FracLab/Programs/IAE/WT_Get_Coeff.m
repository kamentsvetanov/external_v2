function result = WT_Get_Coeff(data, scale)
% --- Return coefficiens from results of WT
% data	WT results
%	scale	the scale to extract
% returns: [horz[]; diag[]; vert[]]

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

erg=[];

scale = data.scales - scale +1;	

for j=1:3
	erg = [erg ; data.wt(data.wti(scale,j):(data.wti(scale,j)+data.wtl(scale,1)*data.wtl(scale,2)-1)) ];
end

result = double(erg);
