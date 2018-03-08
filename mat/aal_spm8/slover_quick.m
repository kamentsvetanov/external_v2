function so = slover_quick(img, orientation, slices)
% Prints current SPM blobs on sagittal sections of a structural image
%
% FORMAT so = slover_quick(img, orientation, slices)
%
% INPUT
% img          - string containing full path to structural image
% orientation  - 'axial' 'sagittal' or 'coronal'
% slices       - vector of slice coordinates in MNI mm
%
% OUTPUT
% so           - slover object
%
% PW 24/05/2010
% Code cannibalized from Matthew Brett's slover

% Get new default object
so = slover;

if nargin < 1
    img = '';
end
if isempty(img)
    img = spm_select(1, 'image', 'Structural image');
end
if iscell(img)
    img = char(img);
end
if nargin < 2
    slices=[];
end

spm_input('!SetNextPos', 1); % Don't know what this does

so.cbar = [];
so.img.vol = spm_vol(img);
[mx mn] = slover('volmaxmin', so.img.vol);

% object properties for Structural
so.img.type = 'truecolour';
so.img.cmap = gray;
so.img.range = [mn mx];
so.img.prop = 1;
so = add_spm(so); % Add SPM blobs
so.transform = orientation;

% use SPM figure window
so.figure = spm_figure('GetWin', 'Graphics');

% slices for display
so = fill_defaults(so);
if isempty(slices)
    slices=so.slices;
    so.slices = spm_input('Slices to display (mm)', '+1', 'e', ...
        sprintf('%0.0f:%0.0f:%0.0f',...
        slices(1),...
        mean(diff(slices)),...
        slices(end))...
        );
else
    so.slices = slices;
end

% and do the display
so = paint(so);
