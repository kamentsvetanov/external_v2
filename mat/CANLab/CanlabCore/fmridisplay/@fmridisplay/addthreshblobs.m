function obj = addthreshblobs(obj, statimg, varargin)
% obj = addthreshblobs(obj, statimg, varargin)
%
% Add blobs from a statistical image object at multiple thresholds to
% montage and other surface plots. 
%
% It passes options specified in varargin onto addblobs, see help addblobs
% for options. In addition it has the parameters 'thresh' and
% 'pruneclusters' are used and have default values.
%
% obj       = fmridisplay object, e.g. from a montage
% statimg   = statistics_image object
% 'thresh',{'fdr',0.01}     = cell array of p-value thresholds in ascending order. 
%                             can be 'fdr', or uncorrecetd p-value. defaults to:
%                             thresh = {'fdr','0.001','0.01'}
% 'pruneclusters', [0 or 1] = Prune clusters that do not have at least one voxel
%                             surving at the most stringent threshold. Defaults to 1.
%
%
%
% Examples:
% obj = addthreshblobs(obj, statimg); 
% Add blobs from statimg at 3 significance levels [FDR, 0.001 unc., 0.01 unc.].
% Prune clusters.
%
% obj = addthreshblobs(obj, statimg, 'thresh', {'fdr', 0.001, 0.01}); 
% Add blobs from statimg at 3 significance levels [FDR, 0.001 unc., 0.01 unc.]. 
% Prune clusters.
%
% obj = addthreshblobs(obj, statimg, 'thresh', {'fdr', 0.001},'pruneclusters',0);
% Add blobs from statimg at 2 significance levels [FDR, 0.001 unc.]. 
% Do not prune clusters
%

%
% 24-Feb-2015 14:17:20 
% stephan geuter



% set defaults for thresholds and cluster pruning
cl_prune       = 1;
thresh         = {'fdr',0.001,0.01};

% parse varargin
cmapset        = 0;
splitcolset    = 0;
rmIdx          = [];

for i = 1:length(varargin)
    
    if ischar(varargin{i})
        switch lower(varargin{i})
            % check for defaults
            case 'cmaprange', cmapset = 1;
            case 'splitcolor', splitcolset = 1;
            case 'pruneclusters', cl_prune = varargin{i+1}; rmIdx = [rmIdx i i+1]; 
            case 'thresh', thresh = varargin{i+1}; rmIdx = [rmIdx i i+1];
        end
    end
end

opts = varargin;
opts(rmIdx) = [];

if cmapset == 0
     % map threshold levels to colors
    vrange        = -numel(thresh):numel(thresh);
    cmaprangevals = [min(vrange)+0.2 max(vrange(vrange<0))-0.2 min(vrange(vrange>0))+0.2  max(vrange)-0.2];
    opts          = cat(2, opts, {'cmaprange', cmaprangevals});
end
if splitcolset == 0
    opts = cat(2,opts,{'splitcolor', {[0 1 1] [0.05 0.45 1] [1 0.38 0.27] [1 1 0]}});
end
    

% loop given thresholds and code significance levels into plotdat
plotdat = 0;
for k = 1:length(thresh)
    
    if ischar(thresh{k})
        tdat = threshold(statimg, 0.05, lower(thresh{k}));
    elseif isnumeric(thresh{k})
        tdat = threshold(statimg, thresh{k}, 'unc');
    end
    plotdat = plotdat + tdat.sig .* sign(tdat.dat);
    
end

% back into statistic_image object and make region
tdat.dat  = plotdat;
r         = region(tdat);

% if prune clusters, keep only clusters with 1 vx surviving the highest
% threshold
if cl_prune
    k = zeros(size(r));
    for i = 1:numel(r)
        if sum(abs(r(i).val) == length(thresh)) == 0
            k(i) = true;
        end
    end  
    r(logical(k)) = [];
end

obj = addblobs(obj, r, opts{:});
