function varargout = gui_fl_bayes_IAE_dialog03(varargin)
% gui_fl_bayes_IAE_dialog03 M-file for gui_fl_bayes_IAE_dialog03.fig
%      gui_fl_bayes_IAE_dialog03, by itself, creates a new gui_fl_bayes_IAE_dialog03 or raises the existing
%      singleton*.
%
%      H = gui_fl_bayes_IAE_dialog03 returns the handle to a new gui_fl_bayes_IAE_dialog03 or the handle to
%      the existing singleton*.
%
%      gui_fl_bayes_IAE_dialog03('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in gui_fl_bayes_IAE_dialog03.M with the given input arguments.
%
%      gui_fl_bayes_IAE_dialog03('Property','Value',...) creates a new gui_fl_bayes_IAE_dialog03 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_fl_bayes_IAE_dialog03_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_fl_bayes_IAE_dialog03_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_fl_bayes_IAE_dialog03

% Last Modified by GUIDE v2.5 25-Jan-2005 19:36:51

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_fl_bayes_IAE_dialog03_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_fl_bayes_IAE_dialog03_OutputFcn, ...
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


% --- Executes just before gui_fl_bayes_IAE_dialog03 is made visible.
function gui_fl_bayes_IAE_dialog03_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_fl_bayes_IAE_dialog03 (see VARARGIN)

% Choose default command line output for gui_fl_bayes_IAE_dialog03
handles.output = hObject;
handles.last_individual = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_fl_bayes_IAE_dialog03 wait for user response (see UIRESUME)
% uiwait(handles.fig_fitnessmap);

[img imgmap] = imread('eval_up.jpg');
	b = Show_Image(hObject, eventdata, handles, 'eval_up_axes',img,7,'fig_fitnessmap'); 
	set(b,'ButtonDownFcn','set(findobj(''Tag'',''evaluation_label''),''String'', min(6, 1+str2num(get(findobj(''Tag'',''evaluation_label''),''String''))) );');			
	
	[img imgmap] = imread('eval_down.jpg');
	b = Show_Image(hObject, eventdata, handles, 'eval_down_axes',img,7,'fig_fitnessmap'); 
	set(b,'ButtonDownFcn','set(findobj(''Tag'',''evaluation_label''),''String'', max(-6, -1+str2num(get(findobj(''Tag'',''evaluation_label''),''String''))) );');	

	[img imgmap] = imread('label_amin.jpg');
	b = Show_Image(hObject, eventdata, handles, 'amin_axes',img,7,'fig_fitnessmap'); 
	
	[img imgmap] = imread('label_gmin.jpg');
	b = Show_Image(hObject, eventdata, handles, 'gmin_axes',img,7,'fig_fitnessmap'); 	
	
	[img imgmap] = imread('label_amax.jpg');
	b = Show_Image(hObject, eventdata, handles, 'amax_axes',img,7,'fig_fitnessmap'); 	
	
	[img imgmap] = imread('label_gmax.jpg');
	b = Show_Image(hObject, eventdata, handles, 'gmax_axes',img,7,'fig_fitnessmap'); 	
	
	[img imgmap] = imread('label_anod.jpg');
	b = Show_Image(hObject, eventdata, handles, 'anod_axes',img,7,'fig_fitnessmap'); 	
	
	[img imgmap] = imread('label_sigma.jpg');
	b = Show_Image(hObject, eventdata, handles, 'sigma_axes',img,7,'fig_fitnessmap'); 	
	
	[img imgmap] = imread('label_filter.jpg');
	b = Show_Image(hObject, eventdata, handles, 'filter_axes',img,7,'fig_fitnessmap'); 	

	global mydata;
	config = mydata.config;

	
	if (size(mydata.fitness.map,2) > 0)
		refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	end


% --- Outputs from this function are returned to the command line.
function varargout = gui_fl_bayes_IAE_dialog03_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function fig_fitnessmap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig_fitnessmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function listbox_individuals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_individuals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on selection change in listbox_individuals.
function listbox_individuals_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_individuals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_individuals contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_individuals
global mydata;

content = get(handles.listbox_individuals,'String');

if (size(mydata.fitness.map,2) < 1)
	return;
end


% save previous item
if (handles.last_individual > 0)
	
	if (mydata.config.save_CData_for_fitnessmap == 1)
		mydata.fitness.CData{handles.last_individual} = mydata.images.image(9).CData;
	end
	
	mydata.fitness.map(1,handles.last_individual) = mydata.images.image(9).genotype.amin;
	mydata.fitness.map(2,handles.last_individual) = mydata.images.image(9).genotype.gmin;
	mydata.fitness.map(3,handles.last_individual) = mydata.images.image(9).genotype.amax;
	mydata.fitness.map(4,handles.last_individual) = mydata.images.image(9).genotype.gmax;
	mydata.fitness.map(5,handles.last_individual) = mydata.images.image(9).genotype.anod;
	mydata.fitness.map(6,handles.last_individual) = mydata.images.image(9).genotype.sigma;
	mydata.fitness.map(7,handles.last_individual) = mydata.images.image(9).genotype.filter;
	mydata.fitness.map(8,handles.last_individual) = str2num(get(handles.evaluation_label,'String'));
	%str2num(get(handles.evaluation_label,'String'))
end


indiv_num = get(findobj('Tag','listbox_individuals'),'Value');
handles.last_individual = indiv_num;
guidata(hObject, handles);


mydata.images.image(9).genotype.amin = mydata.fitness.map(1,indiv_num);
mydata.images.image(9).genotype.gmin = mydata.fitness.map(2,indiv_num);
mydata.images.image(9).genotype.amax = mydata.fitness.map(3,indiv_num);
mydata.images.image(9).genotype.gmax = mydata.fitness.map(4,indiv_num);
mydata.images.image(9).genotype.anod = mydata.fitness.map(5,indiv_num);
mydata.images.image(9).genotype.sigma = mydata.fitness.map(6,indiv_num);
mydata.images.image(9).genotype.filter = mydata.fitness.map(7,indiv_num);
indiv_eval = mydata.fitness.map(8,indiv_num);

if (length(mydata.fitness.CData) >= indiv_num)
	indiv_CData = uint8(mydata.fitness.CData{indiv_num});
	mydata.images.image(9).CData = indiv_CData;
else
	mydata.images.image(9) = Denoise(mydata.images.image(9));
	indiv_CData = uint8(mydata.images.image(9).CData);
end


set(handles.evaluation_label,'String',num2str(indiv_eval));
h = Show_Image(hObject, eventdata, handles, 'individual_axes',indiv_CData,7,'fig_fitnessmap');
mydata.images.image(9).handle = h;

config = mydata.config;

refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

% --- Executes on button press in refresh_individuals_button.
function refresh_individuals_button_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_individuals_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

value = min(get(findobj('Tag','listbox_individuals'),'Value'),size(mydata.fitness.map,2));
value = max(value,1);
last_individual = value;
set(findobj('Tag','listbox_individuals'),'Value',value);

if (size(mydata.fitness.map,2)>0)
	set(findobj('Tag','listbox_individuals'),'String',{1:1:size(mydata.fitness.map,2)});
else
	set(findobj('Tag','listbox_individuals'),'String',{'Fitnessmap is empty'});
end

if (size(mydata.fitness.map,2) < 1)
	last_individual = 0;
	return;
end

mydata.images.image(9).CData = mydata.fitness.CData{value};

mydata.images.image(9).genotype.amin = mydata.fitness.map(1,value);
mydata.images.image(9).genotype.gmin = mydata.fitness.map(2,value);
mydata.images.image(9).genotype.amax = mydata.fitness.map(3,value);
mydata.images.image(9).genotype.gmax = mydata.fitness.map(4,value);
mydata.images.image(9).genotype.anod = mydata.fitness.map(5,value);
mydata.images.image(9).genotype.sigma = mydata.fitness.map(6,value);
mydata.images.image(9).genotype.filter = mydata.fitness.map(7,value);


indiv_eval = mydata.fitness.map(8,value);
indiv_CData = uint8(mydata.fitness.CData{value});

set(findobj('Tag','evaluation_label'),'String',num2str(indiv_eval));
h = Show_Image(hObject, eventdata, handles, 'individual_axes',indiv_CData,7,'fig_fitnessmap');
mydata.images.image(9).handle = h;

config = mydata.config;
refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

% --- Executes on button press in delete_individual_button.
function delete_individual_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_individual_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

if (isempty(mydata.fitness.map) == 0)
	mydata.fitness.map(:,handles.last_individual) = [];
	mydata.fitness.CData(handles.last_individual) = [];
	handles.last_individual = max(min(handles.last_individual,size(mydata.fitness.map,2)),1);
	guidata(hObject, handles);
	
	refresh_individuals_button_Callback(hObject, eventdata, handles);
end

refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

% --- Executes on button press in save_individual_button.
function save_individual_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_individual_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

% save previous item
if (handles.last_individual > 0)

	mydata.fitness.CData{handles.last_individual} = mydata.images.image(9).CData;
	mydata.fitness.map(1,handles.last_individual) = mydata.images.image(9).genotype.amin;
	mydata.fitness.map(2,handles.last_individual) = mydata.images.image(9).genotype.gmin;
	mydata.fitness.map(3,handles.last_individual) = mydata.images.image(9).genotype.amax;
	mydata.fitness.map(4,handles.last_individual) = mydata.images.image(9).genotype.gmax;
	mydata.fitness.map(5,handles.last_individual) = mydata.images.image(9).genotype.anod;
	mydata.fitness.map(6,handles.last_individual) = mydata.images.image(9).genotype.sigma;
	mydata.fitness.map(7,handles.last_individual) = mydata.images.image(9).genotype.filter;
	mydata.fitness.map(8,handles.last_individual) = str2num(get(handles.evaluation_label,'String'));
end

config = mydata.config;
if (size(mydata.fitness.map,2) > 0)
	refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
end

refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

% --- Executes during object creation, after setting all properties.
function evaluation_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to evaluation_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function evaluation_edit_Callback(hObject, eventdata, handles)
% hObject    handle to evaluation_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of evaluation_edit as text
%        str2double(get(hObject,'String')) returns contents of evaluation_edit as a double


% --- Executes on button press in edit_genotype_button.
function edit_genotype_button_Callback(hObject, eventdata, handles)
% hObject    handle to edit_genotype_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

content = get(handles.listbox_individuals,'String');

if (strcmp(content{1},'1') == 0)
	return;
end

mydata.images.analysedimage = 9;


img_num = mydata.images.analysedimage;
mydata.images.image(8) = mydata.images.image(img_num);


% Save current handles for later recall
set(gui_fl_bayes_IAE_dialog01,'UserData',handles);


set(findobj('Tag','edit_sigma'),'String',mydata.images.image(img_num).genotype.sigma);
set(findobj('Tag','edit_amin'),'String',mydata.images.image(img_num).genotype.amin);
set(findobj('Tag','edit_gamin'),'String',mydata.images.image(img_num).genotype.gmin);
set(findobj('Tag','edit_amax'),'String',mydata.images.image(img_num).genotype.amax);
set(findobj('Tag','edit_gamax'),'String',mydata.images.image(img_num).genotype.gmax);
set(findobj('Tag','edit_anod'),'String',mydata.images.image(img_num).genotype.anod);

filter_indices = get(findobj('Tag','listbox_wavelet'),'UserData');
filternum = mydata.images.image(img_num).genotype.filter;

[val, pos] = intersect(filter_indices,filternum);

set(findobj('Tag','listbox_wavelet'),'Value',pos);

show_spectrum(hObject,eventdata,handles,'spectrum_axes','fig_adjust');
h = Show_Image(hObject, eventdata, handles, 'preview_axes',mydata.images.image(mydata.images.analysedimage).CData,7,'fig_adjust');
%set(h,'ButtonDownFcn',@Enlarge_Image);
set(h,'ButtonDownFcn',{@Enlarge_Image,img_num});


% --- Executes on mouse press on fitness plot.
function fitnessplot_ButtonDownFcn(hObject, eventdata, handles, Index)
% hObject    handle to statistics_axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%disp('clicked a gene');
%[x,y] = ginput(0)
set(findobj('Tag','listbox_individuals'),'Value',Index);
listbox_individuals_Callback(hObject, eventdata, handles);


% --- Executes on mouse press on ranges line.
function user_ranges_ButtonDownFcn(hObject, eventdata, handles, Index, Border)
% hObject    handle to statistics_axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;
config = mydata.config;


axes_position = get(gca,'Position');
axes_start_point = get(gca,'CurrentPoint');
fig_start_point = get(gcf,'CurrentPoint'); 

rect = [fig_start_point(1,1) fig_start_point(1,2)-30 2 60];
rect_end_position = dragrect(rect);

axes_range = get(gca,'XLim');

rect_end_position(1) = min(max(rect_end_position(1),axes_position(1)),axes_position(1)+axes_position(3));

value = scale_value(rect_end_position(1), axes_position(1), axes_position(1)+axes_position(3), axes_range(1), axes_range(2));
	
if (Border == 1 && value<mydata.config.user_prefered_regions(2,Index))
	
	% refresh mydata
	mydata.config.user_prefered_regions(1,Index) = value;
		
elseif (Border == 2 && value>mydata.config.user_prefered_regions(1,Index))
		
	% refresh mydata
	mydata.config.user_prefered_regions(2,Index) = value;
		
end


refresh_ranges(handles, Index, {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});



function refresh_ranges(handles, genes, XLimits)

global mydata;

for i=1:1:length(genes)
		
	H_axes = bringup_axes(handles, ['statistics_axes' num2str(genes(i))]);
	
	%disp(['affected axes:' num2str(genes(i))]);

	userdata = get(H_axes,'UserData');
	if (isempty(userdata) == 0)
		if (ishandle(userdata(1)) == 1)
			delete(userdata(1));
		end
		
		if (ishandle(userdata(2)) == 1)
			delete(userdata(2));
		end
	end
	
	if (get(handles.user_constraints_checkbox1,'Value') == 1)

		gene_limits = XLimits{genes(i)};
		bandwith = gene_limits(2) - gene_limits(1);
		
		axes_pos = get(H_axes,'Position');
		
		range_start = max(mydata.config.user_prefered_regions(1,genes(i)),gene_limits(1));
		range_end = min(mydata.config.user_prefered_regions(2,genes(i)),gene_limits(2));
		
		
		H_line1 = line([range_start+bandwith/20,range_start,range_start,range_start+bandwith/20],[-7,-7,7,7], 'LineWidth', 4, 'Color',[0.5,0.5,1]);
		set(H_line1,'ButtonDownFcn',{@user_ranges_ButtonDownFcn, handles, genes(i), 1});	

		H_line2 = line([range_end-bandwith/20,range_end,range_end,range_end-bandwith/20],[-7,-7,7,7], 'LineWidth', 4, 'Color',[0.5,0.5,1]);
		set(H_line2,'ButtonDownFcn',{@user_ranges_ButtonDownFcn, handles, genes(i), 2});			
		
		set(H_axes,'UserData',[H_line1,H_line2]);
		
	end
		

end



% --- plot all genes at once
function refresh_genes(handles, genes, XLimits)

global mydata;

handles.last_individual = max(min(handles.last_individual,size(mydata.fitness.map,2)),1);



for i=1:1:length(genes)
	[H_plots, H_axes, Index] = plot_gene(handles, ['statistics_axes' num2str(genes(i))], 'fitness_trend_checkbox1', 'sharing_trend_checkbox1', 'sharing_fitness_trend_checkbox1', 1, 1, mydata.fitness.map(genes(i),:), mydata.fitness.map(8,:), XLimits{genes(i)}, 'p', [1,0,0], 5, [1,0.1,0.1], [0.0 0.0 0.2], '-r',1, '-y',1, '-g',1);
	%set(H_axes,'ButtonDownFcn',{@axes_ButtonDownFcn, handles, i});	
	
	for indiv=1:1:length(H_plots)
		set(H_plots(indiv),'ButtonDownFcn',{@fitnessplot_ButtonDownFcn, handles, Index(indiv)});
	end
	
	if (handles.last_individual > 0)
		[H_plots, H_axes, Index] = plot_gene(handles, ['statistics_axes' num2str(genes(i))], 'fitness_trend_checkbox1', 'sharing_trend_checkbox1', 'sharing_fitness_trend_checkbox1', 0, 0, mydata.fitness.map(genes(i),handles.last_individual), mydata.fitness.map(8,handles.last_individual), XLimits{i}, 'p', [1,1,0], 8, [1,0.9,0.1], [0.0 0.0 0.2], '-r',1, '-y',1, '-g',1);
		set(H_plots,'ButtonDownFcn',{@fitnessplot_ButtonDownFcn, handles, handles.last_individual});	
	end
	
	
end


% --- Executes on button press in fitness_trend_checkbox1.
function fitness_trend_checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to fitness_trend_checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fitness_trend_checkbox1

	global mydata;
	config = mydata.config;
	
	if (size(mydata.fitness.map,2) > 0)
		refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	end

	refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	
% --- Executes on button press in sharing_trend_checkbox1.
function sharing_trend_checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to sharing_trend_checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sharing_trend_checkbox1

	global mydata;
	config = mydata.config;
	
	if (size(mydata.fitness.map,2) > 0)
	refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	end
	
	refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

% --- Executes on button press in sharing_fitness_trend_checkbox1.
function sharing_fitness_trend_checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to sharing_fitness_trend_checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sharing_fitness_trend_checkbox1


	global mydata;
	config = mydata.config;
	
	if (size(mydata.fitness.map,2) > 0)
	refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	end
	
	refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

% --- Executes on button press in user_constraints_checkbox1.
function user_constraints_checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to user_constraints_checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of user_constraints_checkbox1



	global mydata;
	config = mydata.config;
	
	refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

