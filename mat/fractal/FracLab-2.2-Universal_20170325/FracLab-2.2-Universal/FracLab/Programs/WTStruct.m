function [ScIndex, ScLength] = WTStruct(WT)
%   Retrieve a 1D Discrete Wavelet Structure.
%
%   This routine retrieves the structure informations contained in a 1D
%   Wavelet Transform.
%
%   1.  Usage
%
%   [ScIndex, ScLength]=WT2DStruct(wt)
%
%   1.1.  Input parameters
%
%   o  wt : real unidimensional matrix [1,n]
%      Contains the wavelet transform (obtained with FWT).
%
%   1.2.  Output parameters
%
%   o  index : real matrix [1,NbIter]
%      Contains the indexes (in wt) of the projection of the signal on the
%      multiresolution subspaces
%
%   o  length : real matrix [1,NbIter]
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

	SignalLength = WT(1);
	NbScales =WT(2);
	QMFlength = WT(3) + WT(4) +1 ;
	
	ScIndex=zeros(1,NbScales+1);
	ScLength=zeros(1,NbScales+1);

	ScIndex(1)=5 + QMFlength;
	Sc=1;
	for k=1:NbScales, 
		SignalLength = floor( (SignalLength +1)/2 );
		ScLength(Sc)=SignalLength;
		Sc = Sc + 1;
		ScIndex(Sc) = ScIndex(Sc-1) + SignalLength;	
	end;
	ScLength(Sc) = SignalLength;

% END OF WTStruct

