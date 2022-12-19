function vec = ShapeLike(sig,proto)
% ShapeLike -- Make 1-d signal with given shape
%  Usage
%    vec = ShapeLike(sig,proto)
%  Inputs
%    sig      a row or column vector
%    proto    a prototype shape (row or column vector)
%  Outputs
%    vec      a vector with contents taken from sig
%             and same shape as proto
%
%  See Also
%    ShapeAsRow

% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	sp = size(proto);
	ss = size(sig);
	if( sp(1)>1 & sp(2)>1 )
	   disp('Weird proto argument to ShapeLike')
	elseif ss(1)>1 & ss(2) > 1,
	   disp('Weird sig argument to ShapeLike')
	else
	   if(sp(1) > 1),
		  if ss(1) > 1,
			 vec = sig;
		  else
			 vec = sig(:);
		  end
	   else
		  if ss(2) > 1,
			 vec = sig;
		  else
			 vec = sig(:)';
		  end
	   end
    end
