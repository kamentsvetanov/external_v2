function varargout = NumberComponents(varargin)
% NUMBERCOMPONENTS MATLAB code for NumberComponents.fig
%      NUMBERCOMPONENTS, by itself, creates a new NUMBERCOMPONENTS or raises the existing
%      singleton*.
%
%      H = NUMBERCOMPONENTS returns the handle to a new NUMBERCOMPONENTS or the handle to
%      the existing singleton*.
%
%      NUMBERCOMPONENTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUMBERCOMPONENTS.M with the given input arguments.
%
%      NUMBERCOMPONENTS('Property','Value',...) creates a new NUMBERCOMPONENTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NumberComponents_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NumberComponents_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NumberComponents

% Last Modified by GUIDE v2.5 03-Nov-2015 10:19:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NumberComponents_OpeningFcn, ...
                   'gui_OutputFcn',  @NumberComponents_OutputFcn, ...
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


% --- Executes just before NumberComponents is made visible.
function NumberComponents_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NumberComponents (see VARARGIN)

% Choose default command line output for NumberComponents
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

stru=evalin('base','MDItoolbox_results');
set(handles.popupmenu1,'String',num2cell(1:min(min(size(stru.X_MD)),15))');

% UIWAIT makes NumberComponents wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NumberComponents_OutputFcn(hObject, eventdata, handles) 
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
stru=evalin('base','MDItoolbox_results');

switch stru.Method
    case 'TSR'
        tic
        [X,m,S,It,Tol,Xrec]=pcambtsr(stru.X_MD,stru.PCs,stru.Iterations,stru.Tolerance);
        stru.Computation_time=toc;
    case 'PCR'
        tic
        [X,m,S,It,Tol,Xrec]=pcambpcr(stru.X_MD,stru.PCs,stru.Iterations,stru.Tolerance);
        stru.Computation_time=toc;
    case 'PLS'
        tic
        [X,m,S,It,Tol,Xrec]=pcambpls(stru.X_MD,stru.PCs,stru.Iterations,stru.Tolerance);
        stru.Computation_time=toc;
    case 'KDR'
        tic
        [X,m,S,It,Tol,Xrec]=pcambkdr(stru.X_MD,stru.PCs,stru.Iterations,stru.Tolerance);
        stru.Computation_time=toc;
    case 'PMP'
        tic
        [X,m,S,It,Tol,Xrec]=pcambpmp(stru.X_MD,stru.PCs,stru.Iterations,stru.Tolerance);
        stru.Computation_time=toc;
    case 'IA'
        tic
        [X,m,S,It,Tol,Xrec]=pcambia(stru.X_MD,stru.PCs,stru.Iterations,stru.Tolerance);
        stru.Computation_time=toc;
    case 'NIPALS'
        tic
        [X,m,S,It,Tol,Xrec]=pcambnipals(stru.X_MD,stru.PCs,stru.Iterations,stru.Tolerance);
        stru.Computation_time=toc;
    case 'DA'
        tic,
        [X,m,S,Xrec]=pcambda(stru.X_MD,stru.Num_Markov_Chains,stru.Chain_Length,stru.PCs);
        stru.Computation_time=toc;
        It=[];
        Tol=[];
    otherwise
end

stru.Mean=m;
stru.Covariances=S;
stru.X_imputed=X;
stru.Iterations=It;
stru.Tolerance=Tol;
stru.X_reconstructed=Xrec;

if stru.Method(1:2)=='DA'
    stru.Iterations=[];
    stru.Tolerance=[];
end

assignin('base','MDItoolbox_results',stru)

close
%Calculating
ShowResults


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
pcs = get(handles.popupmenu1,'Value');
stru=evalin('base','MDItoolbox_results');
stru.PCs=pcs;
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


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
DataOverview


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
stru=evalin('base','MDItoolbox_results');
X=stru.X_MD;
maxpcs=min(min(size(X)),10);
diags=stru.Ini_est_eig;


% Scree plot
hold on
plot(diags(1:maxpcs),'LineWidth',2)
plot(diags(1:maxpcs),'.','MarkerSize',15)
%hold
%plot(diags(1:maxpcs),'LineWidth',2)
xlabel('PC number')%,'Fontsize',11)
ylabel('Eigenvalue')%,'Fontsize',11)
title('Scree plot')%,'Fontsize',12)

assignin('base','MDItoolbox_results',stru) % devolvemos la estructura al W

% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2
stru=evalin('base','MDItoolbox_results');
X=stru.X_MD;
maxpcs=min(min(size(X)),10);
diags_acc=stru.Ini_est_cum_R2;


% Plot with the percentages of explained variance
bar(diags_acc(1:maxpcs))
%hold
%bar(diags_acc(1:maxpcs))
xlabel('# of PCs')%,'Fontsize',11)
ylabel('Cum Expl Var')%,'Fontsize',11)
title('% of Explained Variance')%,'Fontsize',12)
axis([0 length(diags_acc(1:maxpcs))+1 0 100])


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3
stru=evalin('base','MDItoolbox_results');
X=stru.X_MD;
maxpcs=min(min(size(X)),10);

Xnew=pcambtri(X);
[u,s,v]=svds(Xnew-repmat(mean(Xnew),size(Xnew,1),1),maxpcs);
T=u*s;P=v;
cumpress = ckf(Xnew-repmat(mean(Xnew),size(Xnew,1),1),T,P);
cumpress=cumpress/cumpress(1);

% Plot with the percentages of explained variance
hold on
plot([0:length(cumpress)-1],cumpress,'LineWidth',2)
plot([0:length(cumpress)-1],cumpress,'.','MarkerSize',15)
xlabel('# of PCs')%,'Fontsize',11)
ylabel('PRESS')%,'Fontsize',11)
title('PCA CV (ckf)')%,'Fontsize',12)
axis([0 maxpcs min(cumpress(1:maxpcs)) max(cumpress(1:maxpcs))])
