function pointer=fl_waiton()
% displays a watch pointer

% Author B. Guiheneuf, 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	pointer{1}=gcf;
	pointer{2} = get(gcf,'Pointer');
	set(gcf,'Pointer','watch');
	pause(0.1);
