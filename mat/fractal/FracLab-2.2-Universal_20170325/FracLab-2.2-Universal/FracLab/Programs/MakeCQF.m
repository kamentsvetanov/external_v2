function [CQF1, CQF2] = MakeCQF(number)
% Returns a couple of Conjugate Quadrature Filters 
% The valid parameter is : 1 (for the moment)
%
% The format of the resulting CQF's is
% [NegInd, PosInd, QMF(NegInd), CQF(NegInd+1), ..., CQF(0), ..., CQF(PosInd)]
% Where NegInd is of course the number of negative indexes in the CQF 
% And PosInd the number of positive indexes in the CQF
%
% See also : MakeQMF, FWT, IWT


% Author Bertrand Guiheneuf, 1996

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
	

	if (number==1),
		CQF1=[4 4 .01767766952966368811 -.04419417382415922027 -.07071067811865475244 .39774756441743298247 .81317279836452965306 .39774756441743298247 -.07071067811865475244 -.04419417382415922027 .01767766952966368811]; 
		CQF2=[7 7 -.00071633413577230232 -.00179083534013786258 .00542714167520842959 .02252202991205450068 -.05617759403373648160 -.07397060550067185209 .40502017708757411652 .81358560108650353931 .40502017708757411652 -.07397060550067185209 -.05617759403373648160 .02252202991205450068 .00542714167520842959 -.00179083534013786258 -.00071633413577230232];
	else 
		disp('No biorthogonal wavelet associated to this number'); 
		CQF1=[0 0 0]; 
		CQF2=[0 0 0];
	end,

% END OF MakeCQF
