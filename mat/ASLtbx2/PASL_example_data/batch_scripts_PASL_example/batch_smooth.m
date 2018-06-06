% Toolbox for batch processing ASL perfusion based fMRI data.
% All rights reserved.
% Ze Wang @ TRC, CFN, Upenn 2004
%
%
% Smoothing batch file for SPM2

% Get subject etc parameters
disp('Smoothing the realigned functional images, it is quick....');
org_pwd=pwd;
% dirnames,
% get the subdirectories in the main directory
for sb = 1:PAR.nsubs % for each subject

    str   = sprintf('sub #%3d/%3d: %-5s',sb,PAR.nsubs,PAR.subjects{sb});
    fprintf('\r%-40s  %30s',str,' ')
    fprintf('%s%30s',repmat(sprintf('\b'),1,30),'...smoothing')  %-#

    for c=1:PAR.ncond
        %P=[];
        %dir_func = fullfile(PAR.root, PAR.subjects{s},PAR.sesses{ses},PAR.condirs{c});
        P=spm_select('FPList', PAR.condirs{sb,c}, ['^r\w*\.img$']);
        sprintf('     There are %u realigned images in this directory.',size(P,1))


        Ptmp=spm_select('FPList', char(PAR.M0dirs{sb,c}),  ['^r\w.*img']);

        P=strvcat(P,Ptmp);

        %take image per image smooth
        for im=1:size(P,1)
            %this is actual image
            Pim=P(im,:);
            %this the new image name
            
            Qim=fullfile(fileparts(Pim),['s' spm_str_manip(Pim,'dt')]);
            %now call spm_smooth with kernel defined at PAR
            spm_smooth(Pim,Qim,PAR.FWHM);
        end
        cd(PAR.condirs{sb,c});

    end

end
cd(org_pwd);
