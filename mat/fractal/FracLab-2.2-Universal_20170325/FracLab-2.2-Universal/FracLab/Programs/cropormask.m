function cropormask(x,name,method)
%CROPORMASK Crops an image or creates a mask using an image
%
%   CROPORMASK(X,'VARNAME') displays the image of X in a figure window and 
%   creates an interactive image tool, associated with the image of X. 
%   The tool is a moveable, resizable rectangle that is interactively placed
%   and manipulated using the mouse.
%   By choosing 'Extract' from the tool's context menu the user crops the image.
%   By choosing 'Modify' the user can modify the tool at any time.
%   The cropped image is saved in the variable VARNAME and added to the
%   list of variables of fraclab.
%   The current figure is closed once the operation is done.
%
%   CROPORMASK(X,'VARNAME','MASK') displays the image of X in a figure window and 
%   creates an interactive image tool, associated with the image of X.
%   Using the tool's context menu, the user creates a mask which has the same size of X. 
%   By choosing 'Mask of ones', the user keeps the region surrounded by 
%   the resizable rectangle and put the rest of the image to zero. 
%   By choosing 'Mask of zeros', the user put the region surrounded by 
%   the resizable rectangle to zero and do not modify the rest of the image.
%   Once the type of mask is selected, in the figure is displayed for a
%   second the result of the combination of the original image and the created mask.
%   By choosing 'Save', the mask is saved in the variable VARNAME and is added on the 
%   list of variables of fraclab.
%   By choosing 'Cancel' the user restores the original image of X at any time.
%   The current figure is closed once the operation is done.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc cropormask ">cropormask</a>

% Author Christian Choque Cortez, February 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,3);
if nargin == 2, method = 'crop'; end
if ~(strcmp(method,'crop') || strcmp(method,'mask')), disp('error');end

figure; set(gcf,'Color',fl_getOption('FrameColor'));
fcolor = fl_getOption('FontColor');
imagesc(x); colormap(gray); title('Original Image','Color',fcolor);
set(gca,'XColor',fcolor,'YColor',fcolor,'ZColor',fcolor);

N1 = max(get(gca,'Xlim'))-min(get(gca,'Xlim')); 
N2 = max(get(gca,'Ylim'))-min(get(gca,'Ylim'));
offset = min(min(get(gca,'Xlim')),min(get(gca,'Ylim')));
mask = getrect(gcf); mask(1:2) = mask(1:2) - offset;

% Reshape borders for the annotation rectangle
gca_pos = get(gca,'position');
annot_pos = rect2annot([N1,N2],mask,gca_pos);

cmenu = uicontextmenu;
annotation('rectangle',annot_pos,'UserData',{x,name},'UIContextMenu',cmenu,'EdgeColor',[1 1 0]);

% Define the context menu items
if strcmp(method,'crop')
    uimenu(cmenu, 'Label', 'Modify', 'Callback', @modify);
    uimenu(cmenu, 'Label', 'Extract', 'Callback', @extraction);
else
    uimenu(cmenu, 'Label', 'Mask of ones', 'Callback', @mask_ones);
    uimenu(cmenu, 'Label', 'Mask of zeros', 'Callback', @mask_zeros);
    uimenu(cmenu, 'Label', 'Modify', 'Callback', @modify);
    uimenu(cmenu, 'Label', 'Save', 'Callback', @save,'Enable','off');
    uimenu(cmenu, 'Label', 'Cancel', 'Callback', @cancel);
end
end

%--------------------------------------------------------------------------
% Functions to reshape positions from rectangle to annotation and vice-versa
function annotation_position = rect2annot(size_data,rectangle_position,current_axes_position)
rectangle_position = round(rectangle_position);
rectangle_position(2) = size_data(2) - (rectangle_position(2) + rectangle_position(4));
annotation_position = rectangle_position.*[current_axes_position(3)/size_data(1),...
                                 current_axes_position(4)/size_data(2),...
                                 current_axes_position(3)/size_data(1),...
                                 current_axes_position(4)/size_data(2)];
annotation_position(1) = annotation_position(1) + current_axes_position(1); 
annotation_position(2) = annotation_position(2) + current_axes_position(2);
end

%--------------------------------------------------------------------------
function rectangle_position = annot2rect(size_data,annotation_position,current_axes_position)
annotation_position(1) = annotation_position(1) - current_axes_position(1); 
annotation_position(2) = annotation_position(2) - current_axes_position(2);
rectangle_position = annotation_position.*[size_data(1)/current_axes_position(3),...
                                 size_data(2)/current_axes_position(4),...
                                 size_data(1)/current_axes_position(3),...
                                 size_data(2)/current_axes_position(4)];
rectangle_position(2) = size_data(2) - (rectangle_position(2) + rectangle_position(4));
rectangle_position = round(rectangle_position);
end

%--------------------------------------------------------------------------
% Definition of Callbacks
function mask_ones(varargin)
fl_clearerror;
fcolor = fl_getOption('FontColor');
gca_pos = get(gca,'Position');
N1 = max(get(gca,'Xlim')) - min(get(gca,'Xlim'));
N2 = max(get(gca,'Ylim')) - min(get(gca,'Ylim'));
annot_pos_ini = get(gco,'Position');
mask = annot2rect([N1,N2],annot_pos_ini,gca_pos);
annot_pos_fin = rect2annot([N1,N2],mask,gca_pos);
set(gco,'Position',annot_pos_fin);
data = get(gco,'UserData'); x = data{1}; 
try
    y = zeros(size(x));
    y(mask(2) + 1 : mask(2) + mask(4),...
        mask(1) + 1 : mask(1) + mask(3)) = 1;
    x = x.*y; 
    imagesc(x);title('Image with the mask','Color',fcolor);
    set(gca,'XColor',fcolor,'YColor',fcolor,'ZColor',fcolor); pause(1);
    imagesc(y);title('Only the mask','Color',fcolor);
    set(gca,'XColor',fcolor,'YColor',fcolor,'ZColor',fcolor);
    options = get(get(gco,'Uicontextmenu'),'Children');
    option_save = options(2); set(option_save,'Enable','on');
catch %#ok<CTCH>
    fl_warning('The rectangle is out of range')
end
end

%--------------------------------------------------------------------------
function mask_zeros(varargin)
fl_clearerror;
fcolor = fl_getOption('FontColor');
gca_pos = get(gca,'Position');
N1 = max(get(gca,'Xlim')) - min(get(gca,'Xlim'));
N2 = max(get(gca,'Ylim')) - min(get(gca,'Ylim'));
annot_pos_ini = get(gco,'Position');
mask = annot2rect([N1,N2],annot_pos_ini,gca_pos);
annot_pos_fin = rect2annot([N1,N2],mask,gca_pos);
set(gco,'Position',annot_pos_fin);
data = get(gco,'UserData'); x = data{1}; 
try
    y = ones(size(x));
    y(mask(2) + 1 : mask(2) + mask(4),...
        mask(1) + 1 : mask(1) + mask(3)) = 0;
    x = x.*y; 
    imagesc(x);title('Image with the mask','Color',fcolor);
    set(gca,'XColor',fcolor,'YColor',fcolor,'ZColor',fcolor); pause(1);
    imagesc(y);title('Only the mask','Color',fcolor);
    set(gca,'XColor',fcolor,'YColor',fcolor,'ZColor',fcolor);
    options = get(get(gco,'Uicontextmenu'),'Children');
    option_save = options(2); set(option_save,'Enable','on');
catch %#ok<CTCH>
    fl_warning('The rectangle is out of range')
end
end

%--------------------------------------------------------------------------
function modify(varargin)
fl_clearerror;
fcolor = fl_getOption('FontColor');
options = get(get(gco,'Uicontextmenu'),'Children');
if length(options) ~= 2
    option_save = options(2);
    set(option_save,'Enable','off');     
end
data = get(gco,'UserData'); x = data{1}; 
imagesc(x); title('Original Image','Color',fcolor);
set(gca,'XColor',fcolor,'YColor',fcolor,'ZColor',fcolor);
set(gco,'Selected','on'); plotedit on;
while ~strcmp(get(gco,'Type'),'hggroup')
    waitforbuttonpress;
end
waitfor(gco,'Selected','off');
plotedit off;
end

%--------------------------------------------------------------------------
function save(varargin)
fl_clearerror;
data = get(gco,'UserData'); name = data{2}; eval(['global ' name]);
new_data = get(gca,'Children'); y = get(new_data,'CData');
eval([name,'=',mat2str(y),';']);
assignin('base', name, y);
fl_addlist(0,name); close(gcf)
end

%--------------------------------------------------------------------------
function extraction(varargin)
fl_clearerror;
gca_pos = get(gca,'Position');
N1 = max(get(gca,'Xlim')) - min(get(gca,'Xlim'));
N2 = max(get(gca,'Ylim')) - min(get(gca,'Ylim'));
annot_pos_ini = get(gco,'Position');
mask = annot2rect([N1,N2],annot_pos_ini,gca_pos);
annot_pos_fin = rect2annot([N1,N2],mask,gca_pos);
set(gco,'Position',annot_pos_fin);
data = get(gco,'UserData'); x = data{1}; 
name = data{2}; eval(['global ' name]);
try
    y = x(mask(2) + 1 : mask(2) + mask(4),...
        mask(1) + 1 : mask(1) + mask(3));
    eval([name,'=',mat2str(y),';']);
    assignin('base', name, y);
    fl_addlist(0,name); close(gcf);
catch %#ok<CTCH>
    fl_warning('The rectangle is out of range')
end
end

%--------------------------------------------------------------------------
function cancel(varargin)
fl_clearerror;
fcolor = fl_getOption('FontColor');
options = get(get(gco,'Uicontextmenu'),'Children');
option_save = options(2);
set(option_save,'Enable','off');
plotedit off;
data = get(gco,'UserData'); 
x = data{1}; imagesc(x); title('Original Image','Color',fcolor);
set(gca,'XColor',fcolor,'YColor',fcolor,'ZColor',fcolor);
end
