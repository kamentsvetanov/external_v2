function varargout = SelectExample(varargin)
% SELECTEXAMPLE MATLAB code for SelectExample.fig
%      SELECTEXAMPLE, by itself, creates a new SELECTEXAMPLE or raises the existing
%      singleton*.
%
%      H = SELECTEXAMPLE returns the handle to a new SELECTEXAMPLE or the handle to
%      the existing singleton*.
%
%      SELECTEXAMPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTEXAMPLE.M with the given input arguments.
%
%      SELECTEXAMPLE('Property','Value',...) creates a new SELECTEXAMPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectExample_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectExample_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectExample

% Last Modified by GUIDE v2.5 06-Oct-2015 12:19:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectExample_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectExample_OutputFcn, ...
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


% --- Executes just before SelectExample is made visible.
function SelectExample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectExample (see VARARGIN)

load('MDI_Example.mat');
stru=evalin('base','MDItoolbox_results');
stru.X_MD = OliveOil_10MD;
assignin('base','complete',OliveOil_Complete)
stru.Dataset='OliveOil_10MD';
assignin('base','MDItoolbox_results',stru) % devolvemos la estructura al WS

% Choose default command line output for SelectExample
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectExample wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SelectExample_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
index_selected = get(handles.listbox1,'Value');
load('MDI_Example.mat');
stru=evalin('base','MDItoolbox_results');

switch index_selected
    case 1
        stru.X_MD = OliveOil_10MD;
        assignin('base','complete',OliveOil_Complete)
        stru.Dataset='OliveOil_10MD';
    case 2
        stru.X_MD = OliveOil_30MD;
        assignin('base','complete',OliveOil_Complete)
        stru.Dataset='OliveOil_30MD';
    case 3
        stru.X_MD = OliveOil_60MD;
        assignin('base','complete',OliveOil_Complete)
        stru.Dataset='OliveOil_60MD';    
    case 4
        stru.X_MD = DieselNIR_10MD;
        assignin('base','complete',DieselNIR_Complete)
        stru.Dataset='DieselNIR_10MD';
    case 5
        stru.X_MD = DieselNIR_30MD;
        assignin('base','complete',DieselNIR_Complete)
        stru.Dataset='DieselNIR_30MD';
    case 6
        stru.X_MD = DieselNIR_60MD;
        assignin('base','complete',DieselNIR_Complete)
        stru.Dataset='DieselNIR_60MD';  
    case 7
        stru.X_MD = Simulated_10MD;
        assignin('base','complete',Simulated_Complete)
        stru.Dataset='Simulated_10MD'; 
    case 8
        stru.X_MD = Simulated_30MD;
        assignin('base','complete',Simulated_Complete)
        stru.Dataset='Simulated_30MD'; 
    case 9
        stru.X_MD = Simulated_60MD;
        assignin('base','complete',Simulated_Complete)
        stru.Dataset='Simulated_60MD';  
    otherwise
end

assignin('base','MDItoolbox_results',stru) 

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
