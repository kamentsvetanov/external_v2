function varargout = gui_fl_bayes_IAE_dialog04(varargin)
% gui_fl_bayes_IAE_dialog04 M-file for gui_fl_bayes_IAE_dialog04.fig
%      gui_fl_bayes_IAE_dialog04, by itself, creates a new gui_fl_bayes_IAE_dialog04 or raises the existing
%      singleton*.
%
%      H = gui_fl_bayes_IAE_dialog04 returns the handle to a new gui_fl_bayes_IAE_dialog04 or the handle to
%      the existing singleton*.
%
%      gui_fl_bayes_IAE_dialog04('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in gui_fl_bayes_IAE_dialog04.M with the given input arguments.
%
%      gui_fl_bayes_IAE_dialog04('Property','Value',...) creates a new gui_fl_bayes_IAE_dialog04 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_fl_bayes_IAE_dialog04_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_fl_bayes_IAE_dialog04_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_fl_bayes_IAE_dialog04

% Last Modified by GUIDE v2.5 26-Jan-2005 01:53:50

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_fl_bayes_IAE_dialog04_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_fl_bayes_IAE_dialog04_OutputFcn, ...
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


% --- Executes just before gui_fl_bayes_IAE_dialog04 is made visible.
function gui_fl_bayes_IAE_dialog04_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_fl_bayes_IAE_dialog04 (see VARARGIN)

% Choose default command line output for gui_fl_bayes_IAE_dialog04
handles.output = hObject;
handles.last_individual = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_fl_bayes_IAE_dialog04 wait for user response (see UIRESUME)
% uiwait(handles.fig_populationmap);

	[img imgmap] = imread('label_amin.jpg');
	b = Show_Image(hObject, eventdata, handles, 'population_amin_axes',img,7,'fig_populationmap'); 
	
	[img imgmap] = imread('label_gmin.jpg');
	b = Show_Image(hObject, eventdata, handles, 'population_gmin_axes',img,7,'fig_populationmap'); 	
	
	[img imgmap] = imread('label_amax.jpg');
	b = Show_Image(hObject, eventdata, handles, 'population_amax_axes',img,7,'fig_populationmap'); 	
	
	[img imgmap] = imread('label_gmax.jpg');
	b = Show_Image(hObject, eventdata, handles, 'population_gmax_axes',img,7,'fig_populationmap'); 	
	
	[img imgmap] = imread('label_anod.jpg');
	b = Show_Image(hObject, eventdata, handles, 'population_anod_axes',img,7,'fig_populationmap'); 	
	
	[img imgmap] = imread('label_sigma.jpg');
	b = Show_Image(hObject, eventdata, handles, 'population_sigma_axes',img,7,'fig_populationmap'); 	
	
	[img imgmap] = imread('label_filter.jpg');
	b = Show_Image(hObject, eventdata, handles, 'population_filter_axes',img,7,'fig_populationmap'); 	

	global mydata;
	config = mydata.config;
	
	if (size(mydata.fitness.map,2) > 0)
	refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	end

	
% --- Outputs from this function are returned to the command line.
function varargout = gui_fl_bayes_IAE_dialog04_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function fig_populationmap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig_populationmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function listbox_population_individuals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_population_individuals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on selection change in listbox_population_individuals.
function listbox_population_individuals_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_population_individuals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_population_individuals contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_population_individuals
global mydata;


if (handles.last_individual > 0)

	mydata.population.individuals(handles.last_individual).genotype.amin = mydata.images.image(10).genotype.amin;
	mydata.population.individuals(handles.last_individual).genotype.gmin = mydata.images.image(10).genotype.gmin;
	mydata.population.individuals(handles.last_individual).genotype.amax = mydata.images.image(10).genotype.amax;
	mydata.population.individuals(handles.last_individual).genotype.gmax = mydata.images.image(10).genotype.gmax;
	mydata.population.individuals(handles.last_individual).genotype.anod = mydata.images.image(10).genotype.anod;
	mydata.population.individuals(handles.last_individual).genotype.sigma = mydata.images.image(10).genotype.sigma;
	mydata.population.individuals(handles.last_individual).genotype.filter = mydata.images.image(10).genotype.filter;
	
end

	value = get(findobj('Tag','listbox_population_individuals'),'Value');	

	mydata.images.image(10).genotype.amin   = mydata.population.individuals(value).genotype.amin;
	mydata.images.image(10).genotype.gmin   = mydata.population.individuals(value).genotype.gmin;
	mydata.images.image(10).genotype.amax   = mydata.population.individuals(value).genotype.amax;
	mydata.images.image(10).genotype.gmax   = mydata.population.individuals(value).genotype.gmax;
	mydata.images.image(10).genotype.anod   = mydata.population.individuals(value).genotype.anod;
	mydata.images.image(10).genotype.sigma  = mydata.population.individuals(value).genotype.sigma;
	mydata.images.image(10).genotype.filter = mydata.population.individuals(value).genotype.filter;

if (get(findobj('Tag','denoise_checkbox'),'Value') == 1)
		mydata.images.image(10) = Denoise(mydata.images.image(10));
		h = Show_Image(hObject, eventdata, handles, 'population_axes',mydata.images.image(10).CData,7,'fig_populationmap');
		mydata.images.image(10).handle = h;
end

handles.last_individual = value;
guidata(hObject, handles);

indiv_eval = mydata.population.individuals(value).fitness;
set(findobj('Tag','population_evaluation_label'),'String',num2str(indiv_eval));

config = mydata.config;
refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

% --- Executes on button press in refresh_population_individuals_button.
function refresh_population_individuals_button_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_population_individuals_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

value = min(get(findobj('Tag','listbox_population_individuals'),'Value'), mydata.config.evol_population_size);
value = max(value,1);
last_individual = value;
set(findobj('Tag','listbox_population_individuals'),'Value',value);

if (size(mydata.population.individuals,2)>0)
	
	listbox_string = [];
	for i=1:1:length(mydata.population.individuals)
		listbox_string{i} = [num2str(i)];
		if (mydata.population.individuals(i).bound_image_number > 0)
			if (mydata.population.individuals(i).is_locked == 1)
				listbox_string{i} = [listbox_string{i} ' (Image ' num2str(mydata.population.individuals(i).bound_image_number-1) ' ,locked)'];
			else
				listbox_string{i} = [listbox_string{i} ' (Image ' num2str(mydata.population.individuals(i).bound_image_number-1) ')'];
			end
		end
	end
	
	set(findobj('Tag','listbox_population_individuals'),'String',listbox_string);
	
	mydata.images.image(10).genotype.amin = mydata.population.individuals(value).genotype.amin;
	mydata.images.image(10).genotype.gmin = mydata.population.individuals(value).genotype.gmin;
	mydata.images.image(10).genotype.amax = mydata.population.individuals(value).genotype.amax;
	mydata.images.image(10).genotype.gmax = mydata.population.individuals(value).genotype.gmax;
	mydata.images.image(10).genotype.anod = mydata.population.individuals(value).genotype.anod;
	mydata.images.image(10).genotype.sigma = mydata.population.individuals(value).genotype.sigma;
	mydata.images.image(10).genotype.filter = mydata.population.individuals(value).genotype.filter;

	% pack EAStruct
	EAStruct.Individuals = mydata.population.individuals;
	EAStruct.Fitness = mydata.fitness;
	EAStruct.Config = mydata.config;

	% evaluate the population
	EAStruct = EA_Fitness(EAStruct);

	% unpack EAStruct
	mydata.population.individuals = EAStruct.Individuals;
	
	indiv_eval = mydata.population.individuals(value).fitness;

	set(findobj('Tag','population_evaluation_label'),'String',num2str(indiv_eval));
	
	if (get(findobj('Tag','denoise_checkbox'),'Value') == 1)
		mydata.images.image(10) = Denoise(mydata.images.image(10));
		h = Show_Image(hObject, eventdata, handles, 'population_axes',mydata.images.image(10).CData,7,'fig_populationmap');
		mydata.images.image(10).handle = h;
	end
	
	config = mydata.config;
	refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	
end



% --- Executes on button press in edit_population_genotype_button.
function edit_population_genotype_button_Callback(hObject, eventdata, handles)
% hObject    handle to edit_population_genotype_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;


if (get(findobj('Tag','denoise_checkbox'),'Value') == 0)
		mydata.images.image(10) = Denoise(mydata.images.image(10));
		h = Show_Image(hObject, eventdata, handles, 'population_axes',mydata.images.image(10).CData,7,'fig_populationmap');
		mydata.images.image(10).handle = h;
end


mydata.images.analysedimage = 10;


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


% --- Executes during object creation, after setting all properties.
function population_distance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to population_distance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function population_distance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to population_distance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of population_distance_edit as text
%        str2double(get(hObject,'String')) returns contents of population_distance_edit as a double


% --- Executes during object creation, after setting all properties.
function population_weighted_evaluation_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to population_weighted_evaluation_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function population_weighted_evaluation_edit_Callback(hObject, eventdata, handles)
% hObject    handle to population_weighted_evaluation_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of population_weighted_evaluation_edit as text
%        str2double(get(hObject,'String')) returns contents of population_weighted_evaluation_edit as a double


% --- Executes on button press in denoise_checkbox.
function denoise_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to denoise_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of denoise_checkbox
listbox_population_individuals_Callback(hObject, eventdata, handles);

% --- Executes on mouse press over axes background.
function fitnessplot_ButtonDownFcn(hObject, eventdata, handles, Index)
% hObject    handle to statistics_axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%disp('clicked a gene');
%[x,y] = ginput(0)
set(findobj('Tag','listbox_population_individuals'),'Value',Index);
listbox_population_individuals_Callback(hObject, eventdata, handles);



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
		
	H_axes = bringup_axes(handles, ['population_statistics_axes' num2str(genes(i))]);
	
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
	
	if (get(handles.user_constraints_checkbox2,'Value') == 1)

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

if (length(mydata.population.individuals) < 1)
	return;
end

map = [];	
for n=1:1:length(mydata.population.individuals)
	map(1,n) = 	mydata.population.individuals(n).genotype.amin;			
	map(2,n) = 	mydata.population.individuals(n).genotype.gmin;			
	map(3,n) = 	mydata.population.individuals(n).genotype.amax;			
	map(4,n) = 	mydata.population.individuals(n).genotype.gmax;			
	map(5,n) = 	mydata.population.individuals(n).genotype.anod;			
	map(6,n) = 	mydata.population.individuals(n).genotype.sigma;			
	map(7,n) = 	mydata.population.individuals(n).genotype.filter;	
	map(8,n) = 	mydata.population.individuals(n).fitness;			
end	

for i=1:1:length(genes)
	
	[H_plots, H_axes, Index] = plot_gene(handles, ['population_statistics_axes' num2str(genes(i))], 'fitness_trend_checkbox2', 'sharing_trend_checkbox2', 'sharing_fitness_trend_checkbox2', 1, 1, map(genes(i),:), map(8,:), XLimits{i}, 'p', [1,0,0], 5, [1,0.1,0.1], [0.0 0.0 0.2], '-r',1, '-y',1, '-g',1);
	
	for indiv=1:1:length(H_plots)
		set(H_plots(indiv),'ButtonDownFcn',{@fitnessplot_ButtonDownFcn, handles, Index(indiv)});
	end
	
	if (handles.last_individual > 0)
		[H_plots, H_axes, Index] = plot_gene(handles, ['population_statistics_axes' num2str(genes(i))], 'fitness_trend_checkbox2', 'sharing_trend_checkbox2', 'sharing_fitness_trend_checkbox2', 0, 0, map(genes(i),handles.last_individual), map(8,handles.last_individual), XLimits{i}, 'p', [1,1,0], 8, [1,0.9,0.1], [0.0 0.0 0.2], '-r',1, '-y',1, '-g',1);
		set(H_plots,'ButtonDownFcn',{@fitnessplot_ButtonDownFcn, handles, handles.last_individual});	
	end
	
	
	
end


% --- Executes on button press in fitness_trend_checkbox2.
function fitness_trend_checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to fitness_trend_checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fitness_trend_checkbox2

	global mydata;
	config = mydata.config;
	
	if (length(mydata.population.individuals) > 0)
		refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
		refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	end

% --- Executes on button press in sharing_trend_checkbox2.
function sharing_trend_checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to sharing_trend_checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sharing_trend_checkbox2

	global mydata;
	config = mydata.config;
	
	if (length(mydata.population.individuals) > 0)
		refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
		refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	end


% --- Executes on button press in sharing_fitness_trend_checkbox2.
function sharing_fitness_trend_checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to sharing_fitness_trend_checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sharing_fitness_trend_checkbox2


	global mydata;
	config = mydata.config;
	
	if (length(mydata.population.individuals) > 0)
		refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
		refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	end


% --- Executes on button press in save_population_individual_button.
function save_population_individual_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_population_individual_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

if (handles.last_individual > 0)
	mydata.population.individuals(handles.last_individual).genotype.amin = mydata.images.image(10).genotype.amin;
	mydata.population.individuals(handles.last_individual).genotype.gmin = mydata.images.image(10).genotype.gmin;
	mydata.population.individuals(handles.last_individual).genotype.amax = mydata.images.image(10).genotype.amax;
	mydata.population.individuals(handles.last_individual).genotype.gmax = mydata.images.image(10).genotype.gmax;
	mydata.population.individuals(handles.last_individual).genotype.anod = mydata.images.image(10).genotype.anod;
	mydata.population.individuals(handles.last_individual).genotype.sigma = mydata.images.image(10).genotype.sigma;
	mydata.population.individuals(handles.last_individual).genotype.filter = mydata.images.image(10).genotype.filter;
end

config = mydata.config;
if (length(mydata.population.individuals) > 0)
	refresh_genes(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
	refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
end
	
% --- Executes on button press in delete_population_individual_button.
function delete_population_individual_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_population_individual_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;
config = mydata.config;

if (handles.last_individual <= 0)
return;
end
                 
if (length(mydata.population.individuals) > mydata.config.image_count && mydata.population.individuals(handles.last_individual).bound_image_number<=0)
	mydata.population.individuals(handles.last_individual) = [];
	mydata.config.evol_population_size = mydata.config.evol_population_size -1;
	handles.last_individual = max(min(handles.last_individual,mydata.config.evol_population_size),1);
	guidata(hObject, handles);
	
	refresh_population_individuals_button_Callback(hObject, eventdata, handles)
	refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});
end

% --- Executes on button press in insert_population_individual_button.
function insert_population_individual_button_Callback(hObject, eventdata, handles)
% hObject    handle to insert_population_individual_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;
config = mydata.config;

mydata.config.evol_population_size = mydata.config.evol_population_size +1;

mydata.population.individuals(mydata.config.evol_population_size) = mydata.population.individuals(1);
mydata.population.individuals(mydata.config.evol_population_size).is_locked = 0;
mydata.population.individuals(mydata.config.evol_population_size).bound_image_number = 0;
mydata.population.individuals(mydata.config.evol_population_size).genotype = evol_init;

handles.last_individual = mydata.config.evol_population_size;
guidata(hObject, handles);

refresh_population_individuals_button_Callback(hObject, eventdata, handles)
refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over denoise_checkbox.
function denoise_checkbox_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to denoise_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in user_constraints_checkbox2.
function user_constraints_checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to user_constraints_checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of user_constraints_checkbox2



	global mydata;
	config = mydata.config;
	
	refresh_ranges(handles, [1,2,3,4,5,6,7], {[config.evol_amin_min,config.evol_amin_max],[config.evol_gmin_min,config.evol_gmin_max],[config.evol_amax_min,config.evol_amax_max],[config.evol_gmax_min,config.evol_gmax_max],[config.evol_anod_min,config.evol_anod_max],[config.evol_sigma_min,config.evol_sigma_max],[1,9]});

