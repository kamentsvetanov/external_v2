function V=WT2Dext(wt,Sc,Num)
%   Extract a Projection from a 2D WT
%
%   This routine extracts a projection from the wavelet transform of a 2D
%   matrix.
%
%   1.  Usage
%
%   [V]=WT2Dext(wt, Scale, Num)
%
%   1.1.  Input parameter
%
%   o  wt : real unidimensional matrix [m,n]
%      Contains the wavelet transform (obtained with FWT2D).
%
%   o  w Scale : real scalar Contains the scale level of the projection to
%      extract.
%
%   o  w Num : real scalar Contains the number of the output to extract in
%      level Scale (between 1 and 4)
%
%   1.2.  Output parameter
%
%   o  V : real matrix [m,n]
%      Contains the  matrix to be visualized directly
%
%   2.  See Also
%
%   FWT2D, IWT2D, WT2DVisu,

% Author Bertrand Guiheneuf, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	[wti, wtl]=WT2DStruct(wt);
	V=zeros(wtl(Sc,1), wtl(Sc,2));
 	index=0;
	for i=0:(wtl(Sc,1)-1);
		for j=0:(wtl(Sc,2)-1);
			V(i+1,j+1)=wt(wti(Sc,Num)+index);
			index = index+1;
		end;
	end;
