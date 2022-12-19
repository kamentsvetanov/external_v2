function [time_sig, paras] = read_philips(spar, sdat)

time_sig = [];
paras = [];

fd = fopen(spar, 'r');
if fd == -1
    fprintf('\nError opening file.');
else
    % open para file
    fd = fopen(spar,'r');
    % while not EOF
    while ~feof(fd)
        % read line
        line = fgetl(fd);
        % use regular expressions to split up the line
        [v1 v2 v3 v4] = regexp(line,'[A-Za-z0-9-_.]*');
        % try to match with known paras
        if length(v4) == 2
            if strcmp(v4{1},'synthesizer_frequency')
                paras.t_freq = str2double(v4{2});
            end
            if strcmp(v4{1},'rows')
                paras.rows = str2double(v4{2});
            end
            if strcmp(v4{1},'sample_frequency')
                paras.fs = str2double(v4{2});
            end
            if strcmp(v4{1},'echo_time')
                paras.te = str2double(v4{2});
            end
            if strcmp(v4{1},'repetition_time')
                paras.tr = str2double(v4{2});
            end
            if strcmp(v4{1},'num_dimensions')
                paras.dim_num = str2double(v4{2});
            end
            if strcmp(v4{1},'dim1_pnts')
                paras.samples = str2double(v4{2});
            end
            if strcmp(v4{1},'dim2_pnts')
                paras.x_dim = str2double(v4{2});
            end
            if strcmp(v4{1},'dim3_pnts')
                paras.y_dim = str2double(v4{2});
            end
            if strcmp(v4{1},'SUN_num_dimensions')
                paras.dim_num = str2double(v4{2});
            end
            if strcmp(v4{1},'SUN_dim1_pnts')
                paras.samples = str2double(v4{2});
            end
            if strcmp(v4{1},'SUN_dim2_pnts')
                paras.x_dim = str2double(v4{2});
            end
            if strcmp(v4{1},'SUN_dim3_pnts')
                paras.y_dim = str2double(v4{2});
            end
            if strcmp(v4{1},'lr_off_center') % added by kat893 29/08/2012
                paras.lr_center = str2double(v4{2});
            end
            if strcmp(v4{1},'ap_off_center') % added by kat893 29/08/2012
                paras.ap_center = str2double(v4{2});
            end
        end
    end
end
% close para file
fclose(fd);

% open the data file
fd = fopen(sdat, 'r', 'ieee-le');
if fd == -1
    fprintf('\nError opening file.');
else 
   % [data, fid_size] = fread(fd, inf, 'float', 0, 'vaxd');
    data = freadVAXD(fd, inf, 'float');
end
fclose(fd);

% make complex and conjugate
data = data(1:2:length(data)) - j*data(2:2:length(data));
%paras.x_dim
%paras.y_dim
%paras.samples
% arange into a matrix
%time_sig = reshape(data, paras.samples, paras.x_dim, paras.y_dim);
time_sig = data;