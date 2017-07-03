function  AnatomicalDistTable=AnatomicalDist(clustermapsource,anatmapsource)
%% Get_Anatomical_Percentages
%Assumes that no label has a value of 0
hdr=spm_vol(clustermapsource);
voxelsize=prod(sqrt(sum(hdr.mat(1:3,1:3).^2)));
cluster=spm_read_vols(spm_vol(clustermapsource));
[regionfile, jnk, label, errorval]=getLabelMap(anatmapsource); %#ok<*ASGLU>
if ~isempty(errorval)
    disp('ERROR:')
    disp(['    ' errorval])
    return
end
anatmap=resizeVol2(spm_vol(regionfile),spm_vol(clustermapsource));
anatrange=0:1:max(unique(anatmap(:)));
cnum=unique(cluster(:));
cnum(cnum==0)=[]; %ignore 0 value
AnatReport={'Cluster Number' 'Cluster Size' 'Top Region' '% Top Region' '2nd Region' '% 2nd Region' '3rd Region' '% 3rd Region' 'Total % Labelled'}; 
fid = fopen('tmp.txt','wt');
jj=1;
for ii=1:numel(cnum)
    anatdist(ii,:)=[cnum(ii) sum(cluster(:)==cnum(ii)) hist(anatmap(cluster==cnum(ii)),anatrange)];
    anatdist(ii,3:end)=anatdist(ii,3:end)./anatdist(ii,2)*100;
    if cnum(ii)>0
        regionalpercents=sort(anatdist(ii,4:end)); regionalpercents=regionalpercents(end:-1:1);
        AnatReport{jj+1,1}=cnum(ii); %Cluster Number
        AnatReport{jj+1,2}=anatdist(ii,2); %Cluster Size
        if regionalpercents(3)>0
            AnatReport{jj+1,3}=label.ROInames{find(regionalpercents(1)==anatdist(ii,4:end))}; %Top Region
            AnatReport{jj+1,4}=regionalpercents(1); %Percent Top Region
            AnatReport{jj+1,5}=label.ROInames{find(regionalpercents(2)==anatdist(ii,4:end))}; %2nd Region
            AnatReport{jj+1,6}=regionalpercents(2); %Percent 2nd Region
            AnatReport{jj+1,7}=label.ROInames{find(regionalpercents(3)==anatdist(ii,4:end))}; %3rd Region
            AnatReport{jj+1,8}=regionalpercents(3); %Percent 3rd Region
            AnatReport{jj+1,9}=sum(anatdist(ii,4:end)); %Total Percent Labelled
            jj=jj+1;
            clear regionalpercents
            fprintf(fid,'Cluster Number: %d has %d voxels (%.1fmm^3).\n\tTop Region: %s with %.2f%% of the cluster.\n\t2nd Region: %s with %.2f%% of the cluster.\n\t3rd Region: %s with %.2f%% of the cluster.\n \tTotal Percent Labelled: %.2f%%.\n\n', ...
                AnatReport{jj,1}, AnatReport{jj,2}, AnatReport{jj,2}*voxelsize,AnatReport{jj,3}, AnatReport{jj,4}, AnatReport{jj,5}, AnatReport{jj,6}, AnatReport{jj,7}, AnatReport{jj,8}, AnatReport{jj,9}); %#ok<PRTCAL>     
        elseif regionalpercents(2)>0
            AnatReport{jj+1,3}=label.ROInames{find(regionalpercents(1)==anatdist(ii,4:end))}; %Top Region
            AnatReport{jj+1,4}=regionalpercents(1); %Percent Top Region
            AnatReport{jj+1,5}=label.ROInames{find(regionalpercents(2)==anatdist(ii,4:end))}; %2nd Region
            AnatReport{jj+1,6}=regionalpercents(2); %Percent 2nd Region
            AnatReport{jj+1,7}=''; %3rd Region
            AnatReport{jj+1,8}=[]; %Percent 3rd Region
            AnatReport{jj+1,9}=sum(anatdist(ii,4:end)); %Total Percent Labelled
            jj=jj+1;
            clear regionalpercents
            fprintf(fid,'Cluster Number: %d has %d voxels (%.1fmm^3).\n\tTop Region: %s with %.2f%% of the cluster.\n\t2nd Region: %s with %.2f%% of the cluster.\n\tTotal Percent Labelled: %.2f%%.\n\n', ...
                AnatReport{jj,1}, AnatReport{jj,2}, AnatReport{jj,2}*voxelsize,AnatReport{jj,3}, AnatReport{jj,4}, AnatReport{jj,5}, AnatReport{jj,6}, AnatReport{jj,9}); %#ok<PRTCAL>          
        elseif regionalpercents(1)>0
            AnatReport{jj+1,3}=label.ROInames{find(regionalpercents(1)==anatdist(ii,4:end))}; %Top Region
            AnatReport{jj+1,4}=regionalpercents(1); %Percent Top Region
            AnatReport{jj+1,5}=''; %2nd Region
            AnatReport{jj+1,6}=[]; %Percent 2nd Region
            AnatReport{jj+1,7}=''; %3rd Region
            AnatReport{jj+1,8}=[]; %Percent 3rd Region
            AnatReport{jj+1,9}=sum(anatdist(ii,4:end)); %Total Percent Labelled
            jj=jj+1;
            clear regionalpercents
            fprintf(fid,'Cluster Number: %d has %d voxels (%.1fmm^3).\n\tTop Region: %s with %.2f%% of the cluster.\n\tTotal Percent Labelled: %.2f%%.\n\n', ...
                AnatReport{jj,1}, AnatReport{jj,2}, AnatReport{jj,2}*voxelsize, AnatReport{jj,3}, AnatReport{jj,4}, AnatReport{jj,9}); %#ok<PRTCAL>
        else
            AnatReport{jj+1,3}=''; %Top Region
            AnatReport{jj+1,4}=[]; %Percent Top Region
            AnatReport{jj+1,5}=''; %2nd Region
            AnatReport{jj+1,6}=[]; %Percent 2nd Region
            AnatReport{jj+1,7}=''; %3rd Region
            AnatReport{jj+1,8}=[]; %Percent 3rd Region
            AnatReport{jj+1,9}=sum(anatdist(ii,4:end)); %Total Percent Labelled
            jj=jj+1;
            clear regionalpercents
            fprintf(fid,'Cluster Number: %d has %d voxels (%.1fmm^3).\n\tTotal Percent Labelled: %.2f%%.\n\n', ...
                AnatReport{jj,1}, AnatReport{jj,2}, AnatReport{jj,2}*voxelsize, AnatReport{jj,9}); %#ok<PRTCAL>
        end
        
    end
end
fclose(fid);
AnatomicalDistTable.ColHeaders=['Cluster Number' 'Cluster Size' 'Not Labelled' label.ROInames];
AnatomicalDistTable.Data=anatdist;
AnatomicalDistTable.Completecol=[AnatomicalDistTable.ColHeaders; num2cell(anatdist)];
AnatomicalDistTable.Completerow=[AnatomicalDistTable.ColHeaders' num2cell(anatdist')];
AnatomicalDistTable.AnatReport=AnatReport;
end