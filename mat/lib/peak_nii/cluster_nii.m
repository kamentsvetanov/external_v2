function [voxelsT region invar]=cluster_nii(image,varstruct)
%%
% cluster_nii will find the current cluster and cluster
% INPUTS:
% image string required. This should be a nii or img file.
% varstruct is either a .mat file or a pre-load structure with the
% following fields:
%          type: statistic type, 'T' or 'F' or 'none'
%       cluster: cluster extent threshold in voxels
%           df1: numerator degrees of freedom for T/F-test (if 0<thresh<1)
%           df2: denominator degrees of freedom for F-test (if 0<thresh<1)
%       nearest: 0 or 1, 0 for leaving some clusters/peaks undefined, 1 for finding the
%                nearest label
%         label: optional to label clusters, options are 'aal_MNI_V4';
%                'Nitschke_Lab'; FSL ATLASES: 'JHU_tracts', 'JHU_whitematter',
%                'Thalamus', 'Talairach', 'MNI', 'HarvardOxford_cortex', 'Cerebellum-flirt', 'Cerebellum=fnirt', and 'Juelich'. 
%                'HarvardOxford_subcortical' is not available at this time because
%                the labels don't match the image.
%                Other atlas labels may be added in the future
%        thresh: T/F statistic or p-value to threshold the data or 0
%
% OUTPUTS:
%   voxels  -- table of peaks
%       col. 1 - Cluster size
%       col. 2 - T/F-statistic
%       col. 3 - X coordinate
%       col. 4 - Y coordinate
%       col. 5 - Z coordinate
%       col. 6 - region number
%       col. 7 - region name
%   region - flag for peak_extract_nii
%
% EXAMPLE: voxels=cluster_nii('imagename',varstruct)
%
% License:
%   Copyright (c) 2011, Donald G. McLaren and Aaron Schultz
%   All rights reserved.
%
%    Redistribution, with or without modification, is permitted provided that the following conditions are met:
%    1. Redistributions must reproduce the above copyright
%        notice, this list of conditions and the following disclaimer in the
%        documentation and/or other materials provided with the distribution.
%    2. All advertising materials mentioning features or use of this software must display the following acknowledgement:
%        This product includes software developed by the Harvard Aging Brain Project.
%    3. Neither the Harvard Aging Brain Project nor the
%        names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
%    4. You are not permitted under this Licence to use these files
%        commercially. Use for which any financial return is received shall be defined as commercial use, and includes (1) integration of all 	
%        or part of the source code or the Software into a product for sale or license by or on behalf of Licensee to third parties or (2) use 	
%        of the Software or any derivative of it for research with the final aim of developing software products for sale or license to a third 	
%        party or (3) use of the Software or any derivative of it for research with the final aim of developing non-software products for sale 
%        or license to a third party, or (4) use of the Software to provide any service to an external organisation for which payment is received.
%
%   THIS SOFTWARE IS PROVIDED BY DONALD G. MCLAREN (mclaren@nmr.mgh.harvard.edu) AND AARON SCHULTZ (aschultz@nmr.mgh.harvard.edu)
%   ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
%   FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
%   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
%   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
%   TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
%   USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%   cluster_nii.v1 -- Last modified on 2/23/2011 by Donald G. McLaren, PhD
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
%   In accordance with the licences of the atlas sources as being distibuted solely
%   for non-commercial use; neither this program, also soley being distributed for non-commercial use,
%   nor the atlases containe herein should therefore not be used for commercial purposes; for such
%   purposes please contact the primary co-ordinator for the relevant
%   atlas:
%       Harvard-Oxford: steve@fmrib.ox.ac.uk
%       JHU: susumu@mri.jhu.edu
%       Juelich: S.Eickhoff@fz-juelich.de
%       Thalamus: behrens@fmrib.ox.ac.uk
%       Cerebellum: j.diedrichsen@bangor.ac.uk
%       AAL_MNI_V4: maldjian@wfubmc.edu and/or bwagner@wfubmc.edu
%
%   For the program in general, please contact mclaren@nmr.mgh.harvard.edu
%

%% Check inputs
if exist(image,'file')==2
    I=spm_vol(image);
    infoI=I;
    [I,voxelcoord]=spm_read_vols(I);
    if nansum(nansum(nansum(abs(I))))==0
        error(['Error: ' image ' is all zeros or all NaNs'])        
    end
else
    error(['File ' image ' does not exist'])
end

try
    if exist(varstruct,'file')==2
        varstruct=load(varstruct);
    end
catch
end

if ~isstruct(varstruct)
    error('varstruct is not a structure. Aaron, this should not be possible.')
end
%% Format input instructure
while numel(fields(varstruct))==1
    F=fieldnames(varstruct);
    varstruct=varstruct.(F{1}); %Ignore coding error flag.
end

%Set defaults:
varstruct.sign='pos';
varstruct.conn=18;
varstrcut.out=[];
varstruct.voxlimit=10; %irrelevant since only the maximum is considered
varstruct.separation=20; %irrelevant since only the maximum is considered
varstruct.SPM=1; % irrelevant since only the maximum is considered
varstruct.mask=[];

invar=peak_nii_inputs(varstruct,infoI.fname,nargout);

if isfield(varstruct,'voxel')
    if size(varstruct.voxel)==[3 1]
        invar.voxel=varstruct.voxel;
    elseif size(varstruct.voxel)==[1 3]
        invar.voxel=varstruct.voxel';
    else
        error('voxel is not a voxel. Aaron, this should not be possible.')
    end 
else
    error('voxel not defined. Aaron, this should not be possible.')
end

%% Program begins here
% Find significant voxels
disp(['Threshold is:' num2str(invar.thresh)])
ind=find(I>invar.thresh);
if isempty(ind)
    error(['NO MAXIMA ABOVE ' num2str(invar.thresh) '.'])
else
   [L(1,:),L(2,:),L(3,:)]=ind2sub(infoI.dim,ind);
end

% Cluster signficant voxels
A=peakcluster(L,invar.conn,infoI); % A is the cluster of each voxel
A=transpose(A);
n=hist(A,1:max(A));
for ii=1:size(A,1)
    if n(A(ii))<invar.cluster % removes clusters smaller than extent threshold
        A(ii,1:2)=NaN;
    else
        A(ii,1:2)=[n(A(ii)) A(ii,1)];
    end
end

% Combine A (cluster labels) and L (voxel indicies)
L=L';
A(:,3:5)=L(:,1:3);
% Remove voxels that are not the current cluster
x=spm_XYZreg('NearestXYZ',invar.voxel,voxelcoord);
xM=round(infoI.mat \ [x; 1]);
ind=find(((A(:,3)==xM(1))+(A(:,4)==xM(2))+(A(:,5)==xM(3)))==3);
if isempty(ind)
    error('voxel is not in a cluster');
end
A=A(A(:,2)==A(ind,2),:); %finds current cluster
A(:,2)=1; %label it as cluster 1
region=[]; %used as a flag in peak_extract_nii

%Output temp cluster file
infoI.fname='temp_cluster.nii';
infoI.descrip='temp cluster';
infoI.pinfo=[1 0 0]';
vol=zeros(infoI.dim(1),infoI.dim(2),infoI.dim(3));
for ii=1:size(A,1)
   vol(A(ii,3),A(ii,4),A(ii,5))=1;
end
spm_write_vol(infoI,vol);

% Find the peakin the current cluster
voxelsT=cell(1,5);
ind=sub2ind(infoI.dim,A(:,3),A(:,4),A(:,5));
maxind=find(I(ind)==max(I(ind)));
voxind=sub2ind(infoI.dim,A(maxind,3),A(maxind,4),A(maxind,5));
voxelsT{1,1}=A(maxind,1);
voxelsT{1,2}=I(voxind);
voxelsT{1,3}=voxelcoord(1,voxind);
voxelsT{1,4}=voxelcoord(2,voxind);
voxelsT{1,5}=voxelcoord(3,voxind);
        
% Label Peaks
if ~isempty(invar.label.source)
    [voxelsT{1,6} voxelsT{1,7}]=regionname(cell2mat(voxelsT),invar.label.rf,invar.label.ROI,invar.label.ROInames,invar.label.nearest);
end


%% Peakcluster
function A=peakcluster(L,conn,infoI1)
dim = infoI1.dim;
vol = zeros(dim(1),dim(2),dim(3));
indx = sub2ind(dim,L(1,:)',L(2,:)',L(3,:)');
vol(indx) = 1;
[cci,num] = spm_bwlabel(vol,conn);
A = cci(indx');
return

%% Regionname
function [ROInum ROIname]=regionname(voxel,rf,ROI,ROInames,nearest)
if nearest==0
        [xyz,ii] = spm_XYZreg('NearestXYZ',voxel(3:5),rf.XYZmm); % use all voxels
        ROInum=rf.img(ii);
else    
        nz_ind=find(rf.img>0);
        [xyz,j] = spm_XYZreg('NearestXYZ',voxel(3:5),rf.XYZmm(:,nz_ind)); % use only voxels with a region greater than 0.
        ii=nz_ind(j);
        [junk,D]=vox_distance([0 0 xyz';voxel(1:5)]); % need to pad xyz, voxel is made to be 1x4 with 2-4 being coordianates
        if D(1,2)>8 % further than 5 mm from region
            ROInum=0;
        else
            ROInum=rf.img(ii);
        end
end
if ROInum~=0
       ROIind=find([ROI.ID]==ROInum);
       ROIname=ROInames{ROIind};
else
       ROIname='undefined';
end
return
   