% Toolbox for batch processing ASL perfusion based fMRI data.
% All rights reserved.
% Ze Wang @ TRC, CFN, Upenn 2004
%
% Batch calculation for the perfusion signals.

for sb = 1:PAR.nsubs % for each subject

    sprintf('Calculate perfusion and CBF signals for subject #%g ... %g subjects left...\n',sb,length(PAR.subjects)-sb)
    for c=1:PAR.ncond

        P=[];
        %ptmp=spm_get('files', PAR.condirs{s,1}, [PAR.subjects{s} '*' PAR.confilters{1} '*img']);
        %P=ptmp(1,:);
        % creating a mask image for removing background
        maskimg = spm_select('FPList', PAR.condirs{sb,c},    ['^mask_perf_cbf\w*\.img$']);
        Filename=spm_select('ExtFPList', PAR.condirs{sb,c}, ['^sr' PAR.confilters{c} '\w*\.img$']);


        Ptmp=spm_select('FPList', char(PAR.M0dirs{sb,c}), ['^sr' PAR.M0filters{c} '\w*\.img$']);
        if  length(deblank( Ptmp (1,:)))~=1
            M0img= Ptmp (1,:);

        end

        %asl_perf_subtract(Filename,FirstimageType, SubtractionType,...
        %   SubtractionOrder,Flag,
        %Timeshift,AslType,labeff,MagType,
        %   Labeltime,Delaytime,Slicetime,TE,M0img,M0seg,maskimg)
        asl_perf_subtract(Filename,0, PAR.subtractiontype, ...
            0,      [1 1 1 0 0 1 0],...
            0.5,     0,      0.95, 1,...
            2, 1.5, 45,17,M0img,[],maskimg);
        fprintf('\n%40s%30s','',' ');
    end
end

