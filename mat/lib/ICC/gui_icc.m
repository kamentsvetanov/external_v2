function varargout = gui_icc(varargin)
warning off MATLAB:divideByZero

% GUI_ICC M-file for gui_icc.fig
%      GUI_ICC, by itself, creates a new GUI_ICC or raises the existing
%      singleton*.
%
%      H = GUI_ICC returns the handle to a new GUI_ICC or the handle to
%      the existing singleton*.
%
%      GUI_ICC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ICC.M with the given input arguments.
%
%      GUI_ICC('Property','Value',...) creates a new GUI_ICC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_icc_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_icc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_icc

% Last Modified by GUIDE v2.5 09-Jun-2008 10:03:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_icc_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_icc_OutputFcn, ...
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


% --- Executes just before gui_icc is made visible.
function gui_icc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_icc (see VARARGIN)

% Choose default command line output for gui_icc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_icc wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_icc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupmenu1

%global icc,icc_2A, icc_2A_con,p_icc,p_icc_2A,cv

str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
case 'copy files' 
    copy_files;

case 'mask images'
    mask_img;
    
case 'one sample t'
    ICC_one_sample_t;
    
case 'nii2img'
    nii2img;
    
case 'fisher z map'
    convert_z;

case 'ROI summary stats'
    global ROI_medians ROI_means ROI_max
   [ROI_medians ROI_means ROI_max]=ROI_stats;
    fprintf('ROI_medians variable stored as global variable;\n')
    fprintf('to access in workspace type: >> global ROI_medians; ROI_medians \n')
    
case 'reliability for summary stats'
    global summary
    
    [summary.icc(1),summary.icc_2A(1), summary.icc_2A_con(1),...
    summary.icc(2),summary.icc_2A(2), summary.cv, summary.sigma2w, summary.sigma2e]=ICC_summary; 
    summary.icc_2A_con(2)=summary.icc_2A(2);
    fprintf('\n')
    fprintf('iccs and p-values \n')
    summary
    fprintf('summary variable stored as global variable;\n')
    fprintf('to access in workspace type: >> global summary; summary \n')
    
end;

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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ICC_maps;

% --- Executes during object creation, after setting all properties.
function pushbutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
case 'distributions and medians' 
    global median_ICC Cmp
    [median_ICC Cmp]=ICC_distributions;
    fprintf('median_ICC stored as global variable;\n')
    fprintf('to access in workspace type: >> global median_ICC; median_ICC \n')
    
    
case 'threshold variations'
    global dat
    [dat]=ICC_threshold;
    fprintf('to access plot data: >> global dat; dat \n')

    
case 'intra-voxel reliability'
    global ROI_vICC_2A_con v_ICC_2A_con v_cv
    [ROI_vICC_2A_con v_ICC_2A_con v_cv]=intravoxel_rel;
    fprintf('ROI_vICC_2A_con, v_ICC_2A_con and v_cv stored as global variables;\n')
    fprintf('to access in workspace type: >> global ROI_vICC_2A_con; intra_voxel_ICC \n')

case '*ICC and smoothing'
    global results
    [results]=smooth_ICC;
    fprintf('results store as global variable;\n')
    fprintf('to access in workspace type: >> global results; results \n')
end;



% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


open README.txt;
