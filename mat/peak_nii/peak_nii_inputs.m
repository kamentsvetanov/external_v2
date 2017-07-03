function [outstructure, errors, errorval]=peak_nii_inputs(instructure,hdrname,outputargs)
% Checks whether inputs are valid or not.
%
%   ppi_nii_inputs.v7 -- Last modified on 05/20/2014 by Donald G. McLaren, PhD
%   (mclaren@nmr.mgh.harvard.edu)
%   GRECC, Bedford VAMC
%   Department of Neurology, Massachusetts General Hospital and Havard
%   Medical School
%
% License:
%   Copyright (c) 2011-12, Donald G. McLaren and Aaron Schultz
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
%   Change Log:
%     4/11/2001: Allows threshold to be -Inf
%     2/8/2012: Added fields needed for corrected statistics and small
%     volume corrections.
%     2/11/2012: Added fields needed for selecting specific voxels.
%     11/20/2012: Switched to getLabelMap for getting ROILABELS. Now
%     compatible with FIVE.
%     11/20/2012: Only grab cluster centers, for binary or clustered
%     images. clustercenter option
%     05/20/2014: Fixed bugs and added save corrected feature

errorval=[];
errors={};
err=1;
%% Format input instructure
pass=0;
while numel(fields(instructure))==1 && pass==0
    F=fieldnames(instructure);
    if isstruct(instructure.(F{1}))
        instructure=instructure.(F{1}); %Ignore coding error flag.
    else
        pass=1;
    end
end

%% Check for UID
if isfield(instructure,'UID')
    if ischar(instructure.UID)
        outstructure.UID=instructure.UID;
    elseif iscell(instructure.UID)
        outstructure.UID=instructure.UID{1};
    else
        errors{err}='UID must be a string or cell array of 1 cell';
        err=err+1;
    end
    if ~strncmp(outstructure.UID,'_',1) && numel(outstructure.UID~=0)
        outstructure.UID=['_' outstructure.UID];
    end
else
    outstructure.UID=datestr(clock,30);
end
%% outfile
try
    outstructure.out=instructure.out;
    if isempty(outstructure.out)
        vardoesnotexist; % triggers catch statement
    end
    path=fileparts(outstructure.out);
    if isempty(path)
        path=pwd;
    end
catch
    outstructure.out=[];
end
if (isfield(instructure,'UID') && ~isempty(instructure.UID)) && isempty(outstructure.out) % edit KAT || to &&
    [path,file]=fileparts(hdrname);
    if ~isempty(path)
        outstructure.out=[path filesep file '_peaks' outstructure.UID];
    else
        path=pwd;
        outstructure.out=[file '_peaks' outstructure.UID];
    end
end

%% sign of data
try
    outstructure.sign=instructure.sign;
    if ~strcmpi(outstructure.sign,'pos') && ~strcmpi(outstructure.sign,'neg')
        vardoesnotexist; % triggers catch statement
    end
catch
    outstructure.sign='pos';
    disp('Using default option of positives for sign')
end

%% threshold
try
    outstructure.thresh=instructure.thresh;
    if ~isnumeric(outstructure.thresh) || isempty(outstructure.thresh)
        vardoesnotexist; % triggers catch statement
    end
    if outstructure.thresh<0
        if strcmpi(outstructure.sign,'neg')
            outstructure.thresh=outstructure.thresh*-1;
        elseif outstructure.thresh==-Inf
        else
            vardoesnotexist; % triggers catch statement
        end
    end
catch
    outstructure.thresh=0;
    disp('Using default option of 0 for threshold')
end

%% statistic type (F or T)
try
    outstructure.type=instructure.type;
    if ~strcmpi(outstructure.type,'T') && ~strcmpi(outstructure.type,'F') && ~strcmpi(outstructure.type,'none') && ~strcmpi(outstructure.type,'Z')
        vardoesnotexist; % triggers catch statement
    end
catch
    if outstructure.thresh<1 && outstructure.thresh>0
        errors{err}=['Statistic must defined using: ' instructure.type];
        err=err+1;
    else
        outstructure.type='none';
    end
end

%% voxel limit
try
    outstructure.voxlimit=instructure.voxlimit;
    if ~isnumeric(outstructure.voxlimit) || outstructure.voxlimit<0
        vardoesnotexist; % triggers catch statement
    end
catch
    outstructure.voxlimit=1000;
    disp('Using default option of 1000 for voxel limit')
end

%% separation distance for peaks
try
    outstructure.separation=instructure.separation;
    if ~isnumeric(outstructure.separation) || outstructure.separation<0
        vardoesnotexist; % triggers catch statement
    end
catch
    outstructure.separation=8;
    disp('Using default option of 8mm for separate peaks')
end

%% Output peaks or collapse peaks within a cluster (0 collapse peaks closer
% than separation distance, 1 remove peaks closer than separation distance
% to mirror SPM)
try
    outstructure.SPM=instructure.SPM;
    if ~isnumeric(outstructure.SPM) || (outstructure.SPM~=0 && outstructure.SPM~=1)
        vardoesnotexist; % triggers catch statement
    end
catch
    outstructure.SPM=0;
    disp('Using default option of collapsing peaks, this is not similar to SPM')
end
%% Connectivity radius
try
    outstructure.conn=instructure.conn;
    if ~isnumeric(outstructure.conn) || (outstructure.conn~=6 && outstructure.conn~=18 && outstructure.conn~=26)
        vardoesnotexist; % triggers catch statement
    end
catch
    outstructure.conn=18;
    disp('Using default option of face connected voxels, 18-voxel neighborhood')
end
%% Cluster extent threshold
try
    outstructure.cluster=instructure.cluster;
    if ~isnumeric(outstructure.cluster) || outstructure.cluster<0
        vardoesnotexist; % triggers catch statement
    end
catch
    outstructure.cluster=0;
    disp('Using default option of 0 voxels for cluster extent. This is BAD!!!!')
    %0 is acceptable for voxelwise correction (hence no warning is generated).
    %and is set to 0 for voxelwise corrections. To keep the specified cluster
    %size during correction, set savedcorrected.changecluster=1. This will
    %change the cluster size from 0 to the specified cluster size (or rather
    %stop the clustersize from being set to 0. Note that this will be a more
    %severe correction because you have specified an extent on top of the
    %voxelwise correction.
end
%% mask file
try
    outstructure.mask=instructure.mask;
    if iscell(outstructure.mask)
        outstructure.mask=outstructure.mask{1};
    end
    if ~isempty(outstructure.mask) && ~exist(outstructure.mask,'file')
        vardoesnotexist; % triggers catch statement
    end
catch
    outstructure.mask='';
    disp('Using default option of no mask')
end

%% degrees of freedom numerator
try
    outstructure.df1=instructure.df1;
    if ~isnumeric(outstructure.df1) || outstructure.df1<1
        vardoesnotexist; % triggers catch statement
    end
catch
    if (strcmpi(outstructure.type,'T') || strcmpi(outstructure.type,'F')) && (outstructure.thresh>0 && outstructure.thresh<1)
        errors{err}='degrees of freedom numerator must be defined using df1 field; can be gotten from SPM';
        err=err+1;
    else
        outstructure.df1=[];
    end
end

%% degrees of freedom denominator
try
    outstructure.df2=instructure.df2;
    if ~isnumeric(outstructure.df2) || outstructure.df2<1
        vardoesnotexist; % triggers catch statement
    end
catch
    if (strcmpi(outstructure.type,'F')) && (outstructure.thresh>0 && outstructure.thresh<1)
        errors{err}='degrees of freedom denominator must be defined using df2 field; can be gotten from SPM';
        err=err+1;
    else
        outstructure.df2=[];
    end
end

%% Convert threshold p-value to its T,F, or Z-value equivalent
if (strcmpi(outstructure.type,'T') || strcmpi(outstructure.type,'F') || strcmpi(outstructure.type,'Z')) && (outstructure.thresh>0 && outstructure.thresh<1)
    if strcmpi(outstructure.type,'T')
        outstructure.inputthresh=outstructure.thresh;
        outstructure.thresh = spm_invTcdf(1-outstructure.thresh,outstructure.df1);
    elseif strcmpi(outstructure.type,'F')
        outstructure.inputthresh=outstructure.thresh;
        outstructure.thresh = spm_invFcdf(1-outstructure.thresh,outstructure.df1,outstructure.df2);
    else
        outstructure.inputthresh=outstructure.thresh;
        outstructure.thresh=norminv(1-outstructure.thresh,0,1);
    end
end

%% Check exact field
if ~isfield(instructure,'exact') || ~isnumeric(instructure.exact) || instructure.exact~=1
    outstructure.exact=0;
else
    outstructure.exact=instructure.exact;
    if outstructure.cluster<=0
        errors{err}='Cluster must be greater than 0';
        err=err+1;
    end
    img=spm_read_vols(spm_vol(outstructure.mask));
    if outstructure.cluster>sum(img(:)>0)
        errors{err}='Cluster must be smaller than mask';
        err=err+1;
    end
end

%% Check for maskname
if isfield(instructure,'maskname') && ~isempty(outstructure.mask)
   if ischar(instructure.maskname)
       outstructure.maskname=instructure.maskname;
   elseif iscell(instructure.maskname)
       outstructure.maskname=instructure.maskname{1};
   else
       errors{err}='Maskname must be a string or cell array of 1 cell';
       err=err+1;
   end
   if ~strncmp(outstructure.maskname,'_',1) && isempty(outstructure.maskname) && ~isempty(outstructure.mask)
        [maskpath maskfilename]=fileparts(outstructure.mask);
        outstructure.maskname=['_' maskfilename];
   elseif ~strncmp(outstructure.maskname,'_',1) && ~isempty(outstructure.maskname)
       outstructure.maskname=['_' outstructure.maskname];
   else
       outstructure.maskname='';
   end
elseif ~isempty(outstructure.mask)
    [maskpath maskfilename]=fileparts(outstructure.mask);
    outstructure.maskname=['_' maskfilename];
else
   outstructure.maskname='';
end

%% Check if clusters should be spheres or restricted to a radius around a peak
if isfield(instructure,'sphere')
    if ~isempty(instructure.sphere) && ~isnumeric(instructure.sphere)
        outstructure.sphere=str2double(instructure.sphere);
        if ~isnumeric(outstructure.sphere)
            disp('Using no sphere radius because it was not set correctly')
        end
    elseif ~isempty(instructure.sphere) && isnumeric(instructure.sphere)
        outstructure.sphere=instructure.sphere;
    else
        outstructure.sphere=instructure.sphere;
    end
else
    outstructure.sphere=[];
end

if isfield(instructure,'clustersphere')
    if ~isempty(instructure.clustersphere) && ~isnumeric(instructure.clustersphere)
        outstructure.clustersphere=str2double(instructure.clustersphere);
        if ~isnumeric(outstructure.clustersphere)
            disp('Using no sphere radius because it was not set correctly')
        end
    elseif ~isempty(instructure.clustersphere) && isnumeric(instructure.clustersphere)
        outstructure.clustersphere=instructure.clustersphere;
    elseif isempty(instructure.clustersphere)
        outstructure.clustersphere=instructure.clustersphere;
    end
else
    outstructure.clustersphere=[];
end
if ~isempty(outstructure.clustersphere) && ~isempty(outstructure.clustersphere)
    errors{err}='You must choose either sphere or clustersphere one of these. Choosing both has broken the program.';
    err=err+1;
end

%% Check for small volume correction (using the mask to limit the search volume rather than using the whole brain for statistics)
try
    outstructure.SV=instructure.SV;
    if ~isnumeric(outstructure.SV) || size(outstructure.SV,1)~=1 || size(outstructure.SV,1)~=1
        vardoesnotexist; % triggers catch statement
    end
    if outstructure.SV==1 && isempty(outstructure.mask)
        errors{err}='You must specify a mask to use small volume correction.';
        err=err+1;
    end
catch
    outstructure.SV=0;
    disp('Using default option of whole brain for statistics, even if there is a mask.')
end

%% Check for RESELS and FWHM
if isfield(instructure,'RESELS') && size(instructure.RESELS,1)==1 && size(instructure.RESELS,2)==4
    outstructure.RESELS=instructure.RESELS;
    if isfield(instructure,'FWHM') && size(instructure.FWHM,1)==1 && size(instructure.FWHM,2)==3
        outstructure.FWHM=instructure.FWHM;
        if outstructure.SV
            outstructure=rmfield(outstructure,'RESELS');
        end
    else
        outstructure=rmfield(outstructure,'RESELS');
        disp('Using the default of no RESELS. FWHM was incorrectly specified or missing.')
    end
end
if isfield(instructure,'FWHM') && size(instructure.FWHM,1)==1 && size(instructure.FWHM,2)==3
    outstructure.FWHM=instructure.FWHM;
    if exist([path filesep 'I.mat'],'file')==2
        try
            maskhdr=spm_vol([path filesep 'NN.nii']);
            if outstructure.SV
                maskhdr(2) = spm_vol(outstructure.mask);
                FWHM=outstructure.FWHM.*(sqrt(sum(maskhdr(1).mat(1:3,1:3).^2))./sqrt(sum(maskhdr(2).mat(1:3,1:3).^2)));
            end
        catch
            if outstructure.SV
                errors{err}='Missing a file: ***Check location of NN.nii image****';
                err=err+1;
            end
        end
    elseif exist([path filesep 'SPM.mat'],'file')==2
        try
            if exist([path filesep 'mask.img'],'file')==2
                maskhdr=spm_vol([path filesep 'mask.img']);
            elseif exist([path filesep 'mask.nii'],'file')==2
                maskhdr=spm_vol([path filesep 'mask.nii']);
            else
                triggercatch
            end
            
            if outstructure.SV
                maskhdr(2) = spm_vol(outstructure.mask);
                FWHM=outstructure.FWHM.*(sqrt(sum(maskhdr(1).mat(1:3,1:3).^2))./sqrt(sum(maskhdr(2).mat(1:3,1:3).^2)));
            end
        catch
            if outstructure.SV
                errors{err}='Missing a file: ***Check location of mask.img/mask.nii image****';
                err=err+1;
            end
        end
    else
        disp('Using the default of no RESELS. Mask file could not be found.')
    end
    try
        if outstructure.SV
            RESELS=spm_resels_vol(maskhdr(2),FWHM)';
        else
            RESELS=spm_resels_vol(maskhdr,outstructure.FWHM)';
        end
        if ~isfield(outstructure,'RESELS')
            outstructure.RESELS=RESELS;
        elseif isfield(outstructure,'RESELS') && all(outstructure.RESELS==RESELS)
            outstructure.RESELS=RESELS;
        else
            try outstructure=rmfield(outstructure,'RESELS'); catch; end
            disp('Using the default of no RESELS. Computed RESELS based on FWHM do not match the specified RESELS value.')
        end
    catch
        disp('Using the default of no RESELS. Mask file could not be found.')
    end
else
    disp('Using the default of no RESELS. FWHM was incorrectly specified or missing.')
end

%% Check for corrected threshold
if isfield(instructure,'threshc')
    outstructure.threshc=instructure.threshc;
    if ~isnumeric(outstructure.threshc) ||  outstructure.threshc<0 || outstructure.threshc>1
        outstructure.threshc=.05;
        disp('Using the default corrected threshold of p<0.05.')
    end
else
    outstructure.threshc=.05;
    disp('Using the default corrected threshold of p<0.05.')
end

%% Check for saving corrected maps
if isfield(instructure,'correctedloop') && instructure.correctedloop==1
    outstructure.correction=instructure.correction;
    outstructure.correctionthresh=instructure.correctionthresh;
    outstructure.savecorrected.do=0;
else
    if isfield(instructure,'savecorrected')
        outstructure.savecorrected=instructure.savecorrected;
        if isfield(instructure.savecorrected,'do') && isnumeric(instructure.savecorrected.do) && instructure.savecorrected.do==0
            outstructure.savecorrected.do=0;
            disp('Not saving corrected output, even if a corrected map was specified.')
        else
            try
                outstructure.savecorrected=rmfield(outstructure.savecorrected,'do');
            end
        end
        if isfield(instructure.savecorrected,'type') && ~isfield(outstructure.savecorrected,'do')
            if iscellstr(instructure.savecorrected.type)
                count=0;
                jj=1;
                for tt=1:numel(instructure.savecorrected.type)
                    if any(strcmp(instructure.savecorrected.type{tt},{'cFWE' 'cFDR' 'vFWE''vFDR' 'tFDR26' 'tFDR18'}))
                        type(tt)=instructure.savecorrected.type(tt);
                        jj=jj+1;
                    else
                        count=1+count;
                    end
                end
                outstructure.savecorrected.type=type;
                clear type
                if count==numel(instructure.savecorrected.type)
                    outstructure.savecorrected.do=0;
                    disp('No correction type specified correctly.')
                    disp('Using the default option of not saving corrected output.')
                else
                    outstructure.savecorrected.do=1;
                end
                if jj-1~=tt
                    disp(['WARNING: Not all correction times were valid (' num2str(jj-1) ' out of ' num2str(tt) ' were valid). Program will use all valid corrections'])
                end
            elseif ischar(instructure.savecorrected.type) && any(strcmp(instructure.savecorrected.type,{'cFWE' 'cFDR' 'vFWE''vFDR' 'tFDR26' 'tFDR18'}))
                outstructure.savecorrected.do=1;
                outstructure.savecorrected.type=cellstr(instructure.savecorrected.type);
            else
                outstructure.savecorrected.do=0;
                disp('Using the default option of not saving corrected output.')
            end
            if ~isfield(instructure.savecorrected,'changecluster') || ~isnumeric(instructure.savecorrected.changecluster) || instructure.savecorrected.changecluster~=1
                outstructure.savecorrected.changecluster=0;
            else
                outstructure.savecorrected.changecluster=1;
            end
        elseif isfield(instructure.savecorrected,'type') && isfield(outstructure.savecorrected,'do')
            outstructure.savecorrected=rmfield(outstructure.savecorrected,'type');
            try outstructure.savecorrected=rmfield(outstructure.savecorrected,'changecluster'); catch; end
        else
            outstructure.savecorrected.do=0;
            disp('Using the default option of not saving corrected output.')
        end
    else
        outstructure.savecorrected.do=0;
        disp('Using the default option of not saving corrected output.')
    end
end

%% Check for exactvoxel
if isfield(instructure,'exactvoxel')
    outstructure.exactvoxel=1;
end

%% Check if this is from FIVE and FIVE only wants sigthresh field
if isfield(instructure,'FIVE')
    if isnumeric(instructure.FIVE) && instructure.FIVE==0
        outstructure.FIVE=instructure.FIVE;
    else
        outstructure.FIVE=1;
    end
else
    outstructure.FIVE=0;
end

%% Check for clustercenter option
if isfield(instructure,'clustercenter') && ~iscell(instructure.clustercenter) && any(instructure.clustercenter)~=0
    outstructure.clustercenter=1;
else
    outstructure.clustercenter=0;
end

%% Check for Peak Labels
try
    outstructure.label.source=instructure.label;
    [regionfile, labelfile, outstructure.label, errorval]=getLabelMap(outstructure.label.source);
    if ~isempty(errorval)
        errordlg(errorval, 'Atlas Error Dialog')
        return
    end
catch
    try
        outstructure.label.source=instructure.label.source;
        [regionfile, labelfile, outstructure.label, errorval]=getLabelMap(outstructure.label.source);
        if ~isempty(errorval)
            errordlg(errorval, 'Atlas Error Dialog')
            return
        end
    catch
        outstructure.label.source={};
        disp('Using default option of no labels.')
    end
end
try
    outstructure.label.nearest=instructure.nearest;
    if ~isnumeric(outstructure.label.nearest) || (outstructure.label.nearest~=0 && outstructure.label.nearest~=1)
        vardoesnotexist; % triggers catch statement
    end
catch
    try
        outstructure.label.nearest=instructure.label.nearest;
        if ~isnumeric(outstructure.label.nearest) || (outstructure.label.nearest~=0 && outstructure.label.nearest~=1)
            vardoesnotexist; % triggers catch statement
        end
    catch
        outstructure.label.nearest=0;
        disp('Using default option of not using the nearest region label.')
    end
end

% Labels needed?
if (outputargs>4) && isempty(outstructure.label.source)
    errors{err}='Labels must be specified';
end
return