function RT_moco()
% Display and save motion information at real time. It also shows images and the
% progress of EPI/DTI while scanning, and allows to check motion information for
% previous series/patients.
%
% To make this work, you will need:
%  1. Set up shared folder at the computer running RT_moco. 
%     The folder default to ../incoming_DICOM, but better set to your own by 
%     setpref('dicm2nii_gui_para', 'incomingDcm', '/mypath/myIncomingDicom');
%     The result log will be saved into incoming_DICOM/RTMM_log/ folder.
%  2. Set up real time image transfer at Siemens console.

% 200207 xiangrui.li at gmail.com first working version inspired by FIRMM

% Create/re-use GUI and start timer
fh = findall(0, 'Type', 'figure', 'Tag', 'RT_moco');
if ~isempty(fh), figure(fh); return; end
res = get(0, 'ScreenSize');
fh = figure('mc'*[256 1]'); clf(fh);
set(fh, 'MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off', ... 
	'DockControls', 'off', 'CloseRequestFcn', @closeFig, 'Color', [1 1 1]*0.94, ...
    'Name', 'Real Time Image Monitor ', 'Tag', 'RT_moco', 'Visible', 'off', ...
    'UserData', struct('FD', {{}}, 'DV', {{}}, 'hdr', {{}}, 'resp', {{}}, 'GM', {{}}));
try fh.WindowState = 'maximized'; catch, fh.Position = [1 60 res(3) res(4)-80]; end
hs.fig = fh;
hs.rootDir = getpref('dicm2nii_gui_para', 'incomingDcm', '../incoming_DICOM/');
hs.backupDir = getpref('dicm2nii_gui_para', 'backupDir', '');
hs.logDir = [hs.rootDir 'RTMM_log/'];
if ~exist(hs.logDir, 'dir'), mkdir(hs.logDir); end % folder to save subj.mat

h = uimenu(fh, 'Label', '&Patient');
hs.menu(1) = uimenu(h, 'Label', 'Load Patient', 'Callback', @loadSubj);
hs.menu(2) = uimenu(h, 'Label', 'Redo Patient', 'Callback', @redoSubj);
hs.menu(3) = uimenu(h, 'Label', 'Close Patient', 'Callback', @closeSubj);

h = uimenu(fh, 'Label', '&Series');
uimenu(h, 'Label', 'View Selected Series in 3D', 'Callback', @view_3D);
uimenu(h, 'Label', 'Overlay Selected Series onto Anatomy', 'Callback', @overlay);
hs.derived = uimenu(h, 'Label', 'Skip DERIVED Series', 'Checked', 'on', ...
    'Callback', @toggleChecked, 'Separator', 'on');
hs.SBRef = uimenu(h, 'Label', 'Skip *_SBRef Series', 'Callback', @toggleChecked, 'Checked', 'on');

h = uimenu(fh, 'Label', '&View');
uimenu(h, 'Label', 'Reset Brightness', 'Callback', @setCLim);
uimenu(h, 'Label', 'Increase Brightness', 'Callback', @setCLim);
uimenu(h, 'Label', 'Decrease Brightness', 'Callback', @setCLim);
hDV = uimenu(h, 'Label', '&DVARS Threshold', 'Separator', 'on');
for i = [0.01 0.02 0.05 0.1 0.12 0.15 0.2 0.4]
    uimenu(hDV, 'Label', num2str(i), 'Callback', @DV_yLim);
end
uimenu(h, 'Label', 'Show FD plot', 'Callback', @toggleFD, 'Separator', 'on');
hFD = uimenu(h, 'Label', '&FD Axis Range');
for i = [0.18 0.3:0.3:1.5 2.4 3 6]
    uimenu(hFD, 'Label', num2str(i), 'Callback', @FD_range)
end

panel = @(pos)uipanel(fh, 'Position', pos, 'BorderType', 'none');
if res(3) < res(4) % Portrait
    pa1 = panel([0 0.62 1 0.38]); % img and label
    pa2 = panel([0 0 1 0.62]); % table and plot
    axPos = [0.05 0 0.65 1]; % img axis
    lbPos = [0.65 0 0.34 1]; % label axis
    subjPos = [1 0.95]; seriesPos = [1 0.1]; msPos = [1 0.7]; ha = 'right';
else
    pa1 = panel([0 0 0.38 1]);
    pa2 = panel([0.38 0 0.62 1]);
    axPos = [0.05 0.31 0.9 0.67];
    lbPos = [0.05 0.01 0.9 0.3]; 
    subjPos = [0 0.98]; seriesPos = [1 0.1]; msPos = [0 0.6]; ha = 'left';
end

dy = 0.12 * (0:3);
hs.ax = axes(pa2, 'Position', [0.07 0.5 0.86 0.38], ...
    'NextPlot', 'add', 'XLim', [0.5 300.5], 'UserData', dy, ...
    'TickDir', 'out', 'TickLength', 0.002*[1 1], 'ColorOrder', [0 0 1; 1 0 1]);
xlabel(hs.ax, 'Instance Number');
hs.slider = uicontrol(pa2, 'Units', 'normalized', 'Position', [0.05 0.96 0.9 0.03], ...
    'Style', 'slider', 'Value', 1, 'Min', 1, 'Max', 300, 'Callback', @sliderCB, ...
    'BackgroundColor', 0.5*[1 1 1], 'SliderStep', [1 1]./300);

yyaxis left; ylabel(hs.ax, 'DVARS');
set(hs.ax, 'YTick', dy, 'YLim', dy([1 4]));
c3 = [0 0.8 0;  0.8 0.8 0;  0.5 0 0];
for i = 3:-1:1
    rectangle(hs.ax, 'Position', [0.5 dy(i) 2000 dy(i+1)-dy(i)], ...
        'FaceColor', c3(i,:), 'EdgeColor', c3(i,:), 'LineWidth', 0.01);
end
hs.dv = plot(hs.ax, 0, '.:');

yyaxis right; ylabel(hs.ax, 'Framewise Displacement (mm)');
set(hs.ax, 'YTick', 0:0.4:1.2, 'YLim', [0 1.2]);

txt = @(a)text(hs.ax, 'Units', 'normalized', 'Position', a, 'FontSize', 12, ...
    'BackgroundColor', [1 1 1]*0.94, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
hs.pct(1) = txt([0.995 0.32]); hs.pct(2) = txt([0.995 0.65]);

hs.fd = plot(hs.ax, 0, '.:', 'Visible', 'off');
hs.ax.YAxis(2).Visible = 'off';

ax = axes(pa2, 'Position', [0.07 0.88 0.86 0.04], 'Color', fh.Color);
hs.resp = plot(ax, nan, ones(1,3), 'o', 'Color', 'none', 'MarkerSize', 8);
set(hs.resp(1), 'MarkerFaceColor', [0 0 0]);
set(hs.resp(2), 'MarkerFaceColor', [1 0 0]);
set(hs.resp(3), 'MarkerFaceColor', [0 0.8 0]);
title(ax, ' ', 'FontSize', 14, 'interpreter', 'tex');
set(ax, 'XLim', [0.5 300.5], 'YLim', [0.5 1.5], 'Visible', 'off');

vars = {'Description' 'Series' 'Instances' '<font color="#00cc00">Green</font>' ...
    '<font color="#cccc00">Yellow</font>' 'MeanFD'};
hs.table = uitable(pa2, 'Units', 'normalized', 'Position', [0.02 0.01 0.96 0.42], ...
    'FontSize', 14, 'RowName', [], 'CellSelectionCallback', @tableCB, ...
    'ColumnName', strcat('<html><h2>', vars, '</h2></html>'));
try hs.table.Multiselect = 'off'; end %#ok<*TRYNC> R2020a+

ax = axes(pa1, 'Position', axPos, 'YDir', 'reverse', 'Visible', 'off', 'CLim', [0 1]);
hs.img = image(ax, 'CData', ones(2)*0.94, 'CDataMapping', 'scaled');
axis equal; colormap(ax, 'gray');
hs.instnc = text(ax, 'Units', 'normalized', 'Position', [0.99 0.01], 'Color', 'y', ...
    'FontSize', 14, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');

ax = axes(pa1, 'Position', lbPos, 'Visible', 'off');
hs.subj = text(ax, 'Position', subjPos, 'FontSize', 24, 'FontWeight', 'bold', ...
    'HorizontalAlignment', ha, 'VerticalAlignment', 'top', 'Interpreter', 'none');
hs.series = text(ax, 'Position', seriesPos, 'FontSize', 18, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
    'BackgroundColor', fh.Color, 'Interpreter', 'none', 'UserData', [1 0]);
hs.MMSS = text(ax, 'Position', msPos, 'FontSize', 18, 'FontWeight', 'bold', ...
    'HorizontalAlignment', ha, 'VerticalAlignment', 'top', 'Interpreter', 'none', ...
    'BackgroundColor', fh.Color, 'String', {'' ''}, 'Color', 'b');

set(fh, 'HandleVisibility', 'callback', 'Visible', 'on'); % fh.Resize = 'off';
drawnow; wt = getpixelposition(hs.table);
w2 = [90 120 90 90 100]; hs.table.ColumnWidth = [wt(3)-sum(w2)-26 num2cell(w2)];

% set up serial port
delete(instrfind('Tag', 'RTMM'));
if ispc, port = 'COM1'; else, port = '/dev/ttyUSB0'; end % change this to yours
hs.serial = serial(port, 'BaudRate', 115200, 'Terminator', '', 'Tag', 'RTMM', ...
    'Timeout', 0.3, 'UserData', struct('fig', fh, 'send', false), ...
    'BytesAvailableFcnCount', 1, 'BytesAvailableFcnMode', 'byte', ...
    'BytesAvailableFcn', @serialRead); %#ok
try fopen(hs.serial); catch, end

hs.timer = timer('StartDelay', 5, 'ObjectVisibility', 'off', 'UserData', fh, ...
    'StopFcn', @saveResult, 'TimerFcn', @doSeries);

hs.countDown = timer('ExecutionMode', 'fixedRate', 'ObjectVisibility', 'off', ...
    'TimerFcn', {@countDown hs}, 'UserData', 0);

guidata(fh, hs);
start(hs.timer);

%% TimerFunc: do a series if avail, then call stopFunc to save result
function doSeries(obj, ~)
hs = guidata(obj.UserData);
hs.fig.Name(end) = 78 - hs.fig.Name(end); % dot/space switch: timer indicator
if hs.timer.StartDelay > 1, return; end % no new series
set(hs.menu, 'Enable', 'off'); set([hs.table hs.slider], 'Enable', 'inactive');

dict = dicm_dict('', {'Rows' 'Columns' 'BitsAllocated' 'InstanceNumber'});
bot = java.awt.Robot(); key = java.awt.event.KeyEvent.VK_SHIFT;
bot.keyPress(key); bot.keyRelease(key); % wake up screen

iRun = hs.series.UserData; % updated in new_series()
f = sprintf('%s/%03u_%06u_', hs.subj.UserData, iRun);
s = dicm_hdr_wait([f '000001.dcm']);
if isempty(s), return; end % non-image dicom, skip series
if all(iRun == 1) % first series: reset GUI
    closeSubj(hs.fig);
    hs.subj.String = regexprep(s.PatientName, '[_\s]', '');
    close(findall(0, 'Type', 'figure', 'Tag', 'nii_viewer')); % last subj if any
end

if hs.derived.Checked=="on" && contains(s.ImageType, 'DERIVED'), return; end
if hs.SBRef.Checked=="on" && endsWith(s.SeriesDescription, '_SBRef'), return; end

nTE = asc_header(s, 'lContrasts');
isMoCo = contains(s.ImageType, '\MOCO');
if ~isMoCo, hs.series.String = seriesInfo(s); end
try 
    nSL = s.CSAImageHeaderInfo.NumberOfImagesInMosaic; % EPI | DTI mosaic
catch % T1, T2, fieldmap etc: show info/img only
    nIN = asc_header(s, 'sSliceArray.lSize'); % 2D
    if nIN==1, nIN = asc_header(s, 'sKSpace.lImagesPerSlab'); end % 3D
    iSL = ceil(nIN/2); % try middle slice for better view
    nam = sprintf('%s%06u.dcm', f, iSL);
    if ~exist(nam, 'file'), pause(2); end % wait for dicom
    if ~exist(nam, 'file'), iSL = 1; nam = sprintf('%s%06u.dcm', f, iSL); end
    % fieldmap phase diff series: nTE=2, EchoNumber=2
    % if startsWith(s.SequenceName, '*fm2d') && contains(s.ImageType, '\P\')
    if isfield(s, 'EchoNumber') && s.EchoNumber>1, nTE = 1; end
    nIN = max(nIN*nTE, numel(dir([f '*.dcm']))); % just in case nTE unreliable
    init_series(hs, s, nIN);
    set_img(hs.img, dicm_img(nam));
    hs.slider.Value = iSL;
    hs.instnc.String = num2str(iSL);
    return;
end

isDTI = contains(s.ImageType, '\DIFFUSION');
if isDTI, nIN = asc_header(s, 'sDiffusion.lDiffDirections') + 1; % free-dir too
else, nIN = asc_header(s, 'lRepetitions') + 1;
end
if isempty(nIN) || endsWith(s.SeriesDescription, '_SBRef'), nIN = 1; end
if nIN>5 && hs.countDown.Running == "off" % work for mosaic without tricks
    dn = dir(s.Filename);
    hs.countDown.UserData = (nIN-1) * s.RepetitionTime/86400000 + dn.datenum;
    start(hs.countDown);
end
try stopAt = str2double(regexp(s.ImageComments, '(?<=stopAt:)\d*', 'match', 'once')); 
catch, stopAt = inf;
end
mos = dicm_img(s); s.PixelData = mos;
img = mos2vol(mos, nSL);
p = refVol(img, [s.PixelSpacing' s.SpacingBetweenSlices]);

ijk = round(p.R0 \ p.mm + 1); % informative voxels
ind = sub2ind(size(img), ijk(1,:), ijk(2,:), ijk(3,:));
img0 = double(mos);
mn = mean(img0(ind));
s.CLim = imgClim(img0);
set_img(hs.img, mos, s.CLim);
init_series(hs, s, nIN);
hs.img.UserData(1) = mean(img(:));
viewer = findall(0, 'Type', 'figure', 'Tag', 'nii_viewer');
if nIN<6 && isempty(viewer), overlay(hs.fig); end

R1 = inv(p.R0);
m6 = zeros(2,6);
hs.fd.YData(2:end) = nan; hs.dv.YData(2:end) = nan;

nextSeries = sprintf('%s/%03u_%06u_000001.dcm', hs.subj.UserData, iRun+[0 1]);
for i = 2:nIN
    nam = sprintf('%s%06u.dcm', f, (i-1)*nTE+1);
    tEnd = now + 1/1440; % 1 minute no mosaic coming, treat as stopped series
    while ~exist(nam, 'file')
        if ~isempty(dir(nextSeries)) || now>tEnd, return; end
        if hs.countDown.Running=="on", countDown(hs.countDown, 0, hs); end
        pause(0.2);
    end
    s = dicm_hdr_wait(nam, dict); iN = s.InstanceNumber;
    if nTE>1, iN = i; end % fake InstanceNumber for special case
    mos = dicm_img(s);
    img = mos2vol(mos, nSL);
    hs.img.CData = mos; hs.instnc.String = num2str(iN);
    hs.slider.Value = iN; % show progress
    if isDTI
        if i==2, hs.img.Parent.CLim(2) = imgClim(mos); end % 1st is B0
        hs.table.Data{1,3} = i; hs.dv.YData(iN) = 0;
        continue;
    end
    
    if isMoCo % FD from dicom hdr, DV uses MoCo img for now
        s1 = dicm_hdr(nam, dicm_dict('Siemens', 'CSAImageHeaderInfo'));
        m6(2,:) = [s1.CSAImageHeaderInfo.RBMoCoTrans; ...
                   s1.CSAImageHeaderInfo.RBMoCoRot];
    else
        p.F.Values = smooth_mc(img, p.sz);
        [m6(2,:), R1] = moco_estim(p, R1);
    end
    a = abs(m6(2,:) - m6(1,:)); m6(1,:) = m6(2,:);
    hs.fd.YData(iN) = sum([a(1:3) a(4:6)*50]); % 50mm: head radius
    
    img = double(mos);
    hs.img.UserData(iN) = mean(img(:)); 
    a = img(ind) - img0(ind); % use only edge voxles: faster & more sensitive
    hs.dv.YData(iN) = sqrt(a*a' / numel(a)) / mn;
    img0 = img;
    if hs.serial.UserData.send
        fwrite(hs.serial, uint8(hs.dv.YData(iN) / hs.ax.YAxis(1).Limits(2)*255));
    end
    
    a = hs.dv.YData(1:iN); a = a(~isnan(a));
    dy = hs.ax.UserData; fd = hs.fd.YData(1:iN);
    N = {numel(a) sum(a<dy(2)) sum(a<dy(3))};
    hs.table.Data(1,3:6) = [N mean(fd(~isnan(fd)))];
    for j = 1:2, hs.pct(j).String = sprintf('%.3g%%', N{j+1}/N{1}*100); end
    if N{2}>=stopAt, [~, ~] = system(['echo 1 > ' hs.rootDir 'StopScan']); end
    if iN>=nIN, return; end % ISSS alike
    % drawnow; % update instance for offline test
end

%% Reshape mosaic into volume, remove padded zeros
function vol = mos2vol(mos, nSL)
nMos = ceil(sqrt(nSL)); % nMos x nMos tiles for Siemens
[nr, nc] = size(mos); % number of row & col in mosaic
nr = nr / nMos; nc = nc / nMos; % number of row and col in slice
vol = zeros([nr nc nSL], class(mos));
for i = 1:nSL
    % r =    mod(i-1, nMos) * nr + (1:nr); % 2nd slice is tile(2,1)
    % c = floor((i-1)/nMos) * nc + (1:nc);
    r = floor((i-1)/nMos) * nr + (1:nr); % 2nd slice is tile(1,2)
    c =    mod(i-1, nMos) * nc + (1:nc);
    vol(:, :, i) = mos(r, c);
end

%% Initialize GUI for a new series
function init_series(hs, s, nIN)
tim = [s.AcquisitionDate(3:end) s.AcquisitionTime(1:6)];
fid = fopen([hs.rootDir 'currentSeries.txt'], 'w');
fprintf(fid, '%s_%s_%s', s.PatientName, asc_header(s, 'tProtocolName'), tim);
fclose(fid);

hs.dv.YData = zeros(nIN,1); hs.fd.YData = zeros(nIN,1); hs.img.UserData = nan(nIN,1);
set(hs.slider, 'Max', nIN, 'Value', 1, 'UserData', s.Filename(1:end-10));
if nIN==1, hs.slider.Visible = 'off';
else, set(hs.slider, 'SliderStep', [1 1]./(nIN-1)); hs.slider.Visible = 'on';
end
hs.ax.XLim(2) = nIN + 0.5;
hs.resp(1).Parent.XLim(2) = hs.ax.XLim(2);
set(hs.resp, 'XData', nan, 'YData', 1); update_resp(hs);
set([hs.instnc hs.pct], 'String', '');
figure(hs.fig); drawnow; % bring GUI front if needed
if contains(s.ImageType, '\MOCO'), return; end
hs.table.Data = [{s.SeriesDescription s.SeriesNumber nIN 0 0 0}; hs.table.Data];
try hs.table.Selection = [1 1]; catch, end % R2020a+
hs.fig.UserData.hdr{end+1} = s; % 1st instance with CLim and maybe image

pat = asc_header(s,'sPat.lAccelFactPE');
if pat==1, thr = 0.12; else, thr = 0.15; end % arbitrary
h = findobj(hs.fig, 'Type', 'uimenu', 'Label', '&DVARS Threshold');
thrs = str2double(get(h.Children, 'Label'));
[~, i] = min(abs(thrs-thr));
DV_yLim(h.Children(i));

%% Set img and img axis
function set_img(hImg, img, CLim)
if nargin<3 || isempty(CLim) || isnan(CLim), CLim = imgClim(img); end
d = size(img) + 0.5;
set(hImg.Parent, 'CLim', [0 CLim], 'XLim', [0.5 d(2)], 'YLim', [0.5 d(1)]);
hImg.CData = img;

%% get some series information
function c = seriesInfo(s)
c{1} = s.SeriesDescription;
if numel(c{1})>24, c{1} = [c{1}(1:16) '...' c{1}(end-3:end)]; end
c{2} = sprintf('Series %g', s.SeriesNumber);
if s.StudyID~="1", c{2} = ['Study ' s.StudyID ', ' c{2}]; end
c{3} = datestr(datenum(s.AcquisitionTime, 'HHMMSS.fff'), 'HH:MM:SS AM');
c{4} = datestr(datenum(s.AcquisitionDate, 'yyyymmdd'), 'ddd, mmm dd, yyyy');
try c{5} = sprintf('TR = %g', s.RepetitionTime); catch, end

%% toggle FD display on/off
function toggleFD(h, ~)
hs = guidata(h);
if hs.fd.Visible == "on"
    set([hs.fd hs.ax.YAxis(2)], 'Visible', 'off');
    h.Label = 'Show FD plot';
else
    set([hs.fd hs.ax.YAxis(2)], 'Visible', 'on');
    h.Label = 'Hide FD plot';
end

%% Set FD plot y-axis limit
function FD_range(h, ~)
hs = guidata(h);
dy = str2double(h.Label) * (0:3) / 3;
yyaxis(hs.ax, 'right'); set(hs.ax, 'YTick', dy, 'YLim', dy([1 4]));

%% Set DVARS plot y-axis limit, and update table
function DV_yLim(h, ~)
hs = guidata(h);
dy = str2double(h.Label) * (0:3);
hs.ax.UserData = dy;
for i = 1:numel(hs.fig.UserData.DV)
    a = hs.fig.UserData.DV{i}; a = a(~isnan(a));
    hs.table.Data(end-i+1, 4:5) = {sum(a<dy(2)) sum(a<dy(3))};
end
yyaxis(hs.ax, 'left'); set(hs.ax, 'YTick', dy, 'YLim', dy([1 4]));
rect = findobj(hs.ax, 'type', 'Rectangle');
for i = 1:3, rect(i).Position([2 4]) = dy([i 2]); end
DV = hs.dv.YData; a = DV(~isnan(DV));
for i = 1:2, hs.pct(i).String = sprintf('%.3g%%', sum(a<dy(i+1))/numel(a)*100); end

%% Table-click callback: show moco/series info and image if avail
function tableCB(h, evt)
if isempty(evt.Indices) || evt.Indices(1,2)>2, return; end
hs = guidata(h);
C = h.Data;
i = evt.Indices(1,1);
iR = size(C,1) - i + 1;
hs.fd.YData = hs.fig.UserData.FD{iR};
hs.dv.YData = hs.fig.UserData.DV{iR};
for j = 1:2, hs.pct(j).String = sprintf('%.3g%%', C{i,j+3}/C{i,3}*100); end

hs.instnc.String = '';
hs.series.String = C{i,1}; % in case hdr not saved
try s = hs.fig.UserData.hdr{iR}; catch, set_img(hs.img, inf(2), 1); return; end

nIN = sum(~isnan(hs.dv.YData));
iIN = ceil(nIN/2); % start with middle Instance if avail
nam = sprintf('%s%06g.dcm', s.Filename(1:end-10), iIN);
if ~exist(nam, 'file'), iIN = 1; nam = s; end
hs.instnc.String = num2str(iIN);
set(hs.slider, 'Max', nIN, 'Value', iIN, 'UserData', s.Filename(1:end-10));
if nIN == 1, hs.slider.Visible = 'off';
else, set(hs.slider, 'SliderStep', [1 1]./(nIN-1)); hs.slider.Visible = 'on';
end
hs.ax.XLim(2) = numel(hs.dv.YData) + 0.5;
hs.resp(1).Parent.XLim(2) = hs.ax.XLim(2);
try 
    for i = 1:3
        a = hs.fig.UserData.resp{iR}{i};
        set(hs.resp(i), 'XData', a, 'YData', ones(size(a)));
    end
catch, set(hs.resp, 'XData', nan, 'YData', 1);
end
update_resp(hs);
hs.series.String = seriesInfo(s);
try CLim = s.CLim; catch, CLim = []; end
try img = dicm_img(nam); catch, img = ones(2)*0.94; end
set_img(hs.img, img, CLim);

%% Load subj data to review
function loadSubj(h, ~)
hs = guidata(h);
[fname, pName] = uigetfile([hs.logDir '*.mat'], 'Select MAT file for a Patient');
if isnumeric(fname), return; end
load([pName '/' fname], 'T3');
hs.fig.UserData = T3.Properties.UserData; 
DV = hs.fig.UserData.DV;
N = size(T3, 1);
C = flip(table2cell(T3), 1); C(:,6) = C(:,3);
dy = hs.ax.UserData;
for i = 1:N
    a = DV{N-i+1}; a = a(~isnan(a));
    C(i,3:5) = {numel(a) sum(a<dy(2)) sum(a<dy(3))};
end 
hs.table.Data = C;
s = hs.fig.UserData.hdr{end};
hs.subj.String = regexprep(s.PatientName, '[_\s]', '');
[hs.subj.UserData, nam] = fileparts(s.Filename);
hs.series.UserData = sscanf(nam, '%u_%u', 1:2);
tableCB(hs.table, struct('Indices', [1 1])); % show top series

%% close subj
function closeSubj(h, ~)
hs = guidata(h);
hs.table.Data = {};
hs.img.CData = ones(2)*0.94;
hs.fd.YData = 0; hs.dv.YData = 0;
hs.fig.UserData = struct('FD', {{}}, 'DV', {{}}, 'hdr', {{}}, 'resp', {{}}, 'GM', {{}});
set([hs.subj hs.series hs.instnc hs.pct], 'String', '');

%% Re-do current subj: useful in case of error during a session
function redoSubj(h, ~)
hs = guidata(h);
subj = hs.subj.String;
if isempty(subj), return; end
if ~exist(hs.subj.UserData, 'dir')
    fprintf(2, 'Image for %s deleted?\n', subj);
    return;
end
try delete([hs.logDir subj '*.mat']); catch, end
hs.table.Data = {}; % quick visual sign

%% Get reference vol info. Adapted from nii_moco.m
function p = refVol(img, pixdim)
d = size(img);
p.R0 = diag([pixdim 1]); % no need for real xform_mat here
p.R0(1:3, 4) = -pixdim .* (d/2); % make center voxel [0 0 0]

sz = pixdim;
if all(abs(diff(sz)/sz(1))<0.05) && sz(1)>2 && sz(1)<4 % 6~12mm
    sz = 3; % iso-voxel, 2~4mm res, simple fast smooth
else
    sz = 9 ./ sz'; % 9 mm seems good
end

% resample ref vol to isovoxel (often lower-res)
d0 = d-1;
dd = 4 ./ pixdim; % use 4 mm grid for alignmen
[i, j, k] = ndgrid(0:dd(1):d0(1)-0.5, 0:dd(2):d0(2)-0.5, 0:dd(3):d0(3)-0.5);
I = [i(:) j(:) k(:)]';
a = rng('default'); I = I + rand(size(I))*0.5; rng(a); % used by spm
V = smooth_mc(img, sz);
F = griddedInterpolant({0:d0(1), 0:d0(2), 0:d0(3)}, V, 'linear', 'none');
V0 = F(I(1,:), I(2,:), I(3,:)); % ref: 1 by nVox
I(4,:) = 1; % 0-based ijk: 4 by nVox
I = p.R0 * I; % xyz of ref voxels

% compute derivative to each motion parameter in ref vol
dG = zeros(6, numel(V0));
dd = 1e-6; % delta of motion parameter, value won't affect dG much
R0i = inv(p.R0); % speed up a little
for i = 1:6
    p6 = zeros(6,1); p6(i) = dd; % change only 1 of 6
    J = R0i * rigid_mat(p6) * I; %#ok<*MINV>
    dG(i,:) = F(J(1,:), J(2,:), J(3,:)) - V0; % diff now
end
dG = dG / dd; % derivative

% choose voxels with larger derivative for alignment: much faster
a = sum(dG.^2); % 6 derivatives has similar range
ind = a > std(a(~isnan(a)))/10; % arbituray threshold. Also exclude NaN
p.dG = dG(:, ind);
p.V0 = V0(ind);
p.mm = I(:, ind);
F.GridVectors = {0:d(1)-1, 0:d(2)-1, 0:d(3)-1};
p.F = F;
p.sz = sz;

%% motion correction to ref-vol. From nii_moco.m
function [m6, rst] = moco_estim(p, R)
mss0 = inf;
rst = R;
for iter = 1:64
    J = R * p.mm; % R_rst*J -> R0*ijk
    V = p.F(J(1,:), J(2,:), J(3,:));
    ind = ~isnan(V); % NaN means out of range
    dV = p.V0(ind) - V(ind);
    mss = dV*dV' / numel(dV); % mean(dV.^2)
    if mss > mss0, break; end % give up and use previous R
    rst = R; % accecpt only if improving
    if 1-mss/mss0 < 1e-6, break; end % little effect, stop
    
    a = p.dG(:, ind);
    p6 = (a * a') \ (a * dV'); % dG(:,ind)'\dV' estimate p6 from current R
    R = R * rigid_mat(p6); % inv(inv(rigid_mat(p6)) * inv(R_rst))
    mss0 = mss;
end

R = p.R0 * rst; % inv(R_rst / Rref)
m6 = -[R(1:3, 4)' atan2(R(2,3), R(3,3)) asin(R(1,3)) atan2(R(1,2), R(1,1))];

%% Translation (mm) and rotation (deg) to 4x4 R. Order: ZYXT
function R = rigid_mat(p6)
ca = cosd(p6(4:6)); sa = sind(p6(4:6));
rx = [1 0 0; 0 ca(1) -sa(1); 0 sa(1) ca(1)]; % 3D rotation
ry = [ca(2) 0 sa(2); 0 1 0; -sa(2) 0 ca(2)];
rz = [ca(3) -sa(3) 0; sa(3) ca(3) 0; 0 0 1];
R = rx * ry * rz;
R = [R p6(1:3); 0 0 0 1];

%% Simple gaussian smooth for motion correction, sz in unit of voxels
function out = smooth_mc(in, sz)
out = double(in);
if all(abs(diff(sz)/sz(1))<0.05) && abs(sz(1)-round(sz(1)))<0.05 ...
        && mod(round(sz(1)),2)==1
    out = smooth3(out, 'gaussian', round(sz)); % sz odd integer
    return; % save time for special case
end

d = size(in);
I = {1:d(1) 1:d(2) 1:d(3)};
n = sz/3;
if numel(n)==1, n = n*[1 1 1]; end
J = {1:n(1):d(1) 1:n(2):d(2) 1:n(3):d(3)};
intp = 'linear';
F = griddedInterpolant(I, out, intp);
out = smooth3(F(J), 'gaussian'); % sz=3
F = griddedInterpolant(J, out, intp);
out = F(I);

%% new series or new subj: result saved as incoming_DCM/RTMM_log/subj.mat
% The subj folders (yyyymmdd.PatientName.PatientID) default to ../incoming_DICOM/
% The dcm file names from Siemens push are always in format of
% 001_000001_000001.dcm. All three numbers always start at 1, and are continuous.
% First is study, second is series and third is instance.
function new = new_series(hs)
try setCountDown(hs); catch, end
try QC_report(hs.rootDir); catch me, assignin('base', 'me', me); end
f = hs.subj.UserData;
if ~isempty(f) % check new run for current subj
    iR = hs.series.UserData;
    if exist(sprintf('%s/%03u_%06u_000001.dcm', f, iR+[0 1]), 'file')
        hs.series.UserData(2) = iR(2) + 1; new = true; return;
    elseif exist(sprintf('%s/%03u_000001_000001.dcm', f, iR(1)+1), 'file')
        hs.series.UserData = [iR(1)+1 1];  new = true; return;
    end
end
dirs = dir([hs.rootDir '20*']); % check new subj
dirs(~[dirs.isdir]) = [];
v = arrayfun(@(a)exist([hs.rootDir '/' a.name '/001_000001_000001.dcm'], 'file'), dirs);
dirs(~v) = [];
new = false;
for i = numel(dirs):-1:1
    subj = regexp(dirs(i).name, '(?<=\d{8}\.).*?(?=\.)', 'match', 'once');
    subj = regexprep(subj, '[_\s]', '');
    if exist([hs.logDir subj '.mat'], 'file'), continue; end
    hs.subj.UserData = [hs.rootDir dirs(i).name]; 
    hs.series.UserData = [1 1];
    new = true; return;
end

% Move/Delete old subj folder right after mid-night
if ~exist([hs.rootDir 'host.txt'], 'file') || mod(now,1) > 10/86400; return; end
dirs(now-[dirs.datenum]<2) = []; % keep for 2 days
for i = 1:numel(dirs)
    try 
        if isempty(hs.backupDir), rmdir([hs.rootDir dirs(i).name], 's');
        else, movefile([hs.rootDir dirs(i).name], [hs.backupDir dirs(i).name]);
        end
    catch me
        disp(me.message); assignin('base', 'me', me);
    end
end

%% Subfunction: get a parameter in CSA series ASC header: MrPhoenixProtocol
function val = asc_header(s, key)
val = []; 
csa = 'CSASeriesHeaderInfo';
if ~isfield(s, csa) % in case of multiframe
    try s.(csa) = s.SharedFunctionalGroupsSequence.Item_1.(csa).Item_1; catch,end
end
if ~isfield(s, csa), return; end
if isfield(s.(csa), 'MrPhoenixProtocol')
    str = s.(csa).MrPhoenixProtocol;
elseif isfield(s.(csa), 'MrProtocol') % older version dicom
    str = s.(csa).MrProtocol;
else % in case of failure to decode CSA header
    str = char(s.(csa)(:)');
    str = regexp(str, 'ASCCONV BEGIN(.*)ASCCONV END', 'tokens', 'once');
    if isempty(str), return; end
    str = str{1};
end

expr = ['\n' regexptranslate('escape', key) '.*?=\s*(.*?)\n'];
str = regexp(str, expr, 'tokens', 'once');
if isempty(str), return; end
str = strtrim(str{1});

if strncmp(str, '""', 2) % str parameter
    val = str(3:end-2);
elseif strncmp(str, '"', 1) % str parameter for version like 2004A
    val = str(2:end-1);
elseif strncmp(str, '0x', 2) % hex parameter, convert to decimal
    val = sscanf(str(3:end), '%x', 1);
else % decimal
    val = sscanf(str, '%g', 1);
end

%% Wait till a file copy is complete
function s = dicm_hdr_wait(varargin)
tEnd = now + 1/86400; % wait up to 1 second
while 1
    s = dicm_hdr(varargin{:});
    try % maybe too strict to be equal? Test indicates always equal 
        if s.PixelData.Start+s.PixelData.Bytes == s.FileSize, return; end
    end
    if now>tEnd, s = []; return; end % give up
    pause(0.1);
end

%% User closing GUI: stop and delete timer
function closeFig(fh, ~)
hs = guidata(fh);
try delete(hs.serial); catch, end
try hs.timer.StopFcn = ''; catch, end
try tObj = timerfindall; stop(tObj); delete(tObj); catch, end
delete(fh);

%% menu callback for both DERIVED and _SBRef
function toggleChecked(h, ~)
if h.Checked == "on", h.Checked = 'off'; else, h.Checked = 'on'; end

%% Increase/Decrease image CLim
function setCLim(h, ~)
hs = guidata(h);
ax = hs.img.Parent;
if startsWith(h.Label, 'Increase'), ax.CLim(2) = ax.CLim(2)*0.8;
elseif startsWith(h.Label, 'Decrease'), ax.CLim(2) = ax.CLim(2)*1.2;
else, ax.CLim(2) = imgClim(hs.img.CData);
end

%% show series in nii_viewer
function view_3D(h, ~)
hs = guidata(h);
nams = dir([hs.slider.UserData '*.dcm']);
if isempty(nams), return; end
nams = strcat(nams(1).folder, '/', {nams.name});
nii = dicm2nii(nams, ' ', 'no_save');
nii_viewer(nii);

%% overlay series onto T1w or Scout if avail
function overlay(h, ~)
hs = guidata(h);
hdrs = hs.fig.UserData.hdr;
if isempty(hdrs), return; end
is3D = @(c)c.MRAcquisitionType=="3D" && ~contains(c.ImageType, 'DERIVED');
is3D = cellfun(is3D, hdrs);
if ~any(is3D), is3D = cellfun(@(c)c.MRAcquisitionType=="3D", hdrs); end
if sum(is3D)>1
    isT1 = cellfun(@(c)contains(c.SequenceName, 'fl3d1'), hdrs);
    isT1 = isT1 & is3D;
    if any(isT1), is3D = isT1; end
end
if ~any(is3D), view_3D(h); return; end % no T1, just show in nii_viewer
is3D = find(is3D, 1, 'last');
nams = dir([hdrs{is3D}.Filename(1:end-10) '*.dcm']);
nams = strcat(nams(1).folder, '/', {nams.name});
T1w = dicm2nii(nams, ' ', 'no_save');
nams = dir([hs.slider.UserData '*.dcm']);
nams = strcat(nams(1).folder, '/', {nams.name});
epi = dicm2nii(nams, ' ', 'no_save');
fh = nii_viewer(T1w, epi);
nii_viewer('LocalFunc', 'nii_viewer_cb', [], [], 'center', fh);

%% slider callback: show img if avail
function sliderCB(h, ~)
hs = guidata(h);
if isempty(h.UserData), return; end
dict = dicm_dict('', {'SamplesPerPixel' 'Rows' 'Columns' 'BitsAllocated' 'InstanceNumber'});
h.Value = round(h.Value);
s = dicm_hdr(sprintf('%s%06u.dcm', h.UserData, h.Value), dict);
if isempty(s), return; end
hs.img.CData = dicm_img(s);
hs.instnc.String = num2str(s.InstanceNumber);

%% Timer StopFunc: Save result, start timer with delay, even after error
function saveResult(obj, ~)
hs = guidata(obj.UserData);
set([hs.menu hs.table hs.slider], 'Enable', 'on');
if size(hs.table.Data,1) > numel(hs.fig.UserData.FD) % new series to save?
    hs.fig.UserData.FD{end+1} = hs.fd.YData;
    hs.fig.UserData.DV{end+1} = hs.dv.YData;
    hs.fig.UserData.GM{end+1} = hs.img.UserData;
    hs.fig.UserData.resp{end+1} = {hs.resp.XData};
    T3 = cell2table(flip(hs.table.Data(:,[1 2 6]), 1), ...
        'VariableNames', {'Description' 'SeriesNumber' 'MeanFD'});
    T3.Properties.UserData = hs.fig.UserData;
    save([hs.logDir hs.subj.String], 'T3');
    hs.serial.UserData.send = false; % stop until asked again
end
if new_series(hs), obj.StartDelay = 0.1; else, obj.StartDelay = 5; end
start(obj);

%% Serial BytesAvail callback: update response: 1=missed, 2=incorrect, 3=correct 
function serialRead(s, ~)
b = fread(s, 1);
hs = guidata(s.UserData.fig);
if     b == '?', fwrite(s, uint8('RTMM')); return; % identity
elseif b == 'P', fwrite(s, uint8(hs.subj.String)); return; % PatientName
elseif b == 'T', fwrite(s, uint8(strjoin(hs.MMSS.String))); return; % count down
elseif b == 'M', s.UserData.send = true; return; % start to send motion info
elseif b == 'Q' % stim computer asks to stop scan
    [~, ~] = system(['echo 1 > ' hs.rootDir 'StopScan']); return;
elseif b<1 || b>3, return; % ignore for now
end
if hs.timer.StartDelay>1, return; end % not during a series
x = find(~isnan(hs.dv.YData), 1, 'last');
if isempty(x), x = 0; end
hs.resp(b).XData(end+1) = x + 1; hs.resp(b).YData(end+1) = 1;
update_resp(hs);

%% update response text
function update_resp(hs)
n = cellfun(@numel, {hs.resp.XData}) - 1;
h = hs.resp(1).Parent.Title;
if ~any(n>0), h.Visible = 'off'; return; end
h.Visible = 'on';
h.String = "Missed " + n(1) + ", \color{red}Incorrect " + n(2) + ...
    ", \color[rgb]{0 0.8 0}Correct " + n(3) + ", \color{blue}Total " + sum(n);

%% start countdown
function setCountDown(hs)
nam = [hs.rootDir 'ScanSec'];
if ~exist(nam, 'file'), return; end
c0 = fileread(nam); pause(0.2); c = fileread(nam);
if ~isequal(c0, c), pause(1); c = fileread(nam); end
tMod = dir(nam); delete(nam);
% From scanner: "RunStartTime" "ProtocolName" TotalScanTimeSec "CurrentTime"
c = regexp(c, '"(.*?)" "(.*?)" (\d+) "(.*?)"', 'tokens', 'once');
tStrt = datenum(c{1}, 'yyyy-mm-dd HH:MM:SS,fff');
tSyng = datenum(c{4}, 'ddd mm/dd/yyyy HH:MM:SS.fff');
tFnsh = tStrt + str2double(c{3})/86400 + tMod.datenum - tSyng;
if tFnsh-now < 2/86400, return; end
hs.countDown.UserData = tFnsh;
if numel(c{2})>24, c{2} = [c{2}(1:16) '...' c{2}(end-3:end)]; end
hs.MMSS.String = {c{2} ''};
if hs.countDown.Running=="off", start(hs.countDown); end

%% timer func to show scanning time
function countDown(tObj, ~, hs)
nam = dir([hs.rootDir 'StoppedByUser']);
if ~isempty(nam)
    delete([hs.rootDir nam.name]);
    if now-nam.datenum < 9/86400 % file was within 9 seconds
        stop(tObj);
        hs.MMSS.String{2} = 'Stopped by Console';
        error('StoppedByConsole');
    end
end
t = tObj.UserData - now;
if t<0, stop(tObj); hs.MMSS.String = {'' ''};
else, hs.MMSS.String{2} = ['Scanning ' datestr(t, 'MM:SS')];
end

%% get CLim for dicom img
function mx = imgClim(img)
im = double(img(:));
im = im(im>max(im)/10);
mx = mean(im) + 2*std(im);

%% Create QC report
function QC_report(rootDir)
nam = dir([rootDir 'closed_*']);
if isempty(nam), return; end
nam = [rootDir nam(1).name];
done = onCleanup(@()movefile(nam, strrep(nam, 'closed_', 'done_'))); 
rmQC = onCleanup(@()delete('./tmp_QC_*.pdf'));
subj = regexp(nam, '(?<=closed_)\d{4}\w{2}$', 'match', 'once');
if isempty(subj), return; end
load([rootDir 'RTMM_log/' subj '.mat'], 'T3');
s = T3.Properties.UserData.hdr{1};
if contains(s.ImageComments, 'NoPDF'), return; end

close all; delete('./tmp_QC_*.pdf');
fig = figure('Position', [10 30 [8.5 11]*96], 'Units', 'normalized');
set(fig, 'Color', 'w', 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1]);
ax = axes(fig, 'Position', [0.01 0.955 0.98 0.045], 'Visible', 'off');
try imshow('./logo.png', 'Parent', ax); ax.HandleVisibility = 'off'; end

layout = getpref('nii_viewer_para', 'layout');
if layout ~= 1
    setpref('nii_viewer_para', 'layout', 1);
    cln = onCleanup(@()setpref('nii_viewer_para', 'layout', layout));
end

ax = axes(fig, 'Position', [0.1 0.92 0.8 0.03], 'Visible', 'off');
text(ax, 0.5, 1, subj, 'FontSize', 18, 'HorizontalAlignment', 'center');
dat = datestr(datenum(s.AcquisitionDate, 'yyyymmdd'), 'dddd mmm dd, yyyy');
text(ax, 0.5, 0, dat, 'FontSize', 12, 'HorizontalAlignment', 'center');
tbl = cell(1, 5);
dict = dicm_dict('', {'AcquisitionTime' 'SeriesNumber' 'SeriesDescription'});
for i = 1:99
    nams = dir([s.Filename(1:end-17) sprintf('%06i',i) '*.dcm']);
    if isempty(nams), break; end
    s = dicm_hdr([nams(1).folder '/' nams(1).name], dict);
    d = s.AcquisitionTime; d = [d(1:2) ':' d(3:4) ':' d(5:6)];
    tbl(i,:) = {s.SeriesNumber d numel(nams) s.SeriesDescription 0};
    a = T3.MeanFD(T3.SeriesNumber == s.SeriesNumber);
    if ~isempty(a), tbl{i,5} = a; end
end
tbl = cellfun(@num2str, tbl, 'UniformOutput', false); % for left-align
vName = {'SeriesNumber' 'Time' 'TotalInstances' 'Description' 'meanFD'};
uitable(fig, 'Units', 'normalized', 'Position', [0.04 0.1 0.9 0.8], ...
    'FontSize', 12, 'RowName', [], 'ColumnName', vName, 'Data', tbl, ...
    'ColumnWidth', {96 96 108 342 82});
newPage(fig); y = 0.95;

for i = 1:numel(T3.Properties.UserData.hdr)
    s = T3.Properties.UserData.hdr{i};
    series = sprintf('%s (Series %g)', s.ProtocolName, s.SeriesNumber);
    if contains(s.SequenceName, {'epfid2d' 'mbPCASL'}) % EPI/ASL
        fd = T3.Properties.UserData.FD{i};
        if numel(fd)<6, continue; end % skip slice check etc
        if y<0.95, newPage(fig); y = 0.95; end
        y = y - 0.3;
        ax = axes(fig, 'Position', [0.1 y+0.19 0.8 0.08]);
        gm = T3.Properties.UserData.GM{i};
        gm = (gm/mean(gm) - 1)*100; % global mean
        % gm = [0; diff(gm)]/mean(gm) * 100; % delta GM
        plot(ax, gm, '.-m');
        set(ax, 'YTick', 0:1, 'YLim', [-1 1], 'XLim', [0 numel(fd)+1], 'XTick', []);
        ylabel(ax, 'GM (%)', 'Color', 'm');
        % ylabel(ax, [char(916) 'GM (%)']);
        title(ax, series, 'Interpreter', 'none', 'FontSize', 12);
        ax = axes(fig, 'Position', [0.1 y+0.03 0.8 0.16]);
        yyaxis right; plot(ax, fd, '.-');
        ylabel(ax, 'FD (mm)'); xlabel(ax, 'Volume Number');
        set(ax, 'YTick', 0:0.6:1.8, 'YLim', [0 1.8], 'XLim', [0 numel(fd)+1]);
        str = sprintf('meanFD=%.2g', nanmean(fd));
        text(ax, 0.8, 0.9, str, 'Units', 'normalized', 'Color', [0.85 0.32 0.1]);
        
        yyaxis left; plot(ax, T3.Properties.UserData.DV{i}, '.-');
        ylabel(ax, 'DVARS'); set(ax, 'YTick', 0:0.12:0.36, 'YLim', [0 0.36]);
        
        img = uint8(double(dicm_img(s)) / s.CLim * 256);
    elseif contains(s.SequenceName, {'tfl3d' 'spc' 'tse2d' 'fm2d'}) % T1/T2/fmap
        nams = dir([s.Filename(1:end-10) '*.dcm']);
        nams = strcat(nams(1).folder, '/', {nams.name});
        fh = nii_viewer( dicm2nii(nams, ' ', 'no_save'));
        nii_viewer('LocalFunc', 'nii_viewer_cb', [], [], 'center', fh);
        hs = guidata(fh);
        drawnow; F = getframe(fh, hs.frame.Position); close(fh); img = F.cdata;
    elseif contains(s.SequenceName, 'ep_b0') % Diff
        if asc_header(s, 'sDiffusion.lDiffDirections')<7, continue; end
        img = uint8(double(dicm_img(s)) / s.CLim * 256);
    else, continue;
    end
    sz = size(img); sz = sz([2 1]) ./ [8.5 11]/96;
    if sz(1)>0.94, sz = sz / sz(1) * 0.94; end
    y = y - sz(2) - 0.08;
    if y<0.02 && y+sz(2)*0.2>0.02, sz = sz * 0.8; y = y + 0.2*sz(2); end
    if y<0.02, newPage(fig); y = 0.92-sz(2); end
    ax = axes(fig, 'Position', [(1-sz(1))/2 y+0.02 sz], 'Visible', 'off');
    imshow(img, 'Parent', ax);
    title(ax, series, 'Interpreter', 'none', 'FontSize', 12);
end
newPage(fig); close(fig);

pdfNam = rootDir+"RTMM_log/"+subj+"_"+s.AcquisitionDate(3:8)+"_QC.pdf";
setenv('LD_LIBRARY_PATH', getenv('PATH'));
[~, ~] = system("pdfunite ./tmp_QC_*.pdf "+pdfNam); % for Linux 

%% print fig to a new PDF, called by QC_report()
function newPage(fig)
nam = dir('./tmp_QC_*.pdf');
if isempty(nam), i = 1; else, i = str2double(nam(end).name(8:10)) + 1; end
print(fig, sprintf('./tmp_QC_%03i.pdf', i), '-dpdf');
clf(fig);
%%
