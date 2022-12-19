function H = show_bars(handles, data, axes_tag, options)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	if(min(size(findobj('Tag',axes_tag))) == 0)
		eval(['axes(handles.' axes_tag ')']);
		H = eval(['handles.' axes_tag]);
	else
		axes(findobj('Tag',axes_tag))
		H = findobj('Tag',axes_tag);
	end
	
	
	if (size(data,1)==1)
		data = [data;data];
	end
	
	bar(data,'grouped');

	
	eval(options);