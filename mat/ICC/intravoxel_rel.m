function [ROI_vICC_2A_con v_ICC_2A_con v_cv]=intravoxel_rel()
%this function plots session 1 vs session 2, for each subjects contrast files and in
%given clusters. Choose all session 1 first, followed by corresponding
%images of session 2. Only 2 sessions are supported. It returns:
%1- ROI_vICC_2A_con: the population ICC_2A_con measure for each ROI, infered by a 
%bootstrapping procedure
%2- v_ICC_2A_con: the ICC_2A_con for each subject and ROI
%3- v_cv: The coefficient of variation for each subject and ROI

global defaults

spm_defaults;

[files,sts] =spm_select(Inf,'image','cluster masks...','', pwd,'^.*\.img$');          
nscans=size(files);
nscans=nscans(1);
cluster_mask_files='';
     
for sc=1:nscans;
    [sd f ex]=fileparts(files(sc,:));
    cluster_mask_files=strvcat(cluster_mask_files,[sd '/' f '.img']);       
end;

num_clusters=size(cluster_mask_files,1);

dim =spm_input('dim(Mask)=dim(ICC)?',1,'b','yes|no',['y' 'n'], 1);

if dim~='y'
        [f_act,sts] =spm_select(1,'image','reference image...','', pwd,'^.*\.img$');      
        [sd f ex]=fileparts(f_act);
        ref_img=[sd '/' f '.img']; 
        
        spm_imcalc_ui(ref_img,[sd '/output.img'],'(i1<-Inf)+1');
        delete([sd '/output.img']);
        
        
        for image=1:size(cluster_mask_files,1);
            cluster_mask_files(image,:)
            [sd f ex]=fileparts(cluster_mask_files(image,:));
            imcal_input=strvcat(ref_img, cluster_mask_files(image,:));
            spm_imcalc_ui(imcal_input,[sd '/' f '.img'],'i1.*i2');
        end;
end    



[files,sts] =spm_select(Inf,'image','contrast images...');          
nscans=size(files);
nscans=nscans(1);
activation_files='';
     
for sc=1:nscans;
    [sd f ex]=fileparts(files(sc,:));
    activation_files=strvcat(activation_files,[sd '/' f '.img']);       
end; 

nsub=size(activation_files,1)/2;
numsubplots=ceil(sqrt(nsub));

%for each cluster extract the values in each activation map

for cluster=1:size(cluster_mask_files,1); % run over clusters

    figure;
    %title(['cluster', num2str(cluster)])
    set(gcf, 'color', 'white');
    
    th=0;
    
    net=[cluster_mask_files(cluster,:)];

    for subject=1:size(activation_files,1)/2; % run first session 

        act=[activation_files(subject,:)] %x axis for the 1st session
        res=[activation_files(subject+size(activation_files,1)/2,:)] %y axis for the 2nd

        
        %use network to extract the sesssion 1 Vs session 2 in the cluster
        %mask
        [datreg, datregn, datregnn] = ICC_network(th,net, act, res);
        
        D1=datregn(:,1); %session 1
        D2=datregn(:,2); %session 2
        D1=D1(D2~=0);
        D2=D2(D2~=0);
        Y = [D1; D2]; 
         
        %calculates the ICC for a concatenated set of values in Y (test-retest)
        [ICC,ICC_2A, ICC_2A_con(cluster,subject), p1, p2, cv(cluster,subject), sw, se]=ICC_summary(Y,2);
%        [r,p] = corrcoef(D1,D2); %correlation between sessions       
%        rcoef(subject,:)=[r(1,2),p(1,2)];
%        strICC=num2str(ICC,'%5.2f'); %ICC(2,1)
        stricc_2A_con=num2str(ICC_2A_con(cluster,subject),'%5.2f'); %ICC(3,1) obtained form BMS/EMS
        strcv=num2str(cv(cluster,subject),'%5.2f');
         
         subplot(numsubplots,numsubplots,subject,'align');
         plot(D1,D2,'.')
         axis equal
         xrange = quantile(D1,[.00005 .99995]);
         yrange = quantile(D2,[.00005 .99995]);
         minr=min([xrange yrange]);
         maxr=max([xrange yrange]);
         axis([minr maxr minr maxr]);
         xlabel('sess 1'); ylabel('sess 2');
         title({['ICC=' stricc_2A_con]});
         
         fprintf('...done subject.')
         fprintf('%5.1f \n', subject)        
     end;
     
end;

fprintf('\n')
fprintf('*******************************\n')
fprintf('Intra-voxel reliability')
fprintf('\n')

%bootstrapping the results for all the subjects
subicc=ICC_2A_con;

%run the bootstrap for the fisher's Z transform 
%as Raemaekers et al 2007
%subicc=log(abs((1+ICC_2A_con)./(1-ICC_2A_con) )  )./2;


md = bootstrp(1000,@median,subicc');

Nv = mean(md);
StErr= std(md);

R=[Nv];
E=StErr;
tt=1:length(R);
figure; 
set(gcf, 'color', 'white');
bar(tt,R,'r')
colormap summer
hold on;
errorbar(tt,R,E,'.')
hold off


xt={};
    
for cluster=1:num_clusters;
    st=[num2str(cluster)];
    xt{cluster}= ['cluster_' st];
end
set(gca,'XTickLabel',xt);
    
ROI_vICC_2A_con={};
    
for cluster=1:num_clusters;
    st=num2str(cluster);
    ROI_vICC_2A_con=setfield(ROI_vICC_2A_con, ['cluster_' st], ...
                    [Nv(cluster) StErr(cluster)]);
end

fprintf('Reliability measures (ICCs and CVs) per-subject per ROI \n')
fprintf('Columns-> subjects; rows-> ROIs \n')
fprintf('\n')
fprintf('ICCs: \n')
v_ICC_2A_con=ICC_2A_con
fprintf('\n')
fprintf('CVs: \n') 
v_cv=cv

fprintf('\n')
fprintf('Medians with standard errors of ROI-ICCs across the population: \n')
ROI_vICC_2A_con
