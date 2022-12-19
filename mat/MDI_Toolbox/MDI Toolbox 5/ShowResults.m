function varargout = ShowResults(varargin)
% SHOWRESULTS MATLAB code for ShowResults.fig
%      SHOWRESULTS, by itself, creates a new SHOWRESULTS or raises the existing
%      singleton*.
%
%      H = SHOWRESULTS returns the handle to a new SHOWRESULTS or the handle to
%      the existing singleton*.
%
%      SHOWRESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOWRESULTS.M with the given input arguments.
%
%      SHOWRESULTS('Property','Value',...) creates a new SHOWRESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ShowResults_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ShowResults_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ShowResults

% Last Modified by GUIDE v2.5 06-Oct-2015 13:40:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ShowResults_OpeningFcn, ...
                   'gui_OutputFcn',  @ShowResults_OutputFcn, ...
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


% --- Executes just before ShowResults is made visible.
function ShowResults_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ShowResults (see VARARGIN)

stru=evalin('base','MDItoolbox_results');
S=stru.Covariances;
m=stru.Mean;
X=stru.X_imputed;
n=size(X,1);
[u d v]=svd(S,0);
P=v(:,1:stru.PCs);
T=(X-ones(n,1)*m)*P;

stru.Loadings=P;
stru.Scores=T;

assignin('base','MDItoolbox_results',stru)

handles.xaxs=1;
handles.yaxs=1;

handles.P=P;
handles.T=T;

axes(handles.axes1)
plot(handles.T(:,handles.xaxs),handles.T(:,handles.yaxs),'.','MarkerSize',10)
xl=['PC #',num2str(handles.xaxs)];
yl=['PC #',num2str(handles.yaxs)];
xlabel(xl)%,'Fontsize',11)
ylabel(yl)%,'Fontsize',11)
title('Scores plot')%,'Fontsize',12)

axes(handles.axes2)
plot(handles.P(:,handles.xaxs),handles.P(:,handles.yaxs),'.','MarkerSize',10)
xl=['PC #',num2str(handles.xaxs)];
yl=['PC #',num2str(handles.yaxs)];
xlabel(xl)%,'Fontsize',11)
ylabel(yl)%,'Fontsize',11)
title('Loadings plot')%,'Fontsize',12)

% Choose default command line output for ShowResults
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

stru=evalin('base','MDItoolbox_results');
set(handles.text26, 'String', stru.Method);
set(handles.text23, 'String', stru.Iterations);
set(handles.text24, 'String', stru.Tolerance);
set(handles.text25, 'String', stru.Computation_time);

set(handles.popupmenu4,'String',num2cell(1:stru.PCs)');
set(handles.popupmenu5,'String',num2cell(1:stru.PCs)');

% UIWAIT makes ShowResults wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ShowResults_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close



% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
NumberComponents

% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
val = get(hObject,'Value');
handles.xaxs=val;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5
val = get(hObject,'Value');
handles.yaxs=val;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
plot(handles.T(:,handles.xaxs),handles.T(:,handles.yaxs),'.','MarkerSize',10)
xl=['PC #',num2str(handles.xaxs)];
yl=['PC #',num2str(handles.yaxs)];
xlabel(xl)%,'Fontsize',11)
ylabel(yl)%,'Fontsize',11)
title('Scores plot')%,'Fontsize',12)

axes(handles.axes2)
plot(handles.P(:,handles.xaxs),handles.P(:,handles.yaxs),'.','MarkerSize',10)
xl=['PC #',num2str(handles.xaxs)];
yl=['PC #',num2str(handles.yaxs)];
xlabel(xl)%,'Fontsize',11)
ylabel(yl)%,'Fontsize',11)
title('Loadings plot')%,'Fontsize',12)

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2
