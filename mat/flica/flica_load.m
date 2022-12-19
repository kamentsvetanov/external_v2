% [Y, fileinfo] = flica_load(Yfiles, transforms)
%
% Loads data from .nii.gz or .mgh files:
% Yfiles{k} is the filename (or pattern) to load from.
% transforms{k,:} = {'' or 'log', '' or subtractThis, '' or divideByThis, 'single' or 'double'}
% Y{k} are the important data.
% masks{k} show which voxels to put these values back into.  In the case of
%   .nii.gz files, this is a 3D boolean matrix. In the case of .mgh files,
%   it's a pair of MRI structures.
% transforms{k} gives the information needed to reverse any
%   transformations applied to the input data (e.g. log then subtract this
%   mean then divide by this RMS).  Format TBA.
% This should provide enough information to reconstru    % Will break for tensor arrangementct a (masked and
% rounded) version of the raw data.

% TODO: Put a "modality_groups" option, with 0 -> omit this; unique
% positive -> flat modality; shared positive -> tensor group; shared
% negative -> concatenation group.

function [Y, fileinfo] = flica_load(Yfiles, transforms)

%#ok<*AGROW> - Remove annoying MATLAB warnings about preallocating.

%% Parse arguments
if nargin<2
    transforms = repmat({'nop','auto2','rms','double'},length(Yfiles),1);
elseif iscell(transforms) && isequal(size(transforms), [1 4])
    transforms = repmat(transforms, length(Yfiles), 1);
else
    assert(isequal(size(transforms), [length(Yfiles) 4]))
end

%% 
prevMask = [];
for k = 1:length(Yfiles)
    fprintf('Loading "%s"... \n', Yfiles{k}); pause(.01)
    if strfind(Yfiles{k},'.nii.gz')
        
        [vol dims scales bpp endian] = read_avw(Yfiles{k});
        if bpp==32, 
            fprintf('Converting back to single... '); 
            vol=single(vol); 
        end % Save RAM immediately. Should really fix read_avw_img so it uses 'float32=>float32' to output singles directly.
        fprintf('Generating mask... ');
        masks{k} = any(vol,4); % 3D, so can't be sparse.
        fprintf('Flattening data matrix... ');
        rawdata{k} = reshape(vol,[],size(vol,4));
        %rawdata{k} = sparse(double(rawdata{k})); % Save memory in TBSS 1mm case -- but doesn't matter any more because we'll delete rawdata{k} soon.
        fprintf('Freeing memory... ');
        clear vol
        filetype{k} = {'NIFTI',dims,scales,bpp,endian};

        % De-duplication to save memory (MATLAB uses copy-on-write)
        if isequal(prevMask, masks{k})
            masks{k} = prevMask; % So out.masks{mi-1} and masks{k} share memory?
        else
            prevMask = masks{k}; % Ready for the next one
        end
        
    elseif strfind(Yfiles{k},'.mgh')
        fprintf('Loading "%s"...\n', Yfiles{k}); pause(.01)
        addpath /usr/local/freesurfer/matlab
        assert(length(strfind(Yfiles{k},'?'))==1)
        filetype{k}(1) = MRIread(regexprep(Yfiles{k},'?','l'));
        vol = filetype{k}(1).vol;
        %assert(ndims(vol)==2)
        filetype{k}(2) = MRIread(regexprep(Yfiles{k},'?','r'));
        vol = [vol filetype{k}(2).vol];
        
        rawdata{k} = reshape(vol,[],size(vol,4));

        masks{k} = any(logical(vol),4);
        NvoxPerHemi = size(vol,2)/2;
        switch (NvoxPerHemi) 
            case 2562
                labelSrcDir = '/vols/Data/oslo/fsaverages/fsaverage4/label/';
            case 10242
                labelSrcDir = '/vols/Data/oslo/fsaverages/fsaverage5/label/';
            case 40962
                labelSrcDir = '/vols/Data/oslo/fsaverages/fsaverage6/label/';
            case 163842
                labelSrcDir = '/vols/Data/oslo/fsaverages/fsaverage/label/';
                %labelSrcDir = '/vols/Data/oslo/fsaverages/fsaverage_/label/';
            otherwise
                labelSrcDir = '';
                size(vol,2)
                error 'Unrecognized number of vertices'
        end                
                
        clear tmp
        if ~isempty(labelSrcDir)
            for fi = 1:4
                {'lh.cortex.label','lh.Medial_wall.label','rh.cortex.label','rh.Medial_wall.label'}; %#ok<VUNUS>
                tmp{fi} = read_label('', [labelSrcDir ans{fi}]); %#ok<USENS,NOANS>
                tmp{fi} = tmp{fi}(:,1) + 1 + (ans{fi}(1)=='r')*NvoxPerHemi; %#ok<NOANS>
            end
            assert(all(sort([tmp{1};tmp{2}])==(1:NvoxPerHemi)'))
            assert(all(sort([tmp{3};tmp{4}])==(1:NvoxPerHemi)'+NvoxPerHemi))
            assert(all(sort(vertcat(tmp{:}))==(1:NvoxPerHemi*2)'))
            assert(size(filetype{k}(1).vol,2)==NvoxPerHemi)
            masks{k}([tmp{2};tmp{4}]) = 0;
        else
            warning 'Not masking out the medial wall' %#ok<WNTAG>
        end
        filetype{k} = rmfield(filetype{k}, 'vol'); % Big and not needed
    else
        error('Unrecognized file type: %s', Yfiles{k})
    end
    
    Y{k} = rawdata{k}(masks{k},:);
    switch transforms{k,4}
        case {'single'}
            Y{k} = single(Y{k});
        case {'double', ''}
            Y{k} = double(Y{k});
        otherwise
            error('Undefined data type "%s"', transforms{k,4})
    end
    rawdata{k} = []; % Free the memory
    fprintf('\n')
end


%% Apply transformations to rawdata to get Y
for k = 1:length(Yfiles)
    % Check for "missing data" volumes
    missingSubjects = all(isnan(Y{k},1) | (Y{k}==0));
    Y{k} = Y{k}(:,~missingSubjects); % Squash them out, temporarily.

    % Nonlinear rescaling?
    switch transforms{k,1}
        case {'','nop'}
            % Do nothing
        case 'log'
            %assert(all(Y{k}(:)>0)) % Only for hard log, below
            %Y{k} = log(Y{k});
            % Use soft log instead:
            Y{k} = log(max(Y{k},mean(Y{k}(:)).^2/max(Y{k}(:))));
        otherwise
            transforms{k,1} %#ok<NOPRT>
            error('Unrecognized transformation!')
    end
    % De-meaning?
    if isnumeric(transforms{k,2}) && numel(transforms{k,2})>1
        % Mismatched size: is useless, should be auto
        % Same size: why are you doing this?
        error 'Unimplemented or illogical!'
    end
    switch transforms{k,2}
        case {'auto12'} % Demean in both directions
            tmp = matched_subtract(Y{k}, mean(Y{k}, 2));
            tmp = matched_subtract(tmp, mean(tmp, 1));
            transforms{k,2} = Y{k} - tmp; clear tmp
        case {'', 'auto2'}  % Have to remove the mean subject map
            transforms{k,2} = mean(Y{k},2);
        case {0}
            % nop
        otherwise
            transforms{k,2} %#ok<NOPRT>
            error('Unrecognized transformation!')
    end
    Y{k} = bsxfun(@minus, Y{k}, transforms{k,2});
    
    % De-scaling?
    switch transforms{k,3}
        case {'', 'rms'}
            transforms{k,3} = rms(Y{k});
        case {1}
            % nop
        otherwise
            if isnumeric(transforms{k,3}) && numel(transforms{k,3})==1
                % ok, fixed rescaling
            else
                transforms{k,3} %#ok<NOPRT>
                error('Unrecognized transformation!')
            end
    end
    Y{k} = bsxfun(@rdivide, Y{k}, transforms{k,3});

    % Re-expand to put back all-zeroes volumes for missing subjects
    if any(missingSubjects)
	warning 'UNTESTED CODE: Dealing with missing data in some subjects'
	disp(find(missingSubjects))
        %tmp = Y{k};
        %Y{k} = zeros(size(tmp,1), length(missingSubjects));
        %Y{k}(:,~missingSubjects) = tmp;
	%clear tmp;
        Y{k}(:,~missingSubjects) = Y{k};
	Y{k}(:,missingSubjects) = 0;
	if size(transforms{k,2},2) == sum(missingSubjects)
	    transforms{k,2}(:,~missingSubjects) = transforms{k,2};
	    transforms{k,2}(:,missingSubjects) = 0;
	end
    end
end

fileinfo.masks = masks;
fileinfo.transforms = transforms;
fileinfo.filetype = filetype;
Yfiles = regexprep(Yfiles, '^.*/', '');
Yfiles = regexprep(Yfiles, '\.[^.]*$', '');
fileinfo.shortNames = Yfiles;



