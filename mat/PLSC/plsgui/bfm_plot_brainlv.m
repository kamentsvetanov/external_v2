%BFM_PLOT_BRAINLV Plot Brainlv
%
%   Usage:  bfm_plot_brainlv(PLSresultFile, lv_idx, new_fig)
%
%   BFM_PLOT_BRAINLV plot the brainlv into BlvAxes, and colorbar into
%	ColorBar Axes. Both axes are either created by bfm_result_ui.m
%	or creat them if new_fig is TRUE
%
%   See also BFM_RESULT_UI
%

%   Called by bfm_result_ui
%
%   I (ViewBootstrapRatio) - if 0, plot blv; if 1, plot compare
%   I (PLSresultFile) - file contains the PLS results for blocked fmri scan
%   I (grp_idx) - Group index of brainlv to be displayed
%   I (lv_idx) - LV index of brainlv to be displayed
%   I (new_fig) - show images on a new figure
%   I (behav_idx) - used when this code is called by bfm_plot_datamatcorrs
%                   input empty in other cases
%
%   Modified on 04-OCT-2002 by Jimmy Shen
%   Modified on 25-Jun-2003, and add prevent_num_lower_color_0
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bfm_plot_brainlv(ViewBootstrapRatio, PLSresultFile, ...
	grp_idx, lv_idx, new_fig, behav_idx, cluster_info, update)

    if (new_fig)
        bg_img = getappdata(gcbf,'BackgroundImg');
        rot_amount = getappdata(gcbf,'RotateAmount');

        if ViewBootstrapRatio == 1
           blv = getappdata(gcbf,'BSRatio');
        elseif ViewBootstrapRatio == 2
           blv = getappdata(gcbf,'BLVData');
           bs = getappdata(gcbf,'BSRatio');
	elseif ViewBootstrapRatio == 0
           blv = getappdata(gcbf,'BLVData');
	end
    else
        bg_img = getappdata(gcf,'BackgroundImg');
        rot_amount = getappdata(gcf,'RotateAmount');

        if ViewBootstrapRatio == 1
           blv = getappdata(gcf,'BSRatio');
        elseif ViewBootstrapRatio == 2
           blv = getappdata(gcf,'BLVData');
           bs = getappdata(gcf,'BSRatio');
	elseif ViewBootstrapRatio == 0
           blv = getappdata(gcf,'BLVData');
	end
    end

    if ~isempty(behav_idx)			% called from datamatcorrs plot
        blv = blv{grp_idx, behav_idx};
    end

    if isempty(bg_img)
       no_background_image = 1;
    else
       no_background_image = 0;
    end

if 0
    if ~isempty(behav_idx)			% called from datamatcorrs plot

        load(PLSresultFile,'num_conditions','st_dims','st_coords','s','st_voxel_size','st_origin','behavname');
        num_behav = length(behavname);

    else
        load(PLSresultFile,'num_conditions','st_dims','st_coords','s','st_voxel_size','st_origin');
    end
end

   load(PLSresultFile);

   if ~isempty(behav_idx)
      num_behav = length(behavname);
   end

   if exist('result','var')
      s = result.s;
      num_conditions = result.num_conditions;

      if isfield(result,'stacked_behavdata')
         num_behav = length(behavname);
      end
   end


    %  match variable name among PET, BfMRI & fMRI
    %
    dims = st_dims;
    newcoords = st_coords;
    voxel_size = st_voxel_size;
    origin = st_origin;



    %  for orient
    %
    if isappdata(gcf, 'BSRatioCoords') | isappdata(gcf, 'BLVCoords')
       dims = getappdata(gcf, 'STDims');
       voxel_size = getappdata(gcf, 'STVoxelSize');
       origin = getappdata(gcf, 'STOrigin');

       if ViewBootstrapRatio
          newcoords = getappdata(gcf, 'BSRatioCoords');
       else
          newcoords = getappdata(gcf, 'BLVCoords');
       end
    else					% from init
       origin_coords = newcoords;
       setting = getappdata(gcf,'setting');
%       orient_pattern = [];
       origin_pattern = [];

       if ~isempty(setting) & isfield(setting,'orient')
          voxel_size = setting.orient.voxel_size;
          dims = setting.orient.dims;
          origin = setting.origin;
          newcoords = setting.orient.coords;
          origin_pattern = setting.orient.pattern;

          setappdata(gcf,'VoxelSize',voxel_size);
          setappdata(gcf,'Dims',dims);
          setappdata(gcf,'Origin',origin);

          setappdata(gcf,'STVoxelSize',voxel_size);
          setappdata(gcf,'STDims',dims);
          setappdata(gcf,'STOrigin',origin);
          setappdata(gcf,'BLVCoords',newcoords);
          setappdata(gcf,'origin_coords',origin_coords);
          setappdata(gcf,'origin_pattern',origin_pattern);

          if ViewBootstrapRatio
             setappdata(gcf,'BSRatioCoords',newcoords);
          end
       end
    end



    num_slices = dims(4);
    slice_idx = [1:num_slices];

    if grp_idx
       num_lv = num_conditions;
    else
       num_lv = size(blv,2);
    end

    brainlv = blv(:,lv_idx);

    if ViewBootstrapRatio == 1
       h = findobj(gcf,'Tag','BSThreshold'); thresh = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','BSThreshold2'); thresh2 = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MaxRatio'); max_blv = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MinRatio'); min_blv = str2num(get(h,'String'));
    elseif ViewBootstrapRatio == 2
       h = findobj(gcf,'Tag','Threshold'); thresh = abs(str2num(get(h,'String')));
						thresh2 = -thresh;
       h = findobj(gcf,'Tag','MaxValue'); max_blv = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MinValue'); min_blv = str2num(get(h,'String'));

       h = findobj(gcf,'Tag','BSLVIndexEdit'); bs_lv_idx = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','BSThreshold'); bs_thresh = abs(str2num(get(h,'String')));
						bs_thresh2 = -bs_thresh;

       bs = bs(:, bs_lv_idx);
       bs_strong = zeros(size(bs));
       bs_idx = [find(bs < bs_thresh2); find(bs > bs_thresh)];
       bs_strong(bs_idx) = 1;
       brainlv = brainlv .* bs_strong;
    elseif ViewBootstrapRatio == 0
       h = findobj(gcf,'Tag','Threshold'); thresh = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','Threshold2'); if isempty(h), thresh2 = -thresh; 
       else, thresh2 = str2num(get(h,'String')); end;
       h = findobj(gcf,'Tag','MaxValue'); max_blv = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MinValue'); min_blv = str2num(get(h,'String'));
    end

    too_large = find(brainlv > max_blv); brainlv(too_large) = max_blv;
    too_small = find(brainlv < min_blv); brainlv(too_small) = min_blv;

    if mod(rot_amount,2)
        img_height = dims(2);		% rows - after 90 or 270 rotation
        img_width  = dims(1);		% by default, 90 rotation
    else
        img_height = dims(1);		% rows
        img_width  = dims(2);
    end

    %  display the images
    %
    if (new_fig)
        [axes_hdl,colorbar_hdl] = bfm_create_newblv_ui;
    else
        axes_hdl = getappdata(gcf,'BlvAxes');
        colorbar_hdl = getappdata(gcf,'Colorbar');
    end

    axes(axes_hdl);

    rows = dims(1);
    cols = dims(2);
    slices = dims(4);

    % create the appropriate colormap
    %
    % cmap = set_colormap(max_blv, min_blv, thresh, thresh2);
   
    bg_values = [1 1 1];
    num_blv_colors = 25;
    brain_region_color_idx = 51;
    first_lower_color_idx = 101;
    first_upper_color_idx = 126;

    % set up the colormap for the background 
    %
    bg_brain_values = [0.54 0.54 0.54];
    if (no_background_image),
       bg_cmap = ones(100,1)*bg_brain_values;	% the brain regions
    else
       bg_cmap = bone(140);
       bg_cmap = bg_cmap(1:100,:);
    end;
   

    %  colormap entries
    %     	 1 - 100    : for the brain regions (background) image
    %           101 - 125    : for the negative blv values below threshold
    %           126 - 150    : for the positive blv values above threshold
    %     	  151       : for the non-brain regions

    cmap = zeros(151,3);
    jetmap = jet(64);
    cmap(1:100,:) = bg_cmap;			% the brain regions
    cmap(101:125,:) = jetmap([1:25],:);		% the negative blv values
    cmap(126:150,:) = jetmap([36:60],:);	% the positive blv values
    cmap(end,:) = bg_values;			% the nonbrain regions


    %  set up the colormap for the display colorbar
    %
    cbar_size = 100;
    cbar_map = ones(cbar_size,1) * bg_brain_values; 
    cbar_step = (max_blv - min_blv) / cbar_size;

    %  prevent_num_lower_color_0
    %
    if 0 % (abs(min_blv) - thresh) < cbar_step & (abs(min_blv) - thresh) ~= 0
        cbar_size = ceil((max_blv - min_blv) / (abs(min_blv) - thresh));
        cbar_map = ones(cbar_size,1) * bg_brain_values;
        cbar_step = (max_blv - min_blv) / cbar_size;
    end
    if 0 % (abs(max_blv) - thresh) < cbar_step & (abs(max_blv) - thresh) ~= 0
        cbar_size = ceil((max_blv - min_blv) / (abs(max_blv) - thresh));
        cbar_map = ones(cbar_size,1) * bg_brain_values;
        cbar_step = (max_blv - min_blv) / cbar_size;
    end

  if cbar_step ~= 0
%    num_lower_color = round((abs(min_blv) - thresh) / cbar_step);

      if max_blv > thresh2 % -abs(thresh)
         num_lower_color = round((thresh2 - min_blv) / cbar_step);
      else
         num_lower_color = round((max_blv - min_blv) / cbar_step);
      end

    if round(64 / 25 * num_lower_color) > 0
       jetmap = jet(round(64 / 25 * num_lower_color));
       cbar_map(1:num_lower_color,:) = jetmap(1:num_lower_color,:);	
    end

%    num_upper_color = round((max_blv - thresh) / cbar_step);

      if min_blv < thresh % abs(thresh)
         num_upper_color = round((max_blv - thresh) / cbar_step);
      else
         num_upper_color = round((max_blv - min_blv) / cbar_step);
      end

    if round(64 / 25 * num_upper_color) > 0
       jetmap = jet(round(64 / 25 * num_upper_color));
       first_jet_color = round((36 / 64) * size(jetmap,1));
       jet_range = [first_jet_color:first_jet_color+num_upper_color-1];
       cbar_map(end-num_upper_color+1:end,:) = jetmap(jet_range,:);
    end

    % Create the image slices in which voxels are set to be within certain range
    %
%    lower_interval = (abs(min_blv) - thresh) / (num_blv_colors-1);
 %   upper_interval = (max_blv - thresh) / (num_blv_colors-1);

      if max_blv > thresh2 % -abs(thresh)
         lower_interval = (thresh2 - min_blv) / (num_blv_colors-1);
      else
         lower_interval = (max_blv - min_blv) / (num_blv_colors-1);
      end

      if min_blv < thresh % abs(thresh)
         upper_interval = (max_blv - thresh) / (num_blv_colors-1);
      else
         upper_interval = (max_blv - min_blv) / (num_blv_colors-1);
      end

    disp_blv = zeros(1,length(newcoords)) + brain_region_color_idx;
    lower_idx = find(brainlv < thresh2);
    blv_offset = brainlv(lower_idx) - min_blv; 

    if lower_interval ~=0
       lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
    else
       lower_color_idx = ones(size(blv_offset)) * first_lower_color_idx;
    end

    disp_blv(lower_idx) = lower_color_idx;

    upper_idx = find(brainlv > thresh);
    blv_offset = max_blv - brainlv(upper_idx); 

    if upper_interval ~=0
       upper_color_idx = num_blv_colors - round(blv_offset/upper_interval);
    else
       upper_color_idx = num_blv_colors * ones(size(blv_offset));
    end

    upper_color_idx = upper_color_idx + first_upper_color_idx - 1;
    disp_blv(upper_idx) = upper_color_idx;
  else
      disp_blv = zeros(1,length(newcoords)) + brain_region_color_idx;

      if abs(min_blv) < 1e-6
         max_blv = min_blv + eps;
      else
         max_blv = min_blv + abs(min_blv)*1e-9;
      end
  end

    % get non_cluster_coords
    %
    if isempty(cluster_info)
       cluster_idx = newcoords;
    else
       cluster_idx = cluster_info.data{1}.idx;
    end

    if isequal(newcoords, cluster_idx)
       non_cluster_coords = [];
    else
       [tmp cluster_coords] = intersect(newcoords,cluster_idx);
       non_cluster_coords = ones(1,length(newcoords));
       non_cluster_coords(cluster_coords) = 0;
       non_cluster_coords = find(non_cluster_coords);
    end

    if (no_background_image),
       non_brain_region_color_idx = size(cmap,1);
       img = zeros(1,rows*cols*slices) + non_brain_region_color_idx;

       disp_blv(non_cluster_coords) = brain_region_color_idx;

       img(newcoords) = disp_blv;
       img = reshape(img,[rows cols 1 slices]); 
    else
       max_bg = max(bg_img(:));
       min_bg = min(bg_img(:));
       img = (bg_img - min_bg) / (max_bg - min_bg) * 100;

       disp_blv(non_cluster_coords) = img(newcoords(non_cluster_coords));

       if exist('lower_idx','var') & ~isempty(lower_idx)
          img(newcoords(lower_idx)) = disp_blv(lower_idx);
       end

       if exist('upper_idx','var') & ~isempty(upper_idx)
          img(newcoords(upper_idx)) = disp_blv(upper_idx);
       end
    end;

    blv = reshape(img,[rows*cols,slices]);

    %  rotate image
    %
    for i=1:num_slices
        tmp=reshape(blv(:,i),img_width,img_height);
        tmp=rot90(tmp,mod(rot_amount,4));
        blv(:,i)=tmp(:);
    end

    % save a cornor of the last slice as the background intensity
    %
    bg_intensity = blv(1, num_slices);

    %  calculate how many slices to display for each row and column
    %  it's an algorithm from montage which will layout the slice
    %  in near square
    %
    if dims(1) > dims(2)
        siz = [dims(1), dims(2), dims(4)];
    else
        siz = [dims(2), dims(1), dims(4)];
    end

    cols_disp = sqrt(prod(siz))/siz(2);
    rows_disp = siz(3)/cols_disp;
    if (ceil(cols_disp)-cols_disp) < (ceil(rows_disp)-rows_disp),
        cols_disp = ceil(cols_disp); rows_disp = ceil(siz(3)/cols_disp);
    else
        rows_disp = ceil(rows_disp); cols_disp = ceil(siz(3)/rows_disp);
    end

    max_slice = rows_disp * cols_disp;
    rest_slices = max_slice - num_slices;
    empty_slices = -1 * ones(1,rest_slices);
    slice_idx = [slice_idx, empty_slices];

    % for empty slice (27-30), filled them with background intensity
    %
    blv_filled = [blv, ...
	bg_intensity * ...
	ones(img_height*img_width,rows_disp*cols_disp-num_slices)];

    blv_disp = [];
    for(row = 0:rows_disp-1)

        % take 'cols_disp' amount of slices from blv_filled
        % and put into blv_row
        %
        blv_row = blv_filled(:,[row*cols_disp+1:row*cols_disp+cols_disp]);

        % reshape the slice to integrate the whole row together
        %
        blv_row = reshape(blv_row, [img_height, img_width*cols_disp]);

        blv_disp = [blv_disp; blv_row];

    end

    blv_disp = reshape(blv_disp, [rows_disp*img_height, cols_disp*img_width]);

%%    h_img = image(blv_disp,'CDataMapping','scaled');
%    h_img = image(blv_disp);

    if update
       h_img = findobj(gcf,'tag','BLVImg');
       set(h_img,'CData',blv_disp);
    else
       h_img = image(blv_disp); 
    end

    set(h_img,'Tag','BLVImg');
    colormap(cmap);

    num_plus = repmat({'+ '},1,rows_disp);
    for i = 0:rows_disp-1
        num_plus{i+1} = [num2str(i*cols_disp) num_plus{i+1}];
    end

    set(gca,'tickdir','out','ticklength',[0.001 0.001]);
    set(gca,'xtick',[img_width/2:img_width:img_width*cols_disp]);
    set(gca,'xticklabel',[1:cols_disp]);
    set(gca,'ytick',[img_height/2:img_height:img_height*rows_disp]);
    set(gca,'yticklabel',num_plus);

    if (new_fig)
        create_colorbar(colorbar_hdl, cbar_map, min_blv, max_blv);
        return;
    end

    if grp_idx				% called from datamatcorrs plot
       set(h_img,'ButtonDownFcn','bfm_plot_datamatcorrs(''SelectPixel'')');
    else
       set(h_img,'ButtonDownFcn','bfm_result_ui(''SelectPixel'')');
    end

    create_colorbar(colorbar_hdl, cbar_map, min_blv, max_blv );


    %  save the attributes of the current image
    %
    if ~isappdata(gcf, 'VoxelSize')
       setappdata(gcf,'Dims',dims);
       setappdata(gcf,'VoxelSize',voxel_size);
       setappdata(gcf,'Origin',origin);
       setappdata(gcf,'orient_pattern', []);
    end

    setappdata(gcf,'SliceIdx',slice_idx);
    setappdata(gcf,'ImgHeight',img_height);
    setappdata(gcf,'ImgWidth',img_width);
    setappdata(gcf,'RowsDisp',rows_disp);
    setappdata(gcf,'ColsDisp',cols_disp);
    setappdata(gcf,'ImgRotateFlg',1);
    setappdata(gcf,'NumLVs',num_lv);
%    setappdata(gcf,'BLVData',brainlv);

    if ~isappdata(gcf,'origin_coords')
       setappdata(gcf,'origin_coords',origin_coords);
    end

    if ~isappdata(gcf,'BLVCoords')
       setappdata(gcf,'BLVCoords',newcoords);
    end

    setappdata(gcf,'BLVThreshold',thresh);
    setappdata(gcf,'BLVThreshold2',thresh2);
    setappdata(gcf,'RotateAmount',rot_amount);
    setappdata(gcf,'BLVDisplay',blv);

    %  in order to use function like 'cluster' etc. created by fMRI
    %
    if ~isappdata(gcf, 'STDims') | ~isappdata(gcf, 'STVoxelSize') ...
	| ~isappdata(gcf, 'STOrigin')
       setappdata(gcf,'STDims',dims);
       setappdata(gcf,'STVoxelSize',voxel_size);
       setappdata(gcf,'STOrigin',origin);
    end

    setappdata(gcf,'WinSize',1);

    if ViewBootstrapRatio
        setappdata(gcf,'BSThreshold',thresh);
        setappdata(gcf,'BSThreshold2',thresh2);

       if ~isappdata(gcf, 'BSRatioCoords')
          setappdata(gcf,'BSRatioCoords',newcoords);
       end
    end

    if ~isempty(behav_idx)			% called from datamatcorrs plot
        setappdata(gcf,'NumBehav',num_behav);
    end

    %  save background to img
    %
    setappdata(gcf,'cmap',cmap);
    
    return;					%  bfm_plot_brainlv


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Convert the indexed matrix back into the original matrix
%
%   Usage [outmat]=unmapblv(inmat, coords, siz)
%
%   I (inmat): indexed matrix
%   I (coords): index
%   I (siz): size of original matrix
%   O (outmat): original matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outmat] = unmapblv(inmat, coords, siz)

    [r c]=size(inmat);
    outmat=zeros(r,siz);

    for i=1:r;
        outmat(i,coords)=inmat(i,:);
    end

    return;					% unmapblv


%-------------------------------------------------------------------------
%
function [cmap] = set_colormap(max_value, min_value, thresh, thresh2)
%
%   set the display colormap based on the max/min display values and 
%   the threshold setting.
%
%   The upper colors are coming from the entries of [140:239] of the 
%   255 jet colormap, and the lower colors are from the entries of 
%   [1:100] of the colormap.
%

   cmap = [];

   range_interval = max_value - min_value;
   upper_interval = max_value - thresh;
   lower_interval = thresh2 - min_value; % abs(min_value) - abs(thresh2);
   
   %  colormap entries for the upper range values, using the
   %  entries of [140:239] from the 255 jet colormap
   %
   num_upper_colors = 0;
   if (upper_interval > 0)
      num_upper_colors = round(upper_interval / range_interval * 255); 
      cmap_size = round(255 * num_upper_colors/100);
      first_color_idx = round(140 / 255 * cmap_size);
      last_color_idx = first_color_idx + num_upper_colors - 1;
      uppermap = jet(cmap_size);
      upper_colors = uppermap(first_color_idx:last_color_idx,:);
   end;
   
   %  colormap entries for the lower range values, using the 
   %  entries of [1:100] from the 255 jet colormap
   %
   num_lower_colors = 0;
   if (lower_interval > 0)  
      num_lower_colors = round(lower_interval / range_interval * 255); 
      cmap_size = round(255 * num_lower_colors/100);
      first_color_idx = 1;
      last_color_idx = num_lower_colors;
      lowermap = jet(cmap_size);
      lower_colors = lowermap(first_color_idx:last_color_idx,:);
   end;
   
   ignore_pts = [num_lower_colors+1:255-num_upper_colors];

   if isempty(ignore_pts), return; end;

   cmap = zeros(256,3);
   cmap(1:255,:) = jet(255);
   
   if (num_lower_colors > 0),
     cmap(1:num_lower_colors,:) = lower_colors;
   end;
   if (num_upper_colors > 0),
     cmap(ignore_pts(end)+1:255,:) = upper_colors;
   end;
   
   cmap(ignore_pts,:) = ones(length(ignore_pts),3) * 140/255;
   cmap(256,:) = [1 1 1];
   
   return; 					% set_colormap


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

