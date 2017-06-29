function mascoi(varargin)

% by Matthias Reimold
% University of Tuebingen
% Nuclear Medicine and PET center
%
% history (major updates only)
%
% V1.0.2 2005 Nov first publicly released version
%
% V1.1   2006 Mar
%
% V2.0b  2006 April (includes "more..." function)
% V2.0b9 = V2.0
%
% V2.1b  2007 February (includes sagittal sections)
% V2.1b2 = V2.1

global mci
mci_version = 'MASCOI v2.11';

%-----------------------------------------------------------------------
% mascoi() = setup
%-----------------------------------------------------------------------

if nargin == 0 % setup
    
    spm_defaults

    a = ver('Matlab');
    mci.sys.matlab = str2num(a.Version);
    mci.sys.os_string = system_dependent('getos');
    stri = version('-java');
    if isempty(strfind(stri, 'not enabled'))
        mci.sys.java = 1;
    else
        mci.sys.java = 0;
    end
    
    if ~isempty(strfind(mci.sys.os_string, 'Mac'))
        mci.sys.os = 'Mac';
    elseif ~isempty(strfind(mci.sys.os_string, 'Windows'))
        mci.sys.os = 'Win';
    else
        mci.sys.os = 'other';
    end
    
    if mci.sys.matlab < 6
        error('So far only matlab 6 or newer is supported');
    end

    % some layout definitions, units: [pixels]
    
    % standard settings, OS-specific modifications below
    
    mci.FontSize.title = 16;
    mci.FontSize.normal = 12;
    mci.FontSize.small = 9;
    mci.FontSize.table = 11;
    mci.FontSize.table2 = 10;
    mci.FontSize.button = 12;
    mci.FontSize.popup = 12;
    
    mci.FontName.boldstr = 'bold';
    mci.FontName.normalstr = 'normal';
    mci.FontName.fixed = 'Courier New';
    
    mci.layout.pby = 21;
    mci.layout.lineskip = 21;
    mci.layout.lineskip_big = 20; % 1*big + 2*small = 2*normal
    mci.layout.lineskip_small = 11;
    mci.layout.dy_text = -3;
    mci.layout.dy_frame = -3;
    
    mci.col.bc = [.85 .85 .85];
    mci.col.frame = [.8 .8 .8];
    mci.col.bc2 = [1 1 1];
    mci.col.bc3 = [.85 .85 .85]; % frame with 3D effekt looks best with bc3 = bc
    mci.col.gray = [.4 .4 .4];
    mci.col.black = [.2 .2 .2];
    mci.col.red = [.7 0 0];
    
    mci.col.table{1} = [.9 .9 .85];
    mci.col.table{2} = [.85 .85 .9];

    % modifications for other OS
    
    if strcmp(mci.sys.os,'Mac') & mci.sys.matlab >= 7.1 & mci.sys.java == 1 % Aqua interface
    
        mci.FontSize.title = 14;
        mci.FontSize.button = 11;
        mci.FontSize.popup = 11;
    
        mci.layout.dy_text = -5;
    
        mci.col.bc = [.97 .97 .97]; % aqua interface looks best with bright background
        mci.col.bc3 = [.93 .93 .93];
        mci.col.red = [1 0 0];
    
        mci.col.table{1} = [1   1  .95];
        mci.col.table{2} = [.95  .95  1];
        
    elseif strcmp(mci.sys.os,'Win')
    
        mci.FontSize.title = 12; % bigger would be nice, but doesn't work
        mci.FontSize.small = 12; % smaller would be nice, but doesn't work
        mci.FontSize.table = 12; % 11 or 12, matter of taste
    
        mci.FontName.boldstr = 'normal'; % bold would be nice, but on windows, bold means different character width
        mci.FontName.fixed = 'Courier New';
    
        mci.layout.pby = 21;
        mci.layout.lineskip = 21;
        mci.layout.lineskip_big = 18;
        mci.layout.lineskip_small = 12; % can't be smaller than FontSize.small
    
        mci.col.bc = [.9 .9 .9];
        
    end

    if exist('spm_get','file') % should be true for spm2
        mci.spm5 = 0;
    elseif exist('spm_select','file') % should be true for spm5
        mci.spm5 = 1;
    else
        error('Failed to locate spm_get or spm_select, have you added SPM to your Matlab path?')
    end

    mci.save.dname = '';

    % init options
    
    mci.opt.funflip = 0; % default: t>0 = red, t<0 = blue
    mci.opt.anaflip = 0; % flip black&white colormap?
    mci.opt.Topt = 0;   % 0 = all t    1 = only t>0    -1 = only t<0

    % load TT coordinates
    
    if ~isfield(mci, 'TD')
        tt_load;
    end

    % load t-map and con-map

    mascoi('load_fun');
    
    % draw figure
    %------------
    
    mci.fig_width = 1000;
    mci.fig_height = 740;
    mci.fig_margin = 40;
    scale = [mci.fig_width, mci.fig_height, mci.fig_width, mci.fig_height];
    scs = get(0, 'ScreenSize');
    mci.scs = scs;
    border = 250;
    dy = mci.layout.lineskip;
    
    mci.h.fig=figure('Position', [(scs(3)-mci.fig_width)/2 (scs(4)-mci.fig_height)/2 mci.fig_width mci.fig_height], 'Color', mci.col.bc);
    set(gcf, 'MenuBar', 'none', 'Resize', 'off');
    P = get(gcf, 'Position');
    mci.fig_height = P(4); % not all screens allow for 740 pixels height
    print_init;

    labels = str2mat( ...
	'File', ...
		'>Load T-map', ...
        '>Load anatomical', ...
        '>-----', ...
		'>Create documentation', ...
		'>Close documentation', ...
	'List', ...
        '>Create list with...', ...
		'>      all clusters', ...
		'>      positive clusters (t>0)', ...
		'>      negative clusters (t<0)', ...
        '>-----', ...
        '>Select all', ...
        '>Unselect all', ...
	'Colormap', ...
		'>Flip functional (red <=> blue)', ...
		'>Flip anatomical (black <=> white)', ...
    'X-Flip' ...
    );

    calls = str2mat( ...
	 	'', ... %  --------------- File --------------- 
		'mascoi(''load_fun''); mascoi(''MIP'')', ... 
	 	'mascoi(''load_ana'')', ...
	 	'', ...
	 	'mascoi(''save'')', ...
	 	'mascoi(''close'')', ...
	 	'', ... %  --------------- List ---------------
        '', ...
        'mascoi(''table'', 0)', ...
        'mascoi(''table'', 1)', ...
        'mascoi(''table'', -1)', ...
        '', ...
        'mascoi(''select'', ''all+'')', ...
        'mascoi(''select'', ''all-'')', ...
	 	'', ... %  --------------- Colormap --------------- 
	 	'mascoi(''funflip'')', ...
	 	'global mci; mci.opt.anaflip = 1-mci.opt.anaflip; mascoi(''colormap'')', ...
        'mascoi(''leftright'')' ...
    );
    
    handles = makemenu(gcf, labels, calls);
    mci.h.save = handles(4);
    mci.h.close = handles(5);
    mci.h.list1 = handles(8);
    mci.h.list2 = handles(9);
    mci.h.list3 = handles(10);    
    mci.h.select1 = handles(11);
    mci.h.select2 = handles(12);
    
    set(mci.h.close, 'Enable', 'off');
    set(mci.h.list1, 'Enable', 'off');
    set(mci.h.list2, 'Enable', 'off');
    set(mci.h.list3, 'Enable', 'off');
    set(mci.h.select1, 'Enable', 'off');
    set(mci.h.select2, 'Enable', 'off');
    
    x0 = mci.fig_margin;
    x1 = 490;
    y0 = mci.fig_height - mci.fig_margin; 

    y = y0;
    
    x = x0;

    uicontrol('Style', 'Frame', 'Position', [x1, y-2*dy+mci.layout.dy_frame, mci.fig_width-mci.fig_margin-x1, dy*3], 'BackgroundColor', mci.col.bc3, 'ForegroundColor', mci.col.frame);
    uicontrol('Style', 'Frame', 'Position', [x0, y-2*dy+mci.layout.dy_frame, x1-x0-10, dy*3], 'BackgroundColor', mci.col.bc3, 'ForegroundColor', mci.col.frame);
    uicontrol('Style', 'Frame', 'Position', [x0, y-5.2*dy+mci.layout.dy_frame, mci.fig_width-mci.fig_margin*2, dy*2.7], 'BackgroundColor', mci.col.bc3, 'ForegroundColor', mci.col.frame);


    
    w = x1-x0-10;
    y = y - mci.layout.lineskip_big;
    uicontrol('style', 'text', 'string', mci_version, 'Position', [x+10 y+mci.layout.dy_text+1 w-20 30], 'BackgroundColor', mci.col.bc3, 'ForegroundColor', [.4 0 .4], 'FontUnits', 'pixels', 'FontSize', mci.FontSize.title, 'FontWeight', 'bold');
    y = y - mci.layout.lineskip_small;
    uicontrol('style', 'text', 'string', '(c) september 2007, Matthias Reimold', 'Position', [x+10 y+mci.layout.dy_text+3 w-20 21], 'BackgroundColor', mci.col.bc3, 'ForegroundColor', [0 0 .6], 'FontUnits', 'pixels', 'FontSize', mci.FontSize.small);
    y = y - mci.layout.lineskip_small;
    uicontrol('style', 'text', 'string', 'Nuclear Medicine and PET center / University of Tuebingen', 'Position', [x+10 y+mci.layout.dy_text+3 w-20 21], 'BackgroundColor', mci.col.bc3, 'ForegroundColor', [0 .4 .4], 'FontUnits', 'pixels', 'FontSize', mci.FontSize.small);

    y = y - 0.5*dy;
    y = y - 1.5*dy; stri = mci.fname{1}; if length(stri)>70 stri = ['...', stri(end-60:end)]; end; stri = ['t-map: ', stri];
    mci.h.fname_t = uicontrol('style', 'text', 'string', stri, 'Position', [x+10 y+mci.layout.dy_text mci.fig_width-border mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'left');
    y = y - dy; stri = mci.fname{2}; if length(stri)>70 stri = ['...', stri(end-60:end)]; end; stri = ['con-map: ', stri];
    mci.h.fname_c = uicontrol('style', 'text', 'string', stri, 'Position', [x+10 y+mci.layout.dy_text mci.fig_width-border mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'left');
    
    x = x1;
    y = y0;
    
    y = y-dy*.5;
    h(1)=uicontrol('style', 'text', 'string', 'Shortcut: calculate t-thresholds with spm_invTcdf(p,df):', 'Position', [mci.fig_width-mci.fig_margin-410 y+mci.layout.dy_text 400 mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'right');

    y = y-dy;
    
    mci.h.pb2=uicontrol('style', 'pushbutton', 'string', 'go!', 'Position', [mci.fig_width-mci.fig_margin-60 y 50 mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.button, 'callback', 'mascoi(''p2t'')');

    h(2)=uicontrol('style', 'text', 'string', 'df: ', 'Position', [mci.fig_width-mci.fig_margin-130-30 y+mci.layout.dy_text 30 mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'right');
    mci.h.ed3=uicontrol('style', 'edit', 'string', num2str(mci.df_default), 'Position', [mci.fig_width-mci.fig_margin-130 y 50 mci.layout.pby], 'BackgroundColor', mci.col.bc2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal);
    
    h(3)=uicontrol('style', 'text', 'string', 'original p: ', 'Position', [mci.fig_width-mci.fig_margin-210-120 y+mci.layout.dy_text 120 mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'right');
    mci.h.ed4=uicontrol('style', 'edit', 'string', '0.001', 'Position', [mci.fig_width-mci.fig_margin-210 y 50 mci.layout.pby], 'BackgroundColor', mci.col.bc2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal);

    h(4)=uicontrol('style', 'text', 'string', 'secondary p: ', 'Position', [mci.fig_width-mci.fig_margin-330-120 y+mci.layout.dy_text 120 mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'right');
    mci.h.ed5=uicontrol('style', 'edit', 'string', '0.05', 'Position', [mci.fig_width-mci.fig_margin-330 y 50 mci.layout.pby], 'BackgroundColor', mci.col.bc2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal);

    y = y-2.5*dy;

    uicontrol('style', 'text', 'string', 'original voxel-level threshold (e.g. for p<0.001):', 'Position', [x y+mci.layout.dy_text 350 mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'right');
    uicontrol('style', 'text', 'string', 't >', 'Position', [mci.fig_width-mci.fig_margin-100 y+mci.layout.dy_text 30 mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'right');
    mci.h.ed1=uicontrol('style', 'edit', 'string', '', 'Position', [mci.fig_width-mci.fig_margin-60 y 50 mci.layout.pby], 'BackgroundColor', mci.col.bc2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'callback', 'mascoi(''table'')');
    
    y = y-dy;
    uicontrol('style', 'text', 'string', 'secondary voxel-level threshold (at least p<0.05):', 'Position', [x y+mci.layout.dy_text 350 mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'right');
    uicontrol('style', 'text', 'string', 't >', 'Position', [mci.fig_width-mci.fig_margin-100 y+mci.layout.dy_text 30 mci.layout.pby], 'BackgroundColor', mci.col.bc3, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'HorizontalAlignment', 'right');
    mci.h.ed2=uicontrol('style', 'edit', 'string', '0', 'Position', [mci.fig_width-mci.fig_margin-60 y 50 mci.layout.pby], 'BackgroundColor', mci.col.bc2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal, 'callback', 'mascoi(''table'')');

    if ~exist('spm_invTcdf', 'file')
        for i=1:length(h)
            set(h(i), 'ForegroundColor', [.6 .6 .6]);
        end
        set(mci.h.pb2, 'Enable', 'off');
        set(mci.h.ed3, 'Enable', 'off');
        set(mci.h.ed4, 'Enable', 'off');
        set(mci.h.ed5, 'Enable', 'off');
    end
    
    yi = mci.dim(2);
    xi = mci.dim(1);
    zi = mci.dim(3);
    
    if xi < 55
        xi = xi*2;
        yi = yi*2;
        zi = zi*2;
    end

    y1 = mci.fig_height-360 - (yi+zi+10)/2 + (zi+10+yi+10);
    
    axes('Position', [mci.fig_width-xi-40 y1 xi 20]./scale);
    text(.5, .5, 'left --- right', 'Color', mci.col.gray, 'HorizontalAlignment', 'center', 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal);
    axis off
    axes('Position', [mci.fig_width-2*xi-40-10 y1 xi 20]./scale);
    text(.5, .5, 'left --- right', 'Color', mci.col.gray, 'HorizontalAlignment', 'center', 'FontUnits', 'pixels', 'FontSize', mci.FontSize.normal);
    axis off
    
    dummy = zeros(mci.dim(1), mci.dim(2));
    mci.h.mip_axi{2} = axes('Position', [mci.fig_width-xi-40 y1-yi-10 xi yi]./scale);
    imagesc(dummy', [0 1]);
    axis off;
    axis equal;
    mci.h.mip_axi{1} = axes('Position', [mci.fig_width-2*xi-40-10 y1-yi-10 xi yi]./scale);
    axis ij;
    imagesc(dummy', [0 1]);
    axis off;
    axis equal;
    
    dummy = zeros(mci.dim(1), mci.dim(3));
    mci.h.mip_cor{2} = axes('Position', [mci.fig_width-xi-40 y1-yi-20-zi xi zi]./scale);
    imagesc(dummy', [0 1]);
    axis off;
    axis equal;
    
    mci.h.mip_cor{1} = axes('Position', [mci.fig_width-2*xi-40-10 y1-yi-20-zi xi zi]./scale);
    imagesc(dummy', [0 1]);
    axis off;
    axis equal;

    mascoi('colormap');
    
    return
    
%-----------------------------------------------------------------------
% mascoi('load_fun') load T- and CON-map
%-----------------------------------------------------------------------

elseif strcmp(varargin{1},'load_fun')

    if allowed==0
        return
    end
    
    if mci.spm5
        fname{1} = spm_select(1, 'spmT.*\.img', 'select t-map');
    else
        fname{1} = spm_get(1, 'spmT*.img', 'select t-map', [], 0);
    end
    if isempty(fname{1})
        return;
    end
    fname{2} = strrep(fname{1}, 'spmT', 'con');
    mci.conname_hdr = strrep(fname{2}, '.img', '.hdr');

    % read t-map (any byte order)
    
    mci.V{1} = spm_vol(fname{1});
    mci.dim = mci.V{1}.dim;
    mci.V{1}.mat_original = mci.V{1}.mat;
    if length(mci.dim)==4 % e.g. SPM2
        DataType = spm_type(mci.dim(4));
    else
        DataType = spm_type(mci.V{1}.dt(1));
    end
    for loop = 1:3
        switch loop
            case 1
                mci.bo = 'native';
            case 2
                mci.bo = 'ieee-le';
            case 3
                mci.bo = 'ieee-be';
        end
        fid = fopen(fname{1}, 'r', mci.bo);
        mci.XYZ{1} = fread(fid, DataType);
        fclose(fid);
        if max(mci.XYZ{1}) < 256
            break;
        end
    end
    if strcmp(mci.V{1}.descrip(1:4), 'SPM{') % this is what I expect from a standard spmT*img file
        mci.df_default = sscanf(mci.V{1}.descrip(8:12), '%d');
    end
        
    % read con-map (same byte order as t-map)
    
    mci.V{2} = spm_vol(fname{2});
    mci.dim = mci.V{2}.dim;
    if length(mci.dim)==4 % e.g. SPM2
        DataType = spm_type(mci.dim(4));
    else
        DataType = spm_type(mci.V{2}.dt(1));
    end
    fid = fopen(fname{2}, 'r', mci.bo);
    mci.XYZ{2} = fread(fid, DataType);
    fclose(fid);
    mci.DataType = DataType; % store datatype for later use (fwrite)

    % prepare MIP
    
    f = find(mci.XYZ{1});
    mci.window1{1} = max(abs(mci.XYZ{1}));
    mci.window0{1} = -mci.window1{1};
    
    mci.window1{2} = max(abs(mci.XYZ{2}));
    mci.window0{2} = -mci.window1{2};

    ori = round([0 0 0 1] * inv(mci.V{1}.mat'));
    
    MIP_axi{2} = zeros(mci.dim(1), mci.dim(2));
    MIP_axi{1} = zeros(mci.dim(1), mci.dim(2));
    for x=1:mci.dim(1)
        for y=1:mci.dim(2)
            index0 = x+(y-1)*mci.dim(1);
            idx = [index0:mci.dim(1)*mci.dim(2):length(mci.XYZ{2})];
            if isempty(find(mci.XYZ{1}(idx))) % outside the brain
                MIP_axi{2}(x,y) = NaN;
                MIP_axi{1}(x,y) = NaN;
            end
        end
    end
    MIP_axi{2}(ori(1),:) = NaN;
    MIP_axi{2}(:,ori(2)) = NaN;
    MIP_axi{1}(ori(1),:) = NaN;
    MIP_axi{1}(:,ori(2)) = NaN;
    
    MIP_cor{2} = zeros(mci.dim(1), mci.dim(3));
    MIP_cor{1} = zeros(mci.dim(1), mci.dim(3));
    for x=1:mci.dim(1)
        for z=1:mci.dim(3)
            index0 = x+(z-1)*mci.dim(1)*mci.dim(2);
            idx = index0 + mci.dim(1)*[0:mci.dim(2)-1];           
            if isempty(find(mci.XYZ{1}(idx))) % outside the brain
                MIP_cor{2}(x,z) = NaN;
                MIP_cor{1}(x,z) = NaN;
            end
        end
    end
    MIP_cor{2}(ori(1),:) = NaN;
    MIP_cor{2}(:,ori(3)) = NaN;
    MIP_cor{1}(ori(1),:) = NaN;
    MIP_cor{1}(:,ori(3)) = NaN;
    
    mci.MIP_cor{2} = MIP_cor{2};
    mci.MIP_axi{2} = MIP_axi{2};
    mci.MIP_cor{1} = MIP_cor{1};
    mci.MIP_axi{1} = MIP_axi{1};

    mci.fname = fname;
    
    mci.cluster = [];
    mci.table.select = [];
    try
        delete(mci.h.axes);
        set(mci.h.ed1, 'String', '');
        set(mci.h.ed2, 'String', '');
        set(mci.h.ed3, 'String', num2str(mci.df_default));
    catch
    end

    try
        stri = mci.fname{1}; if length(stri)>70 stri = ['...', stri(end-60:end)]; end; stri = ['t-map: ', stri];
        set(mci.h.fname_t, 'string', stri);
        stri = mci.fname{2}; if length(stri)>70 stri = ['...', stri(end-60:end)]; end; stri = ['con-map: ', stri];
        set(mci.h.fname_c, 'string', stri);
    catch
    end

    try
        set(mci.h.close, 'Enable', 'off');
        set(mci.h.list1, 'Enable', 'off');
        set(mci.h.list2, 'Enable', 'off');
        set(mci.h.list3, 'Enable', 'off');
        set(mci.h.select1, 'Enable', 'off');
        set(mci.h.select2, 'Enable', 'off');
    catch
    end
    
    return
    
%-----------------------------------------------------------------------
% mascoi('load_ana') load anatomical image
%-----------------------------------------------------------------------

elseif strcmp(varargin{1},'load_ana')

        if mci.spm5
            fname_img = spm_select(1, '.*\.img', 'select anatomical image');
        else
            fname_img = spm_get(1, '*.img', 'select anatomical image', [], 0);
        end
        if strcmp(fname_img(end-3:end), '.img')
            fmt_flag = 1;
            offs = 0;
        elseif strcmp(fname_img(end-3:end), '.mnc')
            fmt_flag = 2;
        else
            error('Sorry, MASCOI only reads analyze- and MINC-files. Filename extention must either be *.img or *.mnc');
        end
        mci.V{3} = spm_vol(fname_img);
        if fmt_flag == 2
            cdf = mci.V{3}.private.cdf;
            for j=1:length(cdf.var_array)
                if strcmp(cdf.var_array(j).name, 'image')
                    break;
                end
            end
            offs = cdf.var_array(j).begin;
        end
        if length(mci.V{3}.dim)==4 % e.g. SPM2
            DataType = spm_type(mci.V{3}.dim(4));
        else
            DataType = spm_type(mci.V{3}.dt(1));
        end
        for loop = 1:3
            switch loop
                case 1
                    bo = 'native';
                case 2
                    bo = 'ieee-le';
                case 2
                    bo = 'ieee-be';
            end
            fid = fopen(fname_img, 'r', bo);
            fseek(fid, offs, 'bof');
            mci.XYZ{3} = fread(fid, DataType);    
            fclose(fid);
            if 1 == 1
                break;
            end
        end
        mci.window0{3} = min(mci.XYZ{3});
        mci.window1{3} = max(mci.XYZ{3});
    
%-----------------------------------------------------------------------
% mascoi('p2t') = calculate t-thresholds
%-----------------------------------------------------------------------

elseif strcmp(varargin{1},'p2t')

    if ~isempty(mci.save.dname)
        menu(280,'Please close output directory before|changing t-thresholds', 'OK');
        return;
    end

    prc = 1000;
    DF    = str2num(get(mci.h.ed3, 'string'));
    P_001 = str2num(get(mci.h.ed4, 'string'));
    P_050 = str2num(get(mci.h.ed5, 'string'));
    T_001 = round(spm_invTcdf(1-P_001, DF)*prc)/prc;
    T_050 = round(spm_invTcdf(1-P_050, DF)*prc)/prc;
    set(mci.h.ed1, 'string', num2str(T_001));
    set(mci.h.ed2, 'string', num2str(T_050));
        
    mascoi('table');

    return
    
%-----------------------------------------------------------------------
% mascoi('table') = search clusters, refresh table
%-----------------------------------------------------------------------

elseif strcmp(varargin{1},'table')

    if nargin==2 % if function is called via MenuBar
        if allowed==0 return; end
        mci.opt.Topt=varargin{2};
    end
    
    % search suprathreshold clusters
    wflag1 = 0;
    wflag2 = 0;
    
    T_001 = str2num(get(mci.h.ed1, 'string'));
    T_050 = str2num(get(mci.h.ed2, 'string'));
    if isempty(T_001) | isempty(T_050)
        return
    end
    if T_050 == 0
        T_050 = T_001;
        set(mci.h.ed2, 'string', num2str(T_050));
    end

    set(mci.h.fig, 'pointer', 'watch');
    drawnow

    % search cluster
    
    sort_v = [];
    loop = 1;

    if mci.opt.Topt >= 0
        
        % search positive cluster
    
        mask = (mci.XYZ{1} > T_001);
        nv = sum(mask);
        list = [];
        h = waitbar(0, 'Preparing positive clusters...');
        for loop = 1:10000 % arbitrary number - exit loop with break
            f = find(mask);
            if isempty(f)
                break;
            end
            waitbar(1-length(f)/nv, h);
            mci.mask = mask;
            p = coord(f(1));
            idx{1} = get_cluster(p);
            mc = mean(mci.XYZ{2}(idx{1})); % least significant contrast
            mci.mask = ((mci.XYZ{2} > mc) & (mci.XYZ{1} > T_050)) | (mci.XYZ{1} > T_001); % enlarge cluster
            idx{2} = get_cluster(p);
    
            list(loop).lsc = mc;
            for vol = 1:2
                [m,im] = max(mci.XYZ{vol}(idx{vol}));
                list(loop).maxi{vol} = m;
                list(loop).pos{vol} = coord(idx{vol}(im)) * mci.V{vol}.mat';
                list(loop).size{vol} = length(idx{vol});
                list(loop).index{vol} = idx{vol};
            end
            sort_v = [sort_v, list(loop).size{1}];
            mask(idx{1}) = 0;
        end
        close(h)
        drawnow;

    end
    if mci.opt.Topt <= 0
        
        % search negative cluster
    
        mask = (mci.XYZ{1} < -T_001);
        nv = sum(mask);
        h = waitbar(0, 'Preparing negative clusters...');
        for loop2 = loop:10000 % arbitrary number - exit loop with break
            tic
            f = find(mask);
            if isempty(f)
                break;
            end
            waitbar(1-length(f)/nv, h);
            mci.mask = mask;
            p = coord(f(1));
            idx{1} = get_cluster(p);
            mc = mean(mci.XYZ{2}(idx{1})); % least significant contrast
            mci.mask = ((mci.XYZ{2} < mc) & (mci.XYZ{1} < -T_050)) | (mci.XYZ{1} < -T_001); % enlarge cluster
            idx{2} = get_cluster(p);
            list(loop2).lsc = mc;
            for vol = 1:2
                [m,im] = min(mci.XYZ{vol}(idx{vol}));
                list(loop2).maxi{vol} = m;
                list(loop2).pos{vol} = coord(idx{vol}(im)) * mci.V{vol}.mat';
                list(loop2).size{vol} = length(idx{vol});
                list(loop2).index{vol} = idx{vol};
            end
            sort_v = [sort_v, list(loop2).size{1}];
            mask(idx{1}) = 0;
        end
        close(h)
        
    end
    
    [y,i] = sort(sort_v);
    mci.cluster = [];
    mci.table.select = [];
    for loop=1:length(sort_v)
        ii=i(end+1-loop);
        mci.cluster{loop} = list(ii);
        mci.table.select(loop) = 0;
    end

    if ~isempty(mci.cluster)
        set(mci.h.save, 'Enable', 'on');
        set(mci.h.select1, 'Enable', 'on');
        set(mci.h.select2, 'Enable', 'on');
    end

    set(mci.h.list1, 'Enable', 'on'); % it may seem more natural to make this call directly after loading the t-map,
    set(mci.h.list2, 'Enable', 'on'); % however, by waiting until here, we ensure that the necessary t-thresholds
    set(mci.h.list3, 'Enable', 'on'); % are set.
    
    % draw axes
    
    try
        delete(mci.h.axes);
    catch
    end
    scale = [mci.fig_width, mci.fig_height, mci.fig_width, mci.fig_height];
    mci.h.axes = axes('Position', [mci.fig_margin, mci.fig_margin, mci.fig_width-2*mci.fig_margin, mci.fig_height-205]./scale, 'YLimMode', 'manual', 'XLimMode', 'manual');
    axis off
    set(gca, 'YLim', [0 1], 'XLim', [0 1]);
    
    y = 1.0; dy = 0.0287;
    line([0 1], [y y], 'Color', mci.col.black);
    y = y-0.75*dy;
    stri = sprintf('                 t-map (t > %5.2f)                masked contrast [t > %5.2f OR (con > rlsd AND t > %5.2f)]', T_001, T_001, T_050);
    text(0,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'Color', mci.col.black);
    y = y-0.75*dy;
    line([0 1], [y y], 'Color', mci.col.black);
    y = y-0.75*dy;
    stri = '          Tmax    MNI coords    voxel    rlsc*     CONmax     MNI coords     voxel   shift[mm]';
    text(0,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'Color', mci.col.black);
    y = y-1.5*dy;
    
    % the contrast may be of any order of magnitude
    % now specify the best fprint format
    
    unit = ' ';
    unit_f = 1;
    l = log10(max(abs(mci.XYZ{2})));
    if l > 3
        fmt = ['%+', num2str(floor(l+1)), '.0f'];
    elseif l > 2
        fmt = '%+6.1f';
    elseif l > 1
        fmt = '%+6.2f';
    elseif l > 0
        fmt = '%+6.3f';
    elseif l > -1
        unit = 'm';
        unit_f = 1000;
        fmt = '%+6.1f';
    elseif l > -2
        unit = 'm';
        unit_f = 1000;
        fmt = '%+6.2f';
    elseif l > -3
        unit = 'm';
        unit_f = 1000;
        fmt = '%+6.3f';
    else
        fmt = '%+.3e';
    end
    fmt = [fmt, unit];
    
    % main loop: print one row for each cluster
    
    wflag1 = 0;
    maxrows = 23;
    rows = length(mci.cluster);
    page = 0;
    first = 1;
    y_firstline = y;
    mci.table.h.main = [];
    mci.table.h.more = [];
    mci.table.h.page = [];
    mci.table.page = [];
    for loop=1:rows
        if rem(loop, maxrows)==1
            page = page+1;
            y = y_firstline;
        end
        cl = mci.cluster{loop};
        rp = (cl.size{1}*3/(4*pi))^(1/3);
        rp = rp+norm(mci.V{1}.mat(1:3,1:3))*4;
        vmax = 4/3*pi*rp^3;
        warning1 = '    ';
        warning2 = '    ';
        if cl.size{2} > vmax
            warning1 = '*** ';
            wflag1 = 1;
        end
        d = norm(cl.pos{2} - cl.pos{1});
        if warning1 == '    ' & d > 4
            warning2 = '**  ';
            wflag2 = 1;
        end
        stri = sprintf(['        %+6.2f [%+3.0f;%+4.0f;%+4.0f]%5d     ', fmt, '    ', fmt, '  [%+3.0f;%+4.0f;%+4.0f] %6d%s  %4.1f%s'], cl.maxi{1}, cl.pos{1}(1), cl.pos{1}(2), cl.pos{1}(3), cl.size{1}, cl.lsc*unit_f, cl.maxi{2}*unit_f, cl.pos{2}(1), cl.pos{2}(2), cl.pos{2}(3), cl.size{2}, warning1, d, warning2);
        more_flag = 1;
        mci.tmp.num = loop;
        while length(stri) < 98
            stri = [stri, ' '];
        end
        mci.table.h.main(loop) = text(0,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'BackgroundColor', mci.col.table{1+rem(loop,2)}, 'Margin', 1, 'ButtonDownFcn', ['mascoi(''click'', ', num2str(loop), ')'], 'visible', 'off');
        mci.table.h.more(loop) = text(0,y,'[more]','FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'ButtonDownFcn', ['mascoi(''more'', ', num2str(loop), ')'], 'Color', mci.col.gray, 'visible', 'off');
        mci.table.page(loop) = page;

        y = y-dy;
    end
    
    y = 0.22;
    line([0 mci.fig_width], [y y], 'Color', mci.col.black);
    
    y = y-0.75*dy;
    x = 0;
    for loop=1:max(mci.table.page)
        first = (loop-1)*maxrows + 1;
        last = loop*maxrows;
        last = min([last, rows]);
        stri = sprintf('<cluster %03d-%03d>', first, last);
        cb = ['global mci; mci.table.currentpage = ', num2str(loop), '; mascoi(''tablerefresh'')'];
        mci.table.h.page(loop) = text(x,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'Interpreter', 'none', 'Color', mci.col.gray, 'ButtonDownFcn', cb);    
        x = x+0.15;
    end

    y = y-0.75*dy;
    line([0 mci.fig_width], [y y], 'Color', mci.col.black);
    
    y = y-dy;

    stri = '*   rlsc = regional least significant contrast (= mean contrast in original cluster)';
    text(0,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'Color', mci.col.black);
    y = y-.5*dy;

    
    if wflag2 == 1
        y = y-dy;
        stri = '**  CAVE: shift between Tmax and CONmax. Contrast images may be spatially more precise than t-maps.';
        text(0,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'Color', mci.col.black);
        y = y-.5*dy;
    end
    if wflag1 == 1
        y = y-dy;
        stri = '*** the corresponding mask in the contrast image is considerably larger than the original cluster. This situation';
        text(0,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'Color', mci.col.black);
        y = y-dy;
        stri = '    can occur when the peak in the t-map originates from a local minimum in the variance rather than a maximum';
        text(0,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'Color', mci.col.black);
        y = y-dy;
        stri = '    in the contrast (be careful when using MNI coordinates of Tmax!). The size of the generated mask depends';
        text(0,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'Color', mci.col.black);
        y = y-dy;
        stri = '    on the specified secondary t-threshold. Please ensure that this threshold is at least p<0.05';
        text(0,y,stri,'FontName', mci.FontName.fixed, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table, 'Color', mci.col.black);
        y = y-.5*dy;
    end
    mci.table.currentpage = 1;
    mascoi('tablerefresh');
    mascoi('colormap');
    mascoi('MIP');
    set(mci.h.fig, 'pointer', 'arrow');
    drawnow
    return;

%-----------------------------------------------------------------------
% mascoi('subpeaks', cluster_id, dist) = detect subpeaks of a given
% cluster
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'subpeaks')

    nc = varargin{2};
    dist = varargin{3};
    dist_min = 1.8;
    if dist < dist_min
        warning('specified distance below reasonable minimum. Using predefined distance');
        dist = dist_min;
    end
    idx = mci.cluster{nc}.index{2};
    sig = sign(mci.cluster{nc}.maxi{2});
    s = size(mci.XYZ{2});
    flags = zeros(s);
    greater = zeros(s);
    flags(idx) = 1;

    XYZ_signed = mci.XYZ{2}(idx)*sig;
    for i=idx' % main loop: go through all pairs...
        p1 = coord(i);
        f = find(idx~=i & mci.XYZ{2}(i)*sig>XYZ_signed & flags(idx)==1);
        idx2 = idx(f);
        for ii=idx2'
            if norm(p1-coord(ii))<dist
                flags(ii) = 0; % this is not a peak. Kill it.
            end
        end
    end
    f = find(flags);
    for i=f'
        fprintf('\n\n (sub-)peak at');
        mni = coord(i) * mci.V{2}.mat';
        tt = round(mni2tal(mni(1:3)));
        ttv = tt + mci.TD.offset;
        mni = round(mni);
        fprintf('\n MNI: %d/%d/%d', mni(1), mni(2), mni(3));
        fprintf('\n TT:  %d/%d/%d', tt(1), tt(2), tt(3));
        fprintf('\n Contrast: %f', mci.XYZ{2}(i));
        
        if min(ttv) > 0 & max(ttv-mci.TD.max) <= 0
            for lv=mci.TD.levels
                code = mci.TD.level{lv}.xyz(ttv(1),ttv(2),ttv(3));
                if code == 0
                    name = '*';
                else
                    name = mci.TD.level{lv}.names{code};
                    name = strrep(name, '__', ' ');
                    name = strrep(name, '_', '-');
                end
                fprintf('\n %s',name)
            end
        end
        fprintf('\n\n');
        
    end
    return;    
    
%-----------------------------------------------------------------------
% mascoi('click') = switch select status of cluster, refresh list and MIP
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'click')

    if allowed==0 return; end

    n = varargin{2};
    mci.table.select(n) = 1-mci.table.select(n);
    mascoi('tablerefresh');
    mascoi('MIP');
    set(mci.h.save, 'Enable', 'on');

    return
    
%-----------------------------------------------------------------------
% mascoi('select') = select/deselect clusters (function called via menubar)
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'select')

    if allowed==0 return; end

    if strcmp(varargin{2}, 'all+')
        mci.table.select(1:length(mci.cluster)) = 1;
    elseif strcmp(varargin{2}, 'all-');
        mci.table.select(1:length(mci.cluster)) = 0;    
    end
    
    mascoi('tablerefresh');
    mascoi('MIP');
    set(mci.h.save, 'Enable', 'on');

    return

%-----------------------------------------------------------------------
% mascoi('tablerefresh')
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'tablerefresh')
    
    ma = mci.table.h.main;
    mo = mci.table.h.more;
    se = mci.table.select;
    
    for i=1:length(mci.cluster)
        if mci.table.currentpage == mci.table.page(i)
            if se(i)==0
                set(ma(i), 'Color', mci.col.gray, 'FontWeight', mci.FontName.normalstr, 'Visible', 'on');
                set(mo(i), 'visible', 'off');
            else
                if mci.cluster{i}.maxi{1} > 0
                    co = mci.col.red;
                else
                    co = 'b';
                end
                set(ma(i), 'Color', co, 'FontWeight', mci.FontName.boldstr, 'Visible', 'on');
                set(mo(i), 'visible', 'on');
            end
        else
            set(ma(i), 'visible', 'off');
            set(mo(i), 'visible', 'off');
        end    
    end

    for i=1:max(mci.table.page)
        if i==mci.table.currentpage
            col = 'b';
        else
            col = mci.col.gray;
        end
        set(mci.table.h.page(i), 'Color', col);
    end
    
%-----------------------------------------------------------------------
% mascoi('click2') = select slice to be displayed
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'click2')
    
    nc = varargin{2};
    pane = varargin{3};
    i = varargin{4}; % from -3 to +3
    IMG = mci.cluster{nc}.pane{pane}.IMG{i+4};
    mci.cluster{nc}.pane{pane}.img_num = i+4;
    imagesc(IMG,[0 2]);
    axis equal; axis off
    stri = ['[<]'; '[<]';'[<]';'[+]';'[>]';'[>]';'[>]'];
    x = size(IMG,2)/2;
    for ii=-3:3
        c = [0 .5 .5];
        if ii==i
            c = [0 1 1];
        end
        text(x+ii*x/6,0,stri(ii+4,:),'Color',c,'VerticalAlignment','top','HorizontalAlignment','center','FontUnits','pixels','FontSize',12,'ButtonDownFcn',['mascoi(''click2'',',num2str(nc),',',num2str(pane),',',num2str(ii),')']);
    end
    text(x,size(IMG,1),mci.cluster{nc}.pane{pane}.location_display{i+4},'Color', [1 1 1],'VerticalAlignment','bottom','HorizontalAlignment','center','FontUnits','pixels','FontSize',12,'ButtonDownFcn',['mascoi(''click2'',',num2str(nc),',',num2str(pane),',',num2str(ii),')']);

    return;

%-----------------------------------------------------------------------
% mascoi('MIP') = refresh MIP
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'MIP')

    set(mci.h.fig, 'pointer', 'watch');
    drawnow

    MIP_axi{1} = mci.MIP_axi{1};
    MIP_cor{1} = mci.MIP_cor{1};
    MIP_axi{2} = mci.MIP_axi{2};
    MIP_cor{2} = mci.MIP_cor{2};

    % calculate masked contrast volume
    mci.mXYZ{2} = zeros(size(mci.XYZ{2}));
    mci.mXYZ{1} = zeros(size(mci.XYZ{2}));
    for i=1:length(mci.table.select)
        if mci.table.select(i) == 1
            idx = mci.cluster{i}.index{1};
            mci.mXYZ{1}(idx) = mci.XYZ{1}(idx);
            idx = mci.cluster{i}.index{2};
            mci.mXYZ{2}(idx) = mci.XYZ{2}(idx);
        end
    end
    for vol = 1:2
        mci.window1{vol} = max(abs(mci.mXYZ{vol}));
        if mci.window1{vol} == 0
            mci.window1{vol} = max(abs(mci.XYZ{vol}));
        end
        mci.window0{vol} = -mci.window1{vol};
    end
    % calculate axial MIP
    for x=1:mci.dim(1)
        for y=1:mci.dim(2)
            index0 = x+(y-1)*mci.dim(1);
            idx = [index0:mci.dim(1)*mci.dim(2):length(mci.mXYZ{2})];
            for vol = 1:2
                ma = max(mci.mXYZ{vol}(idx));
                if ma > 0 %if there is at least one positive cluster
                    MIP_axi{vol}(x,y) = ma;
                elseif min(mci.mXYZ{vol}(idx)) < 0 %if there is at least one negative cluster
                    MIP_axi{vol}(x,y) = min(mci.mXYZ{vol}(idx));
                end
            end
        end
    end

    % calculate coronal MIP
    for x=1:mci.dim(1)
        for z=1:mci.dim(3)
            index0 = x+(z-1)*mci.dim(1)*mci.dim(2);
            idx = index0 + mci.dim(1)*[0:mci.dim(2)-1];
            for vol = 1:2            
                ma = max(mci.mXYZ{vol}(idx));
                if ma > 0 %if there is at least one positive cluster
                    MIP_cor{vol}(x,z) = ma;
                elseif min(mci.mXYZ{vol}(idx)) < 0 %if there is at least one negative cluster
                    MIP_cor{vol}(x,z) = min(mci.mXYZ{vol}(idx));
                end
            end
        end
    end

    if mci.V{1}.mat(1,1) < 0
        for vol = 1:2
            MIP_axi{vol} = flipud(MIP_axi{vol});
            MIP_cor{vol} = flipud(MIP_cor{vol});
        end
    end

    % plot MIP
    MIP_label{1} = 't-map';
    MIP_label{2} = 'contrast';
    for vol = 1:2
        
        axes(mci.h.mip_axi{vol});
        imagesc(scale_img(MIP_axi{vol},vol,[]), [0 2]);
        axis off; axis equal

        axes(mci.h.mip_cor{vol});
        imagesc(scale_img(MIP_cor{vol},vol,[]), [0 2]);
        axis off; axis equal
        text(mci.dim(1)/2, mci.dim(3), MIP_label{vol}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontUnits', 'pixels', 'FontSize', mci.FontSize.small);
    
    end
    set(mci.h.fig, 'pointer', 'arrow');
    drawnow

%-----------------------------------------------------------------------
% mascoi('colormap') = define and apply colormap
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'colormap')

    n=21;
    for i=1:n
        cm(i,:) = [(n-i+1)/n, 1, 1];
    end
    for i=n+1:2*n
        cm(i,:) = [0, (2*n-i+1)/n, 1];
    end
    for i=2*n+1:3*n
        cm(i,:) = [0, 0, (3*n-i+1)/n];
    end
    for i=3*n+1:4*n
        cm(i,:) = [(i-3*n-1)/n, 0, 0];
    end
    for i=4*n+1:5*n
        cm(i,:) = [1, (i-4*n-1)/n, 0];
    end
    for i=5*n+1:6*n
        cm(i,:) = [1, 1, (i-5*n-1)/n];
    end
    limit = [.3 .3 .3];
    for i=1:6*n
        brightness = sum(cm(i,:));
        bl = sum(limit(:));
        if brightness < bl
            cm(i,:) = cm(i,:) + (bl-brightness)/bl * limit;
        end
    end
    
    cm(127,:) = [1 1 1];
    cm(128,:) = [1 1 1];
    
    if mci.opt.funflip==1
        cm(2:128,:) = flipud(cm(2:128,:));
    end
    

    % add grayscale (dual colormap)
    
    mci.cm(1:128,:) = gray(128);
    mci.cm(129:256,:) = cm;
    colormap(mci.cm);

%-----------------------------------------------------------------------
% mascoi('funflip') = flip colormap
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'funflip')

    if allowed==0
        return
    end
    mci.opt.funflip = 1-mci.opt.funflip;
    mascoi('colormap');
    
%-----------------------------------------------------------------------
% mascoi('save') = create output directory and write mci volume
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'save')

    mci.table.currentpage = 1;
    mascoi('tablerefresh');
    
    dname = strrep(mci.conname_hdr, 'con', 'mci');
    dname = dname(1:end-4);
    
    % make new directory
    %-------------------
    
    for i=1:999
        mci.save.dname = sprintf('%s-%03d', dname, i);
        if ~exist(mci.save.dname)
            break;
        end
    end
    
    [pathstr, name] = fileparts(mci.save.dname);
    
    mkdir(pathstr, name);
    
    % disable edit widgets
    %---------------------
    
    set(mci.h.ed1, 'Enable', 'off');
    set(mci.h.ed2, 'Enable', 'off');
    
    % save screenshot
    %----------------
    
    print(mci.h.fig, '-dpdf', [mci.save.dname, filesep, 'screenshot.pdf']);
    
    % write masked contrast volume
    %-----------------------------
    
    outname_img = fullfile(mci.save.dname, 'mci.img');
    outname_hdr = fullfile(mci.save.dname, 'mci.hdr');
    fid = fopen(outname_img, 'w', mci.bo);
    fwrite(fid, mci.mXYZ{2}, mci.DataType);
    fclose(fid);
    if strcmp(mci.sys.os, 'Win')
        stri = sprintf('!copy "%s" "%s"', mci.conname_hdr, outname_hdr);
    else
        stri = sprintf('!cp "%s" "%s"', mci.conname_hdr, outname_hdr);
    end
    eval(stri);

    % create colorbar with tickmarks for export as bitmap
    %----------------------------------------------------
    
    cmf = figure('MenuBar', 'none', 'Position', [201 201 300 300], 'Resize', 'off', 'Visible', 'off');    
    h = axes('Position', [0.1 0.1 .2 .8]);
    for i = 1:128
        A(1:128,i) = [129:256]';
    end
    image(flipud(A));
    hold on;
    colormap(mci.cm);
    plot([0 2],[64.5 64.5], 'k');
    set(gca,'XTick', []);
    for vol = 1:2
        scale = mci.window1{vol};
        maxtick = 20;
        tick{vol} = 0.00001;
        while 1
            if scale/tick{vol} < maxtick
                break;
            end
            tick{vol} = tick{vol} * 5;
            if scale/tick{vol} < maxtick
                break;
            end
            tick{vol} = tick{vol} * 2;
        end
        n = floor(scale/tick{vol});
        ytick = [];
        ylabel = [];
        prec = 10000000000000;
        for loop=-n:n
            val = loop*tick{vol};
            y = (val - mci.window0{vol})/(mci.window1{vol}-mci.window0{vol})*127 + 1;
            ytick = [ytick y];
            ylabel = [ylabel val];
        end
        set(gca, 'YTick', ytick);
        set(gca, 'YTickLabel', fliplr(ylabel));
        if vol==1
            fname = 'colormap_T.png';
        else
            fname = 'colormap_CON.png';
        end
        print(gcf, '-dpng', [mci.save.dname, filesep, fname]);
    end
    close(cmf);

    menu(400, ['successfully created|', mci.save.dname, '|cluster list is frozen until documentation mode is left|(File => Close)'], 'OK');

    set(mci.h.save, 'Enable', 'off');
    set(mci.h.close, 'Enable', 'on');

%-----------------------------------------------------------------------
% mascoi('close') = close output directory
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'close')

    mci.save.dname = '';

    stri = sprintf('%d cluster(s) selected, click [save] to save images and documentation', sum(mci.table.select));
    set(mci.h.close, 'Enable', 'off');
    set(mci.h.save, 'Enable', 'on');
    set(mci.h.ed1, 'Enable', 'on');
    set(mci.h.ed2, 'Enable', 'on');


%-----------------------------------------------------------------------
% mascoi('save2') = save more
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'save2')

    if isempty(mci.save.dname)
        menu(280, 'Please switch to SAVE mode|by clicking [save...] in the|main window', 'OK');
        return;
    end
    cluster = varargin{2};
    dname2r = sprintf('cluster%03d', cluster);
    dname2 = [mci.save.dname, filesep, dname2r];
    if ~exist(dname2)
        mkdir(mci.save.dname, dname2r);
    end
    set(mci.h.save2_pb, 'visible', 'off');
    print(gcf, '-dpdf', [dname2, filesep, 'screenshot.pdf']);
    set(mci.h.save2_pb, 'visible', 'on');

    stri{1} = 'png_T_axi_';
    stri{2} = 'png_CON_axi_';
    stri{3} = 'png_T_cor_';
    stri{4} = 'png_CON_cor_';
    stri{5} = 'png_T_sag_';
    stri{6} = 'png_CON_sag_';
    for pane = 1:6
        img_num = mci.cluster{cluster}.pane{pane}.img_num;
        IMG = mci.cluster{cluster}.pane{pane}.IMG{img_num};
        
        png(IMG, [dname2, filesep, stri{pane}, mci.cluster{cluster}.pane{pane}.location_fname{img_num}, '.png']);
    end

    
%-----------------------------------------------------------------------
% mascoi('leftright') = coordinate system dialog
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'leftright')

    global defaults

    if allowed==0
        return
    end

    stri{1} = 'the voxel order in *.img files may vary...';
    try
        if defaults.analyze.flip == 1
            stri{2} = '- local preferences: defaults.analyze.flip=1';
        else
            stri{2} = '- local preferences: defaults.analyze.flip=0';        
        end
    catch
        stri{2} = '- local preferences: defaults.analyze.flip not set';
    end
    if mci.V{1}.mat_original(1,1) > 0
        stri{3} = '- spm_vol() suggests: left to right';
    else
        stri{3} = '- spm_vol() suggests: right to left';
    end
    if mci.V{1}.mat(1,1) > 0
        stri{4} = '- current interpretation: left to right';
    else
        stri{4} = '- current interpretation: right to left';
    end
    stri{5} = 'please choose:';
    stri0 = '';
    for i=1:5
        stri0 = [stri0,'|',stri{i}];
    end
    m = menu(400, stri0, 'left to right', 'right to left', 'Cancel');
    if m == 3
        return;
    elseif m == 1
        if mci.V{1}.mat(1,1) < 0
            mci.V{1}.mat(1,1) = -mci.V{1}.mat(1,1);
            mci.V{1}.mat(1,4) = -mci.V{1}.mat(1,4);
            mci.V{2}.mat(1,1) = -mci.V{2}.mat(1,1);
            mci.V{2}.mat(1,4) = -mci.V{2}.mat(1,4);
            mascoi('table');
        end
    else
        if mci.V{1}.mat(1,1) > 0
            mci.V{1}.mat(1,1) = -mci.V{1}.mat(1,1);
            mci.V{1}.mat(1,4) = -mci.V{1}.mat(1,4);
            mci.V{2}.mat(1,1) = -mci.V{2}.mat(1,1);
            mci.V{2}.mat(1,4) = -mci.V{2}.mat(1,4);
            mascoi('table');
        end
    end
    
%-----------------------------------------------------------------------
% mascoi('more')
%-----------------------------------------------------------------------
    
elseif strcmp(varargin{1}, 'more')
    
    set(mci.h.fig, 'Pointer', 'watch');
    drawnow

    if length(mci.V) == 2 % no anatomical image loaded yet
        mascoi('load_ana');
    end
    
    nc = varargin{2};
    fig2.width = 950;
    fig2.height = 750;
    scale = [fig2.width fig2.height fig2.width fig2.height];
    border = 10;
    
    scs = get(0, 'ScreenSize');
    figure('Position', [(scs(3)-fig2.width)/2 (scs(4)-fig2.height)/2 fig2.width fig2.height], 'Color', [.8 .8 .8]);
    set(gcf, 'MenuBar', 'none', 'Resize', 'off');   
    set(gcf, 'Name', ['cluster ', num2str(nc)]);
    set(gcf, 'Pointer', 'watch');
    print_init;
    
    colormap(mci.cm);

    A = zeros(128,128);
    for i=1:128
        A(1:128,i) = [1:128]';
    end
    
    axes('position', [0 0 1 1]);
    box on;
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    set(gca, 'Color', [1 1 .9]);
    set(gca, 'XColor', mci.col.frame);
    set(gca, 'YColor', mci.col.frame);
    imagesc(A, [1 512]);
    axis off;
    line([.5 .5], [0 1], 'color', [1 1 1], 'linewidth', 2);
    tcol1 = [.8 .8 .8];
    tcol2 = [1 1 .5];
    
    col{1} = fig2.width * 1/8;
    col{2} = fig2.width * 5/8;
    
    for vol = 1:2
    
        axes('Position', [(vol-1)/2+.25 0 .25 1]);
        set(gca, 'XLim', [0 1]);
        set(gca, 'YLim', [0 1]);
        axis off
        hold on

        yy = 1;
        dy = 0.018;
        yy = yy-4*dy;
        xx = .3;
        idx = mci.cluster{nc}.index{vol};
        if vol == 1
            text(-0.5,yy, 'T-MAP (original cluster)', 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            text(-0.5,yy, '----------------------------------', 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            yy = 1-4*dy;
            text(xx,yy, 'peak position', 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            text(xx,yy, '------------------------', 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            [y,im] = max(abs(mci.XYZ{1}(idx)));
            y = mci.XYZ{1}(idx(im));
            text(xx,yy, ['Tmax = ', num2str(y)], 'HorizontalAlignment', 'center', 'color', tcol1, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
        else
            text(-0.5,yy, 'CONTRAST (enlarged cluster)', 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            text(-0.5,yy, '-------------------------------------', 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            yy = 1-4*dy;
            text(xx,yy, 'peak position', 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            text(xx,yy, '------------------------', 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            [y,im] = max(abs(mci.XYZ{2}(idx)));
            y = mci.XYZ{2}(idx(im));
            text(xx,yy, ['CONmax = ', num2str(y)], 'HorizontalAlignment', 'center', 'color', tcol1, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
        end

        % get coordinates and TT labels of maximum

        p = coord(idx(im));
        mni = p * mci.V{vol}.mat';
        tt = round(mni2tal(mni(1:3)));
        ttv = tt + mci.TD.offset;
        mni = round(mni);
        mni_max{vol} = mni;

        text(xx,yy, ['MNI [', num2str(mni(1)), '/', num2str(mni(2)), '/', num2str(mni(3)),']'], 'HorizontalAlignment', 'center', 'color', tcol1, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
        text(xx,yy, ['TT  [', num2str(tt(1)),  '/', num2str(tt(2)),  '/', num2str(tt(3)), ']'], 'HorizontalAlignment', 'center', 'color', tcol1, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;

        if min(ttv) < 1 | max(ttv-mci.TD.max) > 0
            text(xx,yy, 'No TT label for maximum', 'HorizontalAlignment', 'center', 'color', tcol1); yy = yy-dy;
        else
            for lv=mci.TD.levels
                code = mci.TD.level{lv}.xyz(ttv(1),ttv(2),ttv(3));
                if code == 0
                    name = '*';
                else
                    name = mci.TD.level{lv}.names{code};
                    name = strrep(name, '__', ' ');
                    name = strrep(name, '_', '-');
                end
                text(xx,yy, name, 'HorizontalAlignment', 'center', 'color', tcol1, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            end
        end

        % whole cluster statistics
        
        yy = yy-dy;
        
        text(xx,yy, ['all ', num2str(length(idx)), ' voxels:'], 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
        text(xx,yy, '------------------------', 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
        
        for lv=[1 2 3 4 5]
            v{lv} = zeros(10000,1);
            pointer{lv} = 0;
        end
        for i=idx'        
            p = coord(i);
            mni = p * mci.V{1}.mat';
            tt = round(mni2tal(mni(1:3)));
            ttv = tt + mci.TD.offset;
            if min(ttv) < 1 | max(ttv-mci.TD.max) > 0
                continue
            end
            for lv=[1 2 3 4 5]
                pointer{lv} = pointer{lv}+1;
                v{lv}(pointer{lv}) = mci.TD.level{lv}.xyz(ttv(1),ttv(2),ttv(3));
            end        
        end
        yy = yy+.5*dy;
        for lv=[1 2 3 4 5]
            v{lv} = v{lv}(1:pointer{lv});
            yy = yy-.5*dy;
            text(xx,yy, ['Talairach level ', num2str(lv)], 'HorizontalAlignment', 'center', 'color', tcol2, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            n = [];
            for i=1:mci.TD.level{lv}.namepointer-1
                n(i)=length(find(v{lv}==i));
            end
            n0=length(find(v{lv}==0));
            [s,si]=sort(n);
            s = fliplr(s);
            si = fliplr(si);
            for loop=1:length(si)
                if s(loop) == 0
                    break;
                end
                name = mci.TD.level{lv}.names{si(loop)};
                name = strrep(name, '__', ' ');
                name = strrep(name, '_', '-');
                text(xx,yy, [num2str(s(loop)), ' pixel:'], 'HorizontalAlignment', 'right', 'color', tcol1, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2);
                text(xx,yy, name, 'HorizontalAlignment', 'left', 'color', tcol1, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            end
            text(xx,yy, [num2str(n0), ' pixel:'], 'HorizontalAlignment', 'right', 'color', tcol1, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2);
            text(xx,yy, 'no label', 'HorizontalAlignment', 'left', 'color', tcol1, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.table2); yy = yy-dy;
            drawnow
        end

        % display slices
        
        x = mni_max{vol}(1);
        y = mni_max{vol}(2);
        z = mni_max{vol}(3);
        
        IMG_sag = get_sag(x,vol);
        IMG_cor = get_cor(y,vol);
        IMG_axi = get_axi(z,vol);

        [zf, yf] = size(IMG_sag);
        [zf, xf] = size(IMG_cor);
        
        if yf>240
            zf=zf/2;
            xf=xf/2;
            yf=yf/2;
        end
        
        % axial
        
        yy = fig2.height - 100 - yf;
        haxi{vol} = axes('Position', [col{vol}-xf/2 yy xf yf]./scale);
        imagesc(IMG_axi, [0 2]);
        axis equal; axis off
        text(size(IMG_axi,2)/2,0,'please wait...','Color',[0 1 1],'VerticalAlignment','top','HorizontalAlignment','center','FontUnits','pixels','FontSize',12);
        drawnow
        
        % coronal
        
        yy = yy - zf - 10;
        hcor{vol} = axes('Position', [col{vol}-xf/2 yy xf zf]./scale); 
        imagesc(IMG_cor, [0 2]);
        axis equal; axis off
        text(size(IMG_cor,2)/2,0,'please wait...','Color',[0 1 1],'VerticalAlignment','top','HorizontalAlignment','center','FontUnits','pixels','FontSize',12);
        drawnow

        % sagittal
        
        yy = yy - zf - 20;
        hsag{vol} = axes('Position', [col{vol}-xf/2 yy yf zf]./scale); 
        imagesc(IMG_sag, [0 2]);
        axis equal; axis off
        text(size(IMG_sag,2)/2,0,'please wait...','Color',[0 1 1],'VerticalAlignment','top','HorizontalAlignment','center','FontUnits','pixels','FontSize',12);
        drawnow        
        
    end

    % calculate hidden slices
    
    for vol = 1:2
        
        % axial images
        z0 = mni_max{vol}(3);
        dz = mci.V{vol}.mat(3,3);
        IMG = [];
        for loop = 1:7
            z = z0 + (loop-4)*dz;
            IMG{loop} = get_axi(z,vol);
            location_display{loop} = sprintf('z=%+d', round(z));
            location_fname{loop} = sprintf('z%+03d', round(z));
        end
        mci.cluster{nc}.pane{vol}.IMG = IMG;
        mci.cluster{nc}.pane{vol}.img_num = 4;
        mci.cluster{nc}.pane{vol}.location_display = location_display;
        mci.cluster{nc}.pane{vol}.location_fname = location_fname;
        
        % coronal images
        y0 = mni_max{vol}(2);
        dy = mci.V{vol}.mat(2,2);
        IMG = [];
        for loop = 1:7
            y = y0 + (loop-4)*dy;
            IMG{loop} = get_cor(y,vol);
            location_display{loop} = sprintf('y=%+d', round(y));
            location_fname{loop} = sprintf('y%+03d', round(y));
        end
        mci.cluster{nc}.pane{vol+2}.IMG = IMG;
        mci.cluster{nc}.pane{vol+2}.img_num = 4;
        mci.cluster{nc}.pane{vol+2}.location_display = location_display;
        mci.cluster{nc}.pane{vol+2}.location_fname = location_fname;
               
        % sagittal images
        x0 = mni_max{vol}(1);
        dx = mci.V{vol}.mat(1,1);
        IMG = [];
        for loop = 1:7
            x = x0 + (loop-4)*dx;
            IMG{loop} = get_sag(x,vol);
            location_display{loop} = sprintf('x=%+d', round(x));
            location_fname{loop} = sprintf('x%+03d', round(x));
        end
        mci.cluster{nc}.pane{vol+4}.IMG = IMG;
        mci.cluster{nc}.pane{vol+4}.img_num = 4;
        mci.cluster{nc}.pane{vol+4}.location_display = location_display;
        mci.cluster{nc}.pane{vol+4}.location_fname = location_fname;
               
    end

    for vol = 1:2
        axes(haxi{vol});
        mascoi('click2', nc, vol, 0);
        axes(hcor{vol});
        mascoi('click2', nc, 2+vol, 0);
        axes(hsag{vol});
        mascoi('click2', nc, 4+vol, 0);
    end

    w = 100; h = mci.layout.pby; mci.h.save2_pb = uicontrol('style', 'pushbutton', 'Position', [0 fig2.height-h+1 fig2.width h], 'String', 'save...', 'FontUnits', 'pixels', 'FontSize', mci.FontSize.button, 'BackgroundColor', [.8 .8 .8], 'Callback', ['mascoi(''save2'',', num2str(nc), ');']);

    set(gcf, 'Pointer', 'arrow');
    set(mci.h.fig, 'Pointer', 'arrow');
    drawnow
    return;
    
end

% END of function mascoi()
%=======================================================================



%-----------------------------------------------------------------------
% tt_load() = load talairach coordinates
%-----------------------------------------------------------------------
    
function tt_load()

global mci

if exist('mci_td.mat') == 0
    fprintf('\n file mci_td.mat not found. Looking for text input...\n');
else
    fname = which('mci_td.mat');
    fprintf('\n loading Talairach coordinates from file %s ...', fname);
    try
        load mci_td.mat
        fprintf(' Done.\n');
        mci.TD = TD;
        return;
    catch
        error('error reading mci_td.mat. Delete this file to read text file instead');
    end
end
    
if exist('mci_td.txt') == 0
    error('file mci_td.txt not found. Please ensure that either a readable matlab file named ''mci_td.mat'' or a text file named ''mci_td.txt'' is present in the matlab search path.');
    return;
end
fname = which('mci_td.txt');
TD = [];
dx = 71;
dy = 103;
dz = 43;
TD.offset = [dx, dy, dz];
TD.max = [141, 171, 111];
fprintf('\n Converting text file %s to matlab struct. This may take several minutes (or more) ...\n ', fname)
ftd = fopen(fname);
lin = fgets(ftd); % discard first line...
while lin(1) == '%'
    lin = fgets(ftd); % ...and the following lines if the contain a comment
end
TD.levels = [1 2 3 4 5];
for i=TD.levels
    TD.level{i}.namepointer = 1;
    TD.level{i}.xyz = zeros(TD.max);
end
for loop = 1:10000000
    if mod(loop,500) == 0
        fprintf('.');
        mci.TD = TD;
    end
    if mod(loop,500*40) == 0
        fprintf('\n ');
    end
    lin = fgets(ftd);
    if lin == -1
        break;
    end
    f = findstr(lin, ',');
    if length(f) > 8
        x = str2num(lin(f(1)+1:f(2)-1));
        y = str2num(lin(f(2)+1:f(3)-1));
        z = str2num(lin(f(3)+1:f(4)-1));
        for i=TD.levels
            s = lin(f(i+3)+1:f(i+4)-1);
            s = strtrim(s);
            if strcmp(s, '*') continue; end
            s = strrep(s, ' ', '__');
            s = strrep(s, '-', '_');
            if ~isfield(TD.level{i}, s)
                namepointer = TD.level{i}.namepointer;
                TD.level{i}.(s) = namepointer;
                TD.level{i}.names{namepointer} = s;
                TD.level{i}.namepointer = namepointer + 1;
            end
            TD.level{i}.xyz(x+dx, y+dy, z+dz) = TD.level{i}.(s);
        end
    end
end
fclose(ftd);
fname_out = [fname, '.mat'];
fprintf('\n write matlab struct to %s', fname_out);
save(fname_out, 'TD');
mci.TD = TD;
return;



%=======================================================================
% subroutine index(p)
%=======================================================================

function idx = index(p,vol)

global mci

p = round(p);
if length(p) == 3
    p = p - [1, 1, 1];
else
    p = p - [1, 1, 1, 0];
end
idx = 1 + p(1) + p(2)*mci.V{vol}.dim(1) + p(3)*mci.V{vol}.dim(1)*mci.V{vol}.dim(2);
return



%=======================================================================
% subroutine coord(idx)
%=======================================================================

function p = coord(idx)

if isempty(idx)
    p = [];
    return;
end

global mci

nxy = mci.dim(1)*mci.dim(2);
nx = mci.dim(1);

p(3) = floor(idx/nxy);
idx = idx-p(3)*nxy;
p(2) = floor(idx/nx); 
idx = idx-p(2)*nx;
p(1) = idx-1;
p = p + [1 1 1];
p(4) = 1;
return


%=======================================================================
% subroutine get_cluster(p)
%=======================================================================

function v = get_cluster(p)

global mci

delta(1) = +1;
delta(2) = -1;
delta(3) = +mci.dim(1);
delta(4) = -mci.dim(1);
delta(5) = +mci.dim(1)*mci.dim(2);
delta(6) = -mci.dim(1)*mci.dim(2);
idx_max = mci.dim(1)*mci.dim(2)*mci.dim(3);

mci.mask(idx_max + delta(5)) = 0; % to avoid error

v = zeros(100000,1);
v(1) = index(p,1);

if mci.mask(v(1)) == 0
    error('start coordinates outside cluster');
end

nstack = 1;
flag = mci.mask * 0; % redundancy for performance: flag(idx)=1 means idx is present on stack
flag(v(1)) = 1;

pointer = 1; % v(pointer:end) need to be checked for neighbours

while 1 % repeat until no new neighbours are detected
    
    n = nstack; % number of voxels so far on the stack
    for i=pointer:n
        p = v(i);
        p2 = p+delta;
        p2 = p2(find(p2>0));
        p2 = p2(find(flag(p2) ~= 1 & mci.mask(p2) ~= 0));
        nvox = length(p2);
        v(nstack+1:nstack+nvox) = p2;
        flag(p2) = 1;
        nstack = nstack + nvox;
    end
    if n == nstack % if no new voxels were added
        break;
    end
    pointer = n+1; % all voxels v(1 to n) are now checked for neighbours
end

v = v(1:nstack);


%=======================================================================
% subroutine scale_img(A,vol,B)
%=======================================================================

function B = scale_img(A,vol,B)

global mci

f = find(A);
fNaN = find(isnan(A));
A = (A-mci.window0{vol}) / (mci.window1{vol}-mci.window0{vol});

if isempty(B)
    B = A+1;
else
    if mci.opt.anaflip==0
        B = (B-mci.window0{3}) / (mci.window1{3}-mci.window0{3});
    else
        B = (mci.window1{3}-B) / (mci.window1{3}-mci.window0{3});
    end
    B(f) = A(f)+1;
end
B(fNaN) = 0;
B = flipud(B');


%=======================================================================
% subroutine conv_img(A)
%=======================================================================

function A = conv_img(A)

K = [0 1 0; 1 2 1; 0 1 0];

for i=1:2 % a matter of taste
    A = conv2(A,K);
    A = A(2:end-1,2:end-1) / sum(sum(K));
end


%=======================================================================
% subroutine get_axi(z,vol)
% 
% calculate single slice at position z including
% color blobs from the "functional" image.
%
% The algorithm is optimized for the common case where
% both the anatomical as well as the functional image
% have a size of multiples of .5mm:
% If all source pixel have integer size (1mm, 2mm, 3mm...), 
% the calculated matrix has 1mm pixels, obtained from the source as
% nearest neighbors (optionally duplicated). For source pixels
% with floating point size 0.5mm, 1.5mm etc., a matrix
% with .5mm is calculated. Pixels from the anatomical
% image (but not from the functional image) are slightly smoothed,
% if duplicated.
%=======================================================================

function IMG = get_axi(z,vol)

global mci

mf = mci.V{1}.mat(1,1);
ma = mci.V{3}.mat(1,1);

if mf == round(mf) & ma == round(ma)
    pxs = 1;
elseif mf*2 == round(mf*2) & ma*2 == round(ma*2)
    pxs = .5;
else
    error('Sorry, only traditional voxel sizes (multiples of .5mm) are supported.');
end

% blowup = destination matrix index increment per source index increment
blowup_f = abs(mf) / pxs;
signum_f = sign(mf);
blowup_a = abs(ma) / pxs;
signum_a = sign(ma);

% MNI coordinates of the borders
xlim = [-92, 92]; 
ylim = [-125, 95];

IMG_a = zeros((max(xlim)-min(xlim))/pxs, (max(ylim)-min(ylim))/pxs);
IMG_f = zeros((max(xlim)-min(xlim))/pxs, (max(ylim)-min(ylim))/pxs);

% get functional
for loop = 1:blowup_f
    X{loop} = xlim(1)+(loop-1)*pxs:blowup_f*pxs:xlim(2);
    Xi{loop} = (X{loop}-xlim(1))/pxs+1;
    IDX{loop} = 0:signum_f:(length(X{loop})-1)*signum_f;
end
for y = ylim(1):pxs:ylim(2)
    yi = (y-ylim(1))/pxs+1;
    for dx = 0:blowup_f-1
        mni0 = [xlim(1)+dx y z 1];
        p0 = mni0 * inv(mci.V{vol}.mat)';
        idx0 = index(p0,vol);   
        try
            IMG_f(Xi{dx+1},yi) = mci.mXYZ{vol}(IDX{dx+1}+idx0);
        end
    end
end

% get anatomical
for loop = 1:blowup_a
    X{loop} = xlim(1)+(loop-1)*pxs:blowup_a*pxs:xlim(2);
    Xi{loop} = (X{loop}-xlim(1))/pxs+1;
    IDX{loop} = 0:signum_a:(length(X{loop})-1)*signum_a;
end
for y = ylim(1):pxs:ylim(2)
    yi = (y-ylim(1))/pxs+1;
    for dx = 0:blowup_a-1
        mni0 = [xlim(1)+dx y z 1];
        p0 = mni0 * inv(mci.V{3}.mat)';
        idx0 = index(p0,3);
        try
            IMG_a(Xi{dx+1},yi) = mci.XYZ{3}(IDX{dx+1}+idx0);
        end
    end
end
if blowup_a > 1
    IMG_a = conv_img(IMG_a);
end
IMG = scale_img(IMG_f,vol,IMG_a);


%=======================================================================
% subroutine get_cor(y,vol)
%
% see comment for function get_axi()
%=======================================================================

function IMG = get_cor(y,vol)

global mci

mf = mci.V{1}.mat(1,1);
ma = mci.V{3}.mat(1,1);

if mf == round(mf) & ma == round(ma)
    pxs = 1;
elseif mf*2 == round(mf*2) & ma*2 == round(ma*2)
    pxs = .5;
else
    error('Sorry, only traditional voxel sizes (multiples of .5mm) are supported.');
end

% blowup = destination matrix index increment per source index increment
blowup_f = abs(mf) / pxs;
signum_f = sign(mf);
blowup_a = abs(ma) / pxs;
signum_a = sign(ma);

xlim = [-92, 92];
zlim = [-75, 105];
    
IMG_a = zeros((max(xlim)-min(xlim))/pxs,(max(zlim)-min(zlim))/pxs);
IMG_f = zeros((max(xlim)-min(xlim))/pxs,(max(zlim)-min(zlim))/pxs);

% get functional
for loop = 1:blowup_f
    X{loop} = xlim(1)+(loop-1)*pxs:blowup_f*pxs:xlim(2);
    Xi{loop} = (X{loop}-xlim(1))/pxs+1;
    IDX{loop} = 0:signum_f:(length(X{loop})-1)*signum_f;
end
for z = zlim(1):pxs:zlim(2)
    zi = (z-zlim(1))/pxs+1;
    for dx = 0:blowup_f-1
        mni0 = [xlim(1)+dx y z 1];
        p0 = mni0 * inv(mci.V{vol}.mat)';
        idx0 = index(p0,vol);
        try
            IMG_f(Xi{dx+1},zi) = mci.mXYZ{vol}(IDX{dx+1}+idx0);
        end
    end
end
% get anatomical
for loop = 1:blowup_a
    X{loop} = xlim(1)+(loop-1)*pxs:blowup_a*pxs:xlim(2);
    Xi{loop} = (X{loop}-xlim(1))/pxs+1;
    IDX{loop} = 0:signum_a:(length(X{loop})-1)*signum_a;
end
for z = zlim(1):pxs:zlim(2)
    zi = (z-zlim(1))/pxs+1;
    for dx = 0:blowup_a-1
        mni0 = [xlim(1)+dx y z 1];
        p0 = mni0 * inv(mci.V{3}.mat)';
        idx0 = index(p0,3);
        try
            IMG_a(Xi{dx+1},zi) = mci.XYZ{3}(IDX{dx+1}+idx0);
        end
    end
end
if blowup_a > 1
    IMG_a = conv_img(IMG_a);
end
IMG = scale_img(IMG_f,vol,IMG_a);


%=======================================================================
% subroutine get_sag(x,vol)
%
% see comment for function get_axi()
%=======================================================================

function IMG = get_sag(x,vol)

global mci

mf = mci.V{1}.mat(1,1);
ma = mci.V{3}.mat(1,1);

if mf == round(mf) & ma == round(ma)
    pxs = 1;
elseif mf*2 == round(mf*2) & ma*2 == round(ma*2)
    pxs = .5;
else
    error('Sorry, only traditional voxel sizes (multiples of .5mm) are supported.');
end

% blowup = destination matrix index increment per source index increment
blowup_f = abs(mf) / pxs;
blowup_a = abs(ma) / pxs;

dimx_f = mci.V{1}.dim(1);
dimx_a = mci.V{3}.dim(1);

ylim = [-125, 95];
zlim = [-75, 105];
    
IMG_a = zeros((max(ylim)-min(ylim))/pxs,(max(zlim)-min(zlim))/pxs);
IMG_f = zeros((max(ylim)-min(ylim))/pxs,(max(zlim)-min(zlim))/pxs);

% get functional
for loop = 1:blowup_f
    Y{loop} = ylim(1)+(loop-1)*pxs:blowup_f*pxs:ylim(2);
    Yi{loop} = (Y{loop}-ylim(1))/pxs+1;
    IDX{loop} = 0:dimx_f:(length(Y{loop})-1)*dimx_f;
end
for z = zlim(1):pxs:zlim(2)
    zi = (z-zlim(1))/pxs+1;
    for dy = 0:blowup_f-1
        mni0 = [x ylim(1)+dy z 1];
        p0 = mni0 * inv(mci.V{vol}.mat)';
        idx0 = index(p0,vol);
        try
            IMG_f(Yi{dy+1},zi) = mci.mXYZ{vol}(IDX{dy+1}+idx0);
        end
    end
end
% get anatomical
for loop = 1:blowup_a
    Y{loop} = ylim(1)+(loop-1)*pxs:blowup_a*pxs:ylim(2);
    Yi{loop} = (Y{loop}-ylim(1))/pxs+1;
    IDX{loop} = 0:dimx_a:(length(Y{loop})-1)*dimx_a;
end
for z = zlim(1):pxs:zlim(2)
    zi = (z-zlim(1))/pxs+1;
    for dy = 0:blowup_a-1
        mni0 = [x ylim(1)+dy z 1];
        p0 = mni0 * inv(mci.V{3}.mat)';
        idx0 = index(p0,3);
        try
            IMG_a(Yi{dy+1},zi) = mci.XYZ{3}(IDX{dy+1}+idx0);
        end
    end
end
if blowup_a > 1
    IMG_a = conv_img(IMG_a);
end
IMG = scale_img(IMG_f,vol,IMG_a);


%=======================================================================
% subroutine menu(wx,wy,varargin)
%=======================================================================

function m = menu(wx, varargin)
global mci

stri = [varargin{1}, '|'];
if wx < 150;
    wx = 150;
end
scs = get(0, 'ScreenSize');
mid = scs(3:4) / 2;
margin = 20;
dy = mci.layout.pby+10;
wy = length(find(stri=='|'))*mci.layout.lineskip + (length(varargin)-1)*dy + 3*margin;
mci.h.menu = figure('Position', [mid(1)-wx/2 mid(2)-wy/2 wx wy], 'MenuBar', 'none', 'Color', mci.col.bc, 'Resize', 'off');

m = 0;
y = 0;
for i=length(varargin):-1:2
    y = y + dy;
    uicontrol('Style', 'pushbutton', 'string', varargin{i}, 'Position', [margin y wx-2*margin mci.layout.pby], 'Callback', ['global mci; mci.menu=', num2str(i-1), '; close(mci.h.menu);'], 'BackgroundColor', mci.col.bc, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.button);
end

dy = mci.layout.lineskip;
y = wy-margin-dy;
while 1==1
    f = find(stri == '|');
    if isempty(f)
        break;
    end
    stri1 = stri(1:f(1)-1);
    stri = stri(f(1)+1:end);
    uicontrol('Style', 'text', 'string', stri1, 'Position', [margin y wx-2*margin mci.layout.pby], 'Callback', ['global mci; mci.menu=', num2str(i-1), '; close(mci.h.menu);'], 'BackgroundColor', mci.col.bc, 'FontUnits', 'pixels', 'FontSize', mci.FontSize.button);
    y = y - dy;
end

waitfor(mci.h.menu)
m = mci.menu;


%=======================================================================
% subroutine print_init()
%=======================================================================

function print_init()

set(gcf, 'PaperType', 'A3');
set(gcf, 'PaperOrientation', 'landscape');

set(gcf, 'Units', 'inches');
set(gcf, 'PaperUnits', 'inches');

PS = get(gcf, 'PaperSize');
P = get(gcf, 'Position');
P(1) = (PS(1)-P(3))/2;
P(2) = (PS(2)-P(4))/2;
set(gcf, 'PaperPosition', P);

set(gcf, 'Units', 'pixels');


%=======================================================================
% subroutine strtrim() reimplementation to be compatible with matlab < 7
%=======================================================================

function s = strtrim(s)

f = find(~isspace(s));
s = s(f);


%=======================================================================
% subroutine png() save image as png file
%=======================================================================

function png(A, fname)

global mci

s = size(A);

xmin = 128;
ymin = 128;
for zoom = 1:4
    x = s(2)*zoom;
    y = s(1)*zoom;
    if x >= xmin & y >= ymin
        break;
    end
end
fig = figure('Position', [100 100 x y], 'MenuBar', 'none');
set(fig, 'PaperUnit', 'inches');
set(fig, 'PaperPosition', [0 0 x/150 y/150]);
axes('Position', [0 0 1 1]);
imagesc(A, [0 2]);
axis off
colormap(mci.cm);
print(fig, '-dpng', fname);
close(fig);


%=======================================================================
% subroutine allowed()
%=======================================================================

function flag = allowed

global mci

flag = 1;
if ~isempty(mci.save.dname)
        menu(280,'Please close output directory first', 'OK');
        flag = 0;
end