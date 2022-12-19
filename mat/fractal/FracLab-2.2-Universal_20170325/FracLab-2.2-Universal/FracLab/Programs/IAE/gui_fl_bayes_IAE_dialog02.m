function varargout = gui_fl_bayes_IAE_dialog02(varargin)
% gui_fl_bayes_IAE_dialog02 M-file for gui_fl_bayes_IAE_dialog02.fig
%      gui_fl_bayes_IAE_dialog02, by itself, creates a new gui_fl_bayes_IAE_dialog02 or raises the existing
%      singleton*.
%
%      H = gui_fl_bayes_IAE_dialog02 returns the handle to a new gui_fl_bayes_IAE_dialog02 or the handle to
%      the existing singleton*.
%
%      gui_fl_bayes_IAE_dialog02('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in gui_fl_bayes_IAE_dialog02.M with the given input arguments.
%
%      gui_fl_bayes_IAE_dialog02('Property','Value',...) creates a new gui_fl_bayes_IAE_dialog02 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_fl_bayes_IAE_dialog02_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_fl_bayes_IAE_dialog02_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_fl_bayes_IAE_dialog02

% Last Modified by GUIDE v2.5 14-Nov-2004 00:17:08

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_fl_bayes_IAE_dialog02_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_fl_bayes_IAE_dialog02_OutputFcn, ...
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


% --- Executes just before gui_fl_bayes_IAE_dialog02 is made visible.
function gui_fl_bayes_IAE_dialog02_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_fl_bayes_IAE_dialog02 (see VARARGIN)

% Choose default command line output for gui_fl_bayes_IAE_dialog02
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_fl_bayes_IAE_dialog02 wait for user response (see UIRESUME)
% uiwait(handles.fig_test_coeff);


% --- Outputs from this function are returned to the command line.
function varargout = gui_fl_bayes_IAE_dialog02_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_refresh2.
function pushbutton_refresh2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refresh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

img_num = mydata.images.analysedimage;

mydata.images.image(8).genotype.sigma = 	str2double(get(findobj('Tag','edit_sigma2'),'String'));
mydata.images.image(8).genotype.amin = 	str2double(get(findobj('Tag','edit_amin2'),'String'));
mydata.images.image(8).genotype.gmin = 	str2double(get(findobj('Tag','edit_gamin2'),'String'));
mydata.images.image(8).genotype.amax = 	str2double(get(findobj('Tag','edit_amax2'),'String'));
mydata.images.image(8).genotype.gmax = 	str2double(get(findobj('Tag','edit_gamax2'),'String'));
mydata.images.image(8).genotype.anod = 	str2double(get(findobj('Tag','edit_anod2'),'String'));

filter_indices = get(findobj('Tag','listbox_wavelet2'),'UserData');
filternum = filter_indices(get(findobj('Tag','listbox_wavelet2'),'Value'));
mydata.images.image(8).genotype.filter =	filternum;

scale = str2double(get(findobj('Tag','text_scale2'),'String'));
modus = get(findobj('Tag','checkbox_ideal2'),'Value');

[mydata.images.image(8),old_coeff,new_coeff] = Denoise(mydata.images.image(8));


assignin('base' ,'old_coeff', old_coeff);
assignin('base' ,'new_coeff', new_coeff);

show_coeff_map(hObject, eventdata, handles,'spectrum_axes2','fig_test_coeff',old_coeff, new_coeff, mydata.images.image(8), scale, modus);

h = Show_Image(hObject, eventdata, handles, 'original_axes2',mydata.images.image(1).CData,7,'fig_test_coeff');
%set(h,'ButtonDownFcn',@Enlarge_Image);
set(h,'ButtonDownFcn',{@Enlarge_Image,1});

h = Show_Image(hObject, eventdata, handles, 'preview_axes2',mydata.images.image(8).CData,7,'fig_test_coeff');
%set(h,'ButtonDownFcn',@Enlarge_Image);
set(h,'ButtonDownFcn',{@Enlarge_Image,8});




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
function edit_sigma2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function edit_sigma2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sigma2 as text
%        str2double(get(hObject,'String')) returns contents of edit_sigma2 as a double


% --- Executes during object creation, after setting all properties.
function edit_amin2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_amin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_amin2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_amin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_amin2 as text
%        str2double(get(hObject,'String')) returns contents of edit_amin2 as a double


% --- Executes during object creation, after setting all properties.
function edit_anod2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_anod2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_anod2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_anod2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_anod2 as text
%        str2double(get(hObject,'String')) returns contents of edit_anod2 as a double


% --- Executes during object creation, after setting all properties.
function edit_amax2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_amax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_amax2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_amax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_amax2 as text
%        str2double(get(hObject,'String')) returns contents of edit_amax2 as a double


% --- Executes during object creation, after setting all properties.
function edit_gamax2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gamax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_gamax2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gamax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gamax2 as text
%        str2double(get(hObject,'String')) returns contents of edit_gamax2 as a double


% --- Executes during object creation, after setting all properties.
function edit_gamin2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gamin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_gamin2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gamin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gamin2 as text
%        str2double(get(hObject,'String')) returns contents of edit_gamin2 as a double


% --- Executes during object creation, after setting all properties.
function listbox_wavelet2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_wavelet2 (see GCBO)
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

%userdata2 = get(hObject,'UserData')

% --- Executes on selection change in listbox_wavelet2.
function listbox_wavelet2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_wavelet2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_wavelet2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_wavelet2


% --- Executes on key press over fig_test_coeff with no controls selected.
function fig_test_coeff_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to fig_test_coeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(hObject,'CurrentCharacter') == 'r')
	pushbutton1_Callback(hObject, eventdata, handles);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_random2.
function pushbutton_random2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_random2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_random2.
function pushbutton_random2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_random2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global mydata;

mydata.images.image(8).genotype = evol_init(mydata.images.image(8).genotype);

set(findobj('Tag','edit_sigma2'),'String',mydata.images.image(8).genotype.sigma);
set(findobj('Tag','edit_amin2'),'String',mydata.images.image(8).genotype.amin);
set(findobj('Tag','edit_gamin2'),'String',mydata.images.image(8).genotype.gmin);
set(findobj('Tag','edit_amax2'),'String',mydata.images.image(8).genotype.amax);
set(findobj('Tag','edit_gamax2'),'String',mydata.images.image(8).genotype.gmax);
set(findobj('Tag','edit_anod2'),'String',mydata.images.image(8).genotype.anod);

filter_indices = get(findobj('Tag','listbox_wavelet2'),'UserData');
filternum = mydata.images.image(8).genotype.filter;

[val, pos] = intersect(filter_indices,filternum);

set(findobj('Tag','listbox_wavelet2'),'Value',pos);


pushbutton_refresh2_Callback(hObject, eventdata, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_refresh2.
function pushbutton_refresh2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_refresh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function slider_scale2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_scale2 (see GCBO)
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


% --- Executes on slider movement.
function slider_scale2_Callback(hObject, eventdata, handles)
% hObject    handle to slider_scale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(findobj('Tag','text_scale2'),'String',(get(hObject,'Value')));
pushbutton_refresh2_Callback(hObject, eventdata, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider_scale2.
function slider_scale2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider_scale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_ok2.
function pushbutton_ok2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ok2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

img_num = mydata.images.analysedimage;

% dont change original image
if (img_num ~= 1)
	
	%write temporary data to permanent data structure
	mydata.images.image(img_num) = mydata.images.image(8);
	mydata.population.individuals(mydata.images.image(img_num).evol_individualID).genotype = mydata.images.image(img_num).genotype;
	
	set(mydata.images.image(img_num).handle,'CData',mydata.images.image(img_num).CData);
	gui_fl_bayes_IAE('refresh_image_statistics', hObject, eventdata, img_num);
end

gui_fl_bayes_IAE('update_global_statistics',hObject, eventdata, get(gui_fl_bayes_IAE_dialog02,'UserData'), 1);

close(gui_fl_bayes_IAE_dialog02);

% --- Executes on button press in pushbutton_cancel2.
function pushbutton_cancel2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gui_fl_bayes_IAE_dialog02);

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in checkbox_ideal2.
function checkbox_ideal2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ideal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ideal2

pushbutton_refresh2_Callback(hObject, eventdata, handles);



