function [wtout] = WT2DShrink(wtin, trshld, mode)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	if (nargin < 3), mode='s'; end;
	if (nargin < 1), error('WT2DShrink : You must give at least a wavelet transform'); end;
	
	wsz = WT2DSize(wtin);
	wnbsc = WT2DNbScales(wtin);

	if (nargin < 2), trshld=1; end;


	tsz = size(trshld);
	if (max(tsz)>1), mode='m'; end;

	if ( ~strcmp(mode,'s') &  ~strcmp(mode,'m') ), error('WT2DShrink : mode must be s (single) or m (multi)'); end;

	if ( (min(tsz) > 1 ) | ( (wnbsc+1) < max(tsz) ) ),
		error('WT2DShrink : threshold vector size is not correct.');
	end;

	[wti wtl] = WT2DStruct(wtin);
	wtout = wtin;
	if (strcmp(mode,'m')),
		for sc=1:max(size(trshld)),
			for j=1:3,
			wtout( wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1) ) = wt2dshrink(wtin(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)), trshld(sc));
			end;
		end;

	
	else,
		for sc=1:(wnbsc),
			t=sqrt(2*log(max(wtl(sc,1),wtl(sc,2)))) * trshld;
			for j=1:3,
				wtout( wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1) ) = wt2dshrink(wtin(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)), t);
			end;
		end;
		
	end;


function [out] = wt2dshrink(in,s)

	tmp = abs(in)-s;
	out = tmp .* sign(in) .* (tmp>0);
	
