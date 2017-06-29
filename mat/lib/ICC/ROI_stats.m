function [ROI_medians ROI_means ROI_max] = ROI_stats(cluster_mask_files, image_file) 
%calculate the medians, means, and maxima for each of the files in
%image_file within the ROIs defined by the files in cluster_mask_files

global defaults

th=0;
sel1=['']; 

sv = spm_input('save in txt files?',1,'b','yes|no',['y' 'n'], 1);
    
if nargin<1
    
    [files,sts] =spm_select(Inf,'image','cluster masks...', '', pwd,'^.*\.img$');          
    nscans=size(files);
    nscans=nscans(1);
    cluster_mask_files='';

    for sc=1:nscans;
        [sd f ex]=fileparts(files(sc,:));
        cluster_mask_files=strvcat(cluster_mask_files,[sd '/' f '.img']);       
    end;
    
    dim =spm_input('dim(Mask)=dim(ICC)?',2,'b','yes|no',['y' 'n'], 1);

    if dim~='y'
        [f_act,sts] =spm_select(1,'image','reference image...','', pwd,'^.*\.img$');      
        [sd f ex]=fileparts(f_act);
        ref_img=[sd '/' f '.img']; 
        
        spm_imcalc_ui(ref_img,[pwd '/output.img'],'(i1<-Inf)+1');
        
        for image=1:size(cluster_mask_files,1);
            cluster_mask_files(image,:)
            [sd f ex]=fileparts(cluster_mask_files(image,:));
            imcal_input=strvcat([pwd '/output.img'], cluster_mask_files(image,:));
            spm_imcalc_ui(imcal_input,[sd '/' f '.img'],'i1.*i2');
        end;
        
         delete([pwd '/output.img']);
         delete([pwd '/output.hdr']);
        
        
    end

end;

if nargin<2
    [files,sts] =spm_select(Inf,'image','source images...', '', pwd,'^.*\.img$');          
    nscans=size(files); 
    nscans=nscans(1);
    image_file='';


    for sc=1:nscans;
        [sd f ex]=fileparts(files(sc,:));
        image_file=strvcat(image_file,[sd '/' f '.img']);       
    end;
end;


aproxmeans=[];
aproxmeanscv=[];


if size(cluster_mask_files,1) == 0
    numclus=1;
else
    numclus=size(cluster_mask_files,1);
end

for cluster=1:numclus % run over clusters

    for subject=1:size(image_file,1); % run over subjects
 

        res=[image_file(subject,:)];
        act=res;   

        if size(cluster_mask_files,1) == 0
            net=res;
        else
            net=[cluster_mask_files(cluster,:)];
        end


        [datreg, datregn, datregnn] = ICC_network(th,net, act, res);
%datreg is the couple (t, reliability measure) for each voxel. Each couple is assumed to be
%independent
        D1=datregn(:,1);
        D2=datregn(:,2);
        D1=D1(D2~=0);
        D2=D2(D2~=0);

        D2(D2==0)=[];

        ROI_medians(subject,cluster)=median(D2);
        ROI_means(subject,cluster)=mean(D2);
        ROI_max(subject,cluster)=max(D2);

    end
    
 if sv=='y'    
        s = sprintf('%02.f', cluster);
        file=['ROI',s,'medians.txt'];
        md=ROI_medians(:,cluster);
        save(file, 'md', '-ascii');
    
        file=['ROI',s,'means.txt'];
        mn=ROI_means(:,cluster);
        save(file, 'mn', '-ascii')
    
        file=['ROI',s,'max.txt'];
        mx=ROI_max(:,cluster);
        save(file, 'mx', '-ascii');
 end;
    
end
if sv=='y' 
fprintf('\n')
fprintf('*******************************\n')
fprintf('Data saved in files. \n')
fprintf('load ROI01medians for medians; ROI01means for means; and ROI01max for maxima')
fprintf('\n')
end
