function [Multires]=WTMultires(WT)
%   Construct a 1D Multiresolution Representation
%
%   This routine constructs a matrix that shows the projections of the
%   signal on each multiresolution subspace
%
%   1.  Usage
%
%   [V]=WTMultires(wt)
%
%   1.1.  Input parameter
%
%   o  wt : real unidimensional matrix
%      Contains the wavelet transform (obtained with FWT).
%
%   1.2.  Output parameter
%
%   o  V : real matrix [Nbiter,n]
%      Contains the projections on the Multiresolution. Each line is a
%      projection on a subspace different "low-pass" space Vj
%
%   2.  See Also
%
%   FWT, IWT, WTStruct,

% Author Bertrand Guiheneuf, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	NbSc = WTNbScales(WT);
	SignalSize = WTOrigSize(WT);
	Multires = zeros(NbSc, SignalSize);

	for Sc=1:NbSc,
		a=zeros(1,Sc-1);
		b=zeros(1,NbSc-Sc+2)+1;
		c = [a b];
		WT2 = WTMultScales(WT,c);
		Multires(Sc,:) = IWT(WT2);
	end,
   %%%%%%%%%%%%%%%%%%%%
   %[x,y]=size(Multires);
   %log2y=floor(log2(y));
   %y2=2^log2y;
   %Multires=Multires(:,1:y2);
   
