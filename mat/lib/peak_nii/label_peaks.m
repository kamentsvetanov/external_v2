function peaks_wlabels=label_peaks(label,peaks,nearest)
%%
% USAGE AND EXAMPLES CAN BE FOUND IN PEAK_NII_MANUAL.PDF
%
% License:
%  Copyright (c) 2011, Donald G. McLaren and Aaron Schultz
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
%   label_peaks.v1 -- Last modified on 11/15/2011 by Donald G. McLaren, PhD
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
    if ~strcmp(spm('Ver'),'SPM8')
        disp('PROGRAM ABORTED:')
        disp('  You must use SPM8 to process your data; however, you can use SPM.mat files')
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

%% Define Output
peaks_wlabels=cell(size(peaks,1),5);

%% Error Check
if nargin<3
    nearest=0;
elseif ~isnumeric(nearest)
    nearest=0;
end
if nargin<2
   disp('You must specify at least two input arguments')
else
    if size(peaks,2)~=3
        disp('Peaks must be an n-by-3 matrix of coordinates');
        return
    end
    [labels, errorval]=roilabels(label);
    if isempty(labels)
        disp(['label ' label ' does not exist.']);
        return
    end
end

%% Find Regionnames
for vv=1:size(peaks,1)
    if nearest==0
        [xyz,ii] = spm_XYZreg('NearestXYZ',peaks(vv,:),labels.rf.XYZmm); % use all voxels
        try
            ROInum=labels.rf.img(ii);
        catch
            ROInum=0;
        end
    else
        nz_ind=find(labels.rf.img>0);
        [xyz,j] = spm_XYZreg('NearestXYZ',peaks(vv,:),labels.rf.XYZmm(:,nz_ind)); % use only voxels with a region greater than 0.
        try
            ii=nz_ind(j);
            if isempty(ii)
                invovkecatchstatement
            end
            [junk,D]=vox_distance([xyz';peaks(vv,:)]); % need to pad xyz, voxel is made to be 1x4 with 2-4 being coordianates
        catch
            D(1,2)=Inf;
        end
        if D(1,2)>8 % further than 8 mm from region
            ROInum=0;
        else
            ROInum=labels.rf.img(ii);
        end
    end
    if ROInum~=0
        try
            ROIind=find([labels.ROI.ID]==ROInum);
            ROIname=labels.ROInames{ROIind};
        catch
            keyboard
        end
    else
        ROIname='undefined';
    end
    peaks_wlabels{vv,1}=peaks(vv,1);
    peaks_wlabels{vv,2}=peaks(vv,2);
    peaks_wlabels{vv,3}=peaks(vv,3);
    peaks_wlabels{vv,4}=ROInum; clear ROIind
    peaks_wlabels{vv,5}=ROIname; clear ROIname
end
return

%% ROILABELS
function [label, errorval]=roilabels(source)
errorval=[];
peak_nii_dir=fileparts(which('peak_nii.m'));
switch source
    case 'AAL_MNI_V4'
        regionfile=[peak_nii_dir filesep 'aal_MNI_V4.img']; % From WFU_pickatlas
        load([peak_nii_dir filesep 'aal_MNI_V4_List.mat']);
    case 'Nitschke_Lab'
        regionfile=[peak_nii_dir filesep 'ControlabilityMask.nii']; % Provided by Deb Kerr
        load([peak_nii_dir filesep 'ControlabilityMask_List.mat']);
    case 'JHU_tracts'
        regionfile=[peak_nii_dir filesep 'JHU-ICBM-tracts-maxprob-thr0-1mm.nii']; % From FSL Atlas Files
        load([peak_nii_dir filesep 'JHU_tract_labels.mat']);
    case 'JHU_whitematter'
        regionfile=[peak_nii_dir filesep 'JHU-WhiteMatter-labels-1mm.nii']; % From FSL Atlas Files
        load([peak_nii_dir filesep 'JHU_labels.mat']);
    case 'Thalamus' 
        regionfile=[peak_nii_dir filesep 'Thalamus-maxprob-thr0-1mm.nii']; % From FSL Thalamus Atlas Files
        load([peak_nii_dir filesep 'Thalamus_labels.mat']);
    case 'Talairach'
        regionfile=[peak_nii_dir filesep 'Talairach-labels-1mm.nii']; % From FSL Talairach Atlas Files
        load([peak_nii_dir filesep 'Talairach_Labels.mat']);
    case 'MNI'
        regionfile=[peak_nii_dir filesep 'MNI-maxprob-thr0-1mm.nii']; % From FSL MNI Atlas Files
        load([peak_nii_dir filesep 'MNI_labels.mat']);
    case 'HarvardOxford_cortex'
        regionfile=[peak_nii_dir filesep 'HarvardOxford-cort-maxprob-thr0-1mm.nii']; % From FSL Atlas Files
        load([peak_nii_dir filesep 'HarvardOxford_cortical_labels']);
    %case 'HarvardOxford_subcortical' % Labels do not match image
    %    regionfile=[peak_nii_dir filesep 'HarvardOxford-sub-maxprob-thr0-1mm.nii']; % From FSL Atlas Files
    %    load([peak_nii_dir filesep 'HarvardOxford_subcortical_labels']);
    case 'Juelich'
        regionfile=[peak_nii_dir filesep 'Juelich-maxprob-thr0-1mm.nii']; % From FSL Atlas Files
        load([peak_nii_dir filesep 'Juelich_labels.mat']);
    case 'Cerebellum-flirt'
        regionfile=[peak_nii_dir filesep 'Cerebellum-MNIflirt-maxprob-thr0-1mm.nii']; % From FSL Atlas Files
        load([peak_nii_dir filesep 'Cerebellum_labels.mat']);
    case 'Cerebellum-fnirt'
        regionfile=[peak_nii_dir filesep 'Cerebellum-MNIfnirt-maxprob-thr0-1mm.nii']; % From FSL Atlas Files
        load([peak_nii_dir filesep 'Cerebellum_labels.mat']);
    case 'Hammers'
        if exist([fileparts(which('spm')) filesep 'toolbox' filesep 'HammersAtlas' filesep 'Hammers_mith_atlas_n30r83_SPM5.img'],'file') && exist([fileparts(which('spm')) filesep 'toolbox' filesep 'HammersAtlas' filesep 'Hammers_mith_atlas_n30r83_labels.mat'],'file')
            regionfile=[fileparts(which('spm')) filesep 'toolbox' filesep 'HammersAtlas' filesep 'Hammers_mith_atlas_n30r83_SPM5.img'];
            load([fileparts(which('spm')) filesep 'toolbox' filesep 'HammersAtlas' filesep 'Hammers_mith_atlas_n30r83_labels.mat']);
        else
            errorval='The HammersAtlas is not available. Please contact Alex Hammers (alexander.hammers@fondation-neurodis.org) for the atlas';
            disp('===========')
            disp('IMPORTANT: Once you have downloaded the Atlas files, please put them into a directory called HammersAtlas in the toolbox directory of SPM');
            disp('===========')
            label.source=source;
            return
        end
    case 'BucknerYeo_7_loose'
        regionfile=[peak_nii_dir filesep 'BucknerYeo' filesep 'BucknerYeo2011_7Networks_Loose_MNI152_1mm.nii']; % Derived from http://surfer.nmr.mgh.harvard.edu/fswiki/CerebellumParcellation_Buckner2011 & http://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation_Yeo2011
        load([peak_nii_dir filesep 'BucknerLabels.mat']);
    case 'BucknerYeo_7_tight'
        regionfile=[peak_nii_dir filesep 'BucknerYeo' filesep 'BucknerYeo2011_7Networks_Tight_MNI152_1mm.nii']; % Derived from http://surfer.nmr.mgh.harvard.edu/fswiki/CerebellumParcellation_Buckner2011 & http://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation_Yeo2011
        load([peak_nii_dir filesep 'BucknerLabels.mat']);
    case 'BucknerYeo_17_loose'
        regionfile=[peak_nii_dir filesep 'BucknerYeo' filesep 'BucknerYeo2011_17Networks_Loose_MNI152_1mm.nii']; % Derived from http://surfer.nmr.mgh.harvard.edu/fswiki/CerebellumParcellation_Buckner2011 & http://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation_Yeo2011
        load([peak_nii_dir filesep 'BucknerLabels.mat']);
    case 'BucknerYeo_17_tight'
        regionfile=[peak_nii_dir filesep 'BucknerYeo' filesep 'BucknerYeo2011_17Networks_Tight_MNI152_1mm.nii']; % Derived from http://surfer.nmr.mgh.harvard.edu/fswiki/CerebellumParcellation_Buckner2011 & http://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation_Yeo2011
        load([peak_nii_dir filesep 'BucknerYeo' filesep 'BucknerYeo_Network_Labels.mat']);
    case 'SPMAnatomy'
            regionfile=[peak_nii_dir filesep 'AllAreas_v18_peaknii.nii'];
            load([peak_nii_dir filesep 'AllAreas_v18_MPM_Labels.mat']);
    case 'SPMAnatomyMNI'
        regionfile=[peak_nii_dir filesep 'AllAreas_v18_peaknii_MNI.nii'];
        load([peak_nii_dir filesep 'AllAreas_v18_MPM_Labels.mat']);
    %case 'Custom'
    %    regionfile=['ROI image file'];
    %    load(['ROIlist mat-file']);
    otherwise
        label=[];
        return
end

label.source=source;
label.rf.hdr=spm_vol(regionfile);
[label.rf.img,label.rf.XYZmm]=spm_read_vols(label.rf.hdr);
label.ROI=ROI;
label.ROInames={ROI.Nom_C}; %ROInames is taken from ROI, where ROI is structure
if ~isfield(ROI,'ID')
		 display('ERROR: ROI must be a structure with an ID field that is the ID of values in region file')
		 return
end
