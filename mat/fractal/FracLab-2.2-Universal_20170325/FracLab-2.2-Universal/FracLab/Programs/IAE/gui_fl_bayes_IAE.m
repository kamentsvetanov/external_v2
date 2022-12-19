function varargout = gui_fl_bayes_IAE(varargin)
% gui_fl_bayes_iae M-file for gui_fl_bayes_IAE.fig
%      gui_fl_bayes_iae, by itself, creates a new gui_fl_bayes_iae or
%      raises the existing
%      singleton*.
%
%      H = gui_fl_bayes_iae returns the handle to a new gui_fl_bayes_iae or
%      the handle to
%      the existing singleton*.
%
%      gui_fl_bayes_iae('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in gui_fl_bayes_iae.M with the given input arguments.
%
%      gui_fl_bayes_iae('Property','Value',...) creates a new gui_fl_bayes_iae or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_fl_bayes_IAE_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to gui_fl_bayes_IAE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_fl_bayes_IAE

% Last Modified by GUIDE v2.5 16-Feb-2005 23:03:38
% Modified by Olivier Barrière, September 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
	'gui_Singleton',  gui_Singleton, ...
	'gui_OpeningFcn', @gui_fl_bayes_IAE_OpeningFcn, ...
	'gui_OutputFcn',  @gui_fl_bayes_IAE_OutputFcn, ...
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


% --- Executes just before gui_fl_bayes_IAE is made visible.
function gui_fl_bayes_IAE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_fl_bayes_IAE (see VARARGIN)

% Choose default command line output for gui_fl_bayes_IAE
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_fl_bayes_IAE wait for user response (see UIRESUME)
% uiwait(handles.fig_main);

%%%%%%% opened by FracLab or not


global open_mode
open_mode='Stand_alone';
t=findobj('Tag','FRACLAB Toolbox');
if ~isempty(t)
   ud=get(findobj('Tag','FRACLAB Toolbox'),'UserData');
   if isfield(ud,'Opened_by_fraclab')
       if ud.Opened_by_fraclab
           open_mode = 'Opened_by_fraclab';
       end
   end
end

fl_window_init(hObject,'NoTheme'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


global mydata;
mydata = struct('images',struct('currentimage',-1,'filename','','analysedimage',-1,'colormap',-1,'changed_evaluations',[2,3,4,5,6,7], ...
	'image',struct('handle',-1,'RGB',7,'CData',0, 'WT',-1, ...
	'genotype', struct('amin',0, 'gmin',0, 'amax',4, 'gmax',1, 'anod',0.001, 'sigma',1,'filter',4), ...
	'evol_individualID',0, ...
	'panels',struct('statistics', []), ...
	'current_statistics_panel',0)), ...
	'config',struct('button_red_on',[1,0.35,0.35], ...
	'button_red_off',[1,0.65,0.65], ...
	'button_green_on',[0.23,1,0.23], ...
	'button_green_off',[0.65,1,0.65], ...
	'button_blue_on',[0.23,0.5,1], ...
	'button_blue_off',[0.65,0.65,1], ...
	'write_statistics_2_file', 0, ...
	'statistics_filename', 'output.txt', ...
	'frac_spectrum_max_coeff',3.5, ...
	'frac_spectrum_values',400, ...
	'evaluation_bigger_is_better',1, ...
	'image_count', 6, ...
	'evol_amin_min',0, ...
	'evol_amin_max',0.5, ...
	'evol_gmin_min',0, ...
	'evol_gmin_max',1, ...
	'evol_anod_min',0.001, ...
	'evol_anod_max',0.9, ...
	'evol_amax_min',0.01, ...
	'evol_amax_max',15, ...
	'evol_gmax_min',0.4, ...
	'evol_gmax_max',1, ...
	'evol_filters',[1,2,3,4,5,6,7], ...
	'evol_sigma_min',0.0001, ...
	'evol_sigma_max',50, ...
	'evol_amin_mutation',0.1, ...
	'evol_gmin_mutation',0.2, ...
	'evol_anod_mutation',0.1, ...
	'evol_amax_mutation',0.2, ...
	'evol_gmax_mutation',0.2, ...
	'evol_sigma_mutation',0.2, ...
	'evol_filter_mutation',0.2, ...
	'evol_do_mutation', 0.8, ...
	'evol_do_random_mutation',0.8, ...
	'evol_do_prefered_area_directed_mutation',1, ...
	'evol_do_prefered_area_directed_mutation_plus_random_mutation',1, ...
	'eval_do_crossover', 1, ...
	'evol_do_random_crossover',2, ...
	'evol_do_swapping_crossover',1, ...
	'evol_do_factory_crossover',4, ...
	'evol_population_size', 10, ...
	'evol_fitness_method', 'interpolation', ...
	'evol_parent_selection_method', 'fittest', ...
	'evol_offspring_selection_method', 'fittest', ...
	'evol_offspring_selection_weighted_fitness', 1, ...
	'evol_roulette_distinct_individuals', '1', ...
	'evol_fittest_distinct_individuals', '1', ...
	'evol_fittest_parent_distinct_individuals', 1, ...
	'evol_fittest_offspring_distinct_individuals', 1, ...
	'evol_roulette_parent_distinct_individuals', 1, ...
	'evol_roulette_offspring_distinct_individuals', 1, ...
	'evol_image_selection_method', 'fittest', ...
	'evol_fittest_image_distinct_individuals', '1', ...
	'evol_roulette_image_distinct_individuals', '1', ...
	'evol_generation_gap', 13, ...
	'save_CData_for_fitnessmap', 1, ...
    'evol_disable_fitnessmap', 1, ...
	'user_prefered_regions', [0 0 0.01 0.2 0.0001 0.1 1; 0.5 1 20 1 2 100 9], ...
	'slider_color_red'	,[1.0, 0.9,	0.8, 0.75	,	0.7	, 0.65, 0.5, 0.4	, 0.3, 0.2	, 0.1, 0.0, 0.0], ...
	'slider_color_green',[0.0, 0.0,	0.1, 0.2	,	0.3	, 0.4	, 0.5, 0.65	, 0.7, 0.75	, 0.8, 0.9, 1.0], ...
	'slider_color_blue'	,[0.0, 0.0,	0.1, 0.2	,	0.3	, 0.4	, 1.0, 0.4	, 0.3, 0.2	, 0.1, 0.0, 0.0], ...
	'history_statistics_size', 30, ...
	'population_statistics_1', 'cell2struct({''Variance'',''image_variance''},{''name'',''function''},2)', ...
	'population_statistics_2', 'cell2struct({''NAME3'',3;''NAME4'',4},{''name'',''function''},2)', ...
	'population_statistics_heading_1', '''Phenotype:''', ...
	'population_statistics_heading_2', '''Genotype:''', ...
	'population_statistics_panel_color', 0, ...
	'population_statistics_text_color','b', ...
	'population_statistics_text_background_color','w'), ...
	'history',struct('population', [], ...
	'fitnessmap', [], ...
	'images', [], ...
	'current_genotype', 0, ...
	'distance',[], ...
	'phenotype_distance',[], ...
	'population_distance',[], ...
	'variance',[], ...
	'deviation',[]), ...
	'fitness',struct('map',[],'CData',[]), ...
	'population',struct('individuals', struct('is_locked',0, 'bound_image_number',0, 'fitness', 0, 'sharing',0, 'genotype',struct('amin',0, 'gmin',0, 'amax',4, 'gmax',1, 'anod',0.001, 'sigma',1,'filter',4))));



[img_history_back imgmap] = imread('history_back_empty.jpg');
b = Show_Image(hObject, eventdata, handles, 'history_back_axes',img_history_back,7,'fig_main');
set(b,'ButtonDownFcn',{@query_genotype_history, handles, -1});

[img_history_forward imgmap] = imread('history_forward_empty.jpg');
b = Show_Image(hObject, eventdata, handles, 'history_forward_axes',img_history_forward,7,'fig_main');
set(b,'ButtonDownFcn',{@query_genotype_history, handles, 1});


attribute_axes_1 = {'attributes11_axes';'attributes21_axes';'attributes31_axes';'attributes41_axes';'attributes51_axes';'attributes61_axes';'attributes71_axes'};
attribute_axes_2 = {'attributes12_axes';'attributes22_axes';'attributes32_axes';'attributes42_axes';'attributes52_axes';'attributes62_axes';'attributes72_axes'};

img = imread('statistics1.bmp');
for i=1:1:size(attribute_axes_1,1)
	b = Show_Image(hObject, eventdata, handles, cell2mat(attribute_axes_1(i)) ,img,7,'fig_main');
 
	set(b,'ButtonDownFcn',{@attributes_axes_ButtonDownFcn, handles});
	set(b,'UserData',get(findobj(handles.output,'Tag',cell2mat(attribute_axes_1(i))),'UserData'));
end

img = imread('statistics2.bmp');
for i=1:1:size(attribute_axes_2,1)
	b = Show_Image(hObject, eventdata, handles, cell2mat(attribute_axes_2(i)) ,img,7,'fig_main');	
    set(b,'ButtonDownFcn',{@attributes_axes_ButtonDownFcn, handles});
	set(b,'UserData',get(findobj(handles.output,'Tag',cell2mat(attribute_axes_2(i))),'UserData'));
end


img =  imread('changed2.bmp');
for i=2:1:7
	b = Show_Image(hObject, eventdata, handles, ['axes' num2str(i) '_changed'] ,img,7,'fig_main');
	h = findobj(handles.output,'Tag',['axes' num2str(i) '_changed']);
	set(h,'UserData',b);
	set(b,'Visible','off');
end

img =  imread('unlocked_image.bmp');
for i=2:1:7
	b = Show_Image(hObject, eventdata, handles, ['lock_image_axes' num2str(i)] ,img,7,'fig_main');
	set(b,'ButtonDownFcn',{@lock_image_ButtonDownFcn, handles});
	set(b,'UserData',[i, 0]);
end
M_refresh_settings_from_file_Callback(hObject, eventdata, handles);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (strcmp(open_mode,'Opened_by_fraclab'))
	[InputName error_in] = fl_get_input ('matrix') ;
    
    try
        eval(['global ',InputName]) ;
        SigIn = eval(InputName) ;
        [img,imgmap] = gray2ind(SigIn);
        img = ind2rgb(img,imgmap);
        img = im2uint8(img);
        mydata.images.image.CData = img;
        h = Show_Image(hObject, eventdata, handles, 'axes1',mydata.images.image.CData,7,'fig_main');
    catch
        open_mode = 'Something went wrong!';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Initialize the population
for i=1:1:mydata.config.evol_population_size
	mydata.population.individuals(i) = mydata.population.individuals(1);
	mydata.population.individuals(i).genotype = evol_init(mydata.images.image.genotype);
end

mydata.images.image(2) = mydata.images.image(1);
mydata.images.image(3) = mydata.images.image(1);
mydata.images.image(4) = mydata.images.image(1);
mydata.images.image(5) = mydata.images.image(1);
mydata.images.image(6) = mydata.images.image(1);
mydata.images.image(7) = mydata.images.image(1);

% for temporary usage:
mydata.images.image(8) = mydata.images.image(1);
mydata.images.image(9) = mydata.images.image(1);
mydata.images.image(10) = mydata.images.image(1);

% pick out 6 genotypes to show the user
for i=2:1:7
	mydata.images.image(i).genotype = mydata.population.individuals(i-1).genotype;
	mydata.images.image(i).evol_individualID = i-1;
	mydata.population.individuals(i-1).bound_image_number = i;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(open_mode,'Opened_by_fraclab')
	M_randomize_genotype_Callback(hObject, eventdata, handles);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Function to Refresh the History Buttons (Back & Forward)
function refresh_genotype_history_buttons(hObject, eventdata, handles)
global mydata;

if (mydata.history.current_genotype <= 1)
	[img_history_back imgmap] = imread('history_back_empty.jpg');
else
	[img_history_back imgmap] = imread('history_back.jpg');
end

if (mydata.history.current_genotype >= size(mydata.history.images,2))
	[img_history_forward imgmap] = imread('history_forward_empty.jpg');
else
	[img_history_forward imgmap] = imread('history_forward.jpg');
end

b = Show_Image(hObject, eventdata, handles, 'history_back_axes',img_history_back,7,'fig_main');
set(b,'ButtonDownFcn',{@query_genotype_history, handles, -1});

b = Show_Image(hObject, eventdata, handles, 'history_forward_axes',img_history_forward,7,'fig_main');
set(b,'ButtonDownFcn',{@query_genotype_history, handles, 1});

set(handles.history_position,'String',[num2str(mydata.history.current_genotype) '/' num2str(length(mydata.history.images))]);


% --- Go forth and back in the genotypehistory
function query_genotype_history(hObject, eventdata, handles, direction)
global mydata;

if (mydata.history.current_genotype + direction > size(mydata.history.images,2) | mydata.history.current_genotype + direction < 1)
	return;
end

mydata.history.current_genotype = mydata.history.current_genotype + direction;
set(handles.history_position,'String',[num2str(mydata.history.current_genotype) '/' num2str(length(mydata.history.images))]);

mydata.images = mydata.history.images{mydata.history.current_genotype};
mydata.population = mydata.history.population{mydata.history.current_genotype};
mydata.fitness = mydata.history.fitness{mydata.history.current_genotype};

refresh_genotype_history_buttons(hObject, eventdata, handles);
refresh_images(hObject, eventdata, handles, mydata.images.image(1).CData, [2:1:7]);
refresh_image_statistics(hObject, eventdata, [1,2,3,4,5,6,7]);

% --- Extract color channel [NxM] from image [NxMx3]
function result = Extract_RGB(image,color)
% image	the image matrix
% color	the color to extract (1=Red, 2=Green, 3=Blue)
result = image(:,:,color);


% --- Outputs from this function are returned to the command line.
function varargout = gui_fl_bayes_IAE_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function M_Datei_Callback(hObject, eventdata, handles)
% hObject    handle to M_Datei (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_new_Callback(hObject, eventdata, handles)
% hObject    handle to M_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_open_Callback(hObject, eventdata, handles)
% hObject    handle to M_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_save_Callback(hObject, eventdata, handles)
% hObject    handle to M_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_save_as_Callback(hObject, eventdata, handles)
% hObject    handle to M_save_as (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_save_image_Callback(hObject, eventdata, handles)
% hObject    handle to M_save_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to M_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_evolutionary_rules_Callback(hObject, eventdata, handles)
% hObject    handle to M_evolutionary_rules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_denoising_rules_Callback(hObject, eventdata, handles)
% hObject    handle to M_denoising_rules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_View_Callback(hObject, eventdata, handles)
% hObject    handle to M_View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_zoom100_Callback(hObject, eventdata, handles)
% hObject    handle to M_zoom100 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_zoom50_Callback(hObject, eventdata, handles)
% hObject    handle to M_zoom50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_zoom200_Callback(hObject, eventdata, handles)
% hObject    handle to M_zoom200 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_zoom_to_fit_Callback(hObject, eventdata, handles)
% hObject    handle to M_zoom_to_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_Help_Callback(hObject, eventdata, handles)
% hObject    handle to M_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_about_Callback(hObject, eventdata, handles)
% hObject    handle to M_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

helpdlg({'Denoising IEA v1.0 for Matlab 6','','Developed by Mario Pilz','in Team Complex at INRIA, 2005','','M.a.r.i.o.@gmx.de','http://fractales.inria.fr',''},'About');

% --- Executes during object creation, after setting all properties.
function fig_main_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when fig_main window is resized.
function fig_main_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to fig_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function refresh_Callback(hObject, eventdata, handles)
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------

function refresh_images(hObject, eventdata, handles, img, images_to_refresh)

global mydata;

drawnow;
%set(findobj(handles.output,'Tag','working1'),'String','working...');
b = Show_Image(hObject, eventdata, handles, 'axes1',img,mydata.images.image(1).RGB,'fig_main');
set(b,'ButtonDownFcn',{@Enlarge_Image,1});
c = findobj(handles.output,'Tag','MC_main_image_tool');
set(b,'UIContextMenu',c);
mydata.images.image(1).handle=b;
mydata.images.image(1).CData=img;
mydata.images.image(1).WT=-1;
%set(findobj(handles.output,'Tag','working1'),'String','');


if (max(size(intersect(images_to_refresh,2)))>0)
	set(findobj(handles.output,'Tag','working2'),'String','working...');
	drawnow;
	mydata.images.image(2) = Denoise(mydata.images.image(2));
	b = Show_Image(hObject, eventdata, handles, 'axes2',mydata.images.image(2).CData,mydata.images.image(2).RGB,'fig_main');
	set(b,'ButtonDownFcn',{@Enlarge_Image,2});
	c = findobj(handles.output,'Tag','MC_images');
	set(b,'UIContextMenu',c);
	mydata.images.image(2).handle=b;
	set(findobj(handles.output,'Tag','working2'),'String','');
end

if (max(size(intersect(images_to_refresh,3)))>0)
	set(findobj(handles.output,'Tag','working3'),'String','working...');
	drawnow;
	mydata.images.image(3) = Denoise(mydata.images.image(3));
	b = Show_Image(hObject, eventdata, handles, 'axes3',mydata.images.image(3).CData,mydata.images.image(3).RGB,'fig_main');
	set(b,'ButtonDownFcn',{@Enlarge_Image,3});
	c = findobj(handles.output,'Tag','MC_images');
	set(b,'UIContextMenu',c);
	mydata.images.image(3).handle=b;
	set(findobj(handles.output,'Tag','working3'),'String','');
end

if (max(size(intersect(images_to_refresh,4)))>0)
	set(findobj(handles.output,'Tag','working4'),'String','working...');
	drawnow;
	mydata.images.image(4) = Denoise(mydata.images.image(4));
	b = Show_Image(hObject, eventdata, handles, 'axes4',mydata.images.image(4).CData,mydata.images.image(4).RGB,'fig_main');
	set(b,'ButtonDownFcn',{@Enlarge_Image,4});
	c = findobj(handles.output,'Tag','MC_images');
	set(b,'UIContextMenu',c);
	mydata.images.image(4).handle=b;
	set(findobj(handles.output,'Tag','working4'),'String','');
end

if (max(size(intersect(images_to_refresh,5)))>0)
	set(findobj(handles.output,'Tag','working5'),'String','working...');
	drawnow;
	mydata.images.image(5) = Denoise(mydata.images.image(5));
	b = Show_Image(hObject, eventdata, handles, 'axes5',mydata.images.image(5).CData,mydata.images.image(5).RGB,'fig_main');
	set(b,'ButtonDownFcn',{@Enlarge_Image,5});
	c = findobj(handles.output,'Tag','MC_images');
	set(b,'UIContextMenu',c);
	mydata.images.image(5).handle=b;
	set(findobj(handles.output,'Tag','working5'),'String','');
end

if (max(size(intersect(images_to_refresh,6)))>0)
	set(findobj(handles.output,'Tag','working6'),'String','working...');
	drawnow;
	mydata.images.image(6) = Denoise(mydata.images.image(6));
	b = Show_Image(hObject, eventdata, handles, 'axes6',mydata.images.image(6).CData,mydata.images.image(6).RGB,'fig_main');
	set(b,'ButtonDownFcn',{@Enlarge_Image,6});
	c = findobj(handles.output,'Tag','MC_images');
	set(b,'UIContextMenu',c);
	mydata.images.image(6).handle=b;
	set(findobj(handles.output,'Tag','working6'),'String','');
end

if (max(size(intersect(images_to_refresh,7)))>0)
	set(findobj(handles.output,'Tag','working7'),'String','working...');
	drawnow;
	mydata.images.image(7) = Denoise(mydata.images.image(7));
	b = Show_Image(hObject, eventdata, handles, 'axes7',mydata.images.image(7).CData,mydata.images.image(7).RGB,'fig_main');
	set(b,'ButtonDownFcn',{@Enlarge_Image,7});
	c = findobj(handles.output,'Tag','MC_images');
	set(b,'UIContextMenu',c);
	mydata.images.image(7).handle=b;
	set(findobj(handles.output,'Tag','working7'),'String','');
end

drawnow;

mydata.images.image(8).handle=-1;
mydata.images.image(8).CData=-1;
mydata.images.image(8).WT=-1;

% --------------------------------------------------------------------
function result= is_a_gray_image(img)

result = 0;

if (isa(img,'double') && length(size(img))==2 && max(max(max(img)))<=1 && min(min(min(img)))>=0)
	result = 1;
end

if ( (isa(img,'uint16') || isa(img,'uint8')) && length(size(img))==2)
	result = 1;
end
% --------------------------------------------------------------------
function result= is_an_indexed_image(img)

result = 0;

if (isa(img,'double') && length(size(img))==2 && min(min(min(img)))>=1)
	result = 1;
end

if ( (isa(img,'uint16') || isa(img,'uint8')) && length(size(img))==2)
	result = 1;
end
% --------------------------------------------------------------------
function MC_load_image_Callback(hObject, eventdata, handles)
% hObject    handle to MC_load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile( ...
	{'*.jpeg;*.jpg;*.gif;*.png;*.bmp;*.tif;*.hdf;*.pcx;*.xwd;*.cur;*.ico','Image Files (*.jpeg;*.jpg;*.gif;*.png;*.bmp;*.tif;*.hdf;*.pcx;*.xwd;*.cur;*.ico)';
	'*.jpeg;*.jpg',  'JPEG (*.jpg,*.jpeg)'; ...
	'*.bmp','BMP (*.bmp)'; ...
	'*.gif','GIF (*.gif)'; ...
	'*.png','PNG (*.png)'; ...
	'*.tif','TIF (*.tif)'; ...
	'*.hdf','HDF (*.hdf)'; ...
	'*.pcx','PCX (*.pcx)'; ...
	'*.xwd','XWD (*.xwd)'; ...
	'*.cur','CUR (*.cur)'; ...
	'*.ico','ICO (*.ico)'; ...
	'*.*',  'All Files (*.*)'}, ...
	'Choose Image File');

% do nothing if no file was selected
if (filename == 0)
	return;
end

set(gcf,'Name',['Denoising IAE (',filename,')']);


global mydata;


if (strfind(filename,'.')>0)
	mydata.images.filename = filename(1:strfind(filename,'.')-1);

else
	mydata.images.filename = filename;
end

% reset selection marker in context menu
set(findobj(handles.output,'Tag','MC_main_rgb'),'Checked','on');
set(findobj(handles.output,'Tag','MC_main_red'),'Checked','off');
set(findobj(handles.output,'Tag','MC_main_blue'),'Checked','off');
set(findobj(handles.output,'Tag','MC_main_green'),'Checked','off');



%imfinfo([pathname filename])
global img;
[img imgmap] = imread(fullfile(pathname,filename));

% check if we have to convert from an gray scale/indexed image to RGB
if (is_a_gray_image(img)==1)
	img = reshape([img img img],[size(img) 3]);
end

if (is_an_indexed_image(img) == 1)
	%'indexed image'
	img = ind2rgb(img,imgmap);
end
%
% 	% check if we have to convert from an gray scale/indexed image to RGB
% 	gray_image = 0;
% 	if (isgray(img)==1)
% 		[img,imgmap] = gray2ind(img);
% 		gray_image = 1;
% 		%'grayscale image'
% 	end
%
% 	if (isind(img) == 1)
% 		%'indexed image'
% 		img = ind2rgb(img,imgmap);
% 		if (gray_image == 1)
% 			img = im2uint8(img);
% 		end
% 	end


% Initialize the population
for i=1:1:mydata.config.evol_population_size
	mydata.population.individuals(i).genotype = evol_init(mydata.images.image(1).genotype);
	mydata.population.individuals(i).bound_image_number = 0;
	mydata.population.individuals(i).fitness = 0;
	mydata.population.individuals(i).is_locked = 0;
end

% pick out 6 genotypes to show the user
for i=2:1:7
	mydata.images.image(i).genotype = mydata.population.individuals(i-1).genotype;
	mydata.images.image(i).evol_individualID = i-1;
	mydata.population.individuals(i-1).bound_image_number = i;
end

%reset user prefered regions
mydata.config.user_prefered_regions=[	mydata.config.evol_amin_min		mydata.config.evol_gmin_min		mydata.config.evol_amax_min		mydata.config.evol_gmax_min		mydata.config.evol_anod_min		mydata.config.evol_sigma_min	 min(mydata.config.evol_filters); ...
	mydata.config.evol_amin_max		mydata.config.evol_gmin_max		mydata.config.evol_amax_max		mydata.config.evol_gmax_max		mydata.config.evol_anod_max		mydata.config.evol_sigma_max	 max(mydata.config.evol_filters)];


% reset image locks
for i=2:1:7

	Image_UserData = get(findobj(handles.output,'Tag',['lock_image_axes' num2str(i)]),'UserData');
	Image_UserData(2) = 0;


	lock_img =  imread('unlocked_image.bmp');
	b = Show_Image(hObject, eventdata, handles, ['lock_image_axes' num2str(Image_UserData(1))] ,lock_img,7,'fig_main');
	set(b,'ButtonDownFcn',{@lock_image_ButtonDownFcn, handles});
	set(b,'UserData',Image_UserData);

end


if (mydata.config.write_statistics_2_file == 1)
	refresh_images(hObject, eventdata, handles, img, []);
	calc_statistics_and_write_2_file([1], [1:1:27], mydata.config.statistics_filename,1);
end

% Reset Fitnessmap
mydata.fitness.map = [];
mydata.fitness.CData = [];

% Update Genotype History
M_reset_genotype_history_Callback(hObject, eventdata, handles);

refresh_images(hObject, eventdata, handles, img, [2:1:7]);

update_global_statistics(hObject, eventdata, handles, 0);
refresh_image_statistics(hObject, eventdata, [1,2,3,4,5,6,7]);

set(findobj(handles.output,'Tag','text1'),'String', 0);
set(findobj(handles.output,'Tag','text2'),'String', 0);
set(findobj(handles.output,'Tag','text3'),'String', 0);
set(findobj(handles.output,'Tag','text4'),'String', 0);
set(findobj(handles.output,'Tag','text5'),'String', 0);
set(findobj(handles.output,'Tag','text6'),'String', 0);

slider1_Callback(hObject, eventdata, handles);
slider2_Callback(hObject, eventdata, handles);
slider3_Callback(hObject, eventdata, handles);
slider4_Callback(hObject, eventdata, handles);
slider5_Callback(hObject, eventdata, handles);
slider6_Callback(hObject, eventdata, handles);
mydata.images.changed_evaluations = [2,3,4,5,6,7];

% Update History
mydata.history.images = [];
mydata.history.population = [];
mydata.history.fitness = [];

mydata.history.current_genotype = 1;
mydata.history.images{mydata.history.current_genotype} = mydata.images;
mydata.history.population{mydata.history.current_genotype} = mydata.population;
mydata.history.fitness{mydata.history.current_genotype} = mydata.fitness;

refresh_genotype_history_buttons(hObject, eventdata, handles);


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%figure;
%set(gcf,'CurrentAxes',hObject)
%set(findobj(handles.output,'Tag','debug_text_2'),'String',get(gcf,'SelectionType'));


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
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
%set(findobj(handles.output,'Tag','text1'),'String',round(get(hObject,'Value')));

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
hObject = findobj(handles.output,'Tag','slider1');

set(findobj(handles.output,'Tag','text1'),'String',round(get(hObject,'Value')));

global mydata;
red = mydata.config.slider_color_red(round(get(hObject,'Value')+7));
green = mydata.config.slider_color_green(round(get(hObject,'Value')+7));
blue = mydata.config.slider_color_blue(round(get(hObject,'Value')+7));

set(hObject,'BackgroundColor',[red,green,blue]);
set(findobj(handles.output,'Tag','text1'),'ForeGroundColor',[red,green,blue]);
mydata.images.changed_evaluations = union(mydata.images.changed_evaluations, [2]);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
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
%set(findobj(handles.output,'Tag','text2'),'String',round(get(hObject,'Value')));

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
hObject = findobj(handles.output,'Tag','slider2');

set(findobj(handles.output,'Tag','text2'),'String',round(get(hObject,'Value')));

global mydata;
red = mydata.config.slider_color_red(round(get(hObject,'Value')+7));
green = mydata.config.slider_color_green(round(get(hObject,'Value')+7));
blue = mydata.config.slider_color_blue(round(get(hObject,'Value')+7));

set(hObject,'BackgroundColor',[red,green,blue]);
set(findobj(handles.output,'Tag','text2'),'ForeGroundColor',[red,green,blue]);

mydata.images.changed_evaluations = union(mydata.images.changed_evaluations, [3]);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
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
%set(findobj(handles.output,'Tag','text3'),'String',round(get(hObject,'Value')));


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
hObject = findobj(handles.output,'Tag','slider3');

set(findobj(handles.output,'Tag','text3'),'String',round(get(hObject,'Value')));

global mydata;
red = mydata.config.slider_color_red(round(get(hObject,'Value')+7));
green = mydata.config.slider_color_green(round(get(hObject,'Value')+7));
blue = mydata.config.slider_color_blue(round(get(hObject,'Value')+7));

set(hObject,'BackgroundColor',[red,green,blue]);
set(findobj(handles.output,'Tag','text3'),'ForeGroundColor',[red,green,blue]);

mydata.images.changed_evaluations = union(mydata.images.changed_evaluations, [4]);


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
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
%set(findobj(handles.output,'Tag','text4'),'String',round(get(hObject,'Value')));


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
hObject = findobj(handles.output,'Tag','slider4');

set(findobj(handles.output,'Tag','text4'),'String',round(get(hObject,'Value')));

global mydata;
red = mydata.config.slider_color_red(round(get(hObject,'Value')+7));
green = mydata.config.slider_color_green(round(get(hObject,'Value')+7));
blue = mydata.config.slider_color_blue(round(get(hObject,'Value')+7));

set(hObject,'BackgroundColor',[red,green,blue]);
set(findobj(handles.output,'Tag','text4'),'ForeGroundColor',[red,green,blue]);

mydata.images.changed_evaluations = union(mydata.images.changed_evaluations, [5]);


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
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
%set(findobj(handles.output,'Tag','text5'),'String',round(get(hObject,'Value')));


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
hObject = findobj(handles.output,'Tag','slider5');

set(findobj(handles.output,'Tag','text5'),'String',round(get(hObject,'Value')));

global mydata;
red = mydata.config.slider_color_red(round(get(hObject,'Value')+7));
green = mydata.config.slider_color_green(round(get(hObject,'Value')+7));
blue = mydata.config.slider_color_blue(round(get(hObject,'Value')+7));

set(hObject,'BackgroundColor',[red,green,blue]);
set(findobj(handles.output,'Tag','text5'),'ForeGroundColor',[red,green,blue]);

mydata.images.changed_evaluations = union(mydata.images.changed_evaluations, [6]);


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
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
%set(findobj(handles.output,'Tag','text6'),'String',round(get(hObject,'Value')));


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
hObject = findobj(handles.output,'Tag','slider6');

set(findobj(handles.output,'Tag','text6'),'String',round(get(hObject,'Value')));

global mydata;
red = mydata.config.slider_color_red(round(get(hObject,'Value')+7));
green = mydata.config.slider_color_green(round(get(hObject,'Value')+7));
blue = mydata.config.slider_color_blue(round(get(hObject,'Value')+7));

set(hObject,'BackgroundColor',[red,green,blue]);
set(findobj(handles.output,'Tag','text6'),'ForeGroundColor',[red,green,blue]);

mydata.images.changed_evaluations = union(mydata.images.changed_evaluations, [7]);


% --------------------------------------------------------------------

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;
%disp('----')
% mydata.images.changed_evaluations

if (isempty(findobj(handles.output,'Tag',['image_' get(findobj(handles.output,'Tag','axes1'),'Tag')])) == 1)
	return;
end

%before replacement
if (mydata.config.write_statistics_2_file == 1)
	calc_statistics_and_write_2_file([2:1:7], [1:1:27], mydata.config.statistics_filename,1);
end


% user notations
evaluations = [str2double(get(findobj(handles.output,'Tag','text1'),'String')), str2double(get(findobj(handles.output,'Tag','text2'),'String')), ...
	str2double(get(findobj(handles.output,'Tag','text3'),'String')), str2double(get(findobj(handles.output,'Tag','text4'),'String')), ...
	str2double(get(findobj(handles.output,'Tag','text5'),'String')), str2double(get(findobj(handles.output,'Tag','text6'),'String'))];

%add_to_map = mydata.images.changed_evaluations

% add usernotations to fitnessmap

if (mydata.config.evol_disable_fitnessmap == 1)
	mydata.fitness.map = [];
	mydata.fitness.CData = [];
end

if (mydata.config.evol_disable_fitnessmap == 1)
    % all genotypes will be added to fitnessmap in the next evolutionary step
    mydata.images.changed_evaluations = [2:1:7];
end

for i=1:1:size(mydata.images.changed_evaluations,2)
    
	geno = mydata.images.image(mydata.images.changed_evaluations(i)).genotype;
	append_fitness = [geno.amin, geno.gmin, geno.amax, geno.gmax, geno.anod, geno.sigma, geno.filter, evaluations(mydata.images.changed_evaluations(i)-1)];

	mydata.fitness.map = fitnessmap_add(mydata.fitness.map, append_fitness);
	if (mydata.config.save_CData_for_fitnessmap == 1)
			mydata.fitness.CData{size(mydata.fitness.CData,2)+1} = double(mydata.images.image(mydata.images.changed_evaluations(i)).CData);
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(handles.number_of_generations_edit,'String', num2str(max(1,min(1000,str2num(get(handles.number_of_generations_edit,'String'))))));

for (calculate_generations=1:1:str2num(get(handles.number_of_generations_edit,'String')))

	% pack EAStruct
	EAStruct.Individuals = mydata.population.individuals;
	EAStruct.Fitness = mydata.fitness;
	EAStruct.Config = mydata.config;

	% do one evolutionary step (calculate next generation)
	[EAStruct, modified_individuals, modified_images] = EA_Evolution(EAStruct);

	% unpack EAStruct
	mydata.population.individuals = EAStruct.Individuals;
	mydata.fitness = EAStruct.Fitness;
	mydata.Config = EAStruct.Config;

	
end 

% mydata.images
images_to_replace = [];
for i=1:1:length(EAStruct.Individuals)

	if (EAStruct.Individuals(i).bound_image_number > 0)
		mydata.images.image(EAStruct.Individuals(i).bound_image_number).evol_individualID = i;
		mydata.images.image(EAStruct.Individuals(i).bound_image_number).genotype = EAStruct.Individuals(i).genotype;
	end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update History
mydata.history.current_genotype = length(mydata.history.images) + 1;
mydata.history.images{mydata.history.current_genotype} = mydata.images;
mydata.history.population{mydata.history.current_genotype} = mydata.population;
mydata.history.fitness{mydata.history.current_genotype} = mydata.fitness;



refresh_genotype_history_buttons(hObject, eventdata, handles);

for i=2:1:7
	h = findobj(handles.output,'Tag',['axes' num2str(i) '_changed']);

	if (length(intersect(modified_images,i))>0)
		set(get(h,'Userdata'),'Visible','on');
	else
		set(get(h,'Userdata'),'Visible','off');
	end
end


refresh_images(hObject, eventdata, handles, mydata.images.image(1).CData, modified_images);

update_global_statistics(hObject, eventdata, handles, 0);
refresh_image_statistics(hObject, eventdata, modified_images);




% auto_eval = fitnessmap_query(mydata.fitness.map, images_to_replace, 1, 'nearest');


for i=2:1:7
	h = findobj(handles.output,'Tag',['slider' num2str(i-1)]);
	%mydata.population.individuals(mydata.images.image(i).evol_individualID).fitness
	set(h,'Value', round(mydata.population.individuals(mydata.images.image(i).evol_individualID).fitness));
	eval(['slider' num2str(i-1) '_Callback(hObject, eventdata, handles)']);
end

if (mydata.config.evol_disable_fitnessmap == 1)
    % all genotypes will be added to fitnessmap in the next evolutionary step
    mydata.images.changed_evaluations = [2:1:7];
else
    % prevent fitnessmap from blowing up, add only genotypes that changed
    mydata.images.changed_evaluations = modified_images;
    %mydata.images.changed_evaluations = [];
end

% --------------------------------------------------------------------
function update_global_statistics(hObject, eventdata, handles, refresh)

global mydata;
if (isempty(findobj(handles.output,'Tag',['image_' get(findobj(handles.output,'Tag','axes1'),'Tag')])) == 1)
	return;
end

if (refresh == 1)
	% user wants to refresh the statistics of the current generation
	last_element = max(size(mydata.history.distance));
	
	%% Extend Genotype Distance History %%%%%%%%%%%%%%%%%%
	mydata.history.distance(last_element) = [calc_mean_distance];

	%% Extend Phenotype Distance History %%%%%%%%%%%%%%%%%%
	mydata.history.phenotype_distance(last_element) = [calc_mean_phenotype_distance];

	%% Extend Population Distance History %%%%%%%%%%%%%%%%%%
	mydata.history.population_distance(last_element) = [calc_mean_population_distance];

	%% Extend Variance History %%%%%%%%%%%%%%%%%%
	mydata.history.variance(last_element) = [calc_variance];

	%% Extend Deviation History %%%%%%%%%%%%%%%%%%
	mydata.history.deviation(last_element) = [calc_deviation];

else
	% user wants to see the statistics for a new generation

	%% Extend Genotype Distance History %%%%%%%%%%%%%%%%%%
	mydata.history.distance = [mydata.history.distance, calc_mean_distance];

	%% Extend Phenotype Distance History %%%%%%%%%%%%%%%%%%
	mydata.history.phenotype_distance = [mydata.history.phenotype_distance, calc_mean_phenotype_distance];

	%% Extend Population Distance History %%%%%%%%%%%%%%%%%%
	mydata.history.population_distance = [mydata.history.population_distance, calc_mean_population_distance];
    
	%% Extend Variance History %%%%%%%%%%%%%%%%%%
	mydata.history.variance = [mydata.history.variance, calc_variance];

	%% Extend Deviation History %%%%%%%%%%%%%%%%%%
	mydata.history.deviation = [mydata.history.deviation, calc_deviation];
end

view_start = max ( max(size(mydata.history.distance))-mydata.config.history_statistics_size , 1);
view_end = max( max(size(mydata.history.distance)), view_start);
plot_end = max(view_end-view_start+1,2);


if (max(size(mydata.history.distance))>0)

	%% Show DistancePlot %%%%%%%%%%%%%%%%%%
	H = show_timeseries(handles, mydata.history.distance(view_start:view_end)', 'distance_axes', '');
	set(H,'Color','none');
	set(H,'XLim',[1 plot_end]);
	set(H,'XTick',[1 plot_end]);
	set(H,'XTickLabel',[view_start view_end]);
	set(H,'XColor','k');
	set(H,'YColor','k');

	%% Show Phenotype Distance Plot %%%%%%%%%%%%%%%%%%
	H = show_timeseries(handles, mydata.history.phenotype_distance(view_start:view_end)', 'phenotype_distance_axes', '');
	%set(H,'YLim',[0 0.16]);
	set(H,'Color','none');
	set(H,'XLim',[1 plot_end]);
	set(H,'XTick',[1 plot_end]);
	set(H,'XTickLabel',[view_start view_end]);
	set(H,'XColor','k');
	set(H,'YColor','k');

	%% Show Population Distance Plot %%%%%%%%%%%%%%%%%%
	H = show_timeseries(handles, mydata.history.population_distance(view_start:view_end)', 'population_distance_axes', '');
	set(H,'Color','none');
	%set(H,'YLim',[0 0.27]);
	set(H,'XLim',[1 plot_end]);
	set(H,'XTick',[1 plot_end]);
	set(H,'XTickLabel',[view_start view_end]);
	set(H,'XColor','k');
	set(H,'YColor','k');

else


end



%%% Show Genotype Bars %%%%%%%%%%%%%%%%%%
data = [];
range_amin 		= mydata.config.evol_amin_max - mydata.config.evol_amin_min;
range_gmin 		= mydata.config.evol_gmin_max - mydata.config.evol_gmin_min;
range_amax 		= mydata.config.evol_amax_max - mydata.config.evol_amax_min;
range_gmax 		= mydata.config.evol_gmax_max - mydata.config.evol_gmax_min;
range_anod 		= mydata.config.evol_anod_max - mydata.config.evol_anod_min;
range_sigma	  = mydata.config.evol_sigma_max - mydata.config.evol_sigma_min;
range_filter = max(mydata.config.evol_filters) - min(mydata.config.evol_filters);

for i=2:1:7
	newdata = [(mydata.images.image(i).genotype.amin-mydata.config.evol_amin_min)/range_amin; ...
		(mydata.images.image(i).genotype.gmin-mydata.config.evol_gmin_min)/range_gmin; ...
		(mydata.images.image(i).genotype.anod-mydata.config.evol_anod_min)/range_anod; ...
		(mydata.images.image(i).genotype.amax-mydata.config.evol_amax_min)/range_amax; ...
		(mydata.images.image(i).genotype.gmax-mydata.config.evol_gmax_min)/range_gmax; ...
		(mydata.images.image(i).genotype.sigma-mydata.config.evol_sigma_min)/range_sigma; ...
		(mydata.images.image(i).genotype.filter-min(mydata.config.evol_filters))/range_filter];



	data = [data, newdata];
end
H = show_bars(handles, data, 'genotype_axes', '');
set(H,'Color','none');
set(H,'YLim',[0 1.05]);
set(H,'XLim',[0.5 7.5]);
set(H,'XColor','k');
set(H,'YColor','k');
set(H,'XGrid','on');
set(H,'XTick',[1.5,2.5,3.5,4.5,5.5,6.5]);

% --------------------------------------------------------------------
function MC_main_show_colors_Callback(hObject, eventdata, handles)
% hObject    handle to MC_main_show_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function RGB_Buttons(hObject)
% updates RGB Buttons and redraws corresponding Images

global mydata;


% fetch UserData of the RGB Button (Handle --> hObject)
userdata = get(hObject,'UserData');

% generate Tagname of corresponding Axes
current_axes = ['axes' int2str(userdata(2))];

% generate Tagname of corresponding Image
current_image = ['image_' current_axes];

if (isempty(findobj('Tag',current_image)) == 1)
	return;
end

% fetch the color of the RGB Button
current_color = get(hObject,'String');



eval(['newbit = not(bitget(mydata.images.image(' int2str(userdata(2)) ').RGB,userdata(1)));']);
eval(['mydata.images.image(' int2str(userdata(2)) ').RGB = bitset(mydata.images.image(' int2str(userdata(2)) ').RGB,userdata(1),newbit);']);
eval(['if (bitget(mydata.images.image(' int2str(userdata(2)) ').RGB,userdata(1)) == 1) set(hObject,''BackgroundColor'',mydata.config.button_' current_color '_on); else set(hObject,''BackgroundColor'',mydata.config.button_' current_color '_off); end']);
eval(['b = Show_Image({}, {}, {}, current_axes,mydata.images.image(' int2str(userdata(2)) ').CData,mydata.images.image(' int2str(userdata(2)) ').RGB,''fig_main'');']);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cred0.
function cred0_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cred0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cgreen0.
function cgreen0_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cgreen0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cblue0.
function cblue0_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cblue0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cred1.
function cred1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cred1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cgreen1.
function cgreen1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cgreen1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cblue1.
function cblue1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cblue1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cred2.
function cred2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cred2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cgreen2.
function cgreen2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cgreen2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cblue2.
function cblue2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cblue2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cred3.
function cred3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cred3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cgreen3.
function cgreen3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cgreen3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cblue3.
function cblue3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cblue3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cred4.
function cred4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cred4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);

% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cgreen4.
function cgreen4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cgreen4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);

% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cblue4.
function cblue4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cblue4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);

% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cred5.
function cred5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cred5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cgreen5.
function cgreen5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cgreen5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cblue5.
function cblue5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cblue5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cred6.
function cred6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cred6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cgreen6.
function cgreen6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cgreen6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cblue6.
function cblue6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cblue6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RGB_Buttons(hObject);
% --------------------------------------------------------------------


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function MC_show_spectrum_Callback(hObject, eventdata, handles)
% hObject    handle to MC_show_spectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;


mydata.images.analysedimage = mydata.images.currentimage;

img_num = mydata.images.analysedimage;
mydata.images.image(8) = mydata.images.image(img_num);


% Save current handles for later recall
set(gui_fl_bayes_IAE_dialog01,'UserData',handles);


set(findobj(handles.output,'Tag','edit_sigma'),'String',mydata.images.image(img_num).genotype.sigma);
set(findobj(handles.output,'Tag','edit_amin'),'String',mydata.images.image(img_num).genotype.amin);
set(findobj(handles.output,'Tag','edit_gamin'),'String',mydata.images.image(img_num).genotype.gmin);
set(findobj(handles.output,'Tag','edit_amax'),'String',mydata.images.image(img_num).genotype.amax);
set(findobj(handles.output,'Tag','edit_gamax'),'String',mydata.images.image(img_num).genotype.gmax);
set(findobj(handles.output,'Tag','edit_anod'),'String',mydata.images.image(img_num).genotype.anod);

set(findobj(handles.output,'Tag','scales_label'),'String',floor(log2(max(size(mydata.images.image(1).CData)))));
set(findobj(handles.output,'Tag','scales_slider'),'Value',floor(log2(max(size(mydata.images.image(1).CData)))));


filter_indices = get(findobj(handles.output,'Tag','listbox_wavelet'),'UserData');
filternum = mydata.images.image(img_num).genotype.filter;

[val, pos] = intersect(filter_indices,filternum);

set(findobj(handles.output,'Tag','listbox_wavelet'),'Value',pos);


h = Show_Image(hObject, eventdata, handles, 'preview_axes',mydata.images.image(mydata.images.analysedimage).CData,7,'fig_adjust');
set(h,'ButtonDownFcn',{@Enlarge_Image,img_num});

handles.spectrum_axes = findobj(handles.output,'Tag','spectrum_axes');
handles.preview_axes = findobj(handles.output,'Tag','preview_axes');
guidata(hObject,handles);


[thumb_handles] = show_spectrum(hObject,eventdata,handles,'spectrum_axes','fig_adjust');
set(thumb_handles(1),'ButtonDownFcn',{@genotype_thumb_press, handles, 1});
set(thumb_handles(2),'ButtonDownFcn',{@genotype_thumb_press, handles, 2});
set(thumb_handles(3),'ButtonDownFcn',{@genotype_thumb_press, handles, 3});



% %H = gui_fl_bayes_IAE_dialog01;



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
	set(hObject,'BackgroundColor','white');
else
	set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --------------------------------------------------------------------
function MC_main_image_tool_Callback(hObject, eventdata, handles)
% hObject    handle to MC_main_image_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_Tools_Callback(hObject, eventdata, handles)
% hObject    handle to M_Tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_randomize_genotype_Callback(hObject, eventdata, handles)
% hObject    handle to M_randomize_genotype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (isempty(findobj(handles.output,'Tag',['image_' get(findobj(handles.output,'Tag','axes1'),'Tag')])) == 1)
	return;
end

global mydata;

% Initialize the population
mydata.population.individuals = [];
for i=1:1:mydata.config.evol_population_size
	mydata.population.individuals(i).genotype = evol_init(mydata.images.image(1).genotype);
	mydata.population.individuals(i).bound_image_number = 0;
	mydata.population.individuals(i).fitness = 0;
	mydata.population.individuals(i).is_locked = 0;
end

% pick out 6 genotypes to show the user
for i=2:1:7
	mydata.images.image(i).genotype = mydata.population.individuals(i-1).genotype;
	mydata.images.image(i).evol_individualID = i-1;
	mydata.population.individuals(i-1).bound_image_number = i;
end

% evaluate the generation
EAStruct.Individuals = mydata.population.individuals;
EAStruct.Fitness = mydata.fitness;
EAStruct.Config = mydata.config;

EAStruct = EA_Fitness(EAStruct);

mydata.population.individuals = EAStruct.Individuals;

% reset image locks
for i=2:1:7

	Image_UserData = get(findobj(handles.output,'Tag',['lock_image_axes' num2str(i)]),'UserData');
	Image_UserData(2) = 0;


	img =  imread('unlocked_image.bmp');
	b = Show_Image(hObject, eventdata, handles, ['lock_image_axes' num2str(Image_UserData(1))] ,img,7,'fig_main');
	set(b,'ButtonDownFcn',{@lock_image_ButtonDownFcn, handles});
	set(b,'UserData',Image_UserData);

end


% Update History
mydata.history.current_genotype = length(mydata.history.images) + 1;
mydata.history.images{mydata.history.current_genotype} = mydata.images;
mydata.history.population{mydata.history.current_genotype} = mydata.population;
mydata.history.fitness{mydata.history.current_genotype} = mydata.fitness;

refresh_genotype_history_buttons(hObject, eventdata, handles);


help = mydata.config.write_statistics_2_file;
mydata.config.write_statistics_2_file = 0;
refresh_images(hObject, eventdata, handles, mydata.images.image(1).CData, [2:1:7]);
mydata.config.write_statistics_2_file = help;


update_global_statistics(hObject, eventdata, handles, 0);
refresh_image_statistics(hObject, eventdata, [2,3,4,5,6,7]);

mydata.images.changed_evaluations = [2,3,4,5,6,7];

for i=2:1:7
	h = findobj(handles.output,'Tag',['axes' num2str(i) '_changed']);
	set(get(h,'Userdata'),'Visible','on');
end


for i=2:1:7
	h = findobj(handles.output,'Tag',['slider' num2str(i-1)]);
	set(h,'Value', round(mydata.population.individuals(mydata.images.image(i).evol_individualID).fitness));
	eval(['slider' num2str(i-1) '_Callback(hObject, eventdata, handles)']);
end




% --- Executes on key press over fig_main with no controls selected.
function fig_main_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to fig_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if (get(hObject,'CurrentCharacter') == 'r')
	M_randomize_genotype_Callback(hObject, eventdata, handles);
end

if (get(hObject,'CurrentCharacter') == 'n')
	pushbutton1_Callback(hObject, eventdata, handles);
end

if (double(get(hObject,'CurrentCharacter')) == 28)
	query_genotype_history(hObject, eventdata, handles, -1)
end

if (double(get(hObject,'CurrentCharacter')) == 29)
	query_genotype_history(hObject, eventdata, handles, 1)
end


% --------------------------------------------------------------------
function MC_coefficient_thresholding_Callback(hObject, eventdata, handles)
% hObject    handle to MC_coefficient_thresholding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

mydata.images.analysedimage = mydata.images.currentimage;

img_num = mydata.images.analysedimage;
mydata.images.image(8) = mydata.images.image(img_num);

% Save current handles for later recall
set(gui_fl_bayes_IAE_dialog02,'UserData',handles);

handles.spectrum_axes2 = findobj(handles.output,'Tag','spectrum_axes2');
handles.original_axes2 = findobj(handles.output,'Tag','original_axes2');
handles.preview_axes2 = findobj(handles.output,'Tag','preview_axes2');
guidata(hObject,handles);

set(findobj(handles.output,'Tag','edit_sigma2'),'String',mydata.images.image(img_num).genotype.sigma);
set(findobj(handles.output,'Tag','edit_amin2'),'String',mydata.images.image(img_num).genotype.amin);
set(findobj(handles.output,'Tag','edit_gamin2'),'String',mydata.images.image(img_num).genotype.gmin);
set(findobj(handles.output,'Tag','edit_amax2'),'String',mydata.images.image(img_num).genotype.amax);
set(findobj(handles.output,'Tag','edit_gamax2'),'String',mydata.images.image(img_num).genotype.gmax);
set(findobj(handles.output,'Tag','edit_anod2'),'String',mydata.images.image(img_num).genotype.anod);

filter_indices = get(findobj(handles.output,'Tag','listbox_wavelet2'),'UserData');
filternum = mydata.images.image(img_num).genotype.filter;

[val, pos] = intersect(filter_indices,filternum);

set(findobj(handles.output,'Tag','listbox_wavelet2'),'Value',pos);


[mydata.images.image(8),old_coeff,new_coeff] = Denoise(mydata.images.image(img_num));

max_scale = floor(log2(max(size(mydata.images.image(img_num).CData))));
set(findobj(handles.output,'Tag','slider_scale2'),'Min', 1);
set(findobj(handles.output,'Tag','slider_scale2'),'Max', max_scale);
set(findobj(handles.output,'Tag','text_scale2'),'String', max_scale);
set(findobj(handles.output,'Tag','slider_scale2'),'Value', max_scale);
if (max_scale > 1)
	set(findobj(handles.output,'Tag','slider_scale2'),'SliderStep', [1/(max_scale-1) 1]);
else
	set(findobj(handles.output,'Tag','slider_scale2'),'SliderStep', [1 1]);
end

scale = str2double(get(findobj(handles.output,'Tag','text_scale2'),'String'));
modus = get(findobj(handles.output,'Tag','checkbox_ideal2'),'Value');

h = Show_Image(hObject, eventdata, handles, 'original_axes2',mydata.images.image(1).CData,7,'fig_test_coeff');
h = Show_Image(hObject, eventdata, handles, 'preview_axes2',mydata.images.image(mydata.images.analysedimage).CData,7,'fig_test_coeff');
set(h,'ButtonDownFcn',@Enlarge_Image);

show_coeff_map(hObject, eventdata, handles,'spectrum_axes2','fig_test_coeff',old_coeff, new_coeff, mydata.images.image(8), scale, modus);



% --- Executes during object creation, after setting all properties.
function working1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to working1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');

% --- Executes during object creation, after setting all properties.
function working2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to working2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');

% --- Executes during object creation, after setting all properties.
function working3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to working3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');

% --- Executes during object creation, after setting all properties.
function working4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to working4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');

% --- Executes during object creation, after setting all properties.
function working5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to working5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');

% --- Executes during object creation, after setting all properties.
function working6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to working6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');

% --- Executes during object creation, after setting all properties.
function working7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to working7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');


% --------------------------------------------------------------------
function M_reset_history_Callback(hObject, eventdata, handles)
% hObject    handle to M_reset_history (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;
mydata.history.distance = [];
mydata.history.variance = [];
mydata.history.deviation = [];
mydata.history.phenotype_distance = [];
mydata.history.population_distance = [];
update_global_statistics(hObject, eventdata, handles, 0);


% --------------------------------------------------------------------
function M_refresh_settings_from_file_Callback(hObject, eventdata, handles)
% hObject    handle to M_refresh_settings_from_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;

preset_file = get(handles.M_refresh_settings_from_file,'UserData');

if (exist(preset_file)==2)
	% read settings from file,overwrite the default values specified above (mydata.config)
	mydata.config = read_configuration_from_file(mydata.config, preset_file);
	refresh_image_statistics(hObject, eventdata, [1,2,3,4,5,6,7]);
else
	% generate a settings file containing the default values (mydata.config)
    warndlg(['Could not find preset file ' preset_file '. Continuing with default values!'],'Warning !');
	%write_configuration_to_file(mydata.config, 'preset_default.txt');
end



% --------------------------------------------------------------------
function M_reset_genotype_history_Callback(hObject, eventdata, handles)
% hObject    handle to M_reset_genotype_history (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;

mydata.history.current_genotype = 1;
mydata.history.images = {mydata.images};
mydata.history.population = {mydata.population};
mydata.history.fitness = {mydata.fitness};

refresh_genotype_history_buttons(hObject, eventdata, handles);


% --- Executes on mouse press over axes background.
function attributes_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to attributes21_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;

if (isempty(findobj(handles.output,'Tag',['image_' get(findobj(handles.output,'Tag','axes1'),'Tag')])) == 1)
	return;
end

userdata = get(hObject,'UserData');
parent_axes = findobj(handles.output,'Tag', ['axes' num2str(userdata(1))]);
[axes_pos] = get(parent_axes,'Position');
axes_name = ['statistics_' num2str(userdata(1)) num2str(userdata(2))];
image_handle = findobj(handles.output,'Tag', ['image_axes' num2str(userdata(1))]);
%get(userdata(3),'Visible')

if (mydata.config.population_statistics_panel_color == 0)
	panelcolor = 'none';
else
	panelcolor = mydata.config.population_statistics_panel_color;
end


% Requested statistics pane does not yet exist
if (userdata(3)<=0)

    img = imread(['statistics1.bmp']);
    set(findobj(handles.output,'Tag',['image_attributes' num2str(userdata(1)) num2str(1) '_axes']), 'CData', img);

    img = imread(['statistics2.bmp']);
    set(findobj(handles.output,'Tag',['image_attributes' num2str(userdata(1)) num2str(2) '_axes']), 'CData', img);
    
    img = imread(['statistics' num2str(userdata(2)) '_on.bmp']);
    set(hObject,'CData',img);
    
    tagname = get(hObject,'Tag');
    eval(['handles.' tagname '= hObject;']);
    guidata(hObject, handles);
	
    %'1'
	b = axes('Parent',gcf, ...
		'Box','on', ...
		'Color', panelcolor, ...
		'HandleVisibility','callback', ...
		'Layer','top', ...
		'Units','normalized', ...
		'Position',[axes_pos(1) axes_pos(2) axes_pos(3) axes_pos(4)], ...
		'Tag',axes_name, ...
		'UserData',[], ...
		'Visible','on', ...
		'XColor',[0 0 0], ...
		'XLimMode','manual', ...
		'XTick',[], ...
		'YColor',[0 0 0], ...
		'YLimMode','manual', ...
		'YTick',[], ...
		'ZColor',[0 0 0]);

	set(b,'ButtonDownFcn',{@Enlarge_Image,userdata(1)});
	c = findobj(handles.output,'Tag','MC_images');
	set(b,'UIContextMenu',c);


	% Userdata of button holds handle of corresponding panel
	userdata(3) = b;
	set(hObject,'UserData',userdata);

	%disp('on:'); userdata
	update_image_statistics(userdata);

	if (max(size(mydata.images.image(userdata(1)).current_statistics_panel))>=3)
		set(mydata.images.image(userdata(1)).current_statistics_panel(3), 'Visible', 'off');
		update_image_statistics(mydata.images.image(userdata(1)).current_statistics_panel);
	end

	% User wants to see another statistics pane	or current pane is invisible
elseif (userdata(3) ~= mydata.images.image(userdata(1)).current_statistics_panel(3) | strcmp(get(userdata(3),'Visible'),'off') == 1 )
    
    img = imread(['statistics1.bmp']);
    set(findobj(handles.output,'Tag',['image_attributes' num2str(userdata(1)) num2str(1) '_axes']), 'CData', img);

    img = imread(['statistics2.bmp']);
    set(findobj(handles.output,'Tag',['image_attributes' num2str(userdata(1)) num2str(2) '_axes']), 'CData', img);



    img = imread(['statistics' num2str(userdata(2)) '_on.bmp']);
    set(hObject,'CData',img);

%     img = imread(['statistics' num2str(userdata(2)) '.bmp']);
%     set(hObject,'CData',img);
    
    %'2'
	if (userdata(3) ~= mydata.images.image(userdata(1)).current_statistics_panel(3))
		%'2.1'
		set(mydata.images.image(userdata(1)).current_statistics_panel(3), 'Visible', 'off');

		%disp('off:'); mydata.images.image(userdata(1)).current_statistics_panel
		update_image_statistics(mydata.images.image(userdata(1)).current_statistics_panel);
	end

	set(userdata(3), 'Visible', 'on');
	set(userdata(3),'Color',panelcolor);

	%disp('on:'); userdata
	update_image_statistics(userdata);
	% Make current statistics pane invisible >> make image visible
else
    
    img = imread(['statistics' num2str(userdata(2)) '.bmp']);
    set(hObject,'CData',img);


	%'3'
	set(mydata.images.image(userdata(1)).current_statistics_panel(3), 'Visible', 'off');
	update_image_statistics(mydata.images.image(userdata(1)).current_statistics_panel);
	%disp('off:'); userdata
	%update_image_statistics(userdata);
	set(image_handle, 'Visible', 'on');
end

mydata.images.image(userdata(1)).current_statistics_panel = userdata;


% calculates image statistics and prints them to a panel
function update_image_statistics(panel)
global mydata;
% handles von objekten in userdata vom pane speichern > löschen und replot
% möglich. Werte kommen aus mydata.images.image().statistics

if (isempty(findobj('Tag',['image_' get(findobj('Tag','axes1'),'Tag')])) == 1)
	error('Please load both images first.');
end

if (max(size(panel))<3)
	return;
end

if (mydata.config.population_statistics_text_background_color == 0)
	textbackgroundcolor = 'none';
else
	textbackgroundcolor = mydata.config.population_statistics_text_background_color;
end


% be sure to delete old stats
objects = get(panel(3),'Userdata');
for i=1:1:max(size(objects))
	delete(objects(i));
end
set(panel(3),'Userdata', []);

% only update Panel when visible
if (strcmp(get(panel(3),'Visible'),'on')==1)

	axes(panel(3));
	objects = [];

	h = text(0.02,0.95,eval(['mydata.config.population_statistics_heading_' num2str(panel(2))]),'FontSize',10,'FontWeight','bold','Color',mydata.config.population_statistics_text_color, 'BackgroundColor',textbackgroundcolor);
	objects = [objects, h];

	tasks = eval(['mydata.config.population_statistics_' num2str(panel(2))]);
	if (ischar(tasks) == 1)
		tasks = eval(tasks);
	end
	%size(mydata.images.image(panel(1)).panels)

	if (size(mydata.images.image(panel(1)).panels)<panel(2) | max(size(mydata.images.image(panel(1)).panels(panel(2)).statistics)) < size(tasks,1))
		%'new statistics'
		for i=1:1:size(tasks,1)
			if (isnumeric(tasks(i).function) == 1 )
				value = tasks(i).function;
            else
                %[tasks(i).function '(' num2str(panel(1)) ');']
				value = eval([tasks(i).function '(' num2str(panel(1)) ');']);
			end

			if (size(mydata.images.image(panel(1)).panels,2) < panel(2))
				mydata.images.image(panel(1)).panels(panel(2)).statistics = [];
			end

			stat_size = max(size(mydata.images.image(panel(1)).panels(panel(2)).statistics));
			mydata.images.image(panel(1)).panels(panel(2)).statistics{stat_size+1} = value;
		end
	end

	for i=1:1:size(tasks,1)

		if (max(size(mydata.images.image(panel(1)).panels(panel(2)).statistics{i})) > 1)
			value = mat2str(mydata.images.image(panel(1)).panels(panel(2)).statistics{i});
		else
			value = num2str(mydata.images.image(panel(1)).panels(panel(2)).statistics{i});
		end

		h = text(0.02,0.86 - 0.07*(i-1) ,[tasks(i).name ': ' value],'FontSize',8,'Color',mydata.config.population_statistics_text_color, 'BackgroundColor',textbackgroundcolor);
		objects = [objects, h];
	end

	set(panel(3),'Userdata', objects);

end

function refresh_image_statistics(hObject, eventdata, images)
global mydata;

obj = get(findobj('Tag','axes1'),'Tag');
if iscell(obj), obj = obj{1}; end
if (isempty(findobj('Tag',['image_' obj])) == 1)
	return;
end

for i=1:1:7
	if (max(size(intersect(i,images)))>0 & max(size(mydata.images.image(i).current_statistics_panel))>=3)
		%'refresh'
		for j=1:1:max(size(mydata.images.image(i).panels))
			% Delete all old Statistics of this Image
			mydata.images.image(i).panels(j).statistics = [];
		end

		update_image_statistics(mydata.images.image(i).current_statistics_panel);
	end
end


% --------------------------------------------------------------------
function M_reset_fitness_map_Callback(hObject, eventdata, handles)
% hObject    handle to M_reset_fitness_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;

mydata.fitness.map = [];
mydata.fitness.CData = [];


% --------------------------------------------------------------------
function M_fitnessmap_editor_Callback(hObject, eventdata, handles)
% hObject    handle to M_fitnessmap_editor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;


% Save current handles for later recall
set(gui_fl_bayes_IAE_dialog03,'UserData',handles);

if (size(mydata.fitness.map,2)>0)
	set(findobj(handles.output,'Tag','listbox_individuals'),'String',{1:1:size(mydata.fitness.map,2)});

	indiv_num = 1;
	handles2 = guidata(gui_fl_bayes_IAE_dialog03);
	handles2.last_individual = indiv_num;
	guidata(gui_fl_bayes_IAE_dialog03, handles2);

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


	set(findobj(handles.output,'Tag','evaluation_label'),'String',num2str(indiv_eval));
	h = Show_Image(hObject, eventdata, handles, 'individual_axes',indiv_CData,7,'fig_fitnessmap');
	mydata.images.image(9).handle = h;


end



%h = Show_Image(hObject, eventdata, handles, 'preview_axes',mydata.images.image(mydata.images.analysedimage).CData,7,'fig_adjust');
%set(h,'ButtonDownFcn',{@Enlarge_Image,img_num});




% --------------------------------------------------------------------
function M_population_viewer_Callback(hObject, eventdata, handles)
% hObject    handle to M_population_viewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

% Save current handles for later recall
set(gui_fl_bayes_IAE_dialog04,'UserData',handles);

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

	set(findobj(handles.output,'Tag','listbox_population_individuals'),'String',listbox_string);


	indiv_num = 1;
	handles2 = guidata(gui_fl_bayes_IAE_dialog04);
	handles2.last_individual = indiv_num;
	guidata(gui_fl_bayes_IAE_dialog04, handles2);

	%	indiv_CData = uint8(mydata.fitness.CData{indiv_num});

	%	mydata.images.image(10).CData = indiv_CData;

	mydata.images.image(10).genotype.amin = mydata.population.individuals(indiv_num).genotype.amin;
	mydata.images.image(10).genotype.gmin = mydata.population.individuals(indiv_num).genotype.gmin;
	mydata.images.image(10).genotype.amax = mydata.population.individuals(indiv_num).genotype.amax;
	mydata.images.image(10).genotype.gmax = mydata.population.individuals(indiv_num).genotype.gmax;
	mydata.images.image(10).genotype.anod = mydata.population.individuals(indiv_num).genotype.anod;
	mydata.images.image(10).genotype.sigma = mydata.population.individuals(indiv_num).genotype.sigma;
	mydata.images.image(10).genotype.filter = mydata.population.individuals(indiv_num).genotype.filter;

	% pack EAStruct
	EAStruct.Individuals = mydata.population.individuals;
	EAStruct.Fitness = mydata.fitness;
	EAStruct.Config = mydata.config;

	% evaluate the population
	EAStruct = EA_Fitness(EAStruct);

	% unpack EAStruct
	mydata.population.individuals = EAStruct.Individuals;

	indiv_eval = mydata.population.individuals(indiv_num).fitness;
	set(findobj(handles.output,'Tag','population_evaluation_edit'),'String',num2str(indiv_eval));

	if (get(findobj(handles.output,'Tag','denoise_checkbox'),'Value') == 1)
		mydata.images.image(10) = Denoise(mydata.images.image(10));
		h = Show_Image(hObject, eventdata, handles, 'population_axes',mydata.images.image(10).CData,7,'fig_populationmap');
		mydata.images.image(10).handle = h;
	end


end


% --- Executes during object creation, after setting all properties.
function number_of_generations_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to number_of_generations_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
	set(hObject,'BackgroundColor','white');
else
	set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function number_of_generations_edit_Callback(hObject, eventdata, handles)
% hObject    handle to number_of_generations_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of number_of_generations_edit as text
%        str2double(get(hObject,'String')) returns contents of number_of_generations_edit as a double


% --- Executes on mouse press over the image to lock an image.
function lock_image_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;
if (isempty(findobj(handles.output,'Tag',['image_' get(findobj(handles.output,'Tag','axes1'),'Tag')])) == 1 || mydata.config.allow_superindividuals==0)
	return;
end

Image_UserData = get(hObject,'UserData');

Image_UserData(2) = abs(Image_UserData(2)-1);

if (Image_UserData(2) == 0)
	img =  imread('unlocked_image.bmp');
else
	img =  imread('locked_image.bmp');
end

b = Show_Image(hObject, eventdata, handles, ['lock_image_axes' num2str(Image_UserData(1))] ,img,7,'fig_main');
set(b,'ButtonDownFcn',{@lock_image_ButtonDownFcn, handles});
set(b,'UserData',Image_UserData);

mydata.population.individuals(mydata.images.image(Image_UserData(1)).evol_individualID).is_locked = Image_UserData(2);

%disp('---');
%disp(['Bild ' num2str(Image_UserData(1)-1) ' hat Bindung zu Individuum ' num2str(mydata.images.image(Image_UserData(1)).evol_individualID) ' --> ' num2str(mydata.population.individuals(mydata.images.image(Image_UserData(1)).evol_individualID).is_locked)]);



%mydata.population.individuals(mydata.images.image(Image_UserData(1)).evol_individualID).bound_image_number



% --------------------------------------------------------------------
function MC_load_image_from_fraclab_Callback(hObject, eventdata, handles)
% hObject    handle to MC_load_image_from_fraclab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;

t=findobj('Tag','FRACLAB Toolbox');
if isempty(t)
	fl_warning('Open FracLab Window, before importing data');
	fltool;
else
	[InputName error_in] = fl_get_input ('matrix') ;
	eval(['global ',InputName]) ;
	SigIn = eval(InputName) ;

	%disp(['Get: ' mat2str([min(min(SigIn)),max(max(SigIn))])   ]);

	[img,imgmap] = gray2ind(SigIn);
	img = ind2rgb(img,imgmap);
	img = im2uint8(img);
	mydata.images.image(1).CData = img;

	%disp(['Converted 3D: ' mat2str([min(min(min(SigIn))),max(max(max(SigIn)))])   ]);

	%mydata.images.image(1).CData = uint8(reshape([SigIn SigIn SigIn],[size(SigIn) 3]));
	h = Show_Image(hObject, eventdata, handles, 'axes1',mydata.images.image(1).CData,7,'fig_main');

	M_randomize_genotype_Callback(hObject, eventdata, handles);
end


% --------------------------------------------------------------------
function MC_Send_Image_To_Fraclab_Callback(hObject, eventdata, handles)
% hObject    handle to MC_Send_Image_To_Fraclab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%
global mydata;

img_num =  mydata.images.currentimage;
image_to_export = mydata.images.image(img_num).CData;
image_to_export=rgb2gray(image_to_export);
image_to_export=double(image_to_export)/255;

%disp(['Send: ' mat2str([min(min(image_to_export)),max(max(image_to_export))])   ]);

t=who('global');
InputName=mydata.images.filename;
OutputName=['AE_bayes_' InputName];
varname = fl_findname(OutputName,t);
varargout{1}=varname;
eval(['global ' varname]);
eval([varname,' =image_to_export;']);

t=findobj('Tag','FRACLAB Toolbox');
if ~isempty(t)
	figure(t);
	fl_addlist(0,varname) ;
else
	fltool;fl_addlist(0,varname);
end

assignin('base',varname,image_to_export);

%%%%%%%%%%%%

% --------------------------------------------------------------------
function MC_load_image_from_fraclab_tool_Callback(hObject, eventdata, handles)
% hObject    handle to MC_load_image_from_fraclab_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;

t=findobj('Tag','FRACLAB Toolbox');
if isempty(t)
	fl_warning('Open FracLab Window, before importing data');
	fltool;
else
	[InputName error_in] = fl_get_input ('matrix') ;
	eval(['global ',InputName]) ;
	SigIn = eval(InputName) ;

	%disp(['Get: ' mat2str([min(min(SigIn)),max(max(SigIn))])   ]);

	[img,imgmap] = gray2ind(SigIn);
	img = ind2rgb(img,imgmap);
	img = im2uint8(img);
	mydata.images.image(1).CData = img;

	%disp(['Converted 3D: ' mat2str([min(min(min(SigIn))),max(max(max(SigIn)))])   ]);

	%mydata.images.image(1).CData = uint8(reshape([SigIn SigIn SigIn],[size(SigIn) 3]));
	h = Show_Image(hObject, eventdata, handles, 'axes1',mydata.images.image(1).CData,7,'fig_main');

	M_randomize_genotype_Callback(hObject, eventdata, handles);
end



% --------------------------------------------------------------------
function M_Presets_Callback(hObject, eventdata, handles)
% hObject    handle to M_Presets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function M_preset_original_Callback(hObject, eventdata, handles)
% hObject    handle to M_preset_original (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

if (exist('preset_default.txt')==2)
	% read settings from file,overwrite the default values specified above (mydata.config)
	mydata.config = read_configuration_from_file(mydata.config, 'preset_default.txt');
    warndlg('Preset file preset_default.txt loaded.','Message');
	set(handles.M_preset_original,'Checked','on');
	set(handles.M_preset_new01,'Checked','off');
	M_randomize_genotype_Callback(hObject, eventdata, handles);
	set(handles.M_refresh_settings_from_file,'UserData','preset_default.txt');
else
    warndlg('Could not find preset_default.txt','Warning !');
end


% --------------------------------------------------------------------
function M_preset_new01_Callback(hObject, eventdata, handles)
% hObject    handle to M_preset_new01 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

if (exist('preset_new01.txt')==2)
	% read settings from file,overwrite the default values specified above (mydata.config)
	mydata.config = read_configuration_from_file(mydata.config, 'preset_new01.txt');
    warndlg('Preset file preset_new01.txt loaded.','Message');
	set(handles.M_preset_new01,'Checked','on');
	set(handles.M_preset_original,'Checked','off');
	M_randomize_genotype_Callback(hObject, eventdata, handles);
	set(handles.M_refresh_settings_from_file,'UserData','preset_new01.txt');
else
    warndlg('Could not find preset_new01.txt','Warning !');
end


% --------------------------------------------------------------------
function M_refresh_images_Callback(hObject, eventdata, handles)
% hObject    handle to M_refresh_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;

for i=2:1:7
	mydata.images.image(i).genotype = mydata.population.individuals(mydata.images.image(i).evol_individualID).genotype;
	refresh_images(hObject, eventdata, handles, mydata.images.image(1).CData, [i]);
end


% --------------------------------------------------------------------
function MC_Save_Image_To_File_Callback(hObject, eventdata, handles)
% hObject    handle to MC_Save_Image_To_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mydata;

image = uint8(mydata.images.image(mydata.images.currentimage).CData);
Filter = { '*.jpg',  'JPEG (*.jpg)'; '*.bmp','BMP (*.bmp)'; '*.png','PNG (*.png)'; ...
	'*.tif','TIF (*.tif)'; '*.hdf','HDF (*.hdf)'};


[FileName,PathName,FilterIndex] = uiputfile(Filter, 'Save Image As...');

if (FilterIndex==0)
    return;
end

FileType = Filter{FilterIndex};
FileType(1:2) = [];

imwrite(image,fullfile(PathName,FileName),FileType);

% --------------------------------------------------------------------
function M_Load_Project_Callback(hObject, eventdata, handles)
% hObject    handle to M_Load_Project (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

Filter = { '*.IAE'};

[FileName,PathName,FilterIndex] = uigetfile(Filter, 'Load Project From...');

if (FilterIndex == 0)
	return;
end

load('-mat', fullfile(PathName,FileName), 'mydata');

refresh_images(hObject, eventdata, handles, mydata.images.image(1).CData, [2:1:7]);
refresh_genotype_history_buttons(hObject, eventdata, handles);
refresh_image_statistics(hObject, eventdata, [1,2,3,4,5,6,7]);
update_global_statistics(hObject, eventdata, handles, 1);





% --------------------------------------------------------------------
function M_Save_Project_Callback(hObject, eventdata, handles)
% hObject    handle to M_Save_Project (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global mydata;

Filter = { '*.IAE'};

[FileName,PathName,FilterIndex] = uiputfile(Filter, 'Save Project As...');

if (FilterIndex == 0)
	return;
end

save(fullfile(PathName,FileName),'mydata','-mat');


% --------------------------------------------------------------------
function M_File_Callback(hObject, eventdata, handles)
% hObject    handle to M_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function M_Load_Image_Callback(hObject, eventdata, handles)
% hObject    handle to M_Load_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MC_load_image_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function M_Load_Image_From_Fraclab_Callback(hObject, eventdata, handles)
% hObject    handle to M_Load_Image_From_Fraclab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MC_load_image_from_fraclab_Callback(hObject, eventdata, handles);




% --------------------------------------------------------------------
function M_about_dialog_Callback(hObject, eventdata, handles)
% hObject    handle to M_about_dialog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

helpdlg({'Denoising IEA v1.0 for Matlab 6','','Developed by Mario Pilz','in Team Complex at INRIA, 2005','','M.a.r.i.o.@gmx.de','http://fractales.inria.fr',''},'About');


% --------------------------------------------------------------------
function M_help_dialog_Callback(hObject, eventdata, handles)
% hObject    handle to M_help_dialog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure; imshow('Help_Dialog.gif');

