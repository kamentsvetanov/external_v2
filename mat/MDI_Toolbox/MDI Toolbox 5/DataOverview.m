function varargout = DataOverview(varargin)
% DATAOVERVIEW MATLAB code for DataOverview.fig
%      DATAOVERVIEW, by itself, creates a new DATAOVERVIEW or raises the existing
%      singleton*.
%
%      H = DATAOVERVIEW returns the handle to a new DATAOVERVIEW or the handle to
%      the existing singleton*.
%
%      DATAOVERVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAOVERVIEW.M with the given input arguments.
%
%      DATAOVERVIEW('Property','Value',...) creates a new DATAOVERVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataOverview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataOverview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataOverview

% Last Modified by GUIDE v2.5 06-Oct-2015 13:03:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataOverview_OpeningFcn, ...
                   'gui_OutputFcn',  @DataOverview_OutputFcn, ...
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


% --- Executes just before DataOverview is made visible.
function DataOverview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataOverview (see VARARGIN)

% Choose default command line output for DataOverview
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

stru=evalin('base','MDItoolbox_results');
[obs,vari]=size(stru.X_MD);
perc=100*sum(sum(isnan(stru.X_MD)))/(obs*vari);
set(handles.met, 'String', stru.Method);
set(handles.obs, 'String', num2str(obs));
set(handles.var, 'String', num2str(vari));
set(handles.perc, 'String', num2str(perc));
%clear stru
stru.Percentage_MD=perc;

assignin('base','MDItoolbox_results',stru) 

% UIWAIT makes DataOverview wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataOverview_OutputFcn(hObject, eventdata, handles) 
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

stru=evalin('base','MDItoolbox_results');
X=stru.X_MD;
maxpcs=min(min(size(X)),10);

% Pair-wise estimation of the covariance matrix 
[Sout Rout] = S_pairwise(X);

[u,s,v]=svd(Sout);
diags=diag(s);

for i=1:length(diags)

    diags_acc(i)=100*sum(diags(1:i))/sum(diags);

end

stru.Ini_est_eig=diags;
stru.Ini_est_cum_R2=diags_acc;

assignin('base','MDItoolbox_results',stru) 

NumberComponents


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
MDIgui


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
stru=evalin('base','MDItoolbox_results');
X=stru.X_MD;
pat=isnan(X);
pat=ones(size(X))-pat;

map=[ 1 0 0
    1 1 1];

colormap(map)
imagesc(pat)
title('Missing data pattern')
xlabel('Variables')
ylabel('Observations')
