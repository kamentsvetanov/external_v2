function fl_setOption(option_name,option_value)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%switch(option_name)
%	case('ButtonColor','FrameColor','Fill_inColor','FontColor','LogoFileName','Logo','LogoSize','BackGroundColor','LogoColorMap','SaveLog','SavePosition','ShowSplashScreen','ForceBackGroundColor','FracLabRoot','FracLabPosition')
		try
			flroot = fl_getOption('FracLabRoot');
			fltoolmat = fullfile(flroot,'Gui','fltool.mat');
			eval([ option_name '= option_value;'] );
			p=version;
			if str2num(p(1))>=7
				save(fltoolmat,option_name,'-v6','-append');
			else
				save(fltoolmat,option_name,'-append');
			end
		end
%end