function pointer=fl_waitoff(pointer)
% redisplays an initial pointer

% Author B. Guiheneuf, 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	set(pointer{1},'Pointer',pointer{2});
	pause(0);
