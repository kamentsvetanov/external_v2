function [resultsvoxels columnlistvoxels resultscluster columnlistcluster clusters mapparams subjparams UID]=peak_extract_nii(subjectparameters,mapparameters)
% This program is designed to extract data from a set of ROIS or peak
% coordinates.
% 
% peak_extract_nii.v6
% 
% See PEAK_NII_TOOLBOX_MANUAL.pdf for usage details.
% 
% License:
%  Copyright (c) 2011-2, Donald G. McLaren and Aaron Schultz
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
%
% Last modified on 2/11/2012 by Donald G. McLaren (mclaren@nmr.mgh.harvard.edu)
%   GRECC, Bedford VAMC
%   Department of Neurology, Massachusetts General Hospital and Havard
%   Medical School
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resultsvoxels={}; columnlistvoxels={}; resultscluster={}; columnlistcluster={}; clusters={}; UID=[]; mapparams=struct();
%%Program Begins Here
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

%Check for extraction parameters (mappparameters)
if ischar(mapparameters) && exist(mapparameters,'file')==2
    try
        mapparameters=load(mapparameters);
    catch
        error('mapparameters file does not exist.')
    end
elseif ~exist('mapparameters','var')
    error('mapparameters must be a file, a structure, or a variable.')
end
if isstruct(mapparameters)
    while numel(fields(mapparameters))==1
        F=fieldnames(mapparameters);
        mapparameters=mapparameters.(F{1}); %Ignore coding error flag.
    end
end
if isstruct(mapparameters) && ~isfield(mapparameters,'voxel')
    if ~isfield(mapparameters,'image') || ~exist(mapparameters.image,'file')
        error('mapparameters.image file does not exist.')
    end
    x='[voxelsT voxelstats clusterstats sigthresh regions mapparams UID]=peak_nii(mapparameters.image,mapparameters);';
elseif isstruct(mapparameters) && (size(mapparameters.voxel,1)==3 || size(mapparameters.voxel,2)==3) 
    if size(mapparameters.voxel,1)==3 && size(mapparameters.voxel,2)~=3
        mapparameters.voxel=mapparameters.voxel';
    elseif size(mapparameters.voxel,2)==3
        mapparameters.voxel=mapparameters.voxel;
    end
    if isfield(mapparameters,'image') && exist(mapparameters.image,'file')==2
        x='[voxelsT voxelstats clusterstats sigthresh region mapparams]=peak_nii(mapparameters.image,mapparameters);';
    end
elseif size(mapparameters,1)==3
    voxels(:,3:5)=mapparameters';
elseif size(mapparameters,2)==3
    voxels(:,3:5)=mapparameters;
else
    error('mapparameters must be a file that contains a structure, a Nx3 variable of peak coordinates, or a 3xN variable of peak coordinates.')
end

% Load subject structure
if ~isstruct(subjectparameters) && ~iscell(subjectparameters) && exist(subjectparameters,'file')==2
    subjectparameters=load(subjectparameters);
end

if isstruct(subjectparameters)
    subjparams=subjectparameters; clear subjectparameters;
    while numel(fieldnames(subjparams))==1 && ~any(strcmp(fieldnames(subjparams),{'P' 'directory' 'subjectpeak' 'searchsphere' 'extractsphere' 'SPMmat' 'Imat' 'xY' 'neg' 'nanmethod'}))
        F=fieldnames(subjparams);
        subjparams=subjparams.(F{1}); %Ignore coding error flag.
    end
    clear F
    if numel(subjparams)~=1
        error('Subject parameter structure is the wrong size')
    end
elseif iscell(subjectparameters)
    for ii=1:numel(subjectparameters)
        subjectparameters{ii}=strtok(subjectparameters{ii},',');
    end
    subjparams.P=char(subjectparameters); clear subjectparameters;
elseif isempty(subjectparameters)
    subjparams=subjectparameters; clear subjectparameters;
else
    subjparams=[];clear subjectparameters;
end

if ~isfield(subjparams,'directory') || isempty(subjparams.directory)
    subjparams.directory=pwd;
end

if isfield(subjparams,'SPMmat') && isfield(subjparams,'Imat')
    error('subjparams has conflicting fields SPMmat and Imat. Only one can be entered.')
end

%Load images for extraction
VY=0; %skips using pinfo field from SPM.mat file
if isstruct(mapparameters) && isfield(mapparameters,'voxel')
    try 
        if exist([pwd 'SPM.mat'],'file')==2 || exist([pwd 'I.mat'],'file')==2
            spmpath=pwd;
        else 
            spmpath=fileparts(mapparameters.image);
            if isempty(spmpath)
                spmpath=pwd;
            end
        end
        try
            load([spmpath filesep 'SPM.mat']);
            Imat=0;
        catch
            load([spmpath filesep 'I.mat']);
            Imat=1;
        end
        if isfield(mapparameters,'beta') && isnumeric(mapparameters.beta) && mapparameters.beta==1 % SPM.mat contains the variable SPM, loaded in the previous line.
            if ~Imat
                tmpsubjhdrs=SPM.Vbeta;
            else
                error('Imat cannot be used with the beta field.')
            end
        else
            if ~Imat
                tmpsubjhdrs=SPM.xY.VY; % SPM.mat contains the variable SPM, loaded in the previous line.
                VY=1;
            else
               for ii=1:numel(I.Scans)
                   if exist(strtok(I.Scans{ii},','),'file')==2
                       subjhdrs(ii)=spm_vol(strtok(I.Scans{ii},','));
                   else
                       invokecatchstatement
                   end
               end
            end
        end
        if VY==1 && ~Imat
            for ii=1:numel(tmpsubjhdrs)
                if exist(tmpsubjhdrs(ii).fname,'file')==2
                    subjhdrs(ii)=spm_vol(tmpsubjhdrs(ii).fname);
                elseif exist([subjparams.directory filesep tmpsubjhdrs(ii).fname],'file')==2
                    subjhdrs(ii)=spm_vol([subjparams.directory filesep tmpsubjhdrs(ii).fname]);
                else
                    spm_input('SPM.mat input/beta files do not exist!',1,'bd','ok',1,1)
                    invokecatchstatement
                end
                subjhdrs(ii).pinfo(1)=SPM.xY.VY(ii).pinfo(1);
            end
        elseif ~Imat
            for ii=1:numel(tmpsubjhdrs)
                if exist(tmpsubjhdrs(ii).fname,'file')==2
                    subjhdrs(ii)=spm_vol(tmpsubjhdrs(ii).fname);
                elseif exist([subjparams.directory filesep tmpsubjhdrs(ii).fname],'file')==2
                    subjhdrs(ii)=spm_vol([subjparams.directory filesep tmpsubjhdrs(ii).fname]);
                else
                    spm_input('SPM.mat input/beta files do not exist!',1,'bd','ok',1,1)
                    invokecatchstatement
                end
            end
        end
        [subjimgs XYZmm]=spm_read_vols(subjhdrs);
    catch
        str = {'Do you want to use an SPM.mat file?'};
        if (isfield(subjparams,'SPMmat') && isnumeric(subjparams.SPMmat) && subjparams.SPMmat==1) && ~isfield(subjparams,'Imat') || spm_input(str,1,'bd','yes|no',[1,0],1)
            [spmmatfile, sts]=spm_select(1,'^SPM\.mat$','Select SPM.mat');
            swd = spm_str_manip(spmmatfile,'H');
            try
                load(fullfile(swd,'SPM.mat'));
            catch
                error(['Cannot read ' fullfile(swd,'SPM.mat')]);
            end
            if isfield(mapparameters,'beta') && isnumeric(mapparameters.beta) && mapparameters.beta==1 % SPM.mat contains the variable SPM, loaded in the previous line.
                subjhdrs=SPM.Vbeta;
            else
                subjhdrs=SPM.xY.VY; % SPM.mat contains the variable SPM, loaded in the previous line.
                VY=1;
            end
            if VY==1
                for ii=1:numel(subjhdrs)
                    if exist(subjhdrs(ii).fname,'file')==2
                        subjhdrs(ii)=spm_vol(subjhdrs(ii).fname);
                    elseif exist([subjparams.directory filesep subjhdrs(ii).fname],'file')==2
                        subjhdrs(ii)=spm_vol([subjparams.directory filesep subjhdrs(ii).fname]);
                    else
                        spm_input('SPM.mat input files do not exist!',1,'bd','ok',1,1)
                        error('SPM.mat input files do not exist!')
                    end
                    subjhdrs(ii).pinfo(1)=SPM.xY.VY(ii).pinfo(1);
                end
            else
                for ii=1:numel(subjhdrs)
                    if exist(subjhdrs(ii).fname,'file')==2
                        subjhdrs(ii)=spm_vol(subjhdrs(ii).fname);
                    elseif exist([subjparams.directory filesep subjhdrs(ii).fname],'file')==2
                        subjhdrs(ii)=spm_vol([subjparams.directory filesep subjhdrs(ii).fname]);
                    else
                        spm_input('SPM.mat input files do not exist!',1,'bd','ok',1,1)
                        error('SPM.mat input files do not exist!')
                    end
                end
            end
            [subjimgs XYZmm]=spm_read_vols(subjhdrs);
        else
            str = {'Do you want to use an I.mat file?'};
            if (isfield(subjparams,'Imat') && isnumeric(subjparams.Imat) && subjparams.Imat==1) || spm_input(str,1,'bd','yes|no',[1,0],1)
                [spmmatfile, sts]=spm_select(1,'^I\.mat$','Select I.mat');
                swd = spm_str_manip(spmmatfile,'H');
                try
                    load(fullfile(swd,'I.mat'));
                catch
                    error(['Cannot read ' fullfile(swd,'I.mat')]);
                end
                for ii=1:numel(I.Scans)
                    if exist(strtok(I.Scans{ii},','),'file')==2
                        subjhdrs(ii)=spm_vol(strtok(I.Scans{ii},','));
                    else
                        spm_input('I.mat input files do not exist!',1,'bd','ok',1,1)
                        error('I.mat input files do not exist!')
                    end
                end
                [subjimgs XYZmm]=spm_read_vols(subjhdrs);
            else
                subjparams.P = spm_select(Inf,'image','Select con/beta/other images for extraction',{},pwd,'.*','1');
                t = struct(spm_vol(subjparams.P(1,:))); F=fieldnames(t); for ii=1:numel(F); t.(F{ii})=[]; end
                subjhdrs(1:size(subjparams.P,1))=t; clear t;
                for ii=1:size(subjparams.P,1)
                    subjhdrs(ii)=spm_vol(subjparams.P(ii,:));
                end
                [subjimgs XYZmm]=spm_read_vols(subjhdrs);
            end
        end
    end
else %typical processing stream for peak_extract_nii.m
    try
        if isfield(subjparams,'xY') && isfield(subjparams.xY,'VY')
            tmpsubjhdrs=subjparams.xY.VY;
            for ii=1:numel(subjhdrs)
                if exist(subjhdrs(ii).fname,'file')==2
                    subjhdrs(ii)=spm_vol(subjhdrs(ii).fname);
                elseif exist([subjparams.directory filesep subjhdrs(ii).fname],'file')==2
                    subjhdrs(ii)=spm_vol([subjparams.directory filesep subjhdrs(ii).fname]);
                else
                    spm_input('SPM.mat input files do not exist!',1,'bd','ok',1,1)
                    error('SPM.mat input files do not exist!')
                end
                subjhdrs(ii).pinfo(1)=SPM.xY.VY(ii).pinfo(1);
            end
        elseif isfield(subjparams,'SPMmat') && isnumeric(subjparams.SPMmat) && subjparams.SPMmat==1 && isfield(subjparams,'beta') && isnumeric(subjparams.beta) && subjparams.beta==1
            try
                load([subjparams.directory filesep 'SPM.mat']);
                tmpsubjhdrs=SPM.Vbeta;
                for ii=1:numel(tmpsubjhdrs)
                    if exist(tmpsubjhdrs(ii).fname,'file')==2
                        subjhdrs(ii)=spm_vol(tmpsubjhdrs(ii).fname);
                    elseif exist([subjparams.directory filesep tmpsubjhdrs(ii).fname],'file')==2
                        subjhdrs(ii)=spm_vol([subjparams.directory filesep tmpsubjhdrs(ii).fname]);
                    else
                        spm_input('SPM.mat beta files do not exist!',1,'bd','ok',1,1)
                        invokecatchstatement
                    end
                end
            catch
                invokecatchstatement
            end
        elseif isfield(subjparams,'SPMmat') && isnumeric(subjparams.SPMmat) && subjparams.SPMmat==1
            try
                load([subjparams.directory filesep 'SPM.mat']);
                tmpsubjhdrs=SPM.xY.VY;
                for ii=1:numel(tmpsubjhdrs)
                    if exist(tmpsubjhdrs(ii).fname,'file')==2
                        subjhdrs(ii)=spm_vol(tmpsubjhdrs(ii).fname);
                    else
                        spm_input('SPM.mat input files do not exist!',1,'bd','ok',1,1)
                        invokecatchstatement
                    end
                    subjhdrs(ii).pinfo(1)=SPM.xY.VY(ii).pinfo(1);
                end
            catch 
                invokecatchstatement
            end 
        elseif isfield(subjparams,'Imat') && isnumeric(subjparams.Imat) && subjparams.Imat==1
           try
               load([subjparams.directory filesep 'I.mat']);
               for ii=1:numel(I.Scans)
                   if exist(strtok(I.Scans{ii},','),'file')==2
                       subjhdrs(ii)=spm_vol(strtok(I.Scans{ii},','));
                   else
                       invokecatchstatement
                   end
               end
           catch 
               invokecatchstatement
           end 
        else
            subjparams.P;
            if iscell(subjparams.P)
                try
                    tmpP=cell2mat(subjparams.P);
                    subjparams.P=tmpP;
                catch
                    P=[];
                    for ii=1:size(subjparams.P,1)
                        P     = strvcat(P,subjparams.P{ii});
                    end
                    subjparams.P=P; clear P
                end
            end
            t = struct(spm_vol(subjparams.P(1,:))); F=fieldnames(t); for ii=1:numel(F); t.(F{ii})=[]; end 
            subjhdrs(1:size(subjparams.P,1))=t; clear t;
            for ii=1:size(subjparams.P,1)
                if exist(deblank(subjparams.P(ii,:)),'file')==2
                    subjhdrs(ii)=spm_vol(subjparams.P(ii,:));
                elseif exist(strtok(deblank(subjparams.P(ii,:)),','),'file')==2
                    subjhdrs(ii)=spm_vol(strtok(deblank(subjparams.P(ii,:)),','));
                elseif exist(deblank([subjparams.directory subjparams.P(ii,:)]),'file')==2
                    subjhdrs(ii)=spm_vol([subjparams.directory subjparams.P(ii,:)]);
                elseif exist(strtok(deblank([subjparams.directory subjparams.P(ii,:)]),','),'file')==2
                    subjhdrs(ii)=spm_vol(strtok(deblank([subjparams.directory subjparams.P(ii,:)]),','));   
                else
                    invokecatchstatement
                end
            end
        end
        [subjimgs XYZmm]=spm_read_vols(subjhdrs);
    catch
        subjparams.P=[]; 
        str = {'Do you want to use an SPM.mat file?'};
        if (isfield(subjparams,'SPMmat') && isnumeric(subjparams.SPMmat) && subjparams.SPMmat==1) && ~isfield(subjparams,'Imat') || spm_input(str,1,'bd','yes|no',[1,0],1)
            [spmmatfile, sts]=spm_select(1,'^SPM\.mat$','Select SPM.mat');
            swd = spm_str_manip(spmmatfile,'H');
            try
                load(fullfile(swd,'SPM.mat'));
            catch
                error(['Cannot read ' fullfile(swd,'SPM.mat')]);
            end
            if isfield(subjparams,'beta') && isnumeric(subjparams.beta) && subjparams.beta==1
                tmpsubjhdrs=SPM.Vbeta;
            else
                tmpsubjhdrs=SPM.xY.VY; 
                VY=1;
            end
            if VY==1
                for ii=1:numel(tmpsubjhdrs)
                    if exist(tmpsubjhdrs(ii).fname,'file')==2
                        subjhdrs(ii)=spm_vol(tmpsubjhdrs(ii).fname);
                    elseif exist([subjparams.directory filesep tmpsubjhdrs(ii).fname],'file')==2
                        subjhdrs(ii)=spm_vol([subjparams.directory filesep tmpsubjhdrs(ii).fname]);
                    else
                        error('SPM.mat input/beta files do not exist!');
                    end
                    subjhdrs(ii).pinfo(1)=SPM.xY.VY(ii).pinfo(1);
                end
            else
                for ii=1:numel(tmpsubjhdrs)
                    if exist(tmpsubjhdrs(ii).fname,'file')==2
                        subjhdrs(ii)=spm_vol(tmpsubjhdrs(ii).fname);
                    elseif exist([subjparams.directory filesep tmpsubjhdrs(ii).fname],'file')==2
                        subjhdrs(ii)=spm_vol([subjparams.directory filesep tmpsubjhdrs(ii).fname]);
                    else
                        error('SPM.mat input/beta files do not exist!');
                    end
                end
            end
        else
            str = {'Do you want to use an I.mat file?'};
            if (isfield(subjparams,'Imat') && isnumeric(subjparams.Imat) && subjparams.Imat==1) || spm_input(str,1,'bd','yes|no',[1,0],1)
                [spmmatfile, sts]=spm_select(1,'^I\.mat$','Select I.mat');
                swd = spm_str_manip(spmmatfile,'H');
                try
                    load(fullfile(swd,'I.mat'));
                catch
                    error(['Cannot read ' fullfile(swd,'I.mat')]);
                end
                for ii=1:numel(I.Scans)
                    if exist(strtok(I.Scans{ii},','),'file')==2
                        subjhdrs(ii)=spm_vol(strtok(I.Scans{ii},','));
                    else
                        spm_input('I.mat input files do not exist!',1,'bd','ok',1,1)
                        error('I.mat input files do not exist!')
                    end
                end
                [subjimgs XYZmm]=spm_read_vols(subjhdrs);
            else
                subjparams.P = spm_select(Inf,'image','Select con/beta/other images for extraction',{},pwd,'.*','1');
                t = struct(spm_vol(subjparams.P(1,:))); F=fieldnames(t); for ii=1:numel(F); t.(F{ii})=[]; end
                subjhdrs(1:size(subjparams.P,1))=t; clear t;
                for ii=1:size(subjparams.P,1)
                    subjhdrs(ii)=spm_vol(subjparams.P(ii,:));
                end
                [subjimgs XYZmm]=spm_read_vols(subjhdrs);
            end
        end
    end
end

%Check that all headers are the same
dims = cat(1,subjhdrs.dim);
matx = reshape(cat(3,subjhdrs.mat),[16,numel(subjhdrs)]);

if any(any(diff(dims,1,1),1))
    error('Images for extraction do not have the same dimensions.')
end
if any(any(abs(diff(matx,1,2))>1e-4))
    error('Images for extraction do not have the same orientations.')
end

%Check for subject peaks?
if isfield(subjparams,'subjectpeak') && subjparams.subjectpeak==1
    try
        if strncmp(subjhdrs(1).fname,'con_',4)
            t = struct(spm_vol([subjhdrs(1).fname(1,1:a-1) 'spmT_' subjhdrs(ii).fname(1,a+4:end)])); F=fieldnames(t); for ii=1:numel(F); t.(F{ii})=[]; end
            subjpeakhdrs(1:numel(subjhdrs))=t; clear t;
            for ii=1:numel(subjhdrs)
                a=strfind(subjhdrs(ii).fname,'con_');
                subjpeakhdrs(ii)=spm_vol([subjhdrs(ii).fname(1,1:a-1) 'spmT_' subjhdrs(ii).fname(1,a+4:end)]);
            end
            subjpeakimgs=spm_read_vols(subjpeakhdrs);
        else
            subjpeakimgs=subjimgs;
        end
        if isfield(subjparams,'neg') && subjparams.neg==1
            subjpeakimgs=-1*subjpeakimgs;
        elseif isfield(subjparams,'neg') && ~isnumeric(subjparams.neg)
            error('neg field is not specified correctly')
        end
    catch
        error('Subjectpeak settings are wrong. Missing spmT maps.')
    end
else
    subjparams.subjectpeak=0;
end

%Check NaN Method
if ~isfield(subjparams,'nanmethod') || ~isnumeric(subjparams.nanmethod)
    subjparams.nanmethod=0;
end

%Get Cluster information
try
    eval(x);
    clusters=voxelsT;
    if isempty(clusters)
        display('No clusters found.');
        return
    else
        if exist('regions','var')
            voxels=voxelsT{1};
        elseif exist('region','var')
            voxels=voxelsT{1};
        else
            voxels=cell2mat(voxelsT(1:5));
        end
    end
catch
    if exist('x','var')
        if isfield(mapparameters,'exact') && isnumeric(mapparameters.exact) && mapparameters.exact==1
            if mapparameters.cluster<=0
                error('Cluster must be greater than 0')
            end
            mapmaskimg=spm_read_vols(spm_vol(mapparameters.mask));
            if mapparameters.cluster>sum(mapmaskimg(:)>0)
                error('Cluster must be smaller than mask')
            end
            if isfield(mapparameters,'label')
                error('Error in peak_nii. Mapparameters is not correct. Missing something.')
            else
                error('Error in peak_nii. Label was not set.')
            end
        else
            if isfield(mapparameters,'label')
                error('Error in peak_nii. Mapparameters is not correct. Missing something.')
            else
                error('Error in peak_nii. Label was not set.')
            end
        end
    else
        error('peak_nii was not execute because mapparameters.image does not exist')
    end
end

%%Extraction Code
if subjparams.subjectpeak==1
    subjectpeaklocationsvoxel=cell(numel(subjhdrs),size(voxels,1));
    subjectpeakspherevaluesvoxel=zeros(numel(subjhdrs),size(voxels,1))*NaN;
    subjectpeaksvaluesvoxel=zeros(numel(subjhdrs),size(voxels,1))*NaN;
end
peakspherevaluesavg=zeros(numel(subjhdrs),size(voxels,1))*NaN;
peakspherevalueseig=zeros(numel(subjhdrs),size(voxels,1))*NaN;
peakvalues=zeros(numel(subjhdrs),size(voxels,1))*NaN;
for ii=1:size(voxels,1)
    % Extract peak voxel
    [xyz,ind]=spm_XYZreg('NearestXYZ',voxels(ii,3:5)',XYZmm);
    peakvalues(:,ii)=subjimgs(ind:prod(subjhdrs(1).dim):end);
    clear ind
    
    % Extract sphere around peak
    if isfield(subjparams,'extractsphere') && isnumeric(subjparams.extractsphere)
        ind=find(sum((XYZmm - repmat(voxels(ii,3:5)',1,size(XYZmm,2))).^2) <= subjparams.extractsphere^2);
        inds=zeros(1,numel(ind)*numel(subjhdrs));
        for jj=1:numel(ind)
            inds((jj-1)*numel(subjhdrs)+1:jj*numel(subjhdrs))=ind(jj):prod(subjhdrs(1).dim):prod(subjhdrs(1).dim)*numel(subjhdrs);
        end
        inds=sort(inds);
        data=reshape(subjimgs(inds),numel(ind),numel(subjhdrs));
        [peakspherevaluesavg(:,ii) peakspherevalueseig(:,ii)]=regionalcomps(data',subjparams.nanmethod);
    elseif isfield(subjparams,'extractsphere') && ~isnumeric(subjparams.extractsphere) && ~ischar(subjparams.extractsphere)
        error('extractsphere field must be a number or empty or a string')
    else
        subjparams.extractsphere='NaN';
        peakspherevaluesavg(:,ii)=NaN;
        peakspherevalueseig(:,ii)=NaN;
    end
    clear ind
    
    % Extract sphere around subject peak voxel within X mm of peak
    if subjparams.subjectpeak==1
        if isfield(subjparams,'searchsphere') && isnumeric(subjparams.searchsphere)
            ind=find(sum((XYZmm - repmat(voxels(ii,3:5)',1,size(XYZmm,2))).^2) <= subjparams.searchsphere^2);
            for jj=1:numel(subjhdrs)
                subjectpeak=find(subjimgs((jj-1)*prod(subjhdrs(1).dim)+ind)==max(subjimgs((jj-1)*prod(subjhdrs(1).dim)+ind)));
                subjectpeaklocationsvoxel{jj,ii}=XYZmm(:,ind(subjectpeak))';
                subjectpeaksvaluesvoxel(jj,ii)=subjimgs((jj-1)*prod(subjhdrs(1).dim)+ind(subjectpeak));
                if isfield(subjparams,'extractsphere') && isnumeric(subjparams.extractsphere)
                    ind2=find(sum((XYZmm - repmat(XYZmm(:,ind(subjectpeak)),1,size(XYZmm,2))).^2) <= subjparams.extractsphere^2);
                    subjectpeakspherevaluesvoxel(jj,ii)=mean(subjimgs((jj-1)*prod(subjhdrs(1).dim)+ind2));
                else
                    subjectpeakspherevaluesvoxel(jj,ii)=NaN;
                end
            end
        elseif isfield(subjparams,'searchsphere') && ~isnumeric(subjparams.searchsphere)
            error('searchsphere field must be a number or empty')
        end
        clear ind
    end 
end

if exist('region','var')
    clusterhead='temp_cluster.nii';
    regions=region;
end

if exist('regions','var')
    %Extractions using clusters
    try 
        clusterhead;
    catch
        clusterhead=spm_vol([mapparams.out '_thresh' num2str(mapparams.thresh2) '_extent' num2str(mapparams.cluster) mapparams.maskname '_clusters.nii']);
    end
    clusterimg=zeros(subjhdrs(1).dim(1:3));
    for p = 1:subjhdrs(1).dim(3),
        B = spm_matrix([0 0 -p 0 0 0 1 1 1]);
        M = inv(B*inv(subjhdrs(1).mat)*clusterhead.mat);
        Yp = spm_slice_vol(clusterhead,M,subjhdrs(1).dim(1:2),[0,NaN]);
        if prod(subjhdrs(1).dim(1:2)) ~= numel(Yp),
            error(['"',f,'" produced incompatible image.']); 
        end
        clusterimg(:,:,p) = reshape(Yp,subjhdrs(1).dim(1:2));
    end   

    % Extract all significant voxels
    ind=find(clusterimg>0);
    inds=zeros(1,numel(ind)*numel(subjhdrs));
    for jj=1:numel(ind)
        inds((jj-1)*numel(subjhdrs)+1:jj*numel(subjhdrs))=ind(jj):prod(subjhdrs(1).dim):prod(subjhdrs(1).dim)*numel(subjhdrs);
    end
    inds=sort(inds);
    data=reshape(subjimgs(inds),numel(ind),numel(subjhdrs));
    [allvalueavg allvalueeig]=regionalcomps(data',subjparams.nanmethod);
    clear ind inds
    
    % Extract clusters
    clustervalueavg=zeros(numel(subjhdrs),max(voxels(:,7)))*NaN;
    clustervalueeig=zeros(numel(subjhdrs),max(voxels(:,7)))*NaN;
    if subjparams.subjectpeak==1
        subjectpeaklocationscluster=cell(numel(subjhdrs),max(voxels(:,7)));
        subjectpeakspherevaluescluster=zeros(numel(subjhdrs),max(voxels(:,7)))*NaN;
        subjectpeaksvaluescluster=zeros(numel(subjhdrs),max(voxels(:,7)))*NaN;  
    end
    for ii=1:max(voxels(:,7))
        ind=find(clusterimg==ii);
        inds=zeros(1,numel(ind)*numel(subjhdrs));
        for jj=1:numel(ind)
            inds((jj-1)*numel(subjhdrs)+1:jj*numel(subjhdrs))=ind(jj):prod(subjhdrs(1).dim):prod(subjhdrs(1).dim)*numel(subjhdrs);
        end
        inds=sort(inds);
        data=reshape(subjimgs(inds),numel(ind),numel(subjhdrs));
        [clustervalueavg(:,ii) clustervalueeig(:,ii)]=regionalcomps(data',subjparams.nanmethod);
        clear inds
   
        % Extract peak voxel and sphere around subject peak voxel, 1 per
        % cluster
        if subjparams.subjectpeak==1
            for jj=1:numel(subjhdrs)
                subjectpeak=find(subjimgs((jj-1)*prod(subjhdrs(1).dim)+ind)==max(subjimgs((jj-1)*prod(subjhdrs(1).dim)+ind)));
                subjectpeaklocationscluster{jj,ii}=XYZmm(:,ind(subjectpeak))';
                subjectpeaksvaluescluster(jj,ii)=subjimgs((jj-1)*prod(subjhdrs(1).dim)+ind(subjectpeak));
                if isfield(subjparams,'extractsphere') && isnumeric(subjparams.extractsphere)
                    ind2=find(sum((XYZmm - repmat(XYZmm(:,ind(subjectpeak)),1,size(XYZmm,2))).^2) <= subjparams.extractsphere^2);
                    subjectpeakspherevaluescluster(jj,ii)=mean(subjimgs((jj-1)*prod(subjhdrs(1).dim)+ind2));
                else
                    subjectpeakspherevaluescluster(jj,ii)=NaN;
                end
                clear ind2
            end
        end
        clear ind inds
    end
end

if exist('region','var')
    %Extractions using clusters
    clusterhead=spm_vol('temp_cluster.nii');
    for p = 1:subjhdrs(1).dim(3),
        B = spm_matrix([0 0 -p 0 0 0 1 1 1]);
        M = inv(B*inv(subjhdrs(1).mat)*clusterhead.mat);
        Yp = spm_slice_vol(clusterhead,M,subjhdrs(1).dim(1:2),[0,NaN]);
        if prod(subjhdrs(1).dim(1:2)) ~= numel(Yp),
            error(['"',f,'" produced incompatible image.']); 
        end
        clusterimg(:,:,p) = reshape(Yp,subjhdrs(1).dim(1:2));
    end   
    eval('!rm temp_cluster.nii')
    
    % Extract clusters
    clustervalueavg=zeros(numel(subjhdrs),1);
    clustervalueeig=zeros(numel(subjhdrs),1);
    ind=find(clusterimg==1);
    inds=zeros(1,numel(ind)*numel(subjhdrs));
    for jj=1:numel(ind)
        inds((jj-1)*numel(subjhdrs)+1:jj*numel(subjhdrs))=ind(jj):prod(subjhdrs(1).dim):prod(subjhdrs(1).dim)*numel(subjhdrs);
    end
    inds=sort(inds);
    data=reshape(subjimgs(inds),numel(ind),numel(subjhdrs));
    [clustervalueavg(:,ii) clustervalueeig(:,ii)]=regionalcomps(data',subjparams.nanmethod);
    clear inds
end


%Initialize outputs
if exist('regions','var') 
    tempa=cell(1,numel(unique(voxels(:,7))));
    tempb=cell(1,numel(unique(voxels(:,7))));
    tempc=cell(numel(subjhdrs),numel(unique(voxels(:,7))));
    tempd=cell(numel(subjhdrs),numel(unique(voxels(:,7))));
    for ii=1:numel(unique(voxels(:,7)))
        tempa{1,ii}=['average @ cluster number ' num2str(ii)];
        tempb{1,ii}=['eigenvariate @ cluster number ' num2str(ii)];
        if subjparams.subjectpeak==1
            for jj=1:numel(subjhdrs)
                tempc{jj,ii}=['subject peak @ ' num2str(subjectpeaklocationscluster{jj,ii})];
                tempd{jj,ii}=['subject peak ' num2str(subjparams.extractsphere) 'mm sphere @ ' num2str(subjectpeaklocationscluster{jj,ii})];
            end
        end
    end
end

if exist('region','var')
    tempa=cell(1,1);
    tempb=cell(1,1);
    tempc=cell(numel(subjhdrs),1);
    tempd=cell(numel(subjhdrs),1);
    tempa{1,1}=['average @ cluster number ' num2str(ii)];
    tempb{1,1}=['eigenvariate @ cluster number ' num2str(ii)];
end

tempi=cell(1,size(voxels,1));
tempe=cell(1,size(voxels,1));
tempf=cell(1,size(voxels,1));
tempg=cell(numel(subjhdrs),size(voxels,1));
temph=cell(numel(subjhdrs),size(voxels,1));
for ii=1:size(voxels,1)
    tempi{1,ii}=num2str(voxels(ii,3:5));
    tempe{1,ii}=['average ' num2str(subjparams.extractsphere) 'mm sphere @ ' num2str(voxels(ii,3:5))];
    tempf{1,ii}=['eigenvariate ' num2str(subjparams.extractsphere) 'mm sphere @ ' num2str(voxels(ii,3:5))];
    if subjparams.subjectpeak==1
        for jj=1:numel(subjhdrs)
            tempg{jj,ii}=['subject peak @ ' num2str(subjectpeaklocationsvoxel{jj,ii})];
            temph{jj,ii}=['subject peak ' num2str(subjparams.extractsphere) 'mm sphere @ ' num2str(subjectpeaklocationsvoxel{jj,ii})];
        end
    end
end

%Define outputs
if exist('region','var')
    resultscluster={clustervalueavg clustervalueeig};
    columnlistcluster={tempa tempb}; 
    resultsvoxels={peakvalues peakspherevaluesavg peakspherevalueseig};
    columnlistvoxels={tempi tempe tempf};
elseif subjparams.subjectpeak==1
    if exist('regions','var')
        resultscluster={allvalueavg allvalueeig clustervalueavg clustervalueeig subjectpeaksvaluescluster subjectpeakspherevaluescluster};
        columnlistcluster={'global average' 'global eigenvariate' tempa tempb tempc tempd}; 
    end
    resultsvoxels={peakvalues peakspherevaluesavg peakspherevalueseig subjectpeaksvaluesvoxel subjectpeakspherevaluesvoxel};
    columnlistvoxels={tempi tempe tempf tempg temph};
else
    if exist('regions','var')
        resultscluster={allvalueavg allvalueeig clustervalueavg clustervalueeig};
        columnlistcluster={'global average' 'global eigenvariate' tempa tempb};
    end
    resultsvoxels={peakvalues peakspherevaluesavg peakspherevalueseig};
    columnlistvoxels={tempi tempe tempf};
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Embedded Functions
function [avg eig]=regionalcomps(y,nanmethod)
    eig      = zeros(size(y,1),1)*NaN;
    avg      = zeros(size(y,1),1)*NaN;
    rows=1:1:size(y,1);
    if nanmethod==1
        columns=~any(isnan(y), 1);
        y2=y(:,columns);
        if size(y2,2)==0
            disp('No common voxels, use nanmethod=3 to analyze')
            eig(:)      = NaN;
            avg(:) = NaN;
            return
        end
    elseif nanmethod==2
        rows=~any(isnan(y), 2);
        y2=y(rows,:);
        if size(y2,1)==0
            disp('No subjects with all voxels, use nanmethod=3 to analyze')
            eig(:)      = NaN;
            avg(:) = NaN;
            return
        end
    elseif numel(isnan(y))>0 %nanmethod3
        eig(:)      = NaN;
        avg                 = nanmean(y,2);
        return
    else
        y2=y;
    end
    
    [m n]   = size(y2);
    if m > n
        [v s v] = svd(y2'*y2);
        s       = diag(s);
        v       = v(:,1);
        u       = y2*v/sqrt(s(1));
    else
        [u s u] = svd(y2*y2');
        s       = diag(s);
        u       = u(:,1);
        v       = y2'*u/sqrt(s(1));
    end
    d       = sign(sum(v));
    u       = u*d;
    v       = v*d;
    eig(rows,:)     = (u*sqrt(s(1)/n));
    avg(rows,:)     = mean(y2,2);
end