function [voxels voxelstats clusterstats sigthresh regions mapparameters UID]=peak_nii(image,mapparameters)
%%
% USAGE AND EXAMPLES CAN BE FOUND IN PEAK_NII_MANUAL.PDF
%
% License:
%  Copyright (c) 2011-12 Donald G. McLaren and Aaron Schultz
%   All rights reserved.
%
%    Redistribution, with or without modification, is permitted provided that the following conditions are met:
%    	1. Redistributions must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
%	2. All advertising materials mentioning features or use of this software must display the following acknowledgement:
%	       	This product includes software developed by the Harvard Aging Brain Project (NIH-P01-AG036694), NIH-R01-AG027435, and The General Hospital Corp.
%	3. Neither the Harvard Aging Brain Project nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
%	4. You are not permitted under this License to use these files commercially. Use for which any financial return is received shall be defined as commercial use, and includes (1) integration of all or part
%           of the source code or the Software into a product for sale or license by or on behalf of Licensee to third parties or (2) use of the Software or any derivative of it for research with the final
%           aim of developing software products for sale or license to a third party or (3) use of the Software or any derivative of it for research with the final aim of developing non-software products for
%           sale or license to a third party.
%	5. Use of the Software to provide service to an external organization for which payment is received (e.g. contract research) is permissible.
%
%	THIS SOFTWARE IS PROVIDED BY DONALD G. MCLAREN (mclaren@nmr.mgh.harvard.edu) AND AARON SCHULTZ (aschultz@nmr.mgh.harvard.edu) ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
%   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
%   OR CONSEQUENTIAL %DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
%   LIABILITY, WHETHER IN CONTRACT, %STRICT LIABILITY, OR  TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%   Licenses related to using various atlases are described in Peak_Nii_Atlases.PDF
%
%   For the program in general, please contact mclaren@nmr.mgh.harvard.edu
%
%   peak_nii.v6 -- Last modified on 02/11/2012 by Donald G. McLaren, PhD
%   peak_nii.v7 -- Last modified on 05/20/2014 by Donald G. McLaren, PhD
%   (mclaren@nmr.mgh.harvard.edu)
%   Wisconsin Alzheimer's Disease Research Center - Imaging Core, Univ. of
%   Wisconsin - Madison
%   Neuroscience Training Program and Department of Medicine, Univ. of
%   Wisconsin - Madison
%   GRECC, William S. Middleton Memorial Veteren's Hospital, Madison, WI
%   GRECC, Bedford VAMC
%   Department of Neurology, Massachusetts General Hospital and Havard
%   Medical School
%
%   For the program in general, please contact mclaren@nmr.mgh.harvard.edu
%

%% Program begins here
try
    if ~strcmp(spm('Ver'),'SPM8') && ~strcmp(spm('Ver'),'SPM12') % edit KAT from SPM12b to SPM12
        disp('PROGRAM ABORTED:')
        disp('  You must use SPM8/SPM12b to process your data; however, you can use SPM.mat files')
        disp('  generated with SPM2 or SPM5. In these cases, simply specify the option SPMver')
        disp('  in single qoutes followed by a comma and the version number.')
        disp(' ')
        disp('Make sure to add SPM8 to your MATLAB path before re-running.')
        return
    else
        addpath(fileparts(which('spm')))
    end
catch
    disp('PROGRAM ABORTED:')
    disp('  You must use SPM8 to process your data; however, you can use SPM.mat files')
    disp('  generated with SPM2 or SPM5. In these cases, simply specify the option SPMver')
    disp('  in single qoutes followed by a comma and the version number.')
    disp(' ')
    disp('Make sure to add SPM8 to your MATLAB path before re-running.')
    return
end

%%Placeholder outputs
voxels=[];
regions=[];
voxelstats=[];
clusterstats=[];
sigthresh=cell(6,1);
sigthresh{1,1}='FWEp: '; sigthresh{2,1}='FDRp: '; sigthresh{3,1}='FDRpk18: '; sigthresh{4,1}='FDRpk26: '; sigthresh{5,1}='FWEc: '; sigthresh{6,1}='FDRc: ';

%% Check inputs
if exist(image,'file')==2
    I1=spm_vol(image);
    infoI1=I1;
    [Iorig,voxelcoord]=spm_read_vols(I1);
    if nansum(nansum(nansum(abs(Iorig))))==0
        error(['Error: ' image ' is all zeros or all NaNs'])
    end
else
    error(['File ' image ' does not exist'])
end
if nargin==2
    if ischar(mapparameters) && exist(mapparameters,'file')==2
        mapparameters=load(mapparameters);
    end
    if ~isstruct(mapparameters)
        error('Mapparameters is not a structure OR not a file that contains a structure');
    end
else
    error('Mapparameters must be specified as a file or a structure');
end

[mapparameters, errors, errorval]=peak_nii_inputs(mapparameters,infoI1.fname,nargout);
if isfield(mapparameters,'voxel')
    if size(mapparameters.voxel,2)==3
        mapparameters.voxel=mapparameters.voxel;
    elseif size(mapparameters.voxel,1)==3
        mapparameters.voxel=mapparameters.voxel';
    else
        disp('mapparameters.voxel is not a voxel.')
    end
end
if ~isempty(errorval) || ~isempty(errors)
    disp('There was an error.')
    disp(errorval)
    if size(errors)>1
        for ii=1:size(errors)-1
            disp(errors{ii})
        end
        error(errors{size(errors)})
    else
        error(errors{1})
    end
end
UID=mapparameters.UID;
FIVEF=mapparameters.FIVE;
%% Read in data and mask (if available)
if strcmpi(mapparameters.sign,'neg')
    Iorig=-1.*Iorig;
    disp(['Threshold is:-' num2str(mapparameters.thresh)])
    mapparameters.thresh2=mapparameters.thresh*-1;
else
    disp(['Threshold is:' num2str(mapparameters.thresh)])
    mapparameters.thresh2=mapparameters.thresh;
end

if ~isempty(mapparameters.mask)
    I2=spm_vol(mapparameters.mask);
    infoI2=I2;
    if infoI1.mat==infoI2.mat
        if infoI1.dim==infoI2.dim
            I2=spm_read_vols(I2);
        else
            v = I2;
            [XYZ(1,:), XYZ(2,:), XYZ(3,:)]=ind2sub(I1.dim(1:3),1:prod(I1.dim(1:3)));
            I2 = spm_data_read(v,'xyz',v.mat\I1.mat*[XYZ; ones(1,size(XYZ,2))]);
         end
    else
        v = I2;
        [XYZ(1,:), XYZ(2,:), XYZ(3,:)]=ind2sub(I1.dim(1:3),1:prod(I1.dim(1:3)));
        I2 = spm_data_read(v,'xyz',v.mat\I1.mat*[XYZ; ones(1,size(XYZ,2))]);
    end
    I2=(I2>0)+(I2<0); % Ensures that the mask is binary
    I2(I2==0)=NaN; % Since 0 can be used in computations, convert 0s in mask to NaN.
    I=Iorig; %Copy original data
    I(isnan(I2))=NaN; %Mask out value outside of the mask with NaN
   
    %% Mask Region file
    if ~isempty(mapparameters.label.source)
        try
            mapparameters.label.rf.img=mapparameters.label.rf.img.*(I2~=0);
        catch
            v = mapparameters.label.rf.hdr;
            [XYZ(1,:), XYZ(2,:), XYZ(3,:)]=ind2sub(I1.dim(1:3),1:prod(I1.dim(1:3)));
            AtlasMask = spm_data_read(v,'xyz',v.mat\I1.mat*[XYZ; ones(1,size(XYZ,2))]);
            mapparameters.label.rf.XYZmm=XYZ;
            mapparameters.label.rf.img=zeros(size(I));
            mapparameters.label.rf.img=reshape(AtlasMask.*(I2>0),size(I));
        end
    end
else
    I=Iorig;
end

%% Program begins here
% Get all possible p-values
if mapparameters.SV
    realI=I(~isnan(I));
    realI=realI(realI~=0);
    SV=numel(realI);
else
    realI=Iorig(~isnan(Iorig));
    realI=realI(realI~=0);
    SV=numel(realI); %Search space
end

if strcmpi(mapparameters.type,'T')
    mapparameters.type='T';%compatibility with spm commands
    if ~isempty(mapparameters.df1)
        QPs=sort(1-spm_Tcdf(realI,mapparameters.df1)); %uncorrected P values in searched volume (for voxel FDR) - not the masked volume
        sigthresh{2,1}=[sigthresh{2,1} num2str(spm_uc_FDR(mapparameters.threshc,[1 mapparameters.df1],mapparameters.type,1,QPs)) ',' num2str(1-spm_Tcdf(spm_uc_FDR(mapparameters.threshc,[1 mapparameters.df1],mapparameters.type,1,QPs),mapparameters.df1))];
    else
        sigthresh{2,1}='FDRp: Not Computed. No df provided.'
    end
elseif strcmpi(mapparameters.type,'F')
    mapparameters.type='F';%compatibility with spm commands
    if ~isempty(mapparameters.df1) && ~isempty(mapparameters.df2)
        QPs=sort(1-spm_Fcdf(realI,mapparameters.df1,mapparameters.df2)); %uncorrected P values in searched volume (for voxel FDR) - not the masked volume
        sigthresh{2,1}=[sigthresh{2,1} num2str(spm_uc_FDR(mapparameters.threshc,[mapparameters.df1 mapparameters.df2],mapparameters.type,1,QPs)) ',' num2str(1-spm_Fcdf(spm_uc_FDR(mapparameters.threshc,[mapparameters.df1 mapparameters.df2],mapparameters.type,1,QPs),mapparameters.df1, mapparameters.df2))];
    else
        sigthresh{2,1}='FDRp: Not Computed. No df provided.'
    end
elseif strcmpi(mapparameters.type,'Z')
    mapparameters.type='Z';%compatibility with spm commands
    QPs=sort(1-spm_Ncdf(realI,0,1)); %uncorrected P values in searched volume (for voxel FDR) - not the masked volume
    sigthresh{2,1}=[sigthresh{2,1} num2str(spm_uc_FDR(mapparameters.threshc,[NaN NaN],mapparameters.type,1,QPs)) ',' num2str(1-spm_Ncdf(spm_uc_FDR(mapparameters.threshc,[NaN NaN],mapparameters.type,1,QPs),0,1))];
end

ind=find(I>mapparameters.thresh); %#ok<*EFIND> %Masked file
if isempty(ind)
    voxels=[]; regions={};
    disp(['NO MAXIMA ABOVE ' num2str(mapparameters.thresh) '.'])
    if mapparameters.exact==1
        disp('To find the cluster in this subject, please set thresh to 0')
        return
    else
        return
    end
end

[L(1,:),L(2,:),L(3,:)]=ind2sub(infoI1.dim,ind);
%Cluster signficant voxels
A=peakcluster(L,mapparameters.conn,infoI1); % A is the cluster of each voxel
A=transpose(A);
n=hist(A,1:max(A));
if max(n)<mapparameters.cluster
    voxels=[]; regions={};
    display(['NO CLUSTERS LARGER THAN ' num2str(mapparameters.cluster) ' voxels.'])
    if mapparameters.exact==1
        disp(['The largest cluster in this subject @ ' num2str(mapparameters.thresh2) 'is ' num2str(max(n)) 'voxels.'])
        disp('To find the cluster in this subject, please change the cluster size or threshold.')
    end
    return
end
clear L A n ind

if FIVEF
    iterrange=1;
else
    iterrange=[1 2];
end


for iter=iterrange
    if mapparameters.SV
        Iuse=I;
    elseif iter==1
        Iuse=Iorig;
    else
        Iuse=I;
    end
    
    %Find significant voxels
    ind=find(Iuse>mapparameters.thresh);
    L=[];
    [L(1,:),L(2,:),L(3,:)]=ind2sub(infoI1.dim,ind);
    
    %Cluster signficant voxels
    A=peakcluster(L,mapparameters.conn,infoI1); % A is the cluster of each voxel
    A=transpose(A);
    n=hist(A,1:max(A));
    if iter==1 && isfield(mapparameters,'RESELS')
        FWHM=mapparameters.FWHM(infoI1.dim>0);
        V2R=1/prod(FWHM);
        if strcmpi(mapparameters.type,'T') || strcmpi(mapparameters.type,'F')
            Pk=NaN(length(n),1);
            Pc=NaN(length(n),1); 
            if strcmpi(mapparameters.type,'T')
                DF=[1 mapparameters.df1];
            else
                DF=[mapparameters.df1 mapparameters.df2];
            end
            keyboard
            for ii = 1:length(n)
                [Pk(ii), Pc(ii)] = spm_P_RF(1,n(ii)*V2R,mapparameters.thresh,DF,mapparameters.type,mapparameters.RESELS,1);
            end
            QPc=sort(Pc,'ascend')';
            [Pk, J]  = sort(Pk, 'ascend');
            Ifwe        = find(Pk <= mapparameters.threshc, 1, 'last');
            if isempty(Ifwe)
                sigthresh{5,1}=[sigthresh{5,1} 'Inf'];
            else
                sigthresh{5,1}=[sigthresh{5,1} num2str(n(J(Ifwe)))];
            end
            Fi       = (1:length(Pc))/length(Pc)*mapparameters.threshc/1;%cV       = 1;    % Benjamini & Yeuketeli cV for independence/PosRegDep case
            Ifdr        = find(QPc <= Fi, 1, 'last');
            if isempty(Ifdr)
                sigthresh{6,1}=[sigthresh{6,1} 'Inf'];
            else
                sigthresh{6,1}=[sigthresh{6,1} num2str(n(J(Ifdr)))];
            end
            clear Pk Pc J Ifdr Ifwe
        else
            sigthresh{5,1}=[sigthresh{5,1} 'Only available for T/F-tests.'];
            sigthresh{6,1}=[sigthresh{6,1} 'Only available for T/F-tests.'];
        end
    end
    
    if iter==2
        for ii=1:size(A,1)
            if n(A(ii))<mapparameters.cluster % removes clusters smaller than extent threshold
                A(ii,1:2)=NaN;
            else
                A(ii,1:2)=[n(A(ii)) A(ii,1)];
            end
        end
    end
    % Combine A (cluster labels) and L (voxel indicies)
    L=L';
    A(:,3:5)=L(:,1:3);
    
    if ~isfield(mapparameters,'voxel')
    else
        for vv=1:size(mapparameters.voxel,1)
            x=spm_XYZreg('NearestXYZ',mapparameters.voxel(vv,:),voxelcoord);
            xM=round(infoI1.mat \ [x; 1]);
            indvox=find(((A(:,3)==xM(1))+(A(:,4)==xM(2))+(A(:,5)==xM(3)))==3);
            if isempty(indvox) && size(mapparameters.voxel,1)==1
                disp('voxel is not in a cluster');
                return
            elseif isempty(indvox)
                continue
            else
            end
            Btmp=A(A(:,1)==A(indvox,1),:); %finds current cluster
            Btmp(:,2)=vv; %label it as cluster 1
            try
                B=[B;Btmp];
            catch
                B=Btmp;
            end
            clear Btmp
        end
        try
            A2=B;
        catch
            disp('no voxels are not in a cluster');
            voxels=-1;
            return;
        end
    end
    
    % Save clusters
    if FIVEF
        T=peakcluster(transpose(A(:,3:5)),mapparameters.conn,infoI1,[pwd filesep 'tmp']);
        A(:,2)=T(:,1); clear T
        A=unique(A(:,1:2),'rows','first');
        A(:,1)=n';
        voxelsT=[A(:,1) NaN(size(A,1),5) A(:,2)];
        Iclust=spm_read_vols(spm_vol([pwd filesep 'tmp_clusters.nii']));
    else
        T=peakcluster(transpose(A(:,3:5)),mapparameters.conn,infoI1,[mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname]);
        A(:,2)=T(:,1); clear T    % Save significant data
        Iclust=spm_read_vols(spm_vol([mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_clusters.nii']));
        if isfield(mapparameters,'voxel')
            infoI1.fname='temp_cluster.nii';
            infoI1.descrip='temp cluster(s)';
            infoI1.pinfo=[1 0 0]';
            vol=zeros(infoI1.dim(1),infoI1.dim(2),infoI1.dim(3));
            for ii=1:size(A2,1)
                vol(A2(ii,3),A2(ii,4),A2(ii,5))=A2(ii,2);
            end
            spm_write_vol(infoI1,vol);
        end
    end
    
    % Find all peaks, only look at current cluster to determine the peak
    if mapparameters.clustercenter
        for ii=1:numel(n)
            coords = find(vol == ii);
            [out{1:3}] = ind2sub(size(vol),coords);
            ctr_v = mean(cell2mat(out),1);
            ctr_mm = (infoI1.mat(1:3,:) * [ ctr_v 1]')';
            ctr_v = round(ctr_v);
            voxelsT(ii,1)=NaN;
            voxelsT(ii,2)=Iuse(ind(INDEX(ii)));
            voxelsT(ii,3)=ctr_v(1);
            voxelsT(ii,4)=ctr_v(2);
            voxelsT(ii,5)=ctr_v(3);
            voxelsT(ii,6)=NaN;
            voxelsT(ii,7)=A(INDEX(ii),2);
            voxelsT(ii,8)=2; %Using the cluster cluster.
        end
    else
        INDEX18=[];
        INDEX26=[];
        if iter==1
            if mapparameters.conn==26
                INDEX18 = peak_get_lm18(Iuse,L');
                INDEX26 = peak_get_lm26(Iuse,L');
                voxelsT26=Iuse(ind(INDEX26));
            else
                INDEX18 = peak_get_lm18(Iuse,L');
                for ii=1:max(A(:,2))
                    ind2=find(Iclust==ii);
                    L2=[];
                    [L2(1,:),L2(2,:),L2(3,:)]=ind2sub(infoI1.dim,ind2);
                    INDEX26 =[INDEX26 ind2(peak_get_lm26(Iuse,L2))'];
                end
                voxelsT26=Iuse(INDEX26);
            end
            voxelsT18=Iuse(ind(INDEX18));
        else
            INDEX26_bad=[];
            for ii=1:max(A(:,2))
                ind2=find(Iclust==ii);
                L2=[];
                [L2(1,:),L2(2,:),L2(3,:)]=ind2sub(infoI1.dim,ind2);
                tmp18=ind2(peak_get_lm18(Iuse,L2))';
                tmp26=ind2(peak_get_lm26(Iuse,L2))';
                is26=ismember(tmp18,tmp26);
                INDEX18=[INDEX18 tmp18];
                INDEX26=[INDEX26 ~is26];
                clear tmp18 tmp26
            end
            [jnk,INDEX]=ismember(INDEX18,ind); clear jnk
            voxelsT=zeros(numel(INDEX),7);
            for ii=1:numel(INDEX)
                voxelsT(ii,1)=A(INDEX(ii),1);
                voxelsT(ii,2)=Iuse(ind(INDEX(ii)));
                voxelsT(ii,3)=voxelcoord(1,ind(INDEX(ii)));
                voxelsT(ii,4)=voxelcoord(2,ind(INDEX(ii)));
                voxelsT(ii,5)=voxelcoord(3,ind(INDEX(ii)));
                voxelsT(ii,6)=1;
                voxelsT(ii,7)=A(INDEX(ii),2);
                voxelsT(ii,8)=1;% peak with 26 neighbors, set to zero if not on the next line.
            end
            voxelsT(INDEX26==0,8)=0; % not a peak with 26 neighbors
            %Remove small clusters
            voxelsT=voxelsT(abs(voxelsT(:,1))>=mapparameters.cluster,:);
            % FUTURE FEATURE: Non-stationary correction
            %             if mapparameters.NS.do==1
            %                 mRPV=nanmean(spm_get_data(mapparameters.rpv,find(Iclust~=0)));
            %                 for cc=1:max(voxelsT(:,7))
            %                 %% Get cluster and sample rpv image
            %                     rind=find(Iclust==ii);
            %                     rpv_vals = spm_get_data(maparameters.rpv,rind);
            %                 %% SPM8 Resel Computation
            %                     %-Compute average of valid LKC measures for i-th region
            %                     %----------------------------------------------------------
            %                     valid = ~isnan(rpv_vals);
            %                     if any(valid)
            %                         LKC = sum(rpv_vals(valid)) / sum(valid);
            %                     else
            %                         LKC = 1/prod(mapparameters.FWHM); % fall back to whole-brain resel density
            %                     end
            %
            %                     %-Intrinsic volume (with surface correction)
            %                     %----------------------------------------------------------
            %                     IV   = spm_resels([1 1 1],rind,'V');
            %                     IV   = IV*[1/2 2/3 2/3 1]';
            %                     voxelsT(:,9) = IV*LKC;
            %
            %                %% NS Resel Computation
            %                     if any(valid)
            %                         voxelsT(:,10) = (sum(rpv_vals(valid))/sum(valid))*length(rpv_vals);
            %                     else
            %                         voxelsT(:,10) = mRPV*length(rpv_vals);
            %                     end
            %                 end
            %             else
            %                 voxelsT(:,9)=NaN;
            %                 voxelsT(:,10)=NaN;
            %             end
        end
    end
    
    if ~FIVEF
        if isfield(mapparameters,'voxel')
            % Find the peakin the current cluster
            cc=unique(A2(:,2));
            voxelsT=zeros(numel(cc),5);
            if isfield(mapparameters,'exactvoxel') && mapparameters.exactvoxel==1
                for vv=1:numel(cc)
                    x=spm_XYZreg('NearestXYZ',mapparameters.voxel(vv,:),voxelcoord);
                    xM=round(infoI1.mat \ [x; 1]);
                    ind=find(((A2(:,3)==xM(1))+(A2(:,4)==xM(2))+(A2(:,5)==xM(3)))==3);
                    if ~isempty(ind)
                        voxind=sub2ind(infoI1.dim,A2(ind,3),A2(ind,4),A2(ind,5));
                        voxelsT(vv,1)=n(A2(ind,1));
                        voxelsT(vv,2)=I(voxind);
                        voxelsT(vv,3)=voxelcoord(1,voxind);
                        voxelsT(vv,4)=voxelcoord(2,voxind);
                        voxelsT(vv,5)=voxelcoord(3,voxind);
                        voxelsT(vv,6)=1;
                        voxelsT(vv,7)=A2(ind,1);
                        voxelsT(vv,8)=2; %Using specified voxel.
                    end
                end
            else
                for vv=1:numel(cc)
                    ind=sub2ind(infoI1.dim,A2(A2(:,2)==cc(vv),3),A2(A2(:,2)==cc(vv),4),A2(A2(:,2)==cc(vv),5));
                    if ~isempty(ind)
                        try
                            K=sum(voxelsT(1:vv-1,1));
                        catch
                            K=0;
                        end
                        maxind=find(I(ind)==max(I(ind)));
                        voxind=sub2ind(infoI1.dim,A2(maxind+K,3),A2(maxind+K,4),A2(maxind+K,5));
                        voxelsT(vv,1)=n(A2(maxind+K,1));
                        voxelsT(vv,2)=I(voxind);
                        voxelsT(vv,3)=voxelcoord(1,voxind);
                        voxelsT(vv,4)=voxelcoord(2,voxind);
                        voxelsT(vv,5)=voxelcoord(3,voxind);
                        voxelsT(vv,6)=1;
                        voxelsT(vv,7)=A2(maxind+K,1);
                        voxelsT(vv,8)=2; %Using specified voxel.
                    end
                end
            end
            voxelsT=unique(voxelsT,'rows');
            % Label Peaks
            if ~isempty(mapparameters.label.source)
                regions=regionname(voxelsT,mapparameters.label.rf,mapparameters.label.ROI,mapparameters.label.ROInames,mapparameters.label.nearest);
            end
            if strcmpi(mapparameters.type,'F')
                df=[mapparameters.df1 mapparameters.df2];
                [voxelstats,sigthresh]=calc_voxelstats(mapparameters,voxelsT,voxelsT18,voxelsT26,mapparameters.type,df,QPs,sigthresh,SV);
                cstats=1;
            elseif strcmpi(mapparameters.type,'T')
                df=[1 mapparameters.df1];
                [voxelstats,sigthresh]=calc_voxelstats(mapparameters,voxelsT,voxelsT18,voxelsT26,mapparameters.type,df,QPs,sigthresh,SV);
                cstats=1;
            elseif strcmpi(mapparameters.type,'Z')
                df=[];
                [voxelstats,sigthresh]=calc_voxelstats(mapparameters,voxelsT,voxelsT18,voxelsT26,mapparameters.type,df,QPs,sigthresh,SV);
                cstats=0;
            else
            end
            if isfield(mapparameters,'RESELS')
                try
                    clusterstats=calc_clusterstats(mapparameters,voxelsT,mapparameters.type,df,QPs,QPc,cstats);
                catch
                    clusterstats=calc_clusterstats(mapparameters,voxelsT,mapparameters.type,df,QPs,[],cstats);
                end
            end
            try
                savepeaks(mapparameters,regions,voxelsT,voxelstats,clusterstats,sigthresh);
            catch
                savepeaks(mapparameters,[],voxelsT,voxelstats,clusterstats,sigthresh);
            end
            try
                voxels={voxelsT regions(:,2)};
            catch
                voxels={voxelsT};
            end
            return
        end
    end
end

if ~FIVEF
    %Check number of peaks
    if size(voxelsT,1)>mapparameters.voxlimit
        voxelsT=sortrows(voxelsT,-2);
        voxelsT=voxelsT(1:mapparameters.voxlimit,:); % Limit peak voxels to mapparameters.voxlimit
    end
    
    % Sort table by cluster w/ max T then by T value within cluster (negative
    % data was inverted at beginning, so we are always looking for the max).
    uniqclust=unique(voxelsT(:,7));
    maxT=zeros(length(uniqclust),2);
    for ii=1:length(uniqclust)
        maxT(ii,1)=uniqclust(ii);
        maxT(ii,2)=max(voxelsT(voxelsT(:,7)==uniqclust(ii),2));
    end
    maxT=sortrows(maxT,-2);
    for ii=1:size(maxT,1)
        voxelsT(voxelsT(:,7)==maxT(ii,1),11)=ii;
    end
    voxelsT=sortrows(voxelsT,[11 -2]);
    [cluster,uniq,ind]=unique(voxelsT(:,11)); % get rows of each cluster
    if mapparameters.exact
        voxelsT(2:end,:)=[];
        A=A(A(:,2)==voxelsT(1,7),:); % Keeps most significant cluster
        voxind=zeros(size(A,1),1);
        for ii=1:size(A,1)
            voxind(ii)=sub2ind(infoI1.dim,A(ii,3),A(ii,4),A(ii,5));
            A(ii,6)=I(voxind(ii));
        end
        B=A; %in case eroding doesn't work
        while size(A,1)>mapparameters.cluster
            A(A(:,6)==min(A(:,6)),:)=[];
        end
        
        %check for a single cluster
        newclust=peakcluster(A(:,3:5)',mapparameters.conn,infoI1);
        if max(newclust)>1
            A=B; clear B;
            indmax=find(A(:,6)==max(A(:,6)));
            cluster=zeros(mapparameters.cluster,1);
            cluster(1)=voxind(indmax);
            %voxind is the voxel indices
            indsearch=[];
            for ii=1:(mapparameters.cluster-1)
                a={[A(indmax,3)-1:A(indmax,3)+1],[A(indmax,4)-1:A(indmax,4)+1],[A(indmax,5)-1:A(indmax,5)+1]};
                [xx yy zz]=ndgrid(a{:});
                possind=sub2ind(infoI1.dim,xx(:),yy(:),zz(:));
                addind=voxind(ismember(voxind,possind));
                indsearch=[indsearch addind']; clear addind; %#ok<AGROW>
                indsearch=setdiff(indsearch,cluster);
                indmax=find(A(:,6)==max(I(indsearch)));
                cluster(ii+1)=voxind(indmax);
            end
            A=A(ismember(voxind,cluster),:);
        end
        % Save clusters
        peakcluster2(A,voxelsT,infoI1,[mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname]);
        % Save significant data
        Iclust=spm_read_vols(spm_vol([mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_clusters.nii']));
        if strcmpi(mapparameters.sign,'neg')
            Ithresh=-1.*I.*(Iclust>0);
        else
            Ithresh=I.*(Iclust>0);
        end
        out=infoI1;
        out.fname=[mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '.nii'];
        out.descrip=['Thresholded Map @ thresh ' num2str(mapparameters.thresh2) ' and cluster extent ' num2str(mapparameters.cluster) ' in ' mapparameters.maskname];
        spm_write_vol(out,Ithresh);
        if strcmpi(mapparameters.sign,'neg')
            voxelsT(:,2)=-1*voxelsT(:,2);
        end
        voxelsT(:,7)=[];
        voxels={voxelsT};
        regions={};
        savepeaks(mapparameters,regions,voxelsT,voxelstats,clusterstats,sigthresh)
        return
    end
    
    %Collapse or eliminate peaks closer than a specified distance
    voxelsF=zeros(size(voxelsT,1),size(voxelsT,2));
    nn=[1 zeros(1,length(cluster)-1)];
    for numclust=1:length(cluster)
        Distance=eps;
        voxelsC=voxelsT(ind==numclust,:);
        while min(min(Distance(Distance>0)))<mapparameters.separation
            [voxelsC,Distance]=vox_distance(voxelsC);
            minD=min(min(Distance(Distance>0)));
            if minD<mapparameters.separation
                min_ind=find(Distance==(min(min(Distance(Distance>0)))));
                [ii,jj]=ind2sub(size(Distance),min_ind(1));
                if mapparameters.SPM==1
                    voxelsC(ii,:)=NaN; % elimate peak
                else
                    voxelsC(jj,1)=voxelsC(jj,1);
                    voxelsC(jj,2)=voxelsC(jj,2);
                    voxelsC(jj,3)=((voxelsC(jj,3).*voxelsC(jj,6))+(voxelsC(ii,3).*voxelsC(ii,6)))/(voxelsC(jj,6)+voxelsC(ii,6)); % avg coordinate
                    voxelsC(jj,4)=((voxelsC(jj,4).*voxelsC(jj,6))+(voxelsC(ii,4).*voxelsC(ii,6)))/(voxelsC(jj,6)+voxelsC(ii,6)); % avg coordinate
                    voxelsC(jj,5)=((voxelsC(jj,5).*voxelsC(jj,6))+(voxelsC(ii,5).*voxelsC(ii,6)))/(voxelsC(jj,6)+voxelsC(ii,6)); % avg coordinate
                    voxelsC(jj,6)=voxelsC(jj,6)+voxelsC(ii,6);
                    voxelsC(jj,7)=voxelsC(jj,7);
                    voxelsC(jj,8)=voxelsC(jj,8);
                    %voxelsC(jj,9)=voxelsC(jj,9); % resel counts
                    %voxelsC(jj,10)=voxelsC(jj,10); % resel counts
                    voxelsC(jj,11)=voxelsC(jj,11);
                    voxelsC(ii,:)=NaN; % eliminate second peak
                end
                voxelsC(any(isnan(voxelsC),2),:) = [];
            end
        end
        try
            nn(numclust+1)=nn(numclust)+size(voxelsC,1);
        end
        voxelsF(nn(numclust):nn(numclust)+size(voxelsC,1)-1,:)=voxelsC;
    end
    voxelsT=voxelsF(any(voxelsF'),:);
    clear voxelsF voxelsC nn
    
    % Label Peaks
    if ~isempty(mapparameters.label.source)
        [regions]=regionname(voxelsT,mapparameters.label.rf,mapparameters.label.ROI,mapparameters.label.ROInames,mapparameters.label.nearest);
    end
    
    % Modify T-values for negative
    if strcmpi(mapparameters.sign,'neg')
        voxelsT(:,2)=-1*voxelsT(:,2);
    end
    % Output an image of the peak coordinates (peak number and cluster number)
    peakcluster2(A,voxelsT,infoI1,[mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname]); %outputs revised cluster numbers
    Iclust=spm_read_vols(spm_vol([mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_clusters.nii']));
    if ~isempty(mapparameters.sphere) || ~isempty(mapparameters.clustersphere)% edit KAT from isempty(mapparameters.sphere) && isempty(mapparameters.clustersphere)
        if strcmpi(mapparameters.sign,'neg')
            Ithresh=-1.*I.*(Iclust>0);
        else
            Ithresh=I.*(Iclust>0);
        end
        out=infoI1;
        out.fname=[mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '.nii'];
        out.descrip=['Thresholded Map @ thresh ' num2str(mapparameters.thresh2) ' and cluster extent ' num2str(mapparameters.cluster) ' in ' mapparameters.maskname];
        spm_write_vol(out,Ithresh);
    end
    Iclusthdr=spm_vol([mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_clusters.nii']);
    [Iclust, Ixyz]=spm_read_vols(Iclusthdr);
    Ipeak=Iclust.*0;
    Ipeak2=Ipeak;
    
    if ~isempty(mapparameters.sphere) || ~isempty(mapparameters.clustersphere)
        [simg XYZmmY]=spm_read_vols(Iclusthdr);
        sphereimg=simg*0;
        xY.def='sphere';
        if ~isempty(mapparameters.sphere)
            xY.spec=mapparameters.sphere;
        else
            xY.spec=mapparameters.clustersphere;
        end
        for ii=size(voxelsT,1):-1:1
            xY.xyz=voxelsT(ii,3:5)';
            [xY, XYZmm, j] = spm_ROI(xY, XYZmmY);
            sphereimg(j)=ii;
        end
        if ~isempty(mapparameters.clustersphere)
            sphereimg=(Iclust>0).*sphereimg;
        end
        Ithresh(sphereimg<=0)=0; Ithresh(isnan(sphereimg))=0;
        spm_write_vol(Iclusthdr,sphereimg);
        
        
        spm_write_vol(out,Ithresh);
        n2=hist(sphereimg(:),0:max(sphereimg(:)));
        voxelsT(:,1)=n2(2:end);
        voxelsT(:,12)=1:size(voxelsT,1);
    end
    
    
    %Try to determine orientation
    oris = [[Iclusthdr.mat(1,1) Iclusthdr.mat(2,2) Iclusthdr.mat(3,3)];...
        [Iclusthdr.mat(1,1) Iclusthdr.mat(3,2) Iclusthdr.mat(2,3)];...
        [Iclusthdr.mat(2,1) Iclusthdr.mat(1,2) Iclusthdr.mat(3,3)];...
        [Iclusthdr.mat(2,1) Iclusthdr.mat(3,2) Iclusthdr.mat(1,3)];...
        [Iclusthdr.mat(3,1) Iclusthdr.mat(1,2) Iclusthdr.mat(2,3)];...
        [Iclusthdr.mat(3,1) Iclusthdr.mat(2,2) Iclusthdr.mat(1,3)]];
    ori = find(mean(abs(oris)>.000001',2) == 1);
    if numel(ori)>1 % This part has not been fully tested
        oristmp=oris;
        tmp(1)=max(abs(diff([1 1 1 1; 2 1 1 1]*Iclusthdr.mat')));
        oristmp(abs(oris)==tmp(1))=1;
        tmp(2)=max(abs(diff([1 1 1 1; 1 2 1 1]*Iclusthdr.mat')));
        oristmp(abs(oris)==tmp(2))=1;
        tmp(3)=max(abs(diff([1 1 1 1; 1 1 2 1]*Iclusthdr.mat')));
        oristmp(abs(oris)==tmp(3))=1;
        ori = find(mean(oristmp,2)==1);
    end
    
    %Determine cross hair size, if value is infite, crosshairs are 2 voxels
    a(1)=ceil(2*2/abs(oris(ori,1)));
    a(2)=ceil(2*2/abs(oris(ori,2)));
    a(3)=ceil(2*2/abs(oris(ori,3)));
    a(~isfinite(a))=2;
    for ii=1:size(voxelsT,1)
        [Ipeakxyz,Ipeakind] = spm_XYZreg('NearestXYZ',voxelsT(ii,3:5),Ixyz);
        [Ix,Iy,Iz]=ind2sub(size(Ipeak),Ipeakind);
        
        if (Ix-a(1))<=0 && Ix+a(1)<=Iclusthdr.dim(1)
            Ipeak(1:Ix+a(1),Iy,Iz)=ii;
        elseif (Ix-a(1))<=0
            Ipeak(1:Iclusthdr.dim(1),Iy,Iz)=ii;
        else
            Ipeak(Ix-a(1):Ix+a(1),Iy,Iz)=ii;
        end
        if (Iy-a(2))<=0 && Iy+a(2)<=Iclusthdr.dim(2)
            Ipeak(Ix,1:Iy+a(2),Iz)=ii;
        elseif (Iy-a(2))<=0
            Ipeak(Ix,1:Iclusthdr.dim(2),Iz)=ii;
        else
            Ipeak(Ix,Iy-a(2):Iy+a(2),Iz)=ii;
        end
        if (Iz-a(3))<=0 && Iz+a(3)<=Iclusthdr.dim(3)
            Ipeak(Ix,Iy,1:Iz+a(3))=ii;
        elseif (Iz-a(3))<=0
            Ipeak(Ix,Iy,1:Iclusthdr.dim(3))=ii;
        else
            Ipeak(Ix,Iy,Iz-a(3):Iz+a(3))=ii;
        end
        if (Ix-a(1))<=0 && Ix+a(1)<=Iclusthdr.dim(1)
            Ipeak2(1:Ix+a(1),Iy,Iz)=voxelsT(ii,11);
        elseif (Ix-a(1))<=0
            Ipeak2(1:Iclusthdr.dim(1),Iy,Iz)=voxelsT(ii,11);
        else
            Ipeak2(Ix-a(1):Ix+a(1),Iy,Iz)=voxelsT(ii,11);
        end
        if (Iy-a(2))<=0 && Iy+a(2)<=Iclusthdr.dim(2)
            Ipeak2(Ix,1:Iy+a(2),Iz)=voxelsT(ii,11);
        elseif (Iy-a(2))<=0
            Ipeak2(Ix,1:Iclusthdr.dim(2),Iz)=voxelsT(ii,11);
        else
            Ipeak2(Ix,Iy-a(2):Iy+a(2),Iz)=voxelsT(ii,11);
        end
        if (Iz-a(3))<=0 && Iz+a(3)<=Iclusthdr.dim(3)
            Ipeak2(Ix,Iy,1:Iz+a(3))=voxelsT(ii,11);
        elseif (Iz-a(3))<=0
            Ipeak2(Ix,Iy,1:Iclusthdr.dim(3))=voxelsT(ii,11);
        else
            Ipeak2(Ix,Iy,Iz-a(3):Iz+a(3))=voxelsT(ii,11);
        end
    end
    out=infoI1;
    out.fname=[mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_peaknumber.nii'];
    out.descrip=['Peaks of Thresholded Map @ thresh ' num2str(mapparameters.thresh2) ' and cluster extent ' num2str(mapparameters.cluster) ' in ' mapparameters.maskname];
    out.pinfo(1)=1;
    spm_write_vol(out,Ipeak);
    out=infoI1;
    out.pinfo(1)=1;
    out.fname=[mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_peakcluster.nii'];
    out.descrip=['Peaks of Thresholded Map @ thresh ' num2str(mapparameters.thresh2) ' and cluster extent ' num2str(mapparameters.cluster) ' in ' mapparameters.maskname];
    spm_write_vol(out,Ipeak2);
    %voxelsT(:,7)=[]; Don't want to strip out raw cluster numbers.
end

% Compute voxel and cluster stats
STAT=mapparameters.type;
if ~isempty(mapparameters.df1)
    vstats=1; %Compute voxel stats
    cstats=1; %Compute cluster stats
else
    vstats=0; %Don't Compute voxel stats
    cstats=0; %Don't Compute cluster stats
end
if strcmpi(STAT,'F')
    df=[mapparameters.df1 mapparameters.df2];
elseif strcmpi(STAT,'T')
    df=[1 mapparameters.df1];
elseif strcmpi(STAT,'Z')
    df=[];
    cstats=0;
else
    vstats=0;
    cstats=0;
end
if ~isfield(mapparameters,'RESELS')
    cstats=0;
end
if strcmp(mapparameters.sign,'neg') && vstats
    voxelsT(:,2)=-voxelsT(:,2);
end

% Fill in voxelstats
%--------------------------------------------------------------
if vstats
    [voxelstats,sigthresh]=calc_voxelstats(mapparameters,voxelsT,voxelsT18,voxelsT26,STAT,df,QPs,sigthresh,SV,FIVEF);
end

% Fill in clusterstats
%--------------------------------------------------------------
if cstats && ~FIVEF
    try
        clusterstats=calc_clusterstats(mapparameters,voxelsT,STAT,df,QPs,QPc,cstats);
    catch
        clusterstats=calc_clusterstats(mapparameters,voxelsT,STAT,df,QPs,[],cstats);
    end
end

if ~FIVEF
    voxelsT(:,1)=abs(voxelsT(:,1));
    if strcmp(mapparameters.sign,'neg') && vstats
        voxelsT(:,2)=-voxelsT(:,2);
        voxelstats(:,5)=-voxelstats(:,5);
    end
    
    try
        savepeaks(mapparameters,regions,voxelsT,voxelstats,clusterstats,sigthresh);
    catch
        savepeaks(mapparameters,[],voxelsT,voxelstats,clusterstats,sigthresh);
    end
    
    try
        voxels={voxelsT regions(:,2)};
    catch
        voxels={voxelsT};
    end
end

% edit KAT commented
% if ~FIVEF && ~isempty(mapparameters.label.source)
%     AnatomicalDistTable=AnatomicalDist([mapparameters.out '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_clusters.nii'],mapparameters.label.source); %#ok<*NASGU>
%     [path, filename]=fileparts(mapparameters.out);
%     if isempty(path)
%         path=pwd;
%     end
%     save([path filesep 'AnatDist_' filename '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_' mapparameters.label.source '.mat'],'AnatomicalDistTable')
%     %movefile('tmp.txt',[path filesep 'AnatReport_' filename '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_' mapparameters.label.source '.txt'])
%     clear path filename
% end

if mapparameters.savecorrected.do==1
    for tt=1:numel(mapparameters.savecorrected.type)
        cmapparameters=mapparameters;
        cmapparameters.correctedloop=1;
        cmapparameters.UID=[UID '_' mapparameters.savecorrected.type{tt}, '_corr' num2str(mapparameters.threshc)];
        if strcmpi(mapparameters.savecorrected.type{tt},'cFWE')
            [jnk,tmp]=strtok(sigthresh{5,1},':');
            cmapparameters.cluster=str2num(tmp(2:end));
            cmapparameters.correction=mapparameters.savecorrected.type{tt};
            cmapparameters.correctionthresh=mapparameters.threshc;
        elseif strcmpi(mapparameters.savecorrected.type{tt},'cFDR')
            [jnk,tmp]=strtok(sigthresh{6,1},':');
            cmapparameters.cluster=str2num(tmp(2:end));
            cmapparameters.correction=mapparameters.savecorrected.type{tt};
            cmapparameters.correctionthresh=mapparameters.threshc;
        elseif strcmpi(mapparameters.savecorrected.type{tt},'vFWE')
            [jnk,tmp]=strtok(sigthresh{1,1},':');
            tmp=strtok(tmp,',');
            cmapparameters.thresh=str2num(tmp(2:end));
            if ~mapparameters.savecorrected.changecluster
                cmapparameters.cluster=0;
            end
            cmapparameters.correction=mapparameters.savecorrected.type{tt};
            cmapparameters.correctionthresh=mapparameters.threshc;
        elseif strcmpi(mapparameters.savecorrected.type{tt},'vFDR')
            [jnk,tmp]=strtok(sigthresh{2,1},':');
            tmp=strtok(tmp,',');
            cmapparameters.thresh=str2num(tmp(2:end));
            if ~mapparameters.savecorrected.changecluster
                cmapparameters.cluster=0;
            end
            cmapparameters.correction=mapparameters.savecorrected.type{tt};
            cmapparameters.correctionthresh=mapparameters.threshc;
        elseif strcmpi(mapparameters.savecorrected.type{tt},'tFDR26')
            [jnk,tmp]=strtok(sigthresh{4,1},':');
            cmapparameters.thresh=str2num(tmp(2:end));
            if ~mapparameters.savecorrected.changecluster
                cmapparameters.cluster=0;
            end
            cmapparameters.correction=mapparameters.savecorrected.type{tt};
            cmapparameters.correctionthresh=mapparameters.threshc;
        elseif strcmpi(mapparameters.savecorrected.type{tt},'tFDR18')
            [jnk,tmp]=strtok(sigthresh{3,1},':');
            cmapparameters.thresh=str2num(tmp(2:end));
            if ~mapparameters.savecorrected.changecluster
                cmapparameters.cluster=0;
            end
            cmapparameters.correction=mapparameters.savecorrected.type{tt};
            cmapparameters.correctionthresh=mapparameters.threshc;
        end
        [cvoxels cvoxelstats cclusterstats csigthresh cregions cmapparameters cUID]=peak_nii(image,cmapparameters);
    end
end
end

%% Embedded functions

%% Save Peaks
function savepeaks(mapparameters,regions,voxelsT,voxelstats,clusterstats,sigthresh)
[path,file,ext]=fileparts(mapparameters.out);
if ~isempty(path)
    save([path filesep 'Peak_' file ext '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '.mat'],'regions', 'voxelsT','mapparameters','voxelstats','clusterstats','sigthresh')
    save([path filesep 'Peak_' file ext '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_structure.mat'],'mapparameters')
else
    save(['Peak_' file ext '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '.mat'],'regions', 'voxelsT','mapparameters','voxelstats','clusterstats','sigthresh')
    save(['Peak_' file ext '_thresh' num2str(mapparameters.thresh2) '_extent' num2str(mapparameters.cluster) mapparameters.maskname '_structure.mat'],'mapparameters')
end
end

%% Vox_distance
function [N,Distance] = vox_distance(voxelsT)
% vox_distance compute the distance between local maxima in an image
% The input is expected to be an N-M matrix with columns 2,3,4 being X,Y,Z
% coordinates
%
% pdist is only available with Statistics Toolbox in recent versions of
% MATLAB, thus, the slower code is secondary if the toolbox is unavailable.
% Speed difference is dependent on cluster sizes, 3x at 1000 peaks.
N=sortrows(voxelsT,-1);
try
    Distance=squareform(pdist(N(:,3:5)));
catch
    Distance = zeros(size(N,1),size(N,1));
    for ii = 1:size(N,1);
        TmpD = zeros(size(N,1),3);
        for kk = 1:3;
            TmpD(:,kk) = (N(:,kk+2)-N(ii,kk+2)).^2;
        end
        TmpD = sqrt(sum(TmpD,2));
        Distance(:,ii) = TmpD;
    end
end
end

%% Peakcluster
function A=peakcluster(L,conn,infoI1,out)
dim = infoI1.dim;
vol = zeros(dim(1),dim(2),dim(3));
indx = sub2ind(dim,L(1,:)',L(2,:)',L(3,:)');
vol(indx) = 1;
[cci,num] = spm_bwlabel(vol,conn);
A = cci(indx');
if nargin==4
    infoI1.fname=[out '_clusters.nii'];
    infoI1.descrip='clusters';
    infoI1.pinfo=[1 0 0]';
    A=transpose(A);
    L=transpose(L);
    A(:,2:4)=L(:,1:3);
    vol=zeros(dim(1),dim(2),dim(3));
    for ii=1:size(A,1)
        vol(A(ii,2),A(ii,3),A(ii,4))=A(ii,1);
    end
    spm_write_vol(infoI1,vol);
end
end

%% Regionname
function [ROIinfo]=regionname(voxels,rf,ROI,ROInames,nearest)
ROIinfo=cell(size(voxels,1),2);
if nearest==0
    for jj=1:size(voxels,1)
        [xyz,ii] = spm_XYZreg('NearestXYZ',voxels(jj,3:5),rf.XYZmm); % use all voxels
        try
            ROIinfo{jj,1}=rf.img(ii);
            if ROIinfo{jj,1}~=0
                ROIind=find([ROI.ID]==ROIinfo{jj,1});
                ROIinfo{jj,2}=ROInames{ROIind};
            else
                ROIinfo{jj,2}='undefined';
            end
        catch
            ROIinfo{jj,1}=0;
            ROIinfo{jj,2}='undefined';
        end
    end
else
    nz_ind=find(rf.img>0);
    for jj=1:size(voxels,1)
        [xyz,j] = spm_XYZreg('NearestXYZ',voxels(jj,3:5),rf.XYZmm(:,nz_ind)); % use only voxels with a region greater than 0.
        try
            ii=nz_ind(j);
            if isempty(ii)
                invovkecatchstatement
            end
            [junk,D]=vox_distance([0 0 xyz';voxels(jj,1:5)]); % need to pad xyz, voxel is made to be 1x4 with 2-4 being coordianates
        catch
            D(1,2)=Inf;
        end
        if D(1,2)>8 % further than 5 mm from region
            ROIinfo{jj,1}=0;
            ROIinfo{jj,2}='undefined';
        else
            ROIinfo{jj,1}=rf.img(ii);
            if ROIinfo{jj,1}~=0
                ROIind=find([ROI.ID]==ROIinfo{jj,1});
                ROIinfo{jj,2}=ROInames{ROIind};
            else
                ROIinfo{jj,2}='undefined';
            end
        end
    end
end
end

%% Peakcluster2
function peakcluster2(A,voxelsT,infoI1,out)
dim = infoI1.dim;
vol = zeros(dim(1),dim(2),dim(3));
clusters=unique(voxelsT(:,11));
A(:,6)=-1*A(:,2); % label any small clusters (or clusters with no peaks due to elimination)
% A(:,1)==NaN --> Cluster was smaller than extent - will appear in Anat
% Table this way.
for ii=1:numel(clusters)
    firstvoxel=find(voxelsT(:,11)==ii);
    A(A(:,2)==voxelsT(firstvoxel(1),7),6)=ii;
end
if nargin==4
    infoI1.fname=[out '_clusters.nii'];
    infoI1.descrip='clusters';
    infoI1.pinfo=[1 0 0]';
    for ii=1:size(A,1)
        vol(A(ii,3),A(ii,4),A(ii,5))=A(ii,6);
    end
    spm_write_vol(infoI1,vol);
end
end

%% calc_voxelstats
function [voxelstats,sigthresh]=calc_voxelstats(mapparameters,voxelsT,voxelsT18,voxelsT26,STAT,df,QPs,sigthresh,SV,FIVEF)
if ~isfield(mapparameters,'RESELS')
    vstatsR=0;
else
    vstatsR=1;
    Pu=zeros(size(voxelsT,1),1);
    Qp=zeros(size(voxelsT,1),1);
    Qp1=zeros(size(voxelsT,1),1);
end
if ~FIVEF
    Pz=zeros(size(voxelsT,1),1);
    for ii=1:size(voxelsT,1)
        Pz(ii)      = spm_P(1,0,voxelsT(ii,2),df,STAT,1,1,numel(QPs));  % uncorrected p values
    end
    if Pz < eps*10
        Ze  = repmat(Inf,numel(Pz),1); % Edit kat from Inf 
    else
        Ze  = spm_invNcdf(1 - Pz);
    end
end
Qu=zeros(size(voxelsT,1),1);
if vstatsR
    [P,p,Eu] = spm_P_RF(1,0,mapparameters.thresh,df,STAT,mapparameters.RESELS,1);
    %Topological FDR
    Ez       = zeros(1,numel(voxelsT18));
    for i = 1:length(voxelsT18)
        [P,p,Ez(i)] = spm_P_RF(1,0,voxelsT18(i),df,STAT,mapparameters.RESELS,1);
    end
    [Ps, J]  = sort(Ez ./ Eu, 'ascend');
    QPp18=Ps';
    Fi       = (1:length(Ps))/length(Ps)*mapparameters.threshc/1;%cV       = 1;    % Benjamini & Yeuketeli cV for independence/PosRegDep case
    Ifdr        = find(QPp18' <= Fi, 1, 'last');
    if isempty(Ifdr)
        sigthresh{3,1}=[sigthresh{3,1} 'Inf'];
    else
        if strcmpi(STAT,'T')
            sigthresh{3,1}=[sigthresh{3,1} num2str(voxelsT18(J(Ifdr))) ',' num2str(1-spm_Tcdf(voxelsT18(J(Ifdr)),df(2)))];
        elseif strcmpi(STAT,'F')
            sigthresh{3,1}=[sigthresh{3,1} num2str(voxelsT18(J(Ifdr))) ',' num2str(1-spm_Fcdf(voxelsT18(J(Ifdr)),df))];
        elseif strcmpi(STAT,'Z')
            sigthresh{3,1}=[sigthresh{3,1} num2str(voxelsT18(J(Ifdr))) ',' num2str(1-spm_Ncdf(voxelsT18(J(Ifdr)),0,1))];
        else
            sigthresh{3,1}=[sigthresh{3,1} num2str(voxelsT18(J(Ifdr)))];
        end
    end
    % peak_nii topological correction (difference is in how peaks are
    % defined.
    Ez       = zeros(1,numel(voxelsT26));
    for i = 1:length(voxelsT26)
        [P,p,Ez(i)] = spm_P_RF(1,0,voxelsT26(i),df,STAT,mapparameters.RESELS,1);
    end
    [Ps, J]  = sort(Ez ./ Eu, 'ascend');
    QPp26=Ps';
    Fi       = (1:length(Ps))/length(Ps)*mapparameters.threshc/1;%cV       = 1;    % Benjamini & Yeuketeli cV for independence/PosRegDep case
    Ifdr        = find(QPp26' <= Fi, 1, 'last');
    if isempty(Ifdr)
        sigthresh{4,1}=[sigthresh{4,1} 'Inf'];
    else
        if strcmpi(STAT,'T')
            sigthresh{4,1}=[sigthresh{4,1} num2str(voxelsT26(J(Ifdr))) ',' num2str(1-spm_Tcdf(voxelsT26(J(Ifdr)),df(2)))];
        elseif strcmpi(STAT,'F')
            sigthresh{4,1}=[sigthresh{4,1} num2str(voxelsT26(J(Ifdr))) ',' num2str(1-spm_Fcdf(voxelsT26(J(Ifdr)),df))];
        elseif strcmpi(STAT,'Z')
            sigthresh{4,1}=[sigthresh{4,1} num2str(voxelsT26(J(Ifdr))) ',' num2str(1-spm_Ncdf(voxelsT26(J(Ifdr)),0,1))];
        else
            sigthresh{4,1}=[sigthresh{4,1} num2str(voxelsT26(J(Ifdr)))];
        end
    end
    clear Fi Ifdr J
    if strcmpi(STAT,'T')
        sigthresh{1,1}=[sigthresh{1,1}  num2str(spm_uc(mapparameters.threshc,df,STAT,mapparameters.RESELS,1,SV)) ',' num2str(1-spm_Tcdf(spm_uc(mapparameters.threshc,df,STAT,mapparameters.RESELS,1,SV),df(2)))];
    elseif strcmpi(STAT,'F')
        sigthresh{1,1}=[sigthresh{1,1}  num2str(spm_uc(mapparameters.threshc,df,STAT,mapparameters.RESELS,1,SV)) ',' num2str(1-spm_Fcdf(spm_uc(mapparameters.threshc,df,STAT,mapparameters.RESELS,1,SV),df))];
    elseif strcmpi(STAT,'Z')
        sigthresh{1,1}=[sigthresh{1,1}  num2str(spm_uc(mapparameters.threshc,df,STAT,mapparameters.RESELS,1,SV)) ',' num2str(1-spm_Ncdf(spm_uc(mapparameters.threshc,df,STAT,mapparameters.RESELS,1,SV),0,1))];
    else
        sigthresh{1,1}=[sigthresh{1,1}  num2str(spm_uc(mapparameters.threshc,df,STAT,mapparameters.RESELS,1,SV))];
    end
    
end

%disp(['SPM peak count: ' num2str(numel(voxelsT18))])
%disp(['peak_nii peak count: ' num2str(numel(voxelsT26))])
%disp(['Difference as percent of peak_nii: ' num2str((((numel(voxelsT18)-numel(voxelsT26))/numel(voxelsT26)))*100)])
%disp(sigthresh)

if FIVEF
    voxelstats=[];
else
    for ii=1:size(voxelsT,1)
        if vstatsR && ~isfield(mapparameters,'exactvoxel')
            Pu(ii)          = spm_P(1,0,voxelsT(ii,2),df,STAT,mapparameters.RESELS,1,numel(QPs));                % FWE-corrected {based on Z}
            Qp18(ii,1)      = spm_P_peakFDR(voxelsT(ii,2),df,STAT,mapparameters.RESELS,1,mapparameters.thresh,QPp18);    % topological FDR voxel q-value, based on Z (19 voxel peaks)
            Qp26(ii,1)      = spm_P_peakFDR(voxelsT(ii,2),df,STAT,mapparameters.RESELS,1,mapparameters.thresh,QPp26);    % topological FDR voxel q-value, based on Z (27 voxel peaks)
        elseif vstatsR
            Pu(ii)          = spm_P(1,0,voxelsT(ii,2),df,STAT,mapparameters.RESELS,1,numel(QPs));                % FWE-corrected {based on Z}
            Qp18(ii,1)      = NaN;
            Qp26(ii,1)      = NaN;
        end
        Qu(ii)              = spm_P_FDR(voxelsT(ii,2),df,STAT,1,QPs);                                    % voxel FDR-corrected q-value
    end
    try
        Qp26(voxelsT(:,1)<0)=NaN;
        voxelstats=[round([Pu Qp18 Qp26 Qu voxelsT(:,2) Ze Pz]*1000)/1000 voxelsT(:,3:5) voxelsT(:,7)];
    catch
        voxelstats=round([NaN(size(voxelsT,1),3) Qu voxelsT(:,2) Ze Pz]*1000)/1000;
    end
end
end

%% Calc_clusterstats
function clusterstats=calc_clusterstats(mapparameters,voxelsT,STAT,df,QPs,QPc,cstats)
[jnk,ind]=unique(voxelsT(:,11),'first');
voxelsT(ind,1)=abs(voxelsT(ind,1));
K=voxelsT(ind,1)*(1/prod(mapparameters.FWHM));
Pk=NaN(numel(K),1);
Pn=NaN(numel(K),1);
Qc=NaN(numel(K),1);
try
    if cstats
        for ii=1:numel(K)
            [Pk(ii) Pn(ii)] = spm_P(1,K(ii),mapparameters.thresh,df,STAT,mapparameters.RESELS,1,numel(QPs));  % [un]corrected {based on K}
        end
    end
catch
    Pk(1:numel(K),1)=NaN;
    Pn(1:numel(K),1)=NaN;
end
try
    if cstats
        for ii=1:numel(K)
            Qc(ii)  = spm_P_clusterFDR(K(ii),df,STAT,mapparameters.RESELS,1,mapparameters.thresh,QPc'); % topological FDR-corrected voxel q-value, based on K
        end
    end
catch
    Qc(1:numel(K),1)=NaN;
end
clusterstats=[round([(1:numel(K))' Pk Qc voxelsT(ind,1) Pn]*1000)/1000 voxelsT(ind,3:5)];
end

%% Calc_NSclusterstats
function NSclusterstats=calc_NSclusterstats(mapparameters,voxelsT,STAT,df,QPs,QPc,cstats)
[jnk,ind]=unique(voxelsT(:,7),'first');
voxelsT(ind,1)=abs(voxelsT(ind,1));
K=voxelsT(ind,8);
Pk=NaN(numel(K),1);
Pn=NaN(numel(K),1);
Qc=NaN(numel(K),1);
try 
    if cstats
        for ii=1:numel(K)
            [Pk(ii) Pn(ii)] = spm_P(1,K(ii),mapparameters.thresh,df,STAT,mapparameters.RESELS,1,numel(QPs));  % [un]corrected {based on K}
        end
    end
catch
    Pk(1:numel(K),1)=NaN;
    Pn(1:numel(K),1)=NaN;
end
try
    if cstats
        for ii=1:numel(K)
            Qc(ii)  = spm_P_clusterFDR(K(ii),df,STAT,mapparameters.RESELS,1,mapparameters.thresh,QPc'); % topological FDR-corrected voxel q-value, based on K
        end
    end
catch
    Qc(1:numel(K),1)=NaN;
end
clusterstats=[round([(1:numel(K))' Pk Qc voxelsT(ind,1) Pn]*1000)/1000 voxelsT(ind,3:5)];
end