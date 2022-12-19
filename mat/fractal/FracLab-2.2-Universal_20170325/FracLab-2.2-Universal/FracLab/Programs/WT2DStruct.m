function [ScIndex, ScLength] = WT2DStruct(WT)
%   Retrieve the Structure of a 2D DWT
%
%   This routine retrieve the structure informations contained in a 2D
%   Wavelet Transform.
%
%   1.  Usage
%
%   [ScIndex, ScLength]=WT2DStruct(wt)
%
%   1.1.  Input parameters
%
%   o  wt : real unidimensional matrix [m,n]
%      Contains the wavelet transform (obtained with FWT2D).
%
%   1.2.  Output parameters
%
%   o  index : real matrix [NbIter,4]
%      Contains the indexes (in wt) of the projection of the signal on the
%      multiresolution subspaces
%
%   o  length : real matrix [NbIter,2]
%      Contains the dimensions of each projection
%
%   2.  See Also
%
%   FWT2D, IWT2D, WT2Dext, WT2DVisu

% Author Bertrand Guiheneuf, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	SignalHeight = WT(1);
	SignalWidth = WT(2);
	NbScales = WT(3);
	QMFlength = WT(4) + WT(5) +1;
	
	ScIndex=zeros(NbScales,4);
	ScLength=zeros(NbScales,2);

	Index=6 + QMFlength;
	
	for Sc=1:NbScales; 
		SignalHeight = floor( (SignalHeight +1)/2 );
		SignalWidth = floor( (SignalWidth +1)/2 );
		SignalLength = SignalHeight*SignalWidth;

		ScLength(Sc,1)=SignalHeight;
		ScLength(Sc,2)=SignalWidth;
		
		for j=1:3;
			ScIndex(Sc,j) = Index ;
			Index = Index + SignalLength;
		end;
		ScIndex(Sc,4) = 0;
		
	end;
	ScIndex(NbScales,4) = Index;
