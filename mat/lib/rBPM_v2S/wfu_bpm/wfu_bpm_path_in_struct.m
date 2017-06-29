function BPM = wfu_bpm_path_in_struct(BPM_fname, BPM)
%
% function BPM = wfu_bpm_path_in_struct(BPM_fname, BPM)
%
% If the location of the BPM mat file has been moved, then
% reset the path of all outputs to that of the BPM.mat file.
%
run_result_dir = BPM.result_dir;
BPM.result_dir = fileparts(BPM_fname);
%
% If BPM.mat is in the original location, no changes are needed.
if strcmp(run_result_dir, BPM.result_dir)
    return;
end
disp(['Reset BPM.mat path: ' BPM.result_dir]);
%
% Do not reset BPM.conf since it is a user input in any location.
%
% Reset mask path only if it has a unique path different from
% original BPM result dir, indicating a user input in any location.
if isfield(BPM, 'mask')
    [pathstr, name, ext, version] = fileparts(BPM.mask);
    if strcmp(run_result_dir, pathstr)
        BPM.mask = fullfile(BPM.result_dir, [name ext version]);
    end
end
%
% Reset paths for these BPM outputs:
%   flist, XtX, sig2, X, beta{}, E{}, Stat{}
if isfield(BPM, 'flist')
    [pathstr, name, ext, version] = fileparts(BPM.flist);
    BPM.flist = fullfile(BPM.result_dir, [name ext version]);
end
if isfield(BPM, 'XtX')
    [pathstr, name, ext, version] = fileparts(BPM.XtX);
    BPM.XtX = fullfile(BPM.result_dir, [name ext version]);
end
if isfield(BPM, 'sig2')
    [pathstr, name, ext, version] = fileparts(BPM.sig2);
    BPM.sig2 = fullfile(BPM.result_dir, [name ext version]);
end
if isfield(BPM, 'X')
    [pathstr, name, ext, version] = fileparts(BPM.X);
    BPM.X = fullfile(BPM.result_dir, [name ext version]);
end
if isfield(BPM, 'beta')
    n = size(BPM.beta, 2);
    for i = 1:n
        [pathstr, name, ext, version] = fileparts(BPM.beta{i});
        BPM.beta{i} = fullfile(BPM.result_dir, [name ext version]);
    end
end
if isfield(BPM, 'E')
    n = size(BPM.E, 2);
    for i = 1:n
        [pathstr, name, ext, version] = fileparts(BPM.E{i});
        BPM.E{i} = fullfile(BPM.result_dir, [name ext version]);
    end
end
if isfield(BPM, 'Stat')
    n = size(BPM.Stat, 2);
    for i = 1:n
        [pathstr, name, ext, version] = fileparts(BPM.Stat{i});
        BPM.Stat{i} = fullfile(BPM.result_dir, [name ext version]);
    end
end
