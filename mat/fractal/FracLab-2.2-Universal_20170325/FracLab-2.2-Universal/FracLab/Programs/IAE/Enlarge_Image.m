function Enlarge_Image(hObject, eventdata, imgnum)
% This function enlarges an image to a new figure
% hObject    handle to MC_load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% mark that this image was clicked onto
global mydata;

% Get current image number from the userdate of calling hObject (an image)
%userdata = get(hObject,'UserData');
mydata.images.currentimage = imgnum;

% check for left mouse button, otherwise return
if ( strcmp(  get(gcf,'SelectionType'),'normal')  == 0)
	return;
end
  
  
	% get Image data
	D_img = mydata.images.image(mydata.images.currentimage).CData;
	%D_img = get(hObject,'CData');
	imginfo = size(D_img);
	
	xdim = imginfo(2);
	ydim = imginfo(1);
	
	
	if (bitget(mydata.images.image(mydata.images.currentimage).RGB,1) == 0) 
		D_img(:,:,1) = 0;
	end
	if (bitget(mydata.images.image(mydata.images.currentimage).RGB,2) == 0) 
		D_img(:,:,2) = 0;
	end
	if (bitget(mydata.images.image(mydata.images.currentimage).RGB,3) == 0) 
		D_img(:,:,3) = 0;
	end
	
	

	
	% create figure, apply color map
	H_fig = figure('Units','pixels', ...
								 'MenuBar','none','IntegerHandle','off','NumberTitle','off', ...
								 'Visible','off');
	
	if (xdim<400)
		xdim = 400;
		ydim = xdim * ydim/imginfo(2);
	end
	
	xpos = get(H_fig,'Position'); xpos = xpos(1);
	ypos = get(H_fig,'Position'); ypos = ypos(1);
	
	set(H_fig,'Position',[xpos,ypos,xdim,ydim]);
	set(H_fig,'Resize','on');
	set(H_fig,'Visible','on');
		
	% create axes
	H_axes = axes('Parent',H_fig, ...
		'Box','on', ...
		'CameraUpVector',[0 1 0], ...
		'CameraUpVectorMode','manual', ...
		'Color',[1 1 1], ...
		'HandleVisibility','callback', ...
		'Layer','top', ...
		'Units','normalized', ...
		'Visible','off', ...
		'XColor',[0 0 0], ...
		'XLim',[1 imginfo(2)], ...
		'XLimMode','manual', ...
		'YColor',[0 0 0], ...
		'YDir','reverse', ...
		'YLim',[1 imginfo(1)], ...
		'YLimMode','manual', ...
		'ZColor',[0 0 0] );

	%create image, event: close figure on mouse button
  H_img = image('Parent',H_axes, ...
		'ButtonDownFcn','close(gcf)');

	set(H_img,'CData',D_img);