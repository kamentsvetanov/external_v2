function varargout = MDIgui(varargin)
% MDIGUI MATLAB code for MDIgui.fig
%      MDIGUI, by itself, creates a new MDIGUI or raises the existing
%      singleton*.
%
%      H = MDIGUI returns the handle to a new MDIGUI or the handle to
%      the existing singleton*.
%
%      MDIGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MDIGUI.M with the given input arguments.
%
%      MDIGUI('Property','Value',...) creates a new MDIGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MDIgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MDIgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MDIgui

% Last Modified by GUIDE v2.5 09-Mar-2016 15:01:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MDIgui_OpeningFcn, ...
                   'gui_OutputFcn',  @MDIgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MDIgui is made visible.
function MDIgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MDIgui (see VARARGIN)

% Choose default command line output for MDIgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% DA settings disabled
set(handles.edit3, 'String', '');
set(handles.edit4, 'String', '');
set(handles.edit3,'Enable','off')
set(handles.edit4,'Enable','off') 

% Definimos la estructura de resultados
clear MDItoolbox_results
Dataset='';
X_MD=[];
Percentage_MD=[];
X_imputed=[];
PCs=1;
Mean=[];
Loadings=[];
Scores=[];
Covariances=[];
Iterations=5000;
Tolerance=10e-10;
X_reconstructed=[];
Method='TSR';
Computation_time=[];
Ini_est_cum_R2=[];
Ini_est_eig=[];
M=[];
CL=[];
stru=struct('Dataset',Dataset,'X_MD',X_MD,'Percentage_MD',Percentage_MD,'X_imputed', X_imputed,'PCs',PCs,'Mean',Mean,'Covariances',Covariances,'Iterations',Iterations,'Tolerance',Tolerance,'X_reconstructed',X_reconstructed,'Method', Method,'Computation_time',Computation_time,'Ini_est_cum_R2',Ini_est_cum_R2,'Num_Markov_Chains',M,'Chain_Length',CL);
assignin('base','MDItoolbox_results',stru)

% UIWAIT makes MDIgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MDIgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
DataOverview

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectData

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.xls', 'Excel (*.xls)';'*.xlsx','Excel (*.xlsx)'},'Select File');

if length(filename)>1
    data=xlsread([pathname filename]);
    stru=evalin('base','MDItoolbox_results'); % cogemos la estructura de resultados
    stru.X_MD=data; % rellenamos los datos
    stru.Dataset=filename;
    assignin('base','MDItoolbox_results',stru) % devolvemos la estructura al WS
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectExample


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
its = str2double(get(hObject,'string'));
stru=evalin('base','MDItoolbox_results');
stru.Iterations=its;
assignin('base','MDItoolbox_results',stru)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
tol = str2double(get(hObject,'string'));
stru=evalin('base','MDItoolbox_results');
stru.Tolerance=10^(-tol);
assignin('base','MDItoolbox_results',stru)

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
method = get(handles.popupmenu1,'Value');
stru=evalin('base','MDItoolbox_results');
switch method
    case 1
        stru.Method='TSR';
    case 2
        stru.Method='KDR';
    case 3
        stru.Method='PCR';
    case 4
        stru.Method='PLS';
    case 5
        stru.Method='PMP';
    case 6
        stru.Method='IA';
    case 7
        stru.Method='NIPALS';
    case 8
        stru.Method='DA';
        set(handles.edit1, 'String', '');
        set(handles.edit2, 'String', '');
        set(handles.edit1,'Enable','off')
        set(handles.edit2,'Enable','off') 
        set(handles.edit3, 'String', '10');
        set(handles.edit4, 'String', '100');
        set(handles.edit3,'Enable','on');
        set(handles.edit4,'Enable','on');
        stru.Num_Markov_Chains=10;
        stru.Chain_Length=100;
        stru.Iterations=[];
        stru.Tolerance=[];
    otherwise
end
if method<8
        set(handles.edit3, 'String', '');
        set(handles.edit4, 'String', '');
        set(handles.edit3,'Enable','off')
        set(handles.edit4,'Enable','off') 
        set(handles.edit1, 'String', '5000');
        set(handles.edit2, 'String', '10');
        set(handles.edit1,'Enable','on');
        set(handles.edit2,'Enable','on');
        stru.Iterations=5000;
        stru.Tolerance=10e-10;
        stru.Num_Markov_Chains=[];
        stru.Chain_Length=[];
end
assignin('base','MDItoolbox_results',stru)

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
M = str2double(get(hObject,'string'));
stru=evalin('base','MDItoolbox_results');
stru.Num_Markov_Chains=M;
assignin('base','MDItoolbox_results',stru)

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
CL = str2double(get(hObject,'string'));
stru=evalin('base','MDItoolbox_results');
stru.Chain_Length=CL;
assignin('base','MDItoolbox_results',stru)

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
