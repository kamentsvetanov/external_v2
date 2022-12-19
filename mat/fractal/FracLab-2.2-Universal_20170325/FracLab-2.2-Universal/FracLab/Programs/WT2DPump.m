function [wtout] = WT2DPump(wtin, trshld, mod)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if (nargin < 3), mod='s'; end;
if (nargin < 1), error('WT2DPump : You must give at least a wavelet transform'); end;

wsz = WT2DSize(wtin);
wnbsc = WT2DNbScales(wtin);

if (nargin < 2), trshld=1; end;

tsz = size(trshld);
if (max(max(tsz)>1)), mod='m'; end;

if ( (mod~='s') &  (mod~='m') ), error('WT2DPump : mode must be s (single) or m (multi)'); end;

if ( (min(min(tsz)) > 1 ) | ( (wnbsc+1) < max(max(tsz)) ) ),
  error('WT2DPump : threshold vector size is not correct.');
end;

[wti wtl] = WT2DStruct(wtin);
wtout = wtin;

L2in=norm( wtin( wti(1,1):(wti(wnbsc,4)+(wtl(wnbsc,1)*wtl(wnbsc,2)-1) ) ) );

if ((mod=='m')),
  for sc=1:max(size(trshld)),
    for j=1:3,
      wtout( wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1) ) = the2dpump(wtin(wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1)), 2.^(trshld(sc)*sc));
    end;
  end;
  
  
else,
  for sc=1:(wnbsc),
    for j=1:3,
      wtout( wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1) ) ...
	 = the2dpump(wtin( wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1) ), ...
	  2.^(trshld*sc));
      %wtout( wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1) ) ...
	  %= 3* wtin( wti(sc,j):(wti(sc,j)+wtl(sc,1)*wtl(sc,2)-1) );
	 
	 
	
      end;
    end;
    
  end;
  
  %L2out=norm( wtout( wti(1,1):(wti(wnbsc,4)+(wtl(wnbsc,1)*wtl(wnbsc,2)-1) ) ) );
  %r=L2in/L2out;
  % wtout( wti(1,1):(wti(wnbsc,4)+(wtl(wnbsc,1)*wtl(wnbsc,2)-1) )  ) = r*wtout( wti(1,1):(wti(wnbsc,4)+(wtl(wnbsc,1)*wtl(wnbsc,2)-1) )  );
  
  
  
function [out] = the2dpump(in,s)

out =  in.* s;
	

