function [option_value,varargout] = fl_getOption(option_name,varargin)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

lastwarningstate = warning('off');

switch(option_name)
case 'Layout'
	try
		load('fltool.mat','Layout');
		option_value = Layout;
	catch
		option_value = 1;
	end


case 'ButtonColor'
	try
		load('fltool.mat','ButtonColor');
		option_value = ButtonColor;
	catch
		option_value = [0.8 0.8 0.8];
	end

case 'FrameColor'
	try
		load('fltool.mat','FrameColor');
		option_value = FrameColor;
	catch
		option_value = [0.8 0.8 0.8];
	end

case 'BackGroundFileName'
	try
		load('fltool.mat','BackGroundFileName');
		option_value = BackGroundFileName;
	catch
		option_value = '';
	end	




case 'BackGroundSize'
	try
		bgimage = imread(fl_getOption('BackGroundFileName'));
		size_bg = size(bgimage);
		dimension = size(size_bg);
		if dimension(2) == 3
			option_value = size_bg(1:2);
		else
			option_value = size_bg;
		end
	catch
		option_value = [0 0];
	end

case 'BackGround'
	try 	
		if nargin == 1
			BackGroundFileName = fl_getOption('BackGroundFileName');
		end

		[option_value,bgmap] = imread(BackGroundFileName);
		
		if isempty(bgmap)
			bgmap = gray(256);
		end 
		varargout(1) = {bgmap};
			
	catch
		option_value = [];
		varargout(1) = {gray(256)};
	end

case 'Fill_inColor'
	try
		load('fltool.mat','Fill_inColor');
		option_value = Fill_inColor;
	catch
		option_value = [1 1 1];
	end
	
case 'FontColor'
	try
		load('fltool.mat','FontColor');
		option_value = FontColor;
	catch
		option_value = [0 0 0 ];
	end

case 'AltFontColor'
	try
 		Layout = fl_getOption('Layout');
 		if Layout >= 4
			 option_value =  fl_getOption('FrameColor');	
    else
			 option_value =  fl_getOption('FontColor');	
		end	 
	catch
		option_value = [0 0 0 ];
	end

case 'LogoFileName'
	try
		load('fltool.mat','LogoFileName');
		option_value = LogoFileName;
	catch
		option_value = '';
	end

case 'Logo'
	try 	
		if nargin == 1
			LogoFileName = fl_getOption('LogoFileName');
			BackGroundColor = fl_getOption('BackGroundColor');
			Layout = fl_getOption('Layout');
		end
		if nargin == 2
			LogoFileName = varargin{1};
			BackGroundColor = fl_getOption('BackGroundColor');
			Layout = fl_getOption('Layout');
		end
		if nargin == 3
			LogoFileName = varargin{1};
			BackGroundColor = varargin{2};
			Layout = fl_getOption('Layout');
		end
		if nargin == 4
			LogoFileName = varargin{1};
			BackGroundColor = varargin{2};
			Layout = varargin{3};
		end
		%try
		%	[option_value,logomap] = imread(LogoFileName,'BackgroundColor',BackGroundColor);
		%catch
		%	[option_value,logomap] = imread(LogoFileName);
		%end
		
		[option_value,logomap,alphamap] = imread(LogoFileName);
		
		size_logo = size(option_value);
		dimension = size(size_logo);
		if size_logo(1)<size_logo(2) & Layout>=2
			if dimension(2) == 3
				logo2 = permute(option_value,[2 1 3]);
				option_value = logo2(end:-1:1,:,:);
			else
				logo2 = option_value';
				option_value = logo2(end:-1:1,:);
			end
			alpha2 = alphamap';
			alphamap = alpha2(end:-1:1,:);
		end
		
		if size_logo(1)>size_logo(2) & Layout==1
			if dimension(2) == 3
				logo2 = permute(option_value,[2 1 3]);
				option_value = logo2(:,end:-1:1,:);
			else
				logo2 = option_value';
				option_value = logo2(:,end:-1:1);
			end
			alpha2 = alphamap';
			alphamap = alpha2(:,end:-1:1);			
		end
		
		
		if isempty(logomap)
			logomap = gray(256);
		end 
		varargout(1) = {logomap};
		varargout(2) = {alphamap};
			
	catch
		option_value = [];
		varargout(1) = {gray(256)};
		varargout(2) = {[]};
	end
	
case 'LogoSize'
	try
		if nargin > 1
			logo_frac = fl_getOption('Logo',cell2mat(varargin));
		else
			logo_frac = fl_getOption('Logo');
		end
		size_logo = size(logo_frac);
		dimension = size(size_logo);
		if dimension(2) == 3
			option_value = size_logo(1:2);
		else
			option_value = size_logo;
		end
		
	catch
		option_value = [0 0]
	end

case 'BackGroundColor'
	if nargin == 1
		try
			load('fltool.mat','BackGroundColor');	
			option_value = BackGroundColor;
		catch
			option_value = [0.8 0.8 0.8];
		end
	else
		try
			[logo_frac cmap_frac]=fl_getOption('Logo',cell2mat(varargin));
			if isempty(cmap_frac)
				cmap_frac = gray(256);
			end 
			dimension = size(size(logo_frac));
			if dimension(2) == 3
				r=double(logo_frac(2,2,1))/255;
				g=double(logo_frac(2,2,2))/255;
				b=double(logo_frac(2,2,3))/255;
				option_value = [r g b];
			else
				option_value=cmap_frac(logo_frac(2,2)+1,:);
			end
				
		catch
			option_value = [0.8 0.8 0.8];
		end
	end

	
case 'LogoColorMap'
	if nargin == 1
		try
			load('fltool.mat','LogoColorMap');	
			option_value = LogoColorMap;
		catch
			option_value = gray(256);
		end
		
	else
		try
			[logo_frac cmap_frac]=fl_getOption('Logo',cell2mat(varargin));
			option_value = cmap_frac;
		catch
			option_value = gray(256);
		end
	end


case 'SaveLog'
	try
		load('fltool.mat','SaveLog');
		option_value = SaveLog;
	catch
		option_value = 1;
	end

case 'SavePosition'
	try
		load('fltool.mat','SavePosition');
		option_value = SavePosition;
	catch
		option_value = 1;
	end	
	
case 'ShowSplashScreen'
	try
		load('fltool.mat','ShowSplashScreen');
		option_value = ShowSplashScreen;
	catch
		option_value = 0;
	end

case 'ShowWaitBars'
	try
		ShowHiddenHandlesInit = get(0,'ShowHiddenHandles');
		set(0,'ShowHiddenHandles','on');
		fraclabhandle=findobj(0,'Tag','FRACLAB Toolbox');
		set(0,'ShowHiddenHandles',ShowHiddenHandlesInit);
		if isempty(fraclabhandle)
			option_value = 0;
		else
			load('fltool.mat','ShowWaitBars');
			option_value = ShowWaitBars;
		end
	catch
		option_value = 1;
	end

case 'ForceBackGroundColor'
	try
		load('fltool.mat','ForceBackGroundColor');
		option_value = ForceBackGroundColor;
	catch
		option_value = 0;
	end

case 'FracLabPosition'
	try
		load('fltool.mat','FracLabPosition');
		option_value = FracLabPosition;
	catch
		WindowsScreenSize = get(0,'ScreenSize');
		option_value = [0.35*WindowsScreenSize(3) 0.30*WindowsScreenSize(4) 640 690];
	end


case 'FracLabRoot'
	try
		filefltool = which('fltool');
		pathfltool = fileparts(filefltool);
		listsep = find(filesep == pathfltool);
		lastsep = listsep(end);
		option_value = pathfltool(1:lastsep);
	catch
		option_value = '';
	end

otherwise
	option_value = 0;
end

warning(lastwarningstate);