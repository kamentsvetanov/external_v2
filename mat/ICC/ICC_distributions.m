function [median_ICC Cmp]=ICC_distributions() 
%This function evaluates and displays the joint frequancy distribution of
%ICC valus and T values and computes the marginal probability of ICCs
%across the brain, the activated network, deactivates-network and ROI
%specified by the user. It also compares the medians for each region with
%Standard errors and store them in median_ICC. In Cmp it stores the p
%values of mutiple tests for the differences between medians across the
%specified ROIs. 


global defaults;
spm_defaults;

[f,sts] =spm_select(1,'image','ICC map...','', pwd,'^ICC.*\.img$');      
[sd f ex]=fileparts(f);
image_file=[sd '/' f '.img'];  

res=[image_file];    

ac = spm_input('get network?',1,'b','yes|no',['y' 'n'], 1);
if ac=='y'

    [f_act,sts] =spm_select(1,'image','spmT map...','', pwd,'^spmT.*\.img$');
    [sd f ex]=fileparts(f_act);
    act=[sd '/' f '.img'];  
    
    net= act;


    threshold = spm_input('threshold for T-map',2,'e','"given by group t"',NaN);

    deac = spm_input('deactivation ICC?',3,'b','yes|no',['y' 'n'], 2);

    if deac ~= 'n'
        threshold_d = spm_input('threshold for deac. T-map',4,'e','"given by group t"',NaN);
    end
else
     act= res;
     net= res;

end

th=0;

cl = spm_input('select ROI masks?',5,'b','yes|no',['y' 'n'], 2);

num_clusters=0;
if cl =='y';
    [files,sts] =spm_select(Inf,'image','cluster masks...', '', pwd,'^.*\.img$');          
    nscans=size(files);
    nscans=nscans(1);
    cluster_mask_files='';
    
    
    for sc=1:nscans;
        [sd cluster_file{nscans} ex]=fileparts(files(sc,:));
        cluster_mask_files=strvcat(cluster_mask_files,[sd '/' cluster_file{nscans} '.img']);       
    end;
    num_clusters=size(cluster_mask_files,1);
    
    dim =spm_input('dim(Mask)=dim(ICC)?',6,'b','yes|no',['y' 'n'], 1);

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
    plot_clus = spm_input('plot cluster distributions?',7,'b','yes|no',[1 0], 2);
    
    
end


spm_figure('GetWin','Graphics');
fg=spm_figure('FindWin','Graphics');
spm_figure('Clear','Graphics');

[datreg, datregn, datregnn] = ICC_network(th,net, act, res);
D1=datreg(:,1);
D2=datreg(:,2);
D1=D1(D2~=0);
D2=D2(D2~=0);

dbrain=D2;

%WHOLE BRAIN VOLUME
brn=D2;
dat = [D1,D2];
n = hist3(dat,[150 150]); % Extract histogram data
n1 = n';
n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
% Generate grid for 2-D projected view of intensities
xbb = linspace( min(dat(:,1)) , max(dat(:,1)) , size(n,1) + 1);
ybb = linspace( min(dat(:,2)) , max(dat(:,2)) , size(n,1) + 1);
% Make a pseudocolor plot on this grid

c=trapz(sum(n1));
N1b=n1./c; %normalize distribution

%calculate median and confidence intervals
sD2=sort(D2);
medianN1b=sD2(floor((length(D2)+1)/2));
N1cci(1)=sD2(floor((length(D2)+1)/2  -sqrt(length(D2))/2*2.575 ));
N1cci(2)=sD2(floor((length(D2)+1)/2  +sqrt(length(D2))/2*2.575 ));
BrainStErr = abs(N1cci(1)-N1cci(2))/2;
sigmaBrain = BrainStErr/2.575;

%get high and low quintiles for 2d distribtion plot
xrange = quantile(D1,[.00005 .99995]);
yrange = quantile(D2,[0 1]);

if ac=='y'
%NETWORK
D2=D2(D1>=threshold);
D1=D1(D1>=threshold);

LD2=log(D2);
ntw=D2;
dat = [D1,D2];
n = hist3(dat,[150 150]); % Extract histogram data
n1 = n';
n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
% Generate grid for 2-D projected view of intensities
xb = linspace( min(dat(:,1)) , max(dat(:,1)) , size(n,1) + 1);
yb = linspace( min(dat(:,2)) , max(dat(:,2)) , size(n,1) + 1);
% Make a pseudocolor plot on this grid

c=trapz(sum(n1));
N1=n1./c;

sD2=sort(D2);
medianN1=sD2(floor((length(D2)+1)/2));
N1cci(1)=sD2(floor((length(D2)+1)/2  -sqrt(length(D2))/2*2.575));
N1cci(2)=sD2(floor((length(D2)+1)/2  +sqrt(length(D2))/2*2.575));
NetStErr = abs(N1cci(1)-N1cci(2))/2;
sigmaNet = NetStErr/2.575;

if deac ~= 'n'

    %DEACTIVATED NETWORK
    D1=datreg(:,1);
    D2=datreg(:,2);
    D1=D1(D2~=0);
    D2=D2(D2~=0);
    D2=D2(D1<threshold_d);
    D1=D1(D1<threshold_d);

    dnet=D2;
    dat = [D1,D2];
    n = hist3(dat,[150 150]); % Extract histogram data
    n1 = n';
    n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
    % Generate grid for 2-D projected view of intensities
    dxb = linspace( min(dat(:,1)) , max(dat(:,1)) , size(n,1) + 1);
    dyb = linspace( min(dat(:,2)) , max(dat(:,2)) , size(n,1) + 1);
    % Make a pseudocolor plot on this grid

    c=trapz(sum(n1));
    dN1=n1./c;

    sD2=sort(D2);
    mediandN1=sD2(floor((length(D2)+1)/2));
    dN1cci(1)=sD2(floor((length(D2)+1)/2  -sqrt(length(D2))/2*2.575));
    dN1cci(2)=sD2(floor((length(D2)+1)/2  +sqrt(length(D2))/2*2.575));
    dNetStErr = abs(dN1cci(1)-dN1cci(2))/2;
    sigmadNet = dNetStErr/2.575;

end


ax=axes('Position',[0.1 0.65 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
set(gcf, 'color', 'white');
h = pcolor(xbb,ybb,-1.*log(N1b));
colormap(bone)
shading flat
axis([xrange yrange])
set(get(ax,'Title'),'String','Joint Distribution','FontSize',16,'FontWeight','Bold');
set(get(ax,'Xlabel'),'String','t-score');
set(get(ax,'Ylabel'),'String','ICC');



%plot joint proability distributions (ICC, T)
%figure;
%set(gcf, 'color', 'white');
%h = pcolor(xbb,ybb,-1.*log(N1b));
%colormap(bone)
%shading flat
%axis([xrange yrange])
%ylabel('ICC'); xlabel('t-score');
%title('relative voxel frequency')
%hold on
%plot([threshold, threshold], [-1 1],'black')
%hold off

%figure;
%set(gcf, 'color', 'white');
%h = pcolor(xbb,ybb,-1.*log(N1b));
%colormap(bone)
%shading flat
%axis([min(xbb) max(xbb) min(ybb) max(ybb)])
%ylabel('ICC'); xlabel('t-score');
%hold on
%plot([threshold, threshold], [-1 1],'black')
%hold off


%Marginal distributions: Network and cluster comparison
%figure;

if deac ~= 'n'
    %figure
    ax=axes('Position',[0.1 0.35 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
    set(gcf, 'color', 'white');
    probN1=sum(N1');
    plot(yb,probN1,dyb,sum(dN1'),ybb,sum(N1b'))
    ylabel('relative voxel frequency'); xlabel('ICC');
    legend('network','deactivated', 'brain', 'Location', 'SouthEastOutside');
else
    ax=axes('Position',[0.1 0.35 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
    set(gcf, 'color', 'white');
    probN1=sum(N1');
    plot(yb,probN1,ybb,sum(N1b'))
    ylabel('relative voxel frequency'); xlabel('ICC');
    legend('network', 'brain', 'Location', 'SouthEastOutside');
end

else
    ax=axes('Position',[0.1 0.65 0.8 0.2],'Parent',fg,'Visible','off');
	set(get(ax,'Title'),'String','No Joint Distribution','FontSize',16,'FontWeight','Bold','Visible','on');
   
    %figure
    ax=axes('Position',[0.1 0.35 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
    set(gcf, 'color', 'white');
    plot(ybb,sum(N1b'))
    ylabel('Relative Voxel Frequency'); xlabel('ICC');
    legend('brain', 'Location', 'SouthEastOutside');
    
end

medians=[];
meanscv=[];


Cmp={};
numcomp=0;
if cl =='y'

    for cluster=1:num_clusters; % run over clusters
    
        
        %extract voxel data from cluster
        net=[cluster_mask_files(cluster,:)];
        [datreg, datregn, datregnn] = ICC_network(th,net, act, res);

        %CLUSTER DATA
        D1=datregn(:,1);
        D2=datregn(:,2);
        D1=D1(D2~=0);
        D2=D2(D2~=0);
        LD2=log(D2);

        dcluster(cluster).dat=D2;

        dat = [D1,D2];
        n = hist3(dat,[150 150]); % Extract histogram data
        n1 = n';
        n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
        % Generate grid for 2-D projected view of intensities
        xbc = linspace( min(dat(:,1)) , max(dat(:,1)) , size(n,1) + 1);
        ybc = linspace( min(dat(:,2)) , max(dat(:,2)) , size(n,1) + 1);

        c=trapz(sum(n1));
        N1c=n1./c; 

        
    
        %overlays joint distributions of whole brain and clusters
%        figure;
%        set(gcf, 'color', 'white');
    
%        subplot(2+num_clusters,1,1); %joint distribution
    
%        h = pcolor(xbc,ybc,-1.*log(N1c));
%        colormap(bone)
%        hold on
%        h = pcolor(xbb,ybb,-1.*log(N1b));
%        colormap(hot)
%        alpha(.5)
%        shading flat
%        axis([min(xbb) max(xbb) min(ybb) max(ybb)])
%        ylabel('ICC'); xlabel('t-score');
%        hold off
%        hold on
%        plot([threshold, threshold], [-1 1],'black')
%        hold off


        %marginal distriutions: Network and cluster comparison
     if plot_clus==1
      if ac=='y'
        figure;
       % ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
        set(gcf, 'color', 'white');
        probN1=sum(N1');
        probN1c=sum(N1c');
        plot(yb,probN1,ybc,probN1c,ybb,sum(N1b'))
        ylabel('relative voxel frequency'); xlabel('ICC');
        st=[num2str(cluster)];
        cst= ['cluster ' st];
        legend('network', cst, 'brain', 'Location', 'SouthEastOutside');

      else
        figure;
       % ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
        set(gcf, 'color', 'white');
        probN1c=sum(N1c');
        plot(ybc,probN1c,ybb,sum(N1b'))
        ylabel('relative voxel frequency'); xlabel('ICC');
        st=[num2str(cluster)];
        cst= ['cluster ' st];
        legend(cst, 'brain', 'Location', 'SouthEastOutside');

      end
     end;
     sD2=sort(D2);
        medians(cluster)=sD2(floor((length(D2)+1)/2));
        N1cci(1)=sD2(floor((length(D2)+1)/2  -sqrt(length(D2))/2*2.575 ));
        N1cci(2)=sD2(floor((length(D2)+1)/2  +sqrt(length(D2))/2*2.575 ));
        StErr(cluster)= abs(N1cci(1)-N1cci(2))/2;
        sigma(cluster)= StErr(cluster)/2.575;
%    Cs(cluster).ROI=sD2(:);

    %p values for medians
    %z(cluster) = abs(medians(cluster))/sqrt(sigma(cluster)^2);
    %p(cluster) = (1-cdf('Normal',z(cluster),0,1))*2;



    
       %p-values for cluster comparison
        numclus=0;
        for mm=2:cluster
            z = abs(medians(mm-1) - medians(cluster))/sqrt(sigma(mm-1)^2+sigma(cluster)^2);
            numcomp=1+numcomp;
            p(numcomp) = (1-cdf('Normal',z,0,1))*2;
            ind(numcomp,1)= cluster;
            ind(numcomp,2) = mm-1;
            strg{numcomp}=['clusters_' num2str(ind(numcomp,1)) '_' num2str(ind(numcomp,2))];
            numclus=numclus+1;
        end

    end

    alpha=0.01/numcomp;
    if numclus~=0 
        for numcomp=1:length(p);        
            Cmp=setfield(Cmp, strg{numcomp}, [p(numcomp) p(numcomp)<alpha]);
        end
    end
    fprintf('\n')
    fprintf('\n')
    spm_print
    fprintf('\n')
    fprintf('\n')
    fprintf('\n')
    fprintf('\n')
    fprintf('*******************************\n')
    fprintf('*******************************\n')
    fprintf('Intra-subject reliability \n')
    fprintf('\n')
    
    
    spm_figure('GetWin','Graphics');
    fg=spm_figure('FindWin','Graphics');
    
    if ac=='y'
        if deac ~= 'n'
            ndeac=3;
            R=[medianN1b medianN1 mediandN1 medians];
    
            SE=[BrainStErr/2.575 NetStErr/2.575 dNetStErr/2.575 StErr/2.575];
            tt=1:length(R);
            %figure;
            ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
            set(gcf, 'color', 'white');
            bar(tt,R,'r')
         %   colormap summer
            hold on;
            errorbar(tt,R,SE,'.')
            hold off
            ylabel('Median ICC');
            xt={'Brain';'Net';'Dnet'};
        else
            ndeac=2;
            R=[medianN1b medianN1  medians];    
            SE=[BrainStErr/2.575 NetStErr/2.575 StErr/2.575];
            tt=1:length(R);
            %figure;
            ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
            set(gcf, 'color', 'white');
            bar(tt,R,'r')
        %    colormap summer
            hold on;
            errorbar(tt,R,SE,'.')
            hold off
            ylabel('Median ICC');
            xt={'Brain';'Net'};
        end
    else
        ndeac=1;
        R=[medianN1b  medians];    
        SE=[BrainStErr/2.575 StErr/2.575];
        tt=1:length(R);
        %figure;
        ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
        set(gcf, 'color', 'white');
        bar(tt,R,'r')
       % colormap summer
        hold on;
        errorbar(tt,R,SE,'.')
        hold off
         xt={'Brain'};
        ylabel('Median ICC');
    end
    
    for cluster=1+ndeac:num_clusters+ndeac;
        st=[num2str(cluster-ndeac)];
        xt{cluster}= ['cluster ' st];
    end
    set(gca,'XTickLabel',xt);
    
    median_ICC={};
    median_ICC=setfield(median_ICC, 'brain', [R(1) SE(1)]);
    
    if ac=='y'
        median_ICC=setfield(median_ICC, 'network', [R(2) SE(2)]);
    
        if deac ~= 'n'
            median_ICC=setfield(median_ICC, 'Dnetwork', [R(3) SE(3)]);
        end
    end
    for cluster=1:num_clusters;
        st=num2str(cluster);
        median_ICC=setfield(median_ICC, ['cluster_' st], ...
                   [R(ndeac+cluster) SE(ndeac+cluster)]);
    end
    
    fprintf('medians and standard errors for the medians')
    median_ICC
    

else
    fprintf('\n')
    fprintf('\n')
    spm_print
    fprintf('\n')
    fprintf('\n')
    fprintf('\n')
    fprintf('\n')
    fprintf('*******************************\n')
    fprintf('*******************************\n')
    fprintf('Intra-subject reliability \n')
    fprintf('\n')
    
    if ac=='y'
        if deac ~= 'n'
            R=[medianN1b medianN1 mediandN1];
            SE=[BrainStErr/2.575 NetStErr/2.575 dNetStErr/2.575];
    
            tt=1:length(R);
         %   figure; 
            ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
            set(gcf, 'color', 'white');
            bar(tt,R,'r')
            %colormap summer
            hold on;
            errorbar(tt,R,SE,'.')
            hold off
            ylabel('Median ICC');
            xt={'Brain';'Net';'Dnet'};
            set(gca,'XTickLabel',xt);
        else
            R=[medianN1b medianN1];
            SE=[BrainStErr/2.575 NetStErr/2.575 ];
    
            tt=1:length(R);
          %  figure; 
            ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
            set(gcf, 'color', 'white');
            bar(tt,R,'r')
            %colormap summer
            hold on;
            errorbar(tt,R,SE,'.')
            hold off
            ylabel('Median ICC');
            xt={'Brain';'Net'};
            set(gca,'XTickLabel',xt);
        
        end
    else
         R=[medianN1b];
         SE=[BrainStErr/2.575];
    
         tt=1:length(R);
         %figure; 
         ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
         set(gcf, 'color', 'white');
         bar(tt,R,'r')
         %colormap summer
         hold on;
         errorbar(tt,R,SE,'.')
         hold off
         ylabel('Median ICC');
         xt={'Brain'};
         set(gca,'XTickLabel',xt);
    end
    
    median_ICC={};
    median_ICC=setfield(median_ICC, 'brain', [R(1) SE(1)]);
    if ac=='y'
        median_ICC=setfield(median_ICC, 'network', [R(2) SE(2)]);
        if deac ~= 'n'
            median_ICC=setfield(median_ICC, 'dnet', [R(3) SE(3)]);
        end
    end
    fprintf('medians and standard errors for the medians')
    median_ICC


    
    
end;

fprintf('cluster comparisons \n')
fprintf('p values and test whether p>alpha/number_of_comparisons; alpha=0.01 \n')

Cmp
