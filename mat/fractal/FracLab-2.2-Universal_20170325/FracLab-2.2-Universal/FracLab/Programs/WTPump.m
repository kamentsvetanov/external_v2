function [wtout] = WTPump(wtin, trshld, mod)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
	
	if (nargin < 3), mod='s'; end;
	if (nargin < 1), error('WTPump : You must give at least a wavelet transform'); end;
	
	wsz = WTOrigSize(wtin);
	wnbsc = WTNbScales(wtin);

	if (nargin < 2), trshld=0.5; end;


	tsz = size(trshld);
	if (max(tsz)>1), mod='m'; end;

	if ( (mod~='s') &  (mod~='m') ), error('WTPump : mode must be s (single) or m (multi)'); end;

	if ( (min(tsz) > 1 ) | ( (wnbsc+1) < max(tsz) ) ),
		error('WTPump : threshold vector size is not correct.');
	end;

	[wti wtl] = WTStruct(wtin);
	wtout = wtin;
	L2in=norm( wtin( wti(1):(wti(wnbsc+1)+(wtl(wnbsc+1)-1) ) ) );
	
	if ((mod=='m')),
		for sc=1:max(size(trshld)),
			wtout( wti(sc):(wti(sc)+wtl(sc)-1) ) = thepump(wtin(wti(sc):(wti(sc)+wtl(sc)-1)), 2.^(trshld(sc)*sc));
		end;

	
	else,
		for sc=1:(wnbsc),
			wtout( wti(sc):(wti(sc)+wtl(sc)-1) ) = thepump(wtin(wti(sc):(wti(sc)+wtl(sc)-1)), 2.^(trshld*sc));
		end;
		
	end;

	L2out=norm( wtout( wti(1):(wti(wnbsc+1)+(wtl(wnbsc+1)-1) ) ) );
	r=L2in/L2out;
	wtout( wti(1):(wti(wnbsc+1)+(wtl(wnbsc+1)-1)) ) = r*wtout( wti(1):(wti(wnbsc+1)+(wtl(wnbsc+1)-1))  );
	


function [out] = thepump(in,s)

	out =  in* s;
	
