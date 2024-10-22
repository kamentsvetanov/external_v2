function fig = bfm_plot_datamatcorrs(action,varargin)
%
%  USAGE: fig = bfm_plot_datamatcorrs(action,varargin)
%

   if ~exist('action','var') | isempty(action)

%      [PLSresultFile,PLSresultFilePath] =  ...
%                        rri_selectfile('*_BfMRIresult.mat','Open PLS Result');
%      if (PLSresultFilePath == 0), return; end;

%      PLSResultFile = fullfile(PLSresultFilePath,PLSresultFile);

      h = findobj(gcbf,'Tag','ResultFile');
      PLSResultFile = get(h,'UserData');

      msg = 'Loading Datamat Correlations Data ...    Please wait!';
      hb = rri_wait_box(msg, [0.5 0.1]);

      fig_h = init(PLSResultFile);

      setappdata(gcf,'CallingFigure',gcbf); 
%      set(gcbf,'visible','off');

      rot_amount = load_pls_result;
      bfm_plot_datamatcorrs('Rotation', rot_amount);


      dims = getappdata(gcf,'STDims');
      origin = getappdata(gcf,'STOrigin');
      if origin(1) < 1, origin(1) = 1; end
      if origin(2) < 1, origin(2) = 1; end
      if origin(3) < 1, origin(3) = 1; end
      if origin(1) > dims(1), origin(1) = dims(1); end
      if origin(2) > dims(2), origin(2) = dims(2); end
      if origin(3) > dims(4), origin(3) = dims(4); end
      h = findobj(gcf,'Tag','XYZVoxel');
      set(h, 'string', num2str(origin));
      h = findobj(gcf,'Tag','MessageLine');
      set(h,'String','');
      EditXYZ;


	%  this has to be put at the bottom. otherwise
	%  program will fail on new MATLAB
	%
      if (nargout > 0),
        fig = fig_h;
      end;

      delete(hb);


      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   if (strcmp(action,'PlotBnPress'))
     ShowResult(0,1);                % display brainlv inside the Plot BLV figure
   elseif (strcmp(action,'PlotOnNewFigure'))
     ShowResult(1,0);                % display brainlv in a new figure;
   elseif (strcmp(action,'Zooming'))
     zoom_on_state = get(gcbo,'Userdata');
     if (zoom_on_state == 1)
	zoom on;
        set(gcbo,'Userdata',0,'Label','&Zoom off');
        set(gcf,'pointer','crosshair');
     else
	zoom off;
        set(gcbo,'Userdata',1,'Label','&Zoom on');
        set(gcf,'pointer','arrow');
     end;
   elseif (strcmp(action,'Toggle_View'))
     ToggleView;
     ShowResult(0,1);
   elseif (strcmp(action,'Rotation'))
     p_img = getappdata(gcf,'p_img');
     if ~isempty(p_img)
        p_img = [-1 -1];
        setappdata(gcf,'p_img',p_img);
     end
     setappdata(gcf,'img_xhair',[]);

     rot_amount = varargin{1};
     setappdata(gcf,'RotateAmount',rot_amount);
     switch mod(rot_amount,4)
        case {0},					% 0 degree
           h = findobj(gcf,'Tag','Rotate0Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate90Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate180Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate270Menu');
           set(h,'Checked','on');
        case {1},					% 90 degree by default
           h = findobj(gcf,'Tag','Rotate0Menu');
           set(h,'Checked','on');
           h = findobj(gcf,'Tag','Rotate90Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate180Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate270Menu');
           set(h,'Checked','off');
        case {2},					% 180 degree
           h = findobj(gcf,'Tag','Rotate0Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate90Menu');
           set(h,'Checked','on');
           h = findobj(gcf,'Tag','Rotate180Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate270Menu');
           set(h,'Checked','off');
        case {3},					% 270 degree
           h = findobj(gcf,'Tag','Rotate0Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate90Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate180Menu');
           set(h,'Checked','on');
           h = findobj(gcf,'Tag','Rotate270Menu');
           set(h,'Checked','off');
     end;

     ShowResult(0,0);
     EditXYZ;
   elseif (strcmp(action,'EditGroup'))
     EditGroup;
     ShowResult(0,1);
   elseif (strcmp(action,'EditBehav'))
     EditBehav;
     ShowResult(0,1);
   elseif (strcmp(action,'EditLV'))
     EditLV;
     ShowResult(0,1);
   elseif (strcmp(action,'EditBSLV'))
     EditBSLV;
     ShowResult(0,1);
   elseif (strcmp(action,'EditMin'))
     g_idx = getappdata(gcbf,'CurrGroupIdx');
     c_idx = getappdata(gcbf,'CurrLVIdx');
     b_idx = getappdata(gcbf,'CurrBehavIdx');
     data = getappdata(gcbf,'BLVData');
     thresh = getappdata(gcbf,'BLVThreshold');
     setting = getappdata(gcbf,'setting');
     old_min_blv = setting.min_blv{g_idx,c_idx,b_idx};

     if str2num(get(gco,'string')) < min(data{g_idx,b_idx}(:,c_idx)) | str2num(get(gco,'string')) > thresh
        msg = ['Valid number should be within [' num2str([min(data{g_idx,b_idx}(:,c_idx)) thresh]) ']'];
        set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
        set(gco,'string',num2str(old_min_blv));
        return;
     end

     bfm_plot_datamatcorrs('PlotBnPress');
   elseif (strcmp(action,'EditMax'))
     g_idx = getappdata(gcbf,'CurrGroupIdx');
     c_idx = getappdata(gcbf,'CurrLVIdx');
     b_idx = getappdata(gcbf,'CurrBehavIdx');
     data = getappdata(gcbf,'BLVData');
     thresh = getappdata(gcbf,'BLVThreshold');
     setting = getappdata(gcbf,'setting');
     old_max_blv = setting.max_blv{g_idx,c_idx,b_idx};

     if str2num(get(gco,'string')) > max(data{g_idx,b_idx}(:,c_idx)) | str2num(get(gco,'string')) < thresh
        msg = ['Valid number should be within [' num2str([thresh max(data{g_idx,b_idx}(:,c_idx))]) ']'];
        set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
        set(gco,'string',num2str(old_max_blv));
        return;
     end

     bfm_plot_datamatcorrs('PlotBnPress');
   elseif (strcmp(action,'UpdatePValue'))
     UpdatePValue;
     ShowResult(0,1);  
   elseif (strcmp(action,'SelectPixel'))
     SelectPixel;
   elseif (strcmp(action,'DeleteNewFigure'))
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         bfm_plot_datamatcorrs_newfig_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'bfm_plot_datamatcorrs_newfig_pos');
      catch
      end
   elseif (strcmp(action,'DeleteFigure'))
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         bfm_plot_datamatcorrs_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'bfm_plot_datamatcorrs_pos');
      catch
      end

     old_setting = getappdata(gcbf,'old_setting');
     setting = getappdata(gcbf,'setting');


     save_display_status = 'off';
     try
        load('pls_profile');
     catch 
     end
     if strcmpi(save_display_status, 'off')
        setting = [];
     end


     if ~isequal(setting, old_setting) & strcmpi(save_display_status, 'on')
%        save_setting = ...
%           questdlg('Would you like to save the display setting?', ...
%			'Save current fields', 'yes', 'no', 'yes');
        if 1	% strcmp(save_setting, 'yes')
           try
%              PLSresultFile = get(findobj(gcbf,'Tag','ResultFile'),'UserData');
 %             setting4 = setting;
  %            save(PLSresultFile, '-append', 'setting4');
           catch
              msg = 'Cannot save setting information';
              msgbox(msg,'ERROR','modal');
           end
        end
     end

%      DeleteLinkedFigure;
%      calling_fig = getappdata(gcf,'CallingFigure');
%      set(calling_fig,'visible','on');
   elseif (strcmp(action,'OpenResponseFnPlot'))
     OpenResponseFnPlot;
   elseif (strcmp(action,'OpenCorrelationPlot'))
     OpenCorrelationPlot;
   elseif (strcmp(action,'OpenDatamatcorrsPlot'))
     OpenDatamatcorrsPlot;
   elseif (strcmp(action,'OpenScoresPlot'))
     bfm_plot_scores_ui(varargin{1});
   elseif (strcmp(action,'OpenDesignPlot'))
     OpenDesignPlot;
   elseif (strcmp(action,'OpenBrainScoresPlot'))
     OpenBrainScoresPlot;
   elseif (strcmp(action,'OpenBrainPlot'))
     OpenBrainPlot;
   elseif (strcmp(action,'OpenEigenPlot'))
     OpenEigenPlot;
   elseif (strcmp(action,'OpenContrastWindow'))
     OpenContrastWindow;
   elseif (strcmp(action,'SetClusterReportOptions')) 
     SetClusterReportOptions;
   elseif (strcmp(action,'LoadClusterReport')) 
     fmri_cluster_report('LoadClusterReport',gcbf);
   elseif (strcmp(action,'OpenClusterReport')) 
     OpenClusterReport;
   elseif (strcmp(action,'LoadBackgroundImage'))
     LoadBackgroundImage;
   elseif (strcmp(action,'SaveBackgroundImage'))
     SaveBackgroundImage;
   elseif (strcmp(action,'LoadResultFile'))
     LoadResultFile;
   elseif (strcmp(action,'SaveResultToIMG'))
     SaveResultToIMG(0);
   elseif (strcmp(action,'SaveDisplayToIMG'))
     SaveResultToIMG(1);
   elseif (strcmp(action,'RescaleBnPress'))
     RescaleBnPress;
     ShowResult(0,1);
   elseif (strcmp(action,'EditXYZ'))
      EditXYZ;
   elseif (strcmp(action,'EditXYZmm'))
      xyz_mm = str2num(get(findobj(gcbf,'tag','XYZmm'),'string'));

      if isempty(xyz_mm) | ~isequal(size(xyz_mm),[1 3])
         msg = 'XYZ(mm) should contain 3 numbers (X, Y, and Z)';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end

      origin = getappdata(gcf,'Origin');
      voxel_size = getappdata(gcf,'STVoxelSize');

      xyz_offset = xyz_mm ./ voxel_size;
      xyz = round(xyz_offset + origin);

      set(findobj(gcbf,'tag','XYZVoxel'), 'string', num2str(xyz));
      EditXYZ;
   elseif (strcmp(action,'orient'))
      orient;
   end;

   return;


%---------------------------------------------------------------------------
%
function h0 = init(PLSResultFile);

   setting4 = [];
   warning off;
   load(PLSResultFile, 'setting4');
   setting = setting4;
   warning on;


   save_display_status = 'off';
   try
      load('pls_profile');
   catch 
   end
   if strcmpi(save_display_status, 'off')
      setting = [];
   end


   save_setting_status = 'on';
   bfm_plot_datamatcorrs_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(bfm_plot_datamatcorrs_pos) & strcmp(save_setting_status,'on')

      pos = bfm_plot_datamatcorrs_pos;

   else

      fig_w = 0.85;
      fig_h = 0.8;
      fig_x = (1 - fig_w)/2;
      fig_y = (1 - fig_h)/2;

      pos = [fig_x fig_y fig_w fig_h];

   end

%   [r_path,r_file,r_ext] = fileparts(PLSResultFile);
   
   h0 = figure('Units','normal', ...
   	'Color',[0.8 0.8 0.8], ...
        'Name','Blocked fMRI BLV Plot', ...
        'NumberTitle','off', ...
   	'DoubleBuffer','on', ...
   	'MenuBar','none',...
   	'Position',pos, ...
   	'DeleteFcn','bfm_plot_datamatcorrs(''DeleteFigure'')', ...
   	'Tag','PlotBrainLV');
   %

   x = .37;
   y = .1;
   w = .5;
   h = .85;

   pos = [x y w h];
   
   axes_h = axes('Parent',h0, ...				% axes
        'Units','normal', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','BlvAxes');

   x = x+w+.02;
   w = .04;

   pos = [x y w h];
   
   colorbar_h = axes('Parent',h0, ...				% c axes
        'Units','normal', ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','Colorbar');
   %

   x = .03;
   y = .91;
   w = .14;
   h = .04;

   pos = [x y w h];

   fnt = 0.6;

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Group Index:', ...
   	'Style','text', ...
   	'Tag','ResultFileLabel');

   x = x+w;
   y = y+.01;
   w = .05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','bfm_plot_datamatcorrs(''EditGroup'')', ...
   	'Tag','GroupIndexEdit');

   x = x+w;
   y = y-.01;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','of', ...
   	'Style','text', ...
        'UserData', PLSResultFile, ...
   	'Tag','ResultFile');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','GroupNumberEdit');

   x = .03;
   y = y-h-.03;
   w = .14;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Condition Index:', ...
   	'Style','text', ...
   	'Tag','LVIndexLabel');

   x = x+w;
   y = y+.01;
   w = .05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','bfm_plot_datamatcorrs(''EditLV'')', ...
   	'Tag','LVIndexEdit');

   x = x+w;
   y = y-.01;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv number label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','of', ...
   	'Style','text', ...
   	'Tag','LVNumberLabel');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv number text
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','LVNumberEdit');

   x = .03;
   y = y-h-.03;
   w = .14;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Behavior Index:', ...
   	'Style','text', ...
   	'Tag','BehavIndexLabel');

   x = x+w;
   y = y+.01;
   w = .05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% behav index edit
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','bfm_plot_datamatcorrs(''EditBehav'')', ...
   	'Tag','BehavIndexEdit');

   x = x+w;
   y = y-.01;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% behav number label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','of', ...
   	'Style','text', ...
   	'Tag','BehavNumberLabel');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% behav number text
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','BehavNumberEdit');



   %  Brain LV

   x = .03;
   y = .3;
   w = .26;
   h = .45;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','ThresholdFrame');

   x = .08;
   y = .72;
   w = .16;
   h = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Datamat Correlations', ...
   	'Style','text', ...
   	'Tag','BLVTitle');


   x = .05;
   y = .67;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Threshold:', ...
   	'Style','text', ...
   	'Tag','ThresholdLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
        'Callback','bfm_plot_datamatcorrs(''PlotBnPress'')', ...
   	'Tag','Threshold');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Curr. Value:', ...
   	'Style','text', ...
   	'Tag','BLVValueLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
   	'Style','text', ...
   	'Tag','BLVValue');

   x = .05;
   y = y-h-.01;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Min. Value:', ...
   	'Style','text', ...
   	'Tag','MinValueLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','bfm_plot_datamatcorrs(''EditMin'')', ...
   	'Tag','MinValue');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Max. Value:', ...
   	'Style','text', ...
   	'Tag','MaxValueLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','bfm_plot_datamatcorrs(''EditMax'')', ...
   	'Tag','MaxValue');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','LV Index:', ...
   	'Style','text', ...
   	'Tag','BSLVIndexLabel');

   x = x+w;
   y = y+.01;
   w = .05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv index edit
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','bfm_plot_datamatcorrs(''EditBSLV'')', ...
   	'Tag','BSLVIndexEdit');


   x = x+w;
   y = y-.01;
   w = .03;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv number label
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','of', ...
   	'Style','text', ...
   	'Tag','BSLVNumberLabel');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv number text
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','BSLVNumberEdit');

   x = .05;
   y = y-h-.01;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','BS Threshold:', ...
   	'Style','text', ...
   	'Tag','BSThresholdLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','bfm_plot_datamatcorrs(''UpdatePValue'')', ...
   	'Tag','BSThreshold');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Min. Ratio:', ...
   	'Style','text', ...
   	'Tag','MinRatioLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
        'Callback','bfm_plot_datamatcorrs(''PlotBnPress'')', ...
   	'Tag','MinRatio');

   x = .05;
   y = y-h;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Max. Ratio:', ...
   	'Style','text', ...
   	'Tag','MaxRatioLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
        'Callback','bfm_plot_datamatcorrs(''PlotBnPress'')', ...
   	'Tag','MaxRatio');


   %  Voxel Location

   x = .03;
   y = .16;
   w = .26;
   h = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','LocationFrame');

   x = .05;
   y = .22;
   w = .07;
   h = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','XYZ:', ...
	'ToolTipString','Absolute coxel coordinates', ...
   	'Style','text', ...
   	'Tag','XYZVoxelLabel');

   x = x+w+0.01;
   y = y+.01;
   w = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','go', ...
	'ToolTipString','Click to select the XYZ you entered', ...
   	'Style','push', ...
   	'Callback','bfm_plot_datamatcorrs(''EditXYZ'')');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
	'ToolTipString','Absolute voxel coordinates', ...
   	'Style','edit', ...
   	'Callback','bfm_plot_datamatcorrs(''EditXYZ'')', ...
   	'Tag','XYZVoxel');

   x = .05;
   y = y-h-0.02;
   w = .07;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','XYZ(mm):', ...
	'ToolTipString','Voxel coordinates w.r.t. the origin', ...
   	'Style','text', ...
   	'Tag','XYZmmLabel');

   x = x+w;
   w = .15;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
	'ToolTipString','Voxel coordinates w.r.t. the origin', ...
   	'Style','edit', ...
   	'Callback','bfm_plot_datamatcorrs(''EditXYZmm'')', ...
   	'Tag','XYZmm');

   x = .05;
   y = .27;
   w = .22;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% rescale button
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
        'HorizontalAlignment', 'left', ...
   	'String','RE-SCALE Brain LV', ...
	'Style','check', ...
	'Value',1, ...
	'Visible','off', ...
	'Callback','bfm_plot_datamatcorrs(''RescaleBnPress'')', ...
   	'Tag','RESCALECheckbox');

   x = .1;
   y = .1;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Callback','close(gcf)', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','CLOSE', ...
   	'Tag','EXITButton');

   x = 0.01;
   y = 0;
   w = .5;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% Message Line
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','MessageLine');

   %  File submenu
   %
   h_file = uimenu('Parent',h0, ...
   	   'Label','&File', ...
   	   'Tag','FileMenu', ...
   	   'Visible','on');
   h2 = uimenu(h_file, ...
           'Label','&Load Background Image', ...
   	   'Tag','LoadBGImage', ...
           'Callback','bfm_plot_datamatcorrs(''LoadBackgroundImage'')'); 
   h2 = uimenu(h_file, ...
           'Label','Save brain region to IMG file', ...
   	   'Tag','SaveBGImage', ...
           'Callback','bfm_plot_datamatcorrs(''SaveBackgroundImage'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Load PLS Result', ...
   	   'Tag','LoadPLSResult', ...
		'visible', 'off', ...
           'Callback','bfm_plot_datamatcorrs(''LoadResultFile'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Save Current Display to the IMG files', ...
   	   'Tag','SaveDisplayToIMG', ...
           'Callback','bfm_plot_datamatcorrs(''SaveDisplayToIMG'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Save DatamatCorrelation to IMG file', ...
   	   'Tag','SaveResultToIMG', ...
           'Callback','bfm_plot_datamatcorrs(''SaveResultToIMG'')'); 
   h2 = uimenu(h_file, ...
           'Label','Create Datamat Correlations &Figure', ...
   	   'Tag','PlotNewFigure', ...
           'Callback','bfm_plot_datamatcorrs(''PlotOnNewFigure'')'); 

   rri_file_menu(h0);

   % Xhair submenu
   %
   h_xhair = uimenu('Parent',h0, 'Label','Crosshair');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Crosshair off', ...
	   'Userdata', 0, ...
           'Callback','pet_result_ui(''crosshair'')', ...
   	   'Tag','XhairToggleMenu');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Color ...', ...
	   'Userdata', [1 0 0], ...
           'Callback','pet_result_ui(''set_xhair_color'')', ...
   	   'Tag','XhairColorMenu');

   % Zoom submenu
   %
   h2 = uimenu('Parent',h0, ...
   	   'Label','&Zoom on', ...
	   'Userdata', 1, ...
           'Callback','bfm_plot_datamatcorrs(''Zooming'')', ...
   	   'Tag','ZoomToggleMenu');

   % Rotate submenu
   %
   h_rot = uimenu('Parent',h0, ...
   	   'Label','&Image Rotation', ...
   	   'Tag','RotationMenu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&none', ...
   	   'Checked','on', ...
           'Callback','bfm_plot_datamatcorrs(''Rotation'',1)', ...
   	   'Tag','Rotate0Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&90 degree', ...
   	   'Checked','off', ...
           'Callback','bfm_plot_datamatcorrs(''Rotation'',2)', ...
   	   'Tag','Rotate90Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&180 degree', ...
   	   'Checked','off', ...
           'Callback','bfm_plot_datamatcorrs(''Rotation'',3)', ...
   	   'Tag','Rotate180Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&270 degree', ...
   	   'Checked','off', ...
           'Callback','bfm_plot_datamatcorrs(''Rotation'',0)', ...
   	   'Tag','Rotate270Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','Convert Orientation', ...
	   'separator', 'on', ...
           'Callback','bfm_plot_datamatcorrs(''orient'',0)', ...
		'visible', 'off', ...
   	   'Tag','orient');

   %  Window submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Windows', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','off');
   h2 = uimenu(h_pls, ...
           'Label','&Singular Values Plot', ...
     	   'Tag','OpenEigenPlot', ...
           'Callback','bfm_plot_datamatcorrs(''OpenEigenPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Behavior LV and Behavior Scores Plot', ...
     	   'Tag','OpenBehavPlot', ...
           'Visible', 'off', ...
           'Callback','bfm_plot_datamatcorrs(''OpenScoresPlot'',0)');
   h2 = uimenu(h_pls, ...
           'Label','&Design Scores and LVs Plot', ...
     	   'Tag','OpenDesignPlot', ...
           'Visible', 'off', ...
           'Callback','bfm_plot_datamatcorrs(''OpenDesignPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','B&rain Scores vs. Behavior Data Plot', ...
     	   'Tag','OpenBrainPlot', ...
           'Visible', 'off', ...
           'Callback','bfm_plot_datamatcorrs(''OpenBrainPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Brain Scores Plot', ...
     	   'Tag','OpenBrainScoresPlot', ...
	'visible','off', ...
           'Callback','bfm_plot_datamatcorrs(''OpenBrainScoresPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Response', ...
     	   'Tag','OpenRF1Plot', ...
           'Callback','bfm_plot_datamatcorrs(''OpenCorrelationPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Plot', ...
     	   'Tag','OpenDatamatcorrsPlot', ...
           'Callback','bfm_plot_datamatcorrs(''OpenDatamatcorrsPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Contrasts Information', ...
     	   'Tag','OpenContrastWindow', ...
           'Callback','bfm_plot_datamatcorrs(''OpenContrastWindow'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Create Brain LV &Figure', ...
	   'separator', 'on', ...
   	   'Tag','PlotNewFigure', ...
           'Callback','bfm_plot_datamatcorrs(''PlotOnNewFigure'')'); 


   %  Report submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Report', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','off');
   h2 = uimenu(h_pls, ...
           'Label','&Set Cluster Report Options', ...
     	   'Tag','SetClusterReportOptions', ...
           'Callback','bfm_plot_datamatcorrs(''SetClusterReportOptions'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Load Cluster Report', ...
     	   'Tag','LoadClsuterReport', ...
           'Callback','bfm_plot_datamatcorrs(''LoadClusterReport'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Create Cluster Report', ...
     	   'Tag','OpenClusterReport', ...
           'Callback','bfm_plot_datamatcorrs(''OpenClusterReport'')'); 

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
		'visible', 'off', ...
           'Tag', 'Help');
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','rri_helpfile_ui(''bfm_result_hlp.txt'',''How to use PLS RESULT'');', ...
	   'visible', 'off', ...
           'Tag', 'How');
   Hm_new = uimenu('Parent',Hm_topHelp, ...
           'Label', '&What''s new', ...
	   'Callback','rri_helpfile_ui(''whatsnew.txt'',''What''''s new'');', ...
           'Tag', 'New');
   Hm_about = uimenu('Parent',Hm_topHelp, ...
           'Label', '&About this program', ...
           'Tag', 'About', ...
           'CallBack', 'plsgui_version');

   set(gcf,'Name',sprintf('Blocked fMRI BLV Plot: %s',PLSResultFile));
   set(colorbar_h,'units','normal');

   setappdata(gcf,'Colorbar',colorbar_h);
   setappdata(gcf,'BlvAxes',axes_h);

   setappdata(gcf,'ClusterMinSize',5);
   setappdata(gcf,'ClusterMinDist',10);

   setappdata(gcf,'setting',setting);
   setappdata(gcf,'old_setting',setting);

   setappdata(gcf,'img_xhair',[]);

   return;						% init


%---------------------------------------------------------------------------
%
function DeleteLinkedFigure()

   rf_plot = getappdata(gcbf,'RFPlotHdl');
   if ~isempty(rf_plot) & ishandle(rf_plot)
     close(rf_plot);
   end;

   scores_fig = getappdata(gcbf,'ScorePlotHdl');
   if ~isempty(scores_fig)
     close(scores_fig);
   end;

   bscores_fig = getappdata(gcbf,'BSPlotHdl');
   if ~isempty(bscores_fig) & ishandle(bscores_fig)
     close(bscores_fig);
   end;

   eigen_fig = getappdata(gcbf,'EigenPlotHdl');
   if ~isempty(eigen_fig) & ishandle(eigen_fig)
     close(eigen_fig);
   end;

   brain_fig = getappdata(gcbf,'brain_plot');
   if ~isempty(brain_fig) & ishandle(brain_fig)
     close(brain_fig);
   end;

   contrast_fig = getappdata(gcbf,'ContrastFigHdl');
   if ~isempty(contrast_fig) & ishandle(contrast_fig)
     close(contrast_fig);
   end;
   
   return;						% DeleteLinkedFigure


%---------------------------------------------------------------------------
%
function rot_amount = load_pls_result()

   %  wait message
   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   msg = 'Loading PLS result ... please wait';
   set(findobj(gcf,'Tag','MessageLine'),'String',msg);

   h = findobj(gcf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');

   load(PLSresultFile);

   if exist('result','var')
      if ismember(method, [1 2])
         designlv = result.v;
      end

      if ismember(method, [3 5])
         behavlv = result.v;
      end

      if ismember(method, [4 6])
         ismultiblock = 1;
      end

      brainlv = result.u;
      s = result.s;
      num_conditions = result.num_conditions;
      num_subj_lst = result.num_subj_lst;
      subj_group = result.num_subj_lst;

      if isfield(result,'bscan')
         bscan = result.bscan;
      end

      if isfield(result,'datamatcorrs_lst')
         datamatcorrs_lst = result.datamatcorrs_lst;
      end

      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end
   end


   if exist('bscan','var') & ~isempty(bscan)
      num_conditions = length(bscan);
   end

if(0)
   if exist('datamatcorrs_lst','var')
      setappdata(gcf,'isbehav',1);
   else
      setappdata(gcf,'isbehav',0);
      set(findobj(gcf,'tag','OpenRF1Plot'), 'visible', 'off');
   end

   if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
   end
end

   setting = getappdata(gcf,'setting');



   bsr = [];
   if exist('boot_result','var') & ~isempty(boot_result)
      bsr = boot_result.compare;
   end

   if ~isempty(setting) & isfield(setting,'orient')
      dims = setting.orient.dims;
      origin_pattern = setting.orient.pattern;

      old_coord = st_coords;
      new_coord = setting.orient.coords;

      if exist('datamatcorrs_lst','var') & ~isempty(datamatcorrs_lst)
         for i=1:length(datamatcorrs_lst)
            blv = [datamatcorrs_lst{i}]';
            blv = rri_xy_orient_data(blv,old_coord,new_coord,dims,origin_pattern);
            datamatcorrs_lst{i} = blv';
         end
      end

      if ~isempty(bsr)
         bsr =rri_xy_orient_data(bsr,old_coord,new_coord,dims,origin_pattern);
      end
   end



   if isempty(setting)
      grp_idx = 1;					% group idx
      lv_idx = 1;					% condition idx
      bs_lv_idx = 1;
      behav_idx = 1;					% behavior idx
      rot_amount = 1;
   else
      grp_idx = setting.grp_idx;
      lv_idx = setting.lv_idx;
      if isfield(setting, 'bs_lv_idx')
         bs_lv_idx = setting.bs_lv_idx;
      else
         bs_lv_idx = 1;
      end
      behav_idx = setting.behav_idx;
      rot_amount = setting.rot_amount;
   end;

   num_grp = length(num_subj_lst);
   num_lv = num_conditions;
   bs_num_lv = size(brainlv,2);

   brainlv = datamatcorrs_lst{grp_idx};
   num_behav = size(brainlv, 1) / num_conditions;

   if exist('behavlv','var')
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'On');
   elseif exist('designlv','var')
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'Off');
   end

   h = findobj(gcf,'Tag','GroupIndexEdit');
   set(h,'String',num2str(grp_idx),'Userdata',grp_idx);
   h = findobj(gcf,'Tag','GroupNumberEdit');
   set(h,'String',num2str(num_grp),'Userdata',num_grp);
   h = findobj(gcf,'Tag','LVIndexEdit');
   set(h,'String',num2str(lv_idx),'Userdata',lv_idx);
   h = findobj(gcf,'Tag','LVNumberEdit');
   set(h,'String',num2str(num_lv),'Userdata',num_lv);

   h = findobj(gcf,'Tag','BSLVIndexEdit');
   set(h,'String',num2str(bs_lv_idx),'Userdata',bs_lv_idx);
   h = findobj(gcf,'Tag','BSLVNumberEdit');
   set(h,'String',num2str(bs_num_lv),'Userdata',bs_num_lv);

   h = findobj(gcf,'Tag','BehavIndexEdit');
   set(h,'String',num2str(behav_idx),'Userdata',behav_idx);
   h = findobj(gcf,'Tag','BehavNumberEdit');
   set(h,'String',num2str(num_behav),'Userdata',num_behav);

   brainlv_lst = {};

   for g = 1:num_grp

      brainlv = datamatcorrs_lst{g};		% borrow 'blv' name to reuse code

      r = size(brainlv, 1) / num_conditions;
      c = size(brainlv, 2);

      for b = 1:num_behav

         mask = [0:(num_conditions-1)]*num_behav + b;
         tmp = brainlv(mask, :);
         tmp = tmp';
         brainlv_lst{g,b} = tmp;

%      for i = 1:num_conditions
%         tmp{i} = brainlv(r*(i-1)+1:r*i, :);
%      end  
%
%      brainlv = ones(num_conditions, c);
%
%      for i = 1:num_conditions
%         brainlv(i,:) = mean(tmp{i},1);
%      end
%
%      brainlv = brainlv';
%      brainlv_lst{g} = brainlv;

      end
   end


   setappdata(gcf,'brainlv',brainlv_lst);
   setappdata(gcf, 's', s);
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   if ~exist('boot_result','var') | isempty(boot_result)
      ToggleView(0);
      set(findobj(gcf,'Tag','ViewMenu'),'Visible','off');
   else					% show bootstrap ratio if exist
      ToggleView(1);
      set(findobj(gcf,'Tag','ViewMenu'),'Visible','on');

      % set the bootstrap ratio field values
      %
      setappdata(gcf,'BSRatio',bsr);
      set_bs_fields(bs_lv_idx);
      UpdatePValue;
   end;

   h = findobj(gcf,'Tag','OpenContrastWindow');
   if 1 % isequal(ContrastFile,'NONE') | isequal(ContrastFile,'BEHAV')
      set(h,'Visible','off');
   else
      set(h,'Visible','on');
   end;

   set(gcf,'Pointer',old_pointer);
   set(findobj(gcf,'Tag','MessageLine'),'String','');

   setappdata(gcf,'SessionFileList', SessionProfiles);
   setappdata(gcf,'RotateAmount',rot_amount);
   setappdata(gcf,'CurrGroupIdx',grp_idx);
   setappdata(gcf,'CurrBehavIdx',behav_idx);
   setappdata(gcf,'NumGroup',num_grp);
   setappdata(gcf,'CurrLVIdx',lv_idx);
   setappdata(gcf,'CurrBSLVIdx',bs_lv_idx);
%   setappdata(gcf,'STDims',st_dims);
   setappdata(gcf,'NumBSLVs',bs_num_lv)

   return;						% load_pls_result


%-------------------------------------------------------------------------
%
function OpenResponseFnPlot()

  sessionFileList = getappdata(gcbf,'SessionFileList');

  rf_plot = getappdata(gcf,'RFPlotHdl');
  if ~isempty(rf_plot)
      msg = 'ERROR: Response function plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  rf_plot = fmri_plot_rf('LINK',sessionFileList);
  link_info.hdl = gcbf;
  link_info.name = 'RFPlotHdl';
  setappdata(rf_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'RFPlotHdl',rf_plot);

  %  make sure the Coord of the Response Function Plot contains 
  %  the current point in the Response
  %
  cur_coord = getappdata(gcf,'Coord');
  setappdata(rf_plot,'Coord',cur_coord);

  return;					% OpenResponseFnPlot


%-------------------------------------------------------------------------
%
function SetClusterReportOptions()

   st_origin = getappdata(gcbf,'Origin');
   st_dims = getappdata(gcbf,'STDims');
   cluster_min_size = getappdata(gcbf,'ClusterMinSize');
   cluster_min_dist = getappdata(gcbf,'ClusterMinDist');

   if isempty(st_origin) | all(st_origin == 0)

      st_voxel_size = getappdata(gcf,'STVoxelSize');

      if all(st_dims == [40 48 1 34]) & all(st_voxel_size == [4 4 4])
         st_origin = [20 29 12];
      elseif all(st_dims == [91 109 1 91]) & all(st_voxel_size == [2 2 2])
         st_origin = [46 64 37];
      else
         % according to SPM: if the origin field contains 0, then the origin is
         % assumed to be at the center of the volume.
         %
         st_origin = floor((dims([1 2 4])+1)/2);
         % st_origin = round(st_dims([1 2 4])/2);
      end;
   end;

   prompt = {'Minimum cluster size (in voxels)',  ...
	     'Minimum distance (in mm) between cluster peaks', ...
	     'Origin location (in voxels)' };
   defValues = { num2str(cluster_min_size), ...
		 num2str(cluster_min_dist), ...
		 num2str(st_origin)};
   dlgTitle='Cluster Report Options';
   lineNo = 1;
   answer = inputdlg(prompt,dlgTitle,lineNo,defValues);

   if isempty(answer),
      return;
   end;

   invalid_options = 0;
   min_size = str2num(answer{1}); 
   min_dist = str2num(answer{2}); 
   origin_xyz = str2num(answer{3}); 

   if isempty(min_size) | isempty(min_dist) | isempty(origin_xyz)
      invalid_options = 1;
   elseif (min_size <= 0) | (min_dist <= 0) | (sum(origin_xyz<= 0) ~= 0)
      invalid_options = 1;
   end;   
   
   if (invalid_options)
	msg = 'Invalid cluster report options.  Options do not changed';
	set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
	return;
   end;

   setappdata(gcbf,'Origin',origin_xyz);
   setappdata(gcbf,'ClusterMinSize',min_size);
   setappdata(gcbf,'ClusterMinDist',min_dist);

   return;					% SetClusterReportOptions


%-------------------------------------------------------------------------
%
function OpenClusterReport()

   %  wait message
   old_pointer = get(gcbf,'Pointer');
   set(gcbf,'Pointer','watch');

   msg = 'Generating Cluster Report ... please wait';
   h = rri_wait_box(msg, [0.5 0.1]);

   cluster_min_size = getappdata(gcbf,'ClusterMinSize');
   cluster_min_dist = getappdata(gcbf,'ClusterMinDist');

   fmri_cluster_report(cluster_min_size,cluster_min_dist);


   set(gcbf,'Pointer',old_pointer);
   set(findobj(gcbf,'Tag','MessageLine'),'String','');

   delete(h);

   return;					% OpenClusterReport


%-------------------------------------------------------------------------
function OpenContrastWindow()

   contrast_fig = getappdata(gcbf,'ContrastFigHdl');
   if ~isempty(contrast_fig)
      msg = 'ERROR: Constrasts information has already been dispalyed.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   h = findobj(gcbf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');

   load(PLSresultFile,'ContrastFile','SessionProfiles');

   if isequal(ContrastFile,'NONE'), 
      msg = 'No contrast was used for this PLS analysis.'; 
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   if isequal(ContrastFile,'HELMERT'),   % using Helmert matrix for contrasts
      load(SessionProfiles{1}{1});

      conditions = session_info.condition;
      num_conditions = length(conditions);
      helmert_contrasts = rri_helmert_matrix(num_conditions);

      for i=1:num_conditions-1,
         pls_contrasts(i).name = sprintf('Contrast #%d',i);
         pls_contrasts(i).value = helmert_contrasts(:,i)';
      end;
   else
      try
         load(ContrastFile);
      catch 
         msg = sprintf('ERROR: Cannot open contrast file "%s".',ContrastFile); 
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end;
   end;

   contrast_fig = fmri_input_contrast_ui(pls_contrasts,conditions,1);

   link_info.hdl = gcbf;
   link_info.name = 'ContrastFigHdl';
   setappdata(contrast_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'ContrastFigHdl',contrast_fig);

   return;					% OpenContrastWindow


%-------------------------------------------------------------------------
%
function OpenDesignPlot()


   scores_fig = getappdata(gcbf,'ScorePlotHdl');
   if ~isempty(scores_fig)
      msg = 'ERROR: Design Scores Plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   h = findobj(gcbf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');

   scores_fig = fmri_plot_scores('LINK',PLSresultFile);

   lv_idx = getappdata(gcbf,'CurrLVIdx');
   if (lv_idx ~= 1)
      fmri_plot_scores('UPDATE_LV_SELECTION',scores_fig,lv_idx);
   end;

   link_info.hdl = gcbf;
   link_info.name = 'ScorePlotHdl';
   setappdata(scores_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'ScorePlotHdl',scores_fig);

   return;					% OpenDesignPlot


%-------------------------------------------------------------------------
%
function OpenBrainScoresPlot()


  bs_plot = getappdata(gcf,'BSPlotHdl');
  if ~isempty(bs_plot)
      msg = 'ERROR: Brain score plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  sessionFileList = getappdata(gcbf,'SessionFileList');

  h = findobj(gcbf,'Tag','ResultFile');
  PLSresultFile = get(h,'UserData');


  bs_plot = fmri_plot_brain_scores('LINK',sessionFileList,PLSresultFile);
  link_info.hdl = gcbf;
  link_info.name = 'BSPlotHdl';
  setappdata(bs_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'BSPlotHdl',bs_plot);

  return;					% OpenBrainScoresPlot


%-------------------------------------------------------------------------
%
function SaveResultToIMG(is_disp)
%

  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');

  try 				% load the dimension info of the st_datamat
     load(PLSresultFile,'st_dims'),
  catch
     msg =sprintf('ERROR: Cannot load the PLS result file "%s".',PLSresultFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  h = findobj(gcf,'Tag','LVIndexEdit');  lv_idx = get(h,'Userdata');
  curr_lv_idx = getappdata(gcf,'CurrLVIdx');
  if (lv_idx ~= curr_lv_idx),
     lv_idx = curr_lv_idx;
     set(h,'String',num2str(lv_idx));
  end;

  h = findobj(gcf,'Tag','GroupIndexEdit');  grp_idx = get(h,'Userdata');
  curr_grp_idx = getappdata(gcf,'CurrGroupIdx');
  if (grp_idx ~= curr_grp_idx),
     grp_idx = curr_grp_idx;
     set(h,'String',num2str(grp_idx));
  end;

  h = findobj(gcf,'Tag','BehavIndexEdit');  behav_idx = get(h,'Userdata');
  curr_behav_idx = getappdata(gcf,'CurrBehavIdx');
  if (behav_idx ~= curr_behav_idx),
     behav_idx = curr_behav_idx;
     set(h,'String',num2str(behav_idx));
  end;

  old_pointer = get(gcf,'Pointer');
  fig_hdl = gcf;
  set(fig_hdl,'Pointer','watch');

  if 1 % (getappdata(gcf,'ViewBootstrapRatio') == 0),	% save brain lv 
     thresh = getappdata(gcf,'BLVThreshold'); 
     if is_disp
        create_st_brainlv_disp(PLSresultFile,lv_idx,thresh,grp_idx,behav_idx);
     else
        create_st_brainlv_img(PLSresultFile,lv_idx,thresh,grp_idx,behav_idx);
     end
  else							% save bootstrap ratio
     thresh_ratio = getappdata(gcf,'BSThreshold');  
     create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio);
  end;

  set(fig_hdl,'Pointer',old_pointer);

  return;					% SaveResultToIMG


%--------------------------------------------------------------------------
function create_st_brainlv_disp(PLSresultFile,lv_idx,thresh_ratio,grp_idx,behav_idx);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-11);

  image_fn = sprintf('%sBfMRIdatcorr_disp_grp%d_cond%d_beh%d.img',resultfile_prefix,grp_idx,lv_idx,behav_idx);

  [filename, pathname] = rri_selectfile(image_fn,'Datamat Correlation IMG file');

  img_file = [pathname, filesep, filename];

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
  load(PLSresultFile,'st_dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');

  dims = st_dims([1 2 4]);
  newcoords = st_coords;

  blv = getappdata(gcbf,'BLVData');
  brainlv = blv{grp_idx, behav_idx};

  %  save background to img
  %
  brainlv = brainlv(:,lv_idx);


   bs = getappdata(gcbf,'BSRatio');
   h = findobj(gcf,'Tag','BSLVIndexEdit'); bs_lv_idx = str2num(get(h,'String'));
   h = findobj(gcf,'Tag','BSThreshold'); bs_thresh = str2num(get(h,'String'));
   bs = bs(:, bs_lv_idx);
   bs_strong = zeros(size(bs));
   bs_idx = [find(bs <=- bs_thresh); find(bs >= bs_thresh)];
   bs_strong(bs_idx) = 1;
   brainlv = brainlv .* bs_strong;


  bg_img = getappdata(gcf,'BackgroundImg');
  cmap = getappdata(gcf,'cmap');
  num_blv_colors = 25;
  brain_region_color_idx = 51;
  first_lower_color_idx = 101;
  first_upper_color_idx = 126;
  h = findobj(gcf,'Tag','MaxValue'); max_blv = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','MinValue'); min_blv = str2num(get(h,'String'));
  too_large = find(brainlv > max_blv); brainlv(too_large) = max_blv;
  too_small = find(brainlv < min_blv); brainlv(too_small) = min_blv;

  % Create the image slices in which voxels are set to be within certain range
  %
  lower_interval = (abs(min_blv) - thresh_ratio) / (num_blv_colors-1);
  upper_interval = (max_blv - thresh_ratio) / (num_blv_colors-1);

  blv = zeros(1,length(newcoords)) + brain_region_color_idx;
  lower_idx = find(brainlv <= -thresh_ratio);
  blv_offset = brainlv(lower_idx) - min_blv; 
  lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
  blv(lower_idx) = lower_color_idx;

  upper_idx = find(brainlv >= thresh_ratio);
  blv_offset = max_blv - brainlv(upper_idx); 
  upper_color_idx = num_blv_colors - round(blv_offset/upper_interval);
  upper_color_idx = upper_color_idx + first_upper_color_idx - 1;
  blv(upper_idx) = upper_color_idx;

  if isempty(bg_img)
     non_brain_region_color_idx = size(cmap,1);
     img = zeros(1,dims(1)*dims(2)*dims(3)) + non_brain_region_color_idx;
     img(newcoords) = blv;
     img = reshape(img,dims); 
  else
     max_bg = max(bg_img(:));
     min_bg = min(bg_img(:));
     img = (bg_img - min_bg) / (max_bg - min_bg) * 100;
     img(newcoords(lower_idx)) = blv(lower_idx);
     img(newcoords(upper_idx)) = blv(upper_idx);
     img = reshape(img,dims); 
  end

%  img = zeros(dims);

%  blv = brainlv(1,lv_idx); 
%  blv(abs(blv) < thresh_ratio) = 0;

%  img(st_coords) = blv;
     
  descrip = sprintf('DatamatCorrelation from %s, Group: %d, Condition: %d, Behavior: %d, Threshold: %8.5f', ...
		PLSresultFile,grp_idx,lv_idx,behav_idx,thresh_ratio);
  rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);

  %  save background to img
  %
  [tmp filename] = fileparts(filename);
  filename = [filename '_cmap'];
  save(filename,'cmap');

  return;					% create_st_brainlv_disp


%--------------------------------------------------------------------------
function create_st_brainlv_img(PLSresultFile,lv_idx,thresh_ratio,grp_idx,behav_idx);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-11);

  image_fn = sprintf('%sBfMRIdatcorr_grp%d_cond%d_beh%d.img',resultfile_prefix,grp_idx,lv_idx,behav_idx);

  [filename, pathname] = rri_selectfile(image_fn,'Datamat Correlation IMG file');

  img_file = [pathname, filesep, filename];

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
  load(PLSresultFile,'st_dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');

  dims = st_dims([1 2 4]);
  img = zeros(dims);

  blv = getappdata(gcbf,'BLVData');
  brainlv = blv{grp_idx, behav_idx};

  blv = brainlv(:,lv_idx); 


   bs = getappdata(gcbf,'BSRatio');
   h = findobj(gcf,'Tag','BSLVIndexEdit'); bs_lv_idx = str2num(get(h,'String'));
   h = findobj(gcf,'Tag','BSThreshold'); bs_thresh = str2num(get(h,'String'));
   bs = bs(:, bs_lv_idx);
   bs_strong = zeros(size(bs));
   bs_idx = [find(bs <=- bs_thresh); find(bs >= bs_thresh)];
   bs_strong(bs_idx) = 1;
   blv = blv .* bs_strong;


  blv(abs(blv) < thresh_ratio) = 0;

  img(st_coords) = blv;
     
  descrip = sprintf('DatamatCorrelation from %s, Group: %d, Condition: %d, Behavior: %d, Threshold: %8.5f', ...
		PLSresultFile,grp_idx,lv_idx,behav_idx,thresh_ratio);
  rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);

  return;					% create_st_brainlv_img


%--------------------------------------------------------------------------
function create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-11);
  image_fn = [resultfile_prefix, 'BfMRIbsr.img'];

  [filename, pathname] = rri_selectfile(image_fn,'Bootstrap Result IMG file');

  img_file = [pathname, filesep, filename];

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
  load(PLSresultFile,'boot_result','st_dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');

   if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
   end

  bs_ratio = boot_result.compare_brain;

  dims = st_dims([1 2 4]);
  img = zeros(dims);

  bsr = bs_ratio(1,lv_idx); 

  bsr(abs(bsr) < thresh_ratio) = 0;

  img(st_coords) = bsr;
     
  descrip = sprintf('Bootstrap ratio from %s, LV: %d, Threshold: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio);
  rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);

  return;					% create_bs_ratio_img


%--------------------------------------------------------------------------
function [st_filename] = get_st_datamat_filename(sessionFileList,with_path)
%
%   INPUT:
%       sessionFileList - vector of cell structure, each element contains
%                         the full path of a session file.
%       with_path - whether including path in the constructed the filename 
%                   of the st_datamat. 
%		    with_path = 0 : no path 
%		    with_path = 1 : including path
%
  num_files = length(sessionFileList);
  st_filename = cell(1,num_files);

  for i=1:num_files,
     load( sessionFileList{i} );
     if with_path,
       st_filename{i} = sprintf('%s/%s_BfMRIdatamat.mat', ...
                     session_info.pls_data_path, session_info.datamat_prefix);
     else
       st_filename{i} = sprintf('%s_BfMRIdatamat.mat', ...
                                                 session_info.datamat_prefix);
     end;
  end;

  return;					% get_st_datamat_name


%--------------------------------------------------------------------------
%
function ToggleView(view_state)

   if ~exist('view_state','var') | isempty(view_state),
      view_state = ~(getappdata(gcf,'ViewBootstrapRatio'));
   end;

   if (view_state == 0)			% view brain lv
      setappdata(gcf,'ViewBootstrapRatio',0);
      bs_visibility = 'off';
   else					% view bootstrap ratio
      setappdata(gcf,'ViewBootstrapRatio',1);
      bs_visibility = 'on';
   end;

   %  set visibility of the bootstrap fields
   %
   set(findobj(gcf,'Tag','BSLVIndexLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSLVIndexEdit'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSLVNumberLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSLVNumberEdit'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSThresholdLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSThreshold'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','MinRatioLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','MinRatio'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','MaxRatioLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','MaxRatio'),'enable',bs_visibility);

   %  update menu labels
   %
   PLSResultFile = get(findobj(gcf,'Tag','ResultFile'),'UserData');
   fig_title = sprintf('Blocked fMRI Datamat Correlations Plot: %s',PLSResultFile);
   set(gcf,'Name',fig_title);

   EditXYZ;

   return;					% ToggleView


%--------------------------------------------------------------------------
function EditGroup()

   old_grp_idx = getappdata(gcf,'CurrGroupIdx');	% save old grp_idx
   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   behav_idx_hdl = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = str2num(get(behav_idx_hdl,'String'));

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(grp_idx),
      msg = 'ERROR: Invalid input for the Group index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(grp_idx_hdl,'String',num2str(old_grp_idx));
      return;
   end;

   if ( grp_idx == old_grp_idx)  % LV does not changed do nothing
      return;
   end;

   num_grp = getappdata(gcf,'NumGroup');
   if (grp_idx < 1 | grp_idx > num_grp)
      msg = 'ERROR: Input Group index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(grp_idx_hdl,'String',num2str(old_grp_idx));
      return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   set(grp_idx_hdl,'Userdata',grp_idx);
   setappdata(gcf,'CurrGroupIdx',grp_idx);

   set(gcf,'Pointer',old_pointer);

   EditXYZ;

   return;					% EditGroup


%--------------------------------------------------------------------------
function EditBehav()

   old_behav_idx = getappdata(gcf,'CurrBehavIdx');	% save old behav_idx
   behav_idx_hdl = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = str2num(get(behav_idx_hdl,'String'));

   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(behav_idx),
      msg = 'ERROR: Invalid input for the Behavior index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(behav_idx_hdl,'String',num2str(old_behav_idx));
      return;
   end;

   if ( behav_idx == old_behav_idx)
      return;
   end;

   num_behav = getappdata(gcf,'NumBehav');
   if (behav_idx < 1 | behav_idx > num_behav)
      msg = 'ERROR: Input Behavior index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(behav_idx_hdl,'String',num2str(old_behav_idx));
      return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   set(behav_idx_hdl,'Userdata',behav_idx);
   setappdata(gcf,'CurrBehavIdx',behav_idx);

   set(gcf,'Pointer',old_pointer);

   EditXYZ;

   return;					% EditBehav


%--------------------------------------------------------------------------
function EditLV()

   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   behav_idx_hdl = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = str2num(get(behav_idx_hdl,'String'));

   old_lv_idx = getappdata(gcf,'CurrLVIdx');		% save old lv_idx
   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(lv_idx),
      msg = 'ERROR: Invalid input for Condition index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(old_lv_idx));
      return;
   end;

   if ( lv_idx == old_lv_idx)  % LV does not changed do nothing
      return;
   end;

   num_lv = getappdata(gcf,'NumLVs');
   if (lv_idx < 1 | lv_idx > num_lv)
      msg = 'ERROR: Input Condition index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(old_lv_idx));
      return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   set(lv_idx_hdl,'Userdata',lv_idx);
   setappdata(gcf,'CurrLVIdx',lv_idx);

   set(gcf,'Pointer',old_pointer);

   EditXYZ;

   return;					% EditLV


%--------------------------------------------------------------------------
function EditBSLV()

   old_lv_idx = getappdata(gcf,'CurrBSLVIdx');		% save old lv_idx
   lv_idx_hdl = findobj(gcbf,'Tag','BSLVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(lv_idx),
      msg = 'ERROR: Invalid input for the LV index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(old_lv_idx));
      return;
   end;

   if ( lv_idx == old_lv_idx)  % LV does not changed do nothing
      return;
   end;

   num_lv = getappdata(gcf,'NumBSLVs');
   if (lv_idx < 1 | lv_idx > num_lv)
      msg = 'ERROR: Input LV index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(old_lv_idx));
      return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   %  update the brainlv and bootstrap ratio fields
   %
   set_bs_fields(lv_idx);

   set(lv_idx_hdl,'Userdata',lv_idx);
   setappdata(gcf,'CurrBSLVIdx',lv_idx);

   set(gcf,'Pointer',old_pointer);
   UpdatePValue;

   return;					% EditBSLV


%--------------------------------------------------------------------------
function UpdatePValue()

   h = findobj(gcf,'Tag','BSThreshold');    
   bootstrap_ratio = str2num(get(h,'String'));

   if isempty(bootstrap_ratio),
      msg = 'ERROR: Invalid input for bootstrap ratio.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;


   h = findobj(gcf,'Tag','BSLVIndexEdit');  
   bs_lv_idx = get(h,'Userdata');

   bs_ratio = getappdata(gcf,'BSRatio');
   curr_bs_ratio = bs_ratio(:,bs_lv_idx);
   curr_bs_ratio = curr_bs_ratio(find(isnan(curr_bs_ratio) == 0));

   idx = find(abs(curr_bs_ratio) < std(curr_bs_ratio) * 5); % avoid the outliers
   std_ratio = std(curr_bs_ratio(idx));

   p_value = ratio2p(bootstrap_ratio,0,1);	%std_ratio);
   set(findobj(gcf,'Tag','PValue'), 'String',sprintf('%7.4f',p_value));

   return;					% UpdatePValue


%--------------------------------------------------------------------------
function LoadResultFile()

   [PLSresultFile,PLSresultFilePath] = ...
                         rri_selectfile('*_BfMRIresult.mat','Open PLS Result');
   if isequal(PLSresultFilePath,0), return; end;

   PLSResultFile = [PLSresultFilePath,PLSresultFile];

   DeleteLinkedFigure;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','arrow');

   h = findobj(gcf,'Tag','ResultFile');
   [r_path, r_file, r_ext] = fileparts(PLSResultFile);
   set(h,'UserData', PLSResultFile,'String',r_file);

   % set(gcf,'Name',sprintf('PLS Brain Latent Variable Plot: %s',PLSResultFile));

   load_pls_result;
   ShowResult(0,1);

   % reset 'Checked' mark for new result file
   %
   h = findobj(gcf,'Tag','Rotate0Menu');
   set(h,'Checked','on');
   h = findobj(gcf,'Tag','Rotate90Menu');
   set(h,'Checked','off');
   h = findobj(gcf,'Tag','Rotate180Menu');
   set(h,'Checked','off');
   h = findobj(gcf,'Tag','Rotate270Menu');
   set(h,'Checked','off');

   set(gcf,'Pointer',old_pointer);

   return;					% LoadResultFile


%--------------------------------------------------------------------------
function LoadBackgroundImage()

   [bg_img_file,bg_img_path] = ...
                         rri_selectfile('*.img','Load background image');
   if (bg_img_path == 0), return; end;

   BgImgFile = [bg_img_path,bg_img_file];

   %  make sure the dimension of the bg image is same as the raw images
   try 
     bg_dims = rri_imginfo(BgImgFile);
     bg_dims = [bg_dims(1) bg_dims(2) 1 bg_dims(3)];
   catch
     msg =sprintf('ERROR: Cannot load the background image "%s".',BgImgFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
   end;

   if ~isequal(bg_dims,getappdata(gcf,'STDims'))
     msg = 'The dimensions of the background and data images are not matched'; 
     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
     return;
   end;

   bg_img = load_nii(BgImgFile, 1);
   bg_img = reshape(double(bg_img.img), [bg_img.hdr.dime.dim(2:3) 1 bg_img.hdr.dime.dim(4)]);

   setappdata(gcf,'BackgroundImg',bg_img);

   ShowResult(0,1);

   return;					% LoadBackgroundImage


%--------------------------------------------------------------------------
function SaveBackgroundImage()
%

  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');

  try 				% load the dimension info of the datamat
     load(PLSresultFile,'st_dims','st_voxel_size','st_origin','st_coords'),
  catch
     msg =sprintf('ERROR: Cannot load the PLS result file "%s".',PLSresultFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  newcoords = st_coords;
  voxel_size = st_voxel_size;
  origin = st_origin;

  dims = st_dims([1 2 4]);
  img = zeros(dims);
  img = img(:);
  img(newcoords) = 1;
  img = reshape(img,dims);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-11);
  image_fn = [resultfile_prefix, 'background.img'];

  [filename,pathname] = rri_selectfile(image_fn,'Save brain region to IMG file');
  if isequal(filename,0)
      return;
  end;

  img_file = fullfile(pathname, filename);
  descrip = sprintf('Background Image from %s', PLSresultFile);
  rri_write_img(img_file,img,0,dims,voxel_size,16,origin,descrip);

  return;					% SaveBackgroundImage


%--------------------------------------------------------------------------
function [range, bar_data] = create_colorbar(axes_hdl,cmap,min_range,max_range)

   tick_steps = (max_range - min_range) / (size(cmap,1) - 1);
   y_range = [min_range:tick_steps:max_range];
   range = [max_range:-tick_steps:min_range];
   
   axes(axes_hdl);
   img_h = image([0,1],[min_range max_range],[1:size(cmap,1)]');

   %  use true colour for the colour bar to make sure change of colormap
   %  won't affect it
   %
   bar_data = get(img_h,'CData');
   len = length(bar_data);
   cdata = zeros(len,1,3);
   for i=1:len,
     cdata(i,1,:) = cmap(bar_data(i),:);
   end;
   set(img_h,'CData',cdata);

   %  setup the axes property
%   set(axes_hdl, 'XTick',[],'XLim',[0 1], ...
%            'YLim',[min_range max_range], ...
%	    'YDir','normal', ...
%            'YAxisLocation','right');
   set(axes_hdl, 'XTick',[], ...
            'YLim',[min_range max_range], ...
	    'YDir','normal', ...
            'YAxisLocation','right');

   return;


%--------------------------------------------------------------------------
%
% initially set bs field at left panel
%
%--------------------------------------------------------------------------
function  [min_ratio, max_ratio, bs_thresh] = set_bs_fields(lv_idx,p_value),

   bs_ratio = getappdata(gcf,'BSRatio');
   if isempty(bs_ratio),		 % no bootstrap data -> return;
       return;
   end;

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;

%   p_value = 0.05;		% two-tail 5%
%   cumulated_p = 1 - (p_value/2);

%   curr_bs_ratio = bs_ratio(:,lv_idx);
%   curr_bs_ratio(isnan(curr_bs_ratio)) = 0;
%   idx = find(abs(curr_bs_ratio) < std(curr_bs_ratio) * 5); % avoid the outliers

%   std_ratio = std(curr_bs_ratio(idx));
%   bs_thresh = cumulative_gaussian_inv(cumulated_p,0,std_ratio);

   bs95 = percentile(bs_ratio, 95);

   %  find 95 percentile as initial threshold
   %
   setting = getappdata(gcf,'setting');

   if ~isempty(setting) & isfield(setting,'bs_thresh') ...
	& length(setting.bs_thresh)>=lv_idx ...
	& ~isempty(setting.bs_thresh{lv_idx})
      bs_thresh = setting.bs_thresh{lv_idx};
      min_ratio = setting.min_ratio{lv_idx};
      max_ratio = setting.max_ratio{lv_idx};
   else
      bs_thresh = bs95(lv_idx);
      min_ratio = min(bs_ratio(:,lv_idx));
      max_ratio = max(bs_ratio(:,lv_idx));

      if (abs(max_ratio) < bs_thresh) | (abs(min_ratio) < bs_thresh)
         bs_thresh = 0;
      end
   end;

   setting.bs_thresh{lv_idx} = bs_thresh;
   setting.min_ratio{lv_idx} = min_ratio;
   setting.max_ratio{lv_idx} = max_ratio;
   setappdata(gcf,'setting',setting);

   set(findobj(gcf,'Tag','BSThreshold'),'String',sprintf('%8.5f',bs_thresh));
%   set(findobj(gcf,'Tag','PValue'),'String',sprintf('%8.5f',p_value));
   set(findobj(gcf,'Tag','MinRatio'),'String',sprintf('%8.5f',min_ratio));
   set(findobj(gcf,'Tag','MaxRatio'),'String',sprintf('%8.5f',max_ratio));


   return; 						% set_bs_field


%--------------------------------------------------------------------------
%
% initially set blv field at left panel
%
%--------------------------------------------------------------------------
function  [min_blv,max_blv,thresh] = set_blv_fields(grp_idx,behav_idx,lv_idx,thresh),

if(0)
   is_rescale = get(findobj(gcf,'Tag','RESCALECheckbox'),'value');

   if is_rescale
%      brainlv = getappdata(gcf, 'blv_s');
      brainlv = getappdata(gcf,'brainlv');
      s = getappdata(gcf,'s');
      for i=1:length(s)
         brainlv(:,i) = brainlv(:,i).*s(i);
      end
   else
      brainlv = getappdata(gcf,'brainlv');
   end
end

   brainlv_lst = getappdata(gcf,'brainlv');
   setappdata(gcf,'BLVData',brainlv_lst);

   if isempty(brainlv_lst)		 	% no brain lv data -> return;
       return;
   end;

   if ~exist('grp_idx','var') | isempty(grp_idx),
      grp_idx = 1;
   end;

   if ~exist('behav_idx','var') | isempty(behav_idx),
      behav_idx = 1;
   end;

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;

   brainlv = brainlv_lst{grp_idx, behav_idx};

if(0)
      brainlv = getappdata(gcf,'brainlv');

   if isempty(brainlv),		 	% no brain lv data -> return;
       return;
   end;

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;
end

   blv95 = percentile(brainlv, 95);

   %  find 95 percentile as initial threshold
   %
   setting = getappdata(gcf,'setting');

   if ~isempty(setting) & isfield(setting,'thresh') ...
	& size(setting.thresh,1)>=grp_idx ...
	& size(setting.thresh,2)>=lv_idx ...
	& size(setting.thresh,3)>=behav_idx ...
	& ~isempty(setting.thresh{grp_idx,lv_idx,behav_idx})
      thresh = setting.thresh{grp_idx,lv_idx,behav_idx};
      min_blv = setting.min_blv{grp_idx,lv_idx,behav_idx};
      max_blv = setting.max_blv{grp_idx,lv_idx,behav_idx};
   else
      thresh = blv95(lv_idx);
      min_blv = min(brainlv(:,lv_idx));
      max_blv = max(brainlv(:,lv_idx));

      if (abs(max_blv) < thresh) | (abs(min_blv) < thresh)
         thresh = 0;
      end
   end;

   setting.thresh{grp_idx,lv_idx,behav_idx} = thresh;
   setting.min_blv{grp_idx,lv_idx,behav_idx} = min_blv;
   setting.max_blv{grp_idx,lv_idx,behav_idx} = max_blv;
   setappdata(gcf,'setting',setting);

   set(findobj(gcf,'Tag','Threshold'),'String',sprintf('%8.5f',thresh));
   set(findobj(gcf,'Tag','MinValue'),'String',sprintf('%8.5f',min_blv));
   set(findobj(gcf,'Tag','MaxValue'),'String',sprintf('%8.5f',max_blv));

   return; 						% set_blv_field


%--------------------------------------------------------------------------
function  p_value = ratio2p(x,mu,sigma)

   p_value = (1 + erf( (x - mu) / (sqrt(2)*sigma))) / 2;
   p_value = (1 - p_value) * 2;

   return; 						% ratio2p


%-------------------------------------------------------------------------
%
function ShowResult(action,update)
% action=0 - plot with the control figure
% action=1 - plot in a seperate figure
%

  mainfig = gcf;
  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');


  h = findobj(gcf,'Tag','LVIndexEdit');  lv_idx = get(h,'Userdata');
  curr_lv_idx = getappdata(gcf,'CurrLVIdx');
  if (lv_idx ~= curr_lv_idx),
     lv_idx = curr_lv_idx;
     set(h,'String',num2str(lv_idx));
  end;

  h = findobj(gcf,'Tag','BSLVIndexEdit');  bs_lv_idx = get(h,'Userdata');
  curr_bs_lv_idx = getappdata(gcf,'CurrBSLVIdx');
  if (bs_lv_idx ~= curr_bs_lv_idx),
     bs_lv_idx = curr_bs_lv_idx;
     set(h,'String',num2str(bs_lv_idx));
  end;

  h = findobj(gcf,'Tag','GroupIndexEdit');  grp_idx = get(h,'Userdata');
  curr_grp_idx = getappdata(gcf,'CurrGroupIdx');
  if (grp_idx ~= curr_grp_idx),
     grp_idx = curr_grp_idx;
     set(h,'String',num2str(grp_idx));
  end;

  h = findobj(gcf,'Tag','BehavIndexEdit');  behav_idx = get(h,'Userdata');
  curr_behav_idx = getappdata(gcf,'CurrBehavIdx');
  if (behav_idx ~= curr_behav_idx),
     behav_idx = curr_behav_idx;
     set(h,'String',num2str(behav_idx));
  end;

  old_pointer = get(gcf,'Pointer');
  fig_hdl = gcf;
  set(fig_hdl,'Pointer','watch');

  if (getappdata(gcf,'ViewBootstrapRatio') == 0),	% plot brain lv 

     h = findobj(gcf,'Tag','Threshold');  thresh = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MaxValue');   max_blv = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinValue');   min_blv = str2num(get(h,'String'));

     if isempty(max_blv) | isempty(min_blv) | isempty(thresh) | ...
	   (abs(max_blv) < thresh) | (abs(min_blv) < thresh)
        msg = 'ERROR: Invalid threshold.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
        h = findobj(gcf,'Tag','Threshold');  set(h,'String','0');
        thresh = 0;
     end;

     switch action 
       case {0}
          bfm_plot_brainlv(0,PLSresultFile,grp_idx,lv_idx,0,behav_idx,[],update);
       case {1}
          bfm_plot_brainlv(0,PLSresultFile,grp_idx,lv_idx,1,behav_idx,[],update);
     end

  else							% plot bootstrap ratio

     h = findobj(gcf,'Tag','Threshold');  thresh = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MaxValue');   max_blv = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinValue');   min_blv = str2num(get(h,'String'));

     if isempty(max_blv) | isempty(min_blv) | isempty(thresh) | ...
	   (abs(max_blv) < thresh) | (abs(min_blv) < thresh)
        msg = 'ERROR: Invalid threshold.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
        h = findobj(gcf,'Tag','Threshold');  set(h,'String','0');
        thresh = 0;
     end;

     h = findobj(gcf,'Tag','BSThreshold'); 
     thresh_ratio = str2num(get(h,'String')); 
     h = findobj(gcf,'Tag','MaxRatio'); max_ratio = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinRatio'); min_ratio = str2num(get(h,'String'));

     if isempty(max_ratio) | isempty(min_ratio) | isempty(thresh_ratio) | ...
	   (abs(max_ratio) < thresh_ratio) | (abs(min_ratio) < thresh_ratio)
        msg = 'ERROR: Invalid threshold.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
        h = findobj(gcf,'Tag','BSThreshold');  set(h,'String','0');
        thresh_ratio = 0;
     end;;

     switch action 
       case {0}
          bfm_plot_brainlv(2,PLSresultFile,grp_idx,lv_idx,0,behav_idx,[],update);
       case {1}
          bfm_plot_brainlv(2,PLSresultFile,grp_idx,lv_idx,1,behav_idx,[],update);
     end;

  end;

  if ~action
     setting = getappdata(gcf,'setting');

     if isempty(setting) | ~isfield(setting,'origin')
        setting.origin = getappdata(gcf,'STOrigin');
     else
        setappdata(gcf,'STOrigin',setting.origin);
        setappdata(gcf,'Origin',setting.origin);
     end;

     setting.grp_idx = grp_idx;
     setting.lv_idx = lv_idx;
     setting.bs_lv_idx = bs_lv_idx;
     setting.behav_idx = behav_idx;
     setting.rot_amount = getappdata(gcf,'RotateAmount');

     setting.thresh{grp_idx,lv_idx,behav_idx} = thresh;
     setting.min_blv{grp_idx,lv_idx,behav_idx} = min_blv;
     setting.max_blv{grp_idx,lv_idx,behav_idx} = max_blv;

     if getappdata(gcf,'ViewBootstrapRatio')		% plot bsr
        setting.bs_thresh{bs_lv_idx} = str2num(get(findobj(gcf,'Tag','BSThreshold'),'String'));
     end

     setappdata(gcf,'setting',setting);
  end

  %  create / or re-create xhair
  %
  ax = getappdata(gcf,'BlvAxes');
  p_img = getappdata(gcf,'p_img');

  if isempty(p_img)
     p_img = [-1 -1];
  end

  img_xhair = getappdata(gcf,'img_xhair');
  img_xhair = rri_xhair(p_img,img_xhair,ax);


      %%%%%%%%%%%     update xhair      %%%%%%%%%%%%

  h_img = findobj(gcf,'tag','BLVImg');
  img_xlim = get(h_img, 'xdata');
  img_ylim = get(h_img, 'ydata');
  img_lx = img_xhair.lx;
  img_ly = img_xhair.ly;

  set(img_lx,'xdata', img_xlim, 'ydata', [p_img(2) p_img(2)]);
  set(img_ly,'xdata', [p_img(1) p_img(1)], 'ydata', img_ylim);


  xhair_color = get(findobj(mainfig,'tag','XhairColorMenu'), 'user');
  set(img_xhair.lx, 'color', xhair_color);
  set(img_xhair.ly, 'color', xhair_color);

  setappdata(gcf,'img_xhair',img_xhair);

  % update the LV scores when needed
  %
  scores_fig = getappdata(gcf,'ScorePlotHdl'); 

  if isempty(scores_fig)		
      set(fig_hdl,'Pointer',old_pointer);
      return;
  else
      fmri_plot_scores('UPDATE_LV_SELECTION',scores_fig,lv_idx);
      set(scores_fig,'Pointer',old_pointer);
      set(fig_hdl,'Pointer',old_pointer);
  end;

  return;					% ShowResult


%--------------------------------------------------------------------------
function SelectPixel()

   h = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = get(h,'Userdata');

   h = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = get(h,'Userdata');
   
   h = findobj(gcbf,'Tag','LVIndexEdit');
   lv_idx = get(h,'Userdata');

   h = getappdata(gcbf,'BlvAxes');
   pos = round(get(h,'CurrentPoint'));
   pos_x = pos(1,1,1); pos_y = pos(1,2,1);

   slice_idx = getappdata(gcbf,'SliceIdx');
   img_width = getappdata(gcbf,'ImgWidth');
   img_height = getappdata(gcbf,'ImgHeight');
   rows_disp = getappdata(gcbf,'RowsDisp');
   cols_disp = getappdata(gcbf,'ColsDisp');
   rot_amount = getappdata(gcbf,'RotateAmount');
   origin = getappdata(gcbf,'Origin');
   voxel_size = getappdata(gcbf,'VoxelSize');

   col = floor((pos_x-1) / img_width) + 1;
   row = floor((pos_y-1) / img_height) + 1;
   if (col<1 | col>cols_disp | row<1 | row>rows_disp)
      msg = 'Invalid number in X, Y, or Z';
      set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
      return;
   end

   slice_num = slice_idx(col + (row-1)* cols_disp);

   slice_x = mod(pos_x-1,img_width)+1;
   slice_y = mod(pos_y-1,img_height)+1;
   if (slice_x==0), slice_x = img_width; end;
   if (slice_y==0), slice_y = img_height; end;

   %  Note:  Images are read row by row in MATLAB. The orientation of
   %         the image matrix is 90 degree different from the normal image
   %         orientation convention.
   %
   switch mod(rot_amount,4)
      case {0},					% 0 degree
         cur_x = slice_y;
         cur_y = img_width - slice_x + 1;
      case {1},					% 90 degree by default
         cur_x = slice_x;
         cur_y = slice_y;
      case {2},					% 180 degree
         cur_x = img_height - slice_y + 1;
         cur_y = slice_x;
      case {3},					% 270 degree
         cur_x = img_width - slice_x + 1;
         cur_y = img_height - slice_y + 1;
   end;

   if mod(rot_amount,2)
      coord_x = img_height - cur_y + 1;
      coord_y = cur_x;
      coord = (slice_num-1)*img_height*img_width + ...
		(coord_x-1)*img_width + coord_y;
   else
      coord_x = img_width - cur_y + 1;
      coord_y = cur_x;
      coord = (slice_num-1)*img_width*img_height + ...
		(coord_x-1)*img_height + coord_y;
   end

   setappdata(gcbf,'Coord',coord);

   %  update the brain LV value if needed
   %
   if 1		%(getappdata(gcbf,'ViewBootstrapRatio') == 0),
      brainlv_lst = getappdata(gcbf,'BLVData');
      brainlv = brainlv_lst{grp_idx,behav_idx};
      blv_coords = getappdata(gcbf,'BLVCoords');

      curr_blv = brainlv(:,lv_idx);
      coord_idx = find(blv_coords == coord);

      h = findobj(gcbf,'Tag','BLVValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;

   end;

    % display the current location.
    %
    if slice_num > 0


        if mod(rot_amount,2)
           cur_y = img_height - cur_y + 1;
        else
           cur_y = img_width - cur_y + 1;
        end

        xyz = [cur_x, cur_y, slice_num];
%        xyz_offset = [xyz(1)-origin(1) xyz(2)-origin(2) xyz(3)-origin(3)];
	xyz_offset = xyz - origin;
        xyz_mm = xyz_offset .* voxel_size;

        h = findobj(gcbf,'Tag','XYZVoxel');
        set(h,'String',sprintf('%d %d %d',xyz));

        h = findobj(gcbf,'Tag','XYZmm');
        set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

    else

        xyz = [];

        h = findobj(gcbf,'Tag','XYZVoxel');
        set(h,'String','No slice here!');

        h = findobj(gcbf,'Tag','XYZmm');
        set(h,'String','');

    end

   setappdata(gcbf,'xyz',xyz);

   p_img = [pos_x pos_y];
   img_xhair = getappdata(gcbf,'img_xhair');
   img_xhair = rri_xhair(p_img,img_xhair);
   setappdata(gcbf,'img_xhair',img_xhair);
   setappdata(gcbf,'p_img',p_img);

   return; 					% SelectPixel


%--------------------------------------------------------------------------
function EditXYZ()

   xyz = str2num(get(findobj(gcf,'tag','XYZVoxel'),'string'));

   if isempty(xyz) | ~isequal(size(xyz),[1 3])
      msg = 'XYZ should contain 3 numbers (X, Y, and Z)';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   st_dims = getappdata(gcf,'STDims');

   rows_disp = getappdata(gcf,'RowsDisp');
   cols_disp = getappdata(gcf,'ColsDisp');
   img_width = getappdata(gcf,'ImgWidth');
   img_height = getappdata(gcf,'ImgHeight');
   rot_amount = getappdata(gcf,'RotateAmount');

   switch mod(rot_amount,4)
      case {0,2},
         if ( xyz(1)<1 | xyz(2)<1 | xyz(2)>img_width | xyz(1)>img_height )
            msg = 'Invalid number in X, Y, or Z';
            set(findobj(gcf,'Tag','MessageLine'),'String',msg);
            return;
         end
      case {1,3},
         if ( xyz(1)<1 | xyz(2)<1 | xyz(1)>img_width | xyz(2)>img_height )
            msg = 'Invalid number in X, Y, or Z';
            set(findobj(gcf,'Tag','MessageLine'),'String',msg);
            return;
         end
   end

   org_z = xyz(3);
   org_y = ceil(org_z/cols_disp) - 1;
   org_x = org_z - org_y*cols_disp - 1;

   org_x = org_x * img_width;
   org_y = org_y * img_height;

   if ~isempty(org_x) & ~isempty(org_y)
      switch mod(rot_amount,4)
         case {0},
            cur_x = xyz(2) + org_x;
            cur_y = xyz(1) + org_y;
         case {1},
            cur_x = xyz(1) + org_x;
            cur_y = img_height - xyz(2) + 1 + org_y;
         case {2},
            cur_x = img_width - xyz(2) + 1 + org_x;
            cur_y = img_height - xyz(1) + 1 + org_y;
         case {3},
            cur_x = img_width - xyz(1) + 1 + org_x;
            cur_y = xyz(2) + org_y;
      end
   end

   pos_x = cur_x;
   pos_y = cur_y;

   h = findobj(gcf,'Tag','GroupIndexEdit');    
   grp_idx = get(h,'Userdata');

   h = findobj(gcf,'Tag','BehavIndexEdit');    
   behav_idx = get(h,'Userdata');
   
   h = findobj(gcf,'Tag','LVIndexEdit');
   lv_idx = get(h,'Userdata');

   slice_idx = getappdata(gcf,'SliceIdx');
   rot_amount = getappdata(gcf,'RotateAmount');
   origin = getappdata(gcf,'Origin');
   voxel_size = getappdata(gcf,'VoxelSize');

   col = floor((pos_x-1) / img_width) + 1;
   row = floor((pos_y-1) / img_height) + 1;
   if (col<1 | col>cols_disp | row<1 | row>rows_disp)
      msg = 'Invalid number in X, Y, or Z';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   slice_num = slice_idx(col + (row-1)* cols_disp);

   slice_x = mod(pos_x-1,img_width)+1;
   slice_y = mod(pos_y-1,img_height)+1;
   if (slice_x==0), slice_x = img_width; end;
   if (slice_y==0), slice_y = img_height; end;

   %  Note:  Images are read row by row in MATLAB. The orientation of
   %         the image matrix is 90 degree different from the normal image
   %         orientation convention.
   %
   switch mod(rot_amount,4)
      case {0},					% 0 degree
         cur_x = slice_y;
         cur_y = img_width - slice_x + 1;
      case {1},					% 90 degree by default
         cur_x = slice_x;
         cur_y = slice_y;
      case {2},					% 180 degree
         cur_x = img_height - slice_y + 1;
         cur_y = slice_x;
      case {3},					% 270 degree
         cur_x = img_width - slice_x + 1;
         cur_y = img_height - slice_y + 1;
   end;

   if mod(rot_amount,2)
      coord_x = img_height - cur_y + 1;
      coord_y = cur_x;
      coord = (slice_num-1)*img_height*img_width + ...
		(coord_x-1)*img_width + coord_y;
   else
      coord_x = img_width - cur_y + 1;
      coord_y = cur_x;
      coord = (slice_num-1)*img_width*img_height + ...
		(coord_x-1)*img_height + coord_y;
   end

   setappdata(gcf,'Coord',coord);

   %  update the brain LV value if needed
   %
   if 1		%(getappdata(gcf,'ViewBootstrapRatio') == 0),
      brainlv_lst = getappdata(gcf,'BLVData');
      brainlv = brainlv_lst{grp_idx,behav_idx};
      blv_coords = getappdata(gcf,'BLVCoords');

      curr_blv = brainlv(:,lv_idx);
      coord_idx = find(blv_coords == coord);

      h = findobj(gcf,'Tag','BLVValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;

   end;

    % display the current location.
    %
    if slice_num > 0


        if mod(rot_amount,2)
           cur_y = img_height - cur_y + 1;
        else
           cur_y = img_width - cur_y + 1;
        end

        xyz = [cur_x, cur_y, slice_num];
%        xyz_offset = [xyz(1)-origin(1) xyz(2)-origin(2) xyz(3)-origin(3)];
	xyz_offset = xyz - origin;
        xyz_mm = xyz_offset .* voxel_size;

        h = findobj(gcf,'Tag','XYZVoxel');
        set(h,'String',sprintf('%d %d %d',xyz));

        h = findobj(gcf,'Tag','XYZmm');
        set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

    else

        xyz = [];

        h = findobj(gcf,'Tag','XYZVoxel');
        set(h,'String','No slice here!');

        h = findobj(gcf,'Tag','XYZmm');
        set(h,'String','');

    end

   setappdata(gcf,'xyz',xyz);

   p_img = [pos_x pos_y];
   img_xhair = getappdata(gcf,'img_xhair');
   img_xhair = rri_xhair(p_img,img_xhair);
   setappdata(gcf,'img_xhair',img_xhair);
   setappdata(gcf,'p_img',p_img);

   return; 					% EditXYZ


%--------------------------------------------------------------------------
function RescaleBnPress()

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   set_blv_fields(lv_idx);

   set(gcf,'Pointer',old_pointer);

   return;					% RescaleBnPress


%-------------------------------------------------------------------------
%
function OpenEigenPlot()

   num_lv = getappdata(gcf,'NumLVs');

   eigen_plot = getappdata(gcbf,'EigenPlotHdl');
   if ~isempty(eigen_plot) & ishandle(eigen_plot)
      msg = 'ERROR: Singular Values are already been plotted';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   h = findobj(gcbf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');

   eigen = load(PLSresultFile,'s','perm_result');
   eigen_fig = rri_plot_eigen_ui({eigen.s, eigen.perm_result});

   link_info.hdl = gcbf;
   link_info.name = 'EigenPlotHdl';
   setappdata(eigen_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'EigenPlotHdl',eigen_fig);

   return;					% OpenEigenPlot


%-------------------------------------------------------------------------
%
function OpenBrainPlot()

  h = findobj(gcf,'Tag','ResultFile');
  PLSresultFile = get(h,'UserData');

  brain_plot = getappdata(gcf,'brain_plot');
  if ~isempty(brain_plot)
      msg = 'ERROR: Brain scores plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  brain_plot = bfm_plot_brain_scores('STARTUP',PLSresultFile);
  link_info.hdl = gcbf;
  link_info.name = 'brain_plot';

  if ~isempty(brain_plot)
     setappdata(brain_plot,'LinkFigureInfo',link_info);
     setappdata(gcbf,'brain_plot',brain_plot);
  end

  return;					% OpenBrainPlot


%-------------------------------------------------------------------------
%
function OpenCorrelationPlot

  h = findobj(gcf,'Tag','ResultFile');
  PLSresultFile = get(h,'UserData');

%  load(PLSresultFile);

  rf_plot = getappdata(gcf,'RFPlotHdl');
  if ~isempty(rf_plot)
      msg = 'ERROR: Response function plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  rf_plot = bfm_plot_rf('LINK',PLSresultFile);
  link_info.hdl = gcbf;
  link_info.name = 'RFPlotHdl';
  setappdata(rf_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'RFPlotHdl',rf_plot);

  %  make sure the Coord of the Response Function Plot contains
  %  the current point in the Response
  %
  cur_coord = getappdata(gcf,'Coord');
  setappdata(rf_plot,'Coord',cur_coord);

  return;					% OpenCorrelationPlot


%-------------------------------------------------------------------------
%
function OpenDatamatcorrsPlot

   datamatcorrs_fig = getappdata(gcbf,'DatamatcorrsPlotHdl');
   if ~isempty(datamatcorrs_fig) & ishandle(datamatcorrs_fig)
      msg = 'ERROR: Datamat Correlations Plot has already been plotted';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   datamatcorrs_fig = bfm_plot_datamatcorrs;

   link_info.hdl = gcbf;
   link_info.name = 'DatamatcorrsPlotHdl';
   setappdata(datamatcorrs_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'DatamatcorrsPlotHdl',datamatcorrs_fig);

   return;


%-------------------------------------------------------------------------
%
function orient

   bfm_plot_datamatcorrs('Rotation',1);

   old_pointer = get(gcbf,'Pointer');
   set(gcbf,'Pointer','watch');

   old_dims = getappdata(gcf, 'STDims');
   old_dims = old_dims([1 2 4]);
   old_voxel_size = getappdata(gcf, 'STVoxelSize');
   old_origin = getappdata(gcf, 'STOrigin');
   old_coord = getappdata(gcf, 'BLVCoords');
   old_pattern = getappdata(gcf, 'orient_pattern');

   [orient, new_dims, new_voxel_size, new_origin, new_coord, new_pattern] ...
     = rri_xy_orient(old_dims, old_voxel_size, old_origin, old_coord);

   if isequal(orient, [1 2])
      set(gcbf,'Pointer',old_pointer);
      return;
   end

   new_dims = new_dims([1 2 3 3]);
   new_dims(3) = 1;

   setappdata(gcf, 'orient_pattern', new_pattern);

   setappdata(gcf, 'BLVCoords', new_coord);

   if isappdata(gcf, 'BSRatioCoords')
      setappdata(gcf, 'BSRatioCoords', new_coord);
   end

   setappdata(gcf, 'STDims', new_dims);
   setappdata(gcf, 'STVoxelSize', new_voxel_size);
   setappdata(gcf, 'STOrigin', new_origin);

   setappdata(gcf, 'Dims', new_dims);
   setappdata(gcf, 'VoxelSize', new_voxel_size);
   setappdata(gcf, 'Origin', new_origin);

   set(gcbf,'Pointer',old_pointer);

   p_img = getappdata(gcf,'p_img');
   if ~isempty(p_img)
      p_img = [-1 -1];
      setappdata(gcf,'p_img',p_img);
   end
   setappdata(gcf,'img_xhair',[]);

   %  apply new_pattern here
   %
   orient_pattern = getappdata(gcf,'orient_pattern');

   brainlv = getappdata(gcbf,'brainlv');
   bs = getappdata(gcbf,'BSRatio');
   dims = getappdata(gcf,'STDims');

   for g = 1:size(brainlv, 1)
      for b = 1:size(brainlv, 2)
         blv = brainlv{g, b};
         blv = rri_xy_orient_data(blv, old_coord, new_coord, dims, new_pattern);
         brainlv{g, b} = blv;
      end
   end

   setappdata(gcf,'brainlv',brainlv);
   setappdata(gcf,'BLVData',brainlv);

   if ~isempty(bs)
      bs = rri_xy_orient_data(bs, old_coord, new_coord, dims, new_pattern);
      setappdata(gcf,'BSRatio',bs);
   end

   orient_pattern = getappdata(gcf,'orient_pattern');
   origin_pattern = getappdata(gcf,'origin_pattern');

   setappdata(gcf, 'orient_pattern', new_pattern);

   if isempty(origin_pattern)
      origin_pattern = new_pattern;
   else
      origin_pattern = origin_pattern(new_pattern);
   end

   setappdata(gcf, 'origin_pattern', origin_pattern);

   ShowResult(0,0);

   setting = getappdata(gcf,'setting');

   setting.origin = new_origin;
   setting.orient.dims = new_dims;
   setting.orient.voxel_size = new_voxel_size;
   setting.orient.coords = new_coord;
   setting.orient.pattern = origin_pattern;

   setappdata(gcf,'setting',setting);

   return;

