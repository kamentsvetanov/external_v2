function varargout = gui_fl_bayes_IAE_dialog01(varargin)
% gui_fl_bayes_iae_dialog01 M-file for gui_fl_bayes_IAE_dialog01.fig
%      gui_fl_bayes_iae_dialog01, by itself, creates a new gui_fl_bayes_iae_dialog01 or raises the existing
%      singleton*.
%
%      H = gui_fl_bayes_IAE_dialog01 returns the handle to a new gui_fl_bayes_IAE_dialog01 or the handle to
%      the existing singleton*.
%
%      gui_fl_bayes_IAE_dialog01('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in gui_fl_bayes_IAE_dialog01.M with the given input arguments.
%
%      gui_fl_bayes_IAE_dialog01('Property','Value',...) creates a new gui_fl_bayes_IAE_dialog01 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_fl_bayes_IAE_dialog01_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_fl_bayes_IAE_dialog01_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_fl_bayes_IAE_dialog01

% Last Modified by GUIDE v2.5 07-Feb-2005 15:34:42

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_fl_bayes_IAE_dialog01_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_fl_bayes_IAE_dialog01_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_fl_bayes_IAE_dialog01 is made visible.
function gui_fl_bayes_IAE_dialog01_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_fl_bayes_IAE_dialog01 (see VARARGIN)

% Choose default command line output for gui_fl_bayes_IAE_dialog01
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_fl_bayes_IAE_dialog01 wait for user response (see UIRESUME)
% uiwait(handles.fig_adjust);



% --- Outputs from this function are returned to the command line.
function varargout = gui_fl_bayes_IAE_dialog01_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1 (random button).
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

img_num = mydata.images.analysedimage;

mydata.images.image(8).genotype.sigma = 	str2double(get(findobj('Tag','edit_sigma'),'String'));
mydata.images.image(8).genotype.amin = 	str2double(get(findobj('Tag','edit_amin'),'String'));
mydata.images.image(8).genotype.gmin = 	str2double(get(findobj('Tag','edit_gamin'),'String'));
mydata.images.image(8).genotype.amax = 	str2double(get(findobj('Tag','edit_amax'),'String'));
mydata.images.image(8).genotype.gmax = 	str2double(get(findobj('Tag','edit_gamax'),'String'));
mydata.images.image(8).genotype.anod = 	str2double(get(findobj('Tag','edit_anod'),'String'));


filter_indices = get(findobj('Tag','listbox_wavelet'),'UserData');
filternum = filter_indices(get(findobj('Tag','listbox_wavelet'),'Value'));
mydata.images.image(8).genotype.filter =	filternum;

scales = round(str2num(get(findobj('Tag','scales_label'),'String')));
scales = max(scales,1);

[mydata.images.image(8),old_coeff,new_coeff] = Denoise(mydata.images.image(8),scales);

%assignin('base' ,'old_coeff', old_coeff);
%assignin('base' ,'new_coeff', new_coeff);

%old_coeff(size(old_coeff,2)).vals
%new_coeff(size(new_coeff,2)).vals

%old_coeff = reshape(abs(old_coeff(size(old_coeff,2)).vals),1,[]);
%new_coeff = reshape(abs(new_coeff(size(new_coeff,2)).vals),1,[]);

%nz = find(old_coeff>0);
%new_coeff = new_coeff(nz);
%old_coeff = old_coeff(nz);

%[x,y]=sort(old_coeff);
%figure;
%plot(x,new_coeff(y),'r');

h = Show_Image(hObject, eventdata, handles, 'preview_axes',mydata.images.image(8).CData,7,'fig_adjust');
%set(h,'ButtonDownFcn',@Enlarge_Image);
set(h,'ButtonDownFcn',{@Enlarge_Image,8});


[thumb_handles] = show_spectrum(hObject, eventdata, handles, 'spectrum_axes','fig_adjust');
set(thumb_handles(1),'ButtonDownFcn',{@genotype_thumb_press, handles, 1});
set(thumb_handles(2),'ButtonDownFcn',{@genotype_thumb_press, handles, 2});
set(thumb_handles(3),'ButtonDownFcn',{@genotype_thumb_press, handles, 3});



% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit_sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function edit_sigma_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sigma as text
%        str2double(get(hObject,'String')) returns contents of edit_sigma as a double






% --- Executes during object creation, after setting all properties.
function edit_amin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_amin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_amin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_amin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_amin as text
%        str2double(get(hObject,'String')) returns contents of edit_amin as a double


% --- Executes during object creation, after setting all properties.
function edit_anod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_anod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_anod_Callback(hObject, eventdata, handles)
% hObject    handle to edit_anod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_anod as text
%        str2double(get(hObject,'String')) returns contents of edit_anod as a double


% --- Executes during object creation, after setting all properties.
function edit_amax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_amax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_amax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_amax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_amax as text
%        str2double(get(hObject,'String')) returns contents of edit_amax as a double


% --- Executes during object creation, after setting all properties.
function edit_gamax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gamax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_gamax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gamax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gamax as text
%        str2double(get(hObject,'String')) returns contents of edit_gamax as a double


% --- Executes during object creation, after setting all properties.
function edit_gamin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gamin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_gamin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gamin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gamin as text
%        str2double(get(hObject,'String')) returns contents of edit_gamin as a double


% --- Executes during object creation, after setting all properties.
function listbox_wavelet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_wavelet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

global mydata;

filter_list = [];
filter_indices = [];

try
    for i=1:1:max(size(mydata.config.evol_filters))

        [QMF,NAME] = MakeFilter(mydata.config.evol_filters(i));

        filter_list{i} = NAME;
        filter_indices = [filter_indices, mydata.config.evol_filters(i)];
    end
catch
end

set(hObject,'String',filter_list);
set(hObject,'UserData',filter_indices);
%userdata1 = get(hObject,'UserData')

% --- Executes on selection change in listbox_wavelet.
function listbox_wavelet_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_wavelet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_wavelet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_wavelet


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;


img_num = mydata.images.analysedimage;

if (img_num < 1 || img_num > 7)
	
	%write temporary data to permanent data structure
	mydata.images.image(img_num) = mydata.images.image(8);
		
	set(mydata.images.image(img_num).handle,'CData',mydata.images.image(img_num).CData);
	close(gui_fl_bayes_IAE_dialog01);
	return;
end

% dont change original image
if (img_num ~= 1)
	
	%write temporary data to permanent data structure
	mydata.images.image(img_num) = mydata.images.image(8);
	mydata.population.individuals(mydata.images.image(img_num).evol_individualID).genotype = mydata.images.image(img_num).genotype;
	
	%update the corresponding image in main dialog
	set(mydata.images.image(img_num).handle,'CData',mydata.images.image(img_num).CData);
	gui_fl_bayes_IAE('refresh_image_statistics', hObject, eventdata, img_num);
	drawnow;
end

%set(gui_fl_bayes_IAE_dialog01,'Visible','off');

gui_fl_bayes_IAE('update_global_statistics',hObject, eventdata, get(gui_fl_bayes_IAE_dialog01,'UserData'), 1);
close(gui_fl_bayes_IAE_dialog01);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gui_fl_bayes_IAE_dialog01);


% --- Executes on key press over fig_adjust with no controls selected.
function fig_adjust_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to fig_adjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(hObject,'CurrentCharacter') == 'r')
	pushbutton1_Callback(hObject, eventdata, handles);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton5.
function pushbutton5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global mydata;

mydata.images.image(8).genotype = evol_init(mydata.images.image(8).genotype);
fix_genotypes(8);

set(findobj('Tag','edit_sigma'),'String',mydata.images.image(8).genotype.sigma);
set(findobj('Tag','edit_amin'),'String',mydata.images.image(8).genotype.amin);
set(findobj('Tag','edit_gamin'),'String',mydata.images.image(8).genotype.gmin);
set(findobj('Tag','edit_amax'),'String',mydata.images.image(8).genotype.amax);
set(findobj('Tag','edit_gamax'),'String',mydata.images.image(8).genotype.gmax);
set(findobj('Tag','edit_anod'),'String',mydata.images.image(8).genotype.anod);

filter_indices = get(findobj('Tag','listbox_wavelet'),'UserData');
filternum = mydata.images.image(8).genotype.filter;

[val, pos] = intersect(filter_indices,filternum);

set(findobj('Tag','listbox_wavelet'),'Value',pos);
pushbutton1_Callback(hObject, eventdata, handles);

% Load saved handles from Main figure


% --- Executes when user attempts to close fig_adjust.
function fig_adjust_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fig_adjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



% --- Executes on slider movement.
function scales_slider_Callback(hObject, eventdata, handles)
% hObject    handle to scales_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(findobj('Tag','scales_label'),'String', max(1,round(get(hObject,'Value'))));

% --- Executes during object creation, after setting all properties.
function scales_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scales_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


