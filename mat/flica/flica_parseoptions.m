% Takes the same options as flica()
% In particular, Y is included because it's needed to initialize
% dof_per_voxel, etc.
function opts = flica_parseoptions(Y, varargin)

%% Set all options to sensible defaults. Note these shouldn't refer to the data YET.
%opts.modality_groups = 1:length(Y);  % Not used any more; ALL Y are analysed.

opts.maxits = 10000;
opts.dof_per_voxel = 'auto_eigenspectrum';
opts.num_components = 10;
opts.X_model = 'BayesianICA, M=3, nullMix, piPrior=0.1N';
opts.lambda_dims = 'R';
opts.calcFits = 'all'; % 'log2' is faster

opts.subcalcF = false; % 1 = each main update, 2 = Additionally stop after each P'(X,q)_k,i update.
opts.keyboardEveryIterations = 0; % pause for interaction if mod(its,that)==0.  Conveniently, mods(its,0) is always nonzero (since its>0).
opts.plotConvergence = 1; % which figure to update?
opts.plotEta = false;
opts.Rgroups = 1; % Will be replaced by ones(R,1) later, once we're allowed to look at the data Y.

opts.initH = 'PCA'; % Or an LxR matrix.

if nargin==0
    disp 'No arguments given, displaying usage info instead instead!'
    disp(opts) 
    disp 'Yes I realize this isn''t enough detail, but it''s a start. Please refer to source code.'
    clear opts; return
end

%% Convert arguments in a structure S:
if length(varargin) == 0
    S = struct();
    
elseif length(varargin) == 1 && isstruct(varargin{1})
    S = varargin{1};
    
else % assume it's "'fieldname', value," pairs
    for i=1:2:length(varargin)
        if isfield(S, varargin{i}), 
            error('Duplicate option: %s', varargin{i}); 
        end
        S.(varargin{i}) = varargin{i+1};
    end
end

%% Apply these options to the default-options structure
fs = fieldnames(S);
for i = 1:length(fs)
    f = fs{i};
    if ~isfield(opts, f)
        error('Unrecognized option: %s', f)
    else
        opts.(f) = S.(f);
    end
end

opts.manually_set_options = S; % Copy for later re-running

%% Interpret any options that need to refer to the data:

R = size(Y{1},2); % for convenience

assert(opts.num_components < R)

if isequal(opts.Rgroups, 1)
    opts.Rgroups = ones(R,1); % Everything in the same group, by default.
end

if isnumeric(opts.initH)
    assert(isequal(size(opts.initH),[opts.num_components R]))
else
    assert(isequal(opts.initH, 'PCA'))
end

if isequal(opts.dof_per_voxel, 'auto_eigenspectrum')
    opts.dof_per_voxel = [];
    for k=1:length(Y)
        assert(all(isfinite(Y{k}(:))) && size(Y{k},3)==1)
        opts.dof_per_voxel(k) = ...
            est_DOF_eigenspectrum(full(Y{k})) / size(Y{k},1);
    end
end

if ischar(opts.X_model)
    opts.X_model = repmat({opts.X_model},length(Y),1);
end
if ischar(opts.lambda_dims)
    opts.lambda_dims = repmat({opts.lambda_dims},length(Y),1);
end

if isequal(opts.calcFits, 'log2')
    opts.calcFits = [1:5 floor(2.^(3:.5:log2(opts.maxits-1))) opts.maxits];
elseif isequal(opts.calcFits, 'all')
    opts.calcFits = 1:opts.maxits;
else
    assert(isnumeric(opts.calcFits) && all(diff(opts.calcFits)>0) ...
        && opts.calcFits(1)>0 && opts.calcFits(end) <= opts.maxits);
end



%% Return opts!
return