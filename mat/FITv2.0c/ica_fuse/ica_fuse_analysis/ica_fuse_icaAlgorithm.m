function [icaAlgo, W, A, icasig_tmp] = ica_fuse_icaAlgorithm(ica_algorithm, data, ICA_Options)
%% Function to get the number of ICA algorithms, run a particular algorithm
%
% Input:
% No inputs gives all the algorithms available
% 1. ica_algorithm - Number or specify the algorithm name directly
% 2. data - 2D matrix components by volume
% 3. icaOptions - cell array containing necessary parameters
%
% Output:
% 1. icaAlgo - all algorithms available
% 2. W - Weights matrix (components by components)
% 3. A - inverse of Weights (components by components)
% 4. icasig_tmp - Sources (components by volume)
%

%% All the available algorithms
icaAlgo = str2mat('Infomax','Fast ICA', 'Erica', 'Simbec', 'Evd', 'Jade Opac', 'Amuse', ...
    'SDD ICA', 'CCICA', 'Combi');


if (nargin > 3)
    error('Max number of args allowed is 3.');
end


W = 0; icasig_tmp = 0;

%% If there are more than one arguments
if (nargin > 0 && nargin <= 3)

    % get the ica algorithm
    if isnumeric(ica_algorithm)
        if (ica_algorithm > size(icaAlgo, 1))
            disp(['Selected algorithm number is : ', num2str(size(icaAlgo, 1)), '. Presently there are ', ...
                num2str(size(icaAlgo, 1)), ' algorithms. By default selecting the first algorithm.']);
            ica_algorithm = 1;
        end
        selected_ica_algorithm = lower(deblank(icaAlgo(ica_algorithm, :))); % selected ICA algorithm
    elseif ischar(ica_algorithm)
        selected_ica_algorithm = lower(deblank(ica_algorithm));
        matchIndex = strmatch(selected_ica_algorithm, lower(icaAlgo), 'exact');
        if isempty(matchIndex)
            disp('Algorithm specified is not in the available ICA algorithms. By default selecting the first algorithm.');
            selected_ica_algorithm = lower(deblank(icaAlgo(1, :)));
        end
    end

end
% end for checking the number of arguments

%% Run ICA
if (nargin > 0 && nargin <= 3)

    %% Check ICA options
    if ~exist('ICA_Options', 'var')
        ICA_Options = {};
    else
        if isempty(ICA_Options)
            ICA_Options = {};
        end
    end


    switch(lower(selected_ica_algorithm))

        case 'infomax'
            %% Infomax
            [W, sphere] = ica_fuse_runica(data, ICA_Options{1:length(ICA_Options)});
            W = W*sphere;
            icasig_tmp = W*data;
            A = pinv(W);

        case 'fast ica'
            %% FAST ICA
            [icasig_tmp, A_est, W] = ica_fuse_fastICA(data, ICA_Options{1:length(ICA_Options)});
            A = A_est;

        case 'erica'
            %% ERICA
            [BW, B, W, A, icasig_tmp] = ica_fuse_erica(data);
            W = BW;

        case 'simbec'
            %% SIMBEC
            [c_index, W] = ica_fuse_simbec(data, size(data, 1));
            A = pinv(W);
            icasig_tmp = W*data;

        case 'evd'
            %% EVD
            [icasig_tmp, W] = ica_fuse_evd(data, size(data, 1));
            A = pinv(W);

        case 'jade opac'
            %% Jade Opac
            [icasig_tmp, W] = ica_fuse_jade_opac(data);
            A = pinv(W);

        case 'amuse'
            %% Amuse
            [icasig_tmp, W] = ica_fuse_amuse(data);
            A = pinv(W);

        case 'sdd ica'
            %% Optimal ICA
            [W, sphere] = ica_fuse_runica_opt(data, ICA_Options{1:length(ICA_Options)});
            W = W*sphere;
            icasig_tmp = W*data;
            A = pinv(W);

        case 'ccica'
            %% Constraint supervisedICA
            [W, sphere, icasig_tmp] = ica_fuse_runica_ccica(data, ICA_Options{1:length(ICA_Options)});
            A = pinv(W);

        case 'combi'
            %% Combi
            W = ica_fuse_combi(data);
            icasig_tmp = W*data;
            A = pinv(W);

            %% Add your own ICA algorithm code below

        otherwise
            error('Unknown ICA algorithm specified');

    end
    % end for checking the ICA algorithms

end