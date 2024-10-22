% batch reset T1 orientation

global PAR
par
fprintf('\r%-40s\n','batch reset orientation ')
%%%%% the following codes are changed from batch_smooth

% dirnames,
% get the subdirectories in the main directory
for sb = 1:PAR.nsubs % for each subject
    %go get the sessions
    str   = sprintf('sub #%3d/%3d: %-5s',sb,PAR.nsubs,PAR.subjects{sb} );
    fprintf('\r%-40s  %30s',str,' ')
    fprintf('%s%30s',repmat(sprintf('\b'),1,30),'...reseting')  %-#
    %now get all images to reset orientation
    %prepare directory
    P=[];
    for c=1:PAR.ncond
        % get files in this directory
        Ptmp=spm_select('FPList', char(PAR.condirs{sb,c}), ['^' PAR.confilters{c} '\w*\.img$']);

        P=strvcat(P,Ptmp);
        
        
        if strcmp(P(1,:),'/')
            disp('!!!!!!!!\n NO epi file\n!!!!!!!!!!')
            continue;
        end;

        
        Ptmp=spm_select('FPList', char(PAR.M0dirs{sb,c}), ['^' PAR.M0filters{c} '\w*\.img$']);
        
        
        P=strvcat(P,Ptmp);
        
        
        for i=1:size(P,1)
            fprintf('%s%30s',repmat(sprintf('\b'),1,30),sprintf('%s%5d/%5d','...reseting epi ',i,size(P,1)) ) %-#

            V    = spm_vol(deblank(P(i,:)));
            M    = V.mat;
            vox  = sqrt(sum(M(1:3,1:3).^2));
            if det(M(1:3,1:3))<0, vox(1) = -vox(1); end;
            orig = (V.dim(1:3)+1)/2;
            off  = -vox.*orig;
            M    = [vox(1)  0      0      off(1)
                0      vox(2) 0      off(2)
                0      0      vox(3) off(3)
                0      0      0      1       ];
            spm_get_space(P(i,:),M);
        end
    end

    P=[];
    Ptmp=spm_select('FPList', char(PAR.structdir{sb}), ['^' PAR.structprefs '\w*.img$']);

    P=strvcat(P,Ptmp);
    if strcmp(P(1,:),'/')
        disp('!!!!!\n NO struct file\n!!!!!!!!!!!!!!!')
        continue;
    end;

    for i=1:size(P,1),
        fprintf('%s%30s',repmat(sprintf('\b'),1,30),sprintf('%s%5d/%5d','...reseting T1 ',i,size(P,1)) ) %-#
        V    = spm_vol(deblank(P(i,:)));
        M    = V.mat;
        vox  = sqrt(sum(M(1:3,1:3).^2));
        if det(M(1:3,1:3))<0, vox(1) = -vox(1); end;
        orig = (V.dim(1:3)+1)/2;
        off  = -vox.*orig;
        M    = [vox(1)  0      0      off(1)
                 0      vox(2) 0      off(2)
                 0      0      vox(3) off(3)
                 0      0      0      1   ];
        spm_get_space(P(i,:),M);
    end;

    fprintf('%s%30s',repmat(sprintf('\b'),1,30),'...done')  %-#
end
