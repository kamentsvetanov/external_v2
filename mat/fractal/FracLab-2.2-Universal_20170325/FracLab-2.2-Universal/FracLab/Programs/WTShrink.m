function [wtout] = WTShrink(wtin, trshld, mode)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	if (nargin < 3), mode='s'; end;
	if (nargin < 1), error('WTShrink : You must give at least a wavelet transform'); end;
	
	wsz = WTOrigSize(wtin);
	wnbsc = WTNbScales(wtin);

	if (nargin < 2), trshld=1; end;


	tsz = size(trshld);
	if (max(tsz)>1), mode='m'; end;

	if ( ~strcmp(mode,'s') &  ~strcmp(mode,'m') ), error('WTShrink : mode must be s (single) or m (multi)'); end;

	if ( (min(tsz) > 1 ) | ( (wnbsc+1) < max(tsz) ) ),
		error('WTShrink : threshold vector size is not correct.');
	end;

	[wti wtl] = WTStruct(wtin);
	wtout = wtin;
	if (strcmp(mode,'m')),
		for sc=1:max(size(trshld)),
			wtout( wti(sc):wti(sc)+(wtl(sc)-1) ) = wtshrink(wtin(wti(sc):(wti(sc)+wtl(sc)-1)), trshld(sc));
		end;

	
	else,
		for sc=1:(wnbsc+1),
			t=sqrt(2*log(wtl(sc))) * trshld;
			wtout( wti(sc):(wti(sc)+wtl(sc)-1) ) = wtshrink(wtin(wti(sc):(wti(sc)+wtl(sc)-1)), t);
		end;
		
	end;


function [out] = wtshrink(in,s)

	tmp = abs(in)-s;
	out = tmp .* sign(in) .* (tmp>0);
	
