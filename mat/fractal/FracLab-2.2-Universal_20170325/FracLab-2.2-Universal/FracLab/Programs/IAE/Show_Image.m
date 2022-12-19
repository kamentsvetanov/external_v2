function P_imghandle = Show_Image(hObject, eventdata, handles, P_axes, P_img, P_RGB, P_fig)
% P_axes The axes (placeholder) in which the image should be rendered 
% P_img The image matrix
% P_RGB which Color channel to draw, Matrix [1,3]
% P_fig The parent figure

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	H_axes = findobj('Tag',P_axes);
	[axes_pos] = get(H_axes,'Position');
	H_fig = findobj('Tag',P_fig);
	
	%get(H_fig,'Name')
	
	filter_img = P_img;
	if (bitget(P_RGB,1) == 0) 
		filter_img(:,:,1) = 0;
	end
	if (bitget(P_RGB,2) == 0) 
		filter_img(:,:,2) = 0;
	end
	if (bitget(P_RGB,3) == 0) 
		filter_img(:,:,3) = 0;
	end

 	
	imginfo = size(filter_img);
	
	%check if image allready exists --> dont recreate each time
	if (isempty(findobj('Tag',['image_' get(H_axes,'Tag')])) == 0)
		
		%output old image handle
		P_imghandle = findobj('Tag',['image_' get(H_axes,'Tag')]);
		
		%update old image's content
		set(P_imghandle,'CData',uint8(filter_img));
		
		%adjust existing axes to fit with new image content 
		H_axeshandle = findobj('Tag',['I_' get(H_axes,'Tag')] );
		set(H_axeshandle,'XLim',[1 imginfo(2)]);
		set(H_axeshandle,'YLim',[1 imginfo(1)]);
		return;
	end
	
	b = axes('Parent',H_fig, ...
	'Box','on', ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'HandleVisibility','callback', ...
	'Layer','top', ...
	'Units','normalized', ...
	'Position',[axes_pos(1) axes_pos(2) axes_pos(3) axes_pos(4)], ...
	'Tag',['I_' get(H_axes,'Tag')], ...
	'UserData',get(H_axes,'UserData'), ...
	'Visible','off', ...
	'XColor',[0 0 0], ...
	'XLim',[1 imginfo(2)], ...
	'XLimMode','manual', ...
	'YColor',[0 0 0], ...
	'YDir','reverse', ...
	'YLim',[1 imginfo(1)], ...
	'YLimMode','manual', ...
	'ZColor',[0 0 0]);
	
	D_axes = get(H_axes,'UserData');
	
	
	d = image('Parent',b, ...
	'CData',filter_img, ...
	'Interruptible','off', ...
	'Tag',['image_' get(H_axes,'Tag')], ...
	'UserData',D_axes(1));

 P_imghandle = d;
 refresh;