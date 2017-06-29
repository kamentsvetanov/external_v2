function OUT = xcorr_multisubject(data)
%
% OUT = xcorr_multisubject(data)
%
% cl cell structure:
% for i = 1:length(clpos_data), data{i} = cat(2, clpos_data{i}.timeseries); end
%
% cl structure:
% for i = 1:size(cl(1).all_data, 2), for c = 1:length(cl), data{i}(:,c) = cl(c).all_data(:, i); end, end
%
% parcel_cl_avgs or clpos_data2 structure:
% for i = 1:length(parcel_cl_avgs), for j = 1:N, data{j}(:,i) = parcel_cl_avgs(i).timeseries{j}; end, end
%
% create_figure('Xcorr', 1, 3); imagesc(OUT.stats.mean);  subplot(1, 3, 2); imagesc(OUT.stats.sig); subplot(1, 3, 3); imagesc(OUT.stats.fdrsig);
% colormap gray
%
% Example of MDS and plotting total (not decomposed) relationships:
% -------------------------------------------------
%OUT.stats.D = (1 - OUT.stats.mean) ./ 2;
% [OUT.stats_mds.GroupSpace,OUT.stats_mds.obs,OUT.stats_mds.implied_dissim] = shepardplot(OUT.stats.D,[]);
% OUT.stats_mds = nmdsfig_tools('cluster_solution',OUT.stats_mds, OUT.stats_mds.GroupSpace, 2:5, 1000, []);
% nmdsfig(OUT.stats_mds.GroupSpace,'classes',OUT.stats_mds.ClusterSolution.classes,'names',OUT.stats_mds.names,'sig',OUT.stats.fdrsig);
% 
% Example of MDS and plotting direct relationships:
% -------------------------------------------------
% OUT.ridge = matrix_direct_effects_ridge(data);
% D = OUT.ridge.mean; D(find(eye(size(D)))) = 1;
% D = (D' + D) ./ 2;
% OUT.ridge.D = (1 - D) ./ 2;
% [OUT.stats_mds.GroupSpace,OUT.stats_mds.obs,OUT.stats_mds.implied_dissim] = shepardplot(OUT.ridge.D,[]);
% OUT.stats_mds = nmdsfig_tools('cluster_solution',OUT.stats_mds, OUT.stats_mds.GroupSpace, 2:10, 1000, []);
% nmdsfig(OUT.stats_mds.GroupSpace,'classes',OUT.stats_mds.ClusterSolution.classes,'names',OUT.stats_mds.names,'sig',OUT.ridge.fdrsig);
% hh = nmdsfig_fill(OUT.stats_mds);
% axis image, axis equal

% OUT.stats_mds = nmdsfig_tools('cluster_solution',OUT.stats_mds, OUT.stats_mds.GroupSpace, 2:5, 1000, []);
% 
% % data is cell, one cell per subject
% [OUT.stats_mds.GroupSpace,OUT.stats_mds.obs,OUT.stats_mds.implied_dissim] = shepardplot(OUT.stats.D,[]);
% OUT.stats_mds = nmdsfig_tools('cluster_solution',OUT.stats_mds, OUT.stats_mds.GroupSpace, 2:5, 1000, []);

shift_by = 0;
robustflag = 0;
betaflag = 1;
betastr = 'betas'; % or corr
nconditions = 1;

fprintf(1,'Multi-subject cross correlation  \n\t')

warning off     % for robustfit iteration limit

numsub = length(data);

for i = 1:numsub            %size(DATA.dat,3);

    subjdat = data{i};
    m = size(subjdat, 2);
    
    fprintf(1,'%3.0f ',i);

    warning off
    
    for n=1:nconditions

        for j = 1:m - 1
            for k = j + 1 : m
                % now can handle shift by 0 in shift_correl
                if shift_by > 0
                [sval,myc, mylat, myxc] = shift_correl(subjdat(:,j), subjdat(:,k), shift_by, robustflag, betaflag);

                if isempty(mylat), mylat = NaN; end
                
                nxl(j,k) = mylat;
                nxc(j,k) = myxc;
                
                                    
                else
                    rr = corrcoef(subjdat(:,j), subjdat(:,k));    %if there's no shift by; fastest
                    
                    nxc(j,k) = rr(1,2);
                    nxl = [];
                    
                end
                
            end
        end

        warning on

        nxc(end+1,:) = 0;
        nxc=nxc + nxc' + eye(size(nxc,1));

        %xc(n,:,:,i)=nxc;
        OUT.(betastr){n}(:,:,i) = nxc;
        clear nxc;

        nxl(end+1,:) = 0;
        nxl=nxl+nxl';

        %xl(n,:,:,i)=nxl;
        OUT.latency{n}(:,:,i)  = nxl;
        clear nxl;

    end         % condition loop


end             % subject loop

fprintf('\n');

[mxc,t,sig,OUT.stats] = ttest3d(OUT.(betastr){1});

end



