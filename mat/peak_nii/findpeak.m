function peakinfo=findpeak(voxels,peak)
% Lists information about the peak requested.
% Usage: peakinfo=findpeak(clusters,peak)
% Inputs:
%   clusters: output from peak_extract_nii
%   peak: peak number to provide information (can be multiple)
%
% Output: 
%   peakinfo: table of useful information with column headers
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
% Last modified on 2/17/2011 by Donald G. McLaren (mclaren@nmr.mgh.harvard.edu)
%   GRECC, Bedford VAMC
%   Department of Neurology, Massachusetts General Hospital and Havard
%   Medical School
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Program
if ~all(size(voxels)==[1 2]) && size(voxels,2)~=7
    error('voxels did not come from peak_extract_nii');
end
if ~isnumeric(peak) || max(peak)>size(voxels{1},1) || min(peak)<1
    error('peak must be a number that is less than or equal to the number of peaks and greater than 0');
end
if all(size(voxels)==[1 2])
    peakinfo=cell(numel(peak)+1,7);
    peakinfo{1,6}='cluster number'; 
    peakinfo{1,7}='region name';
else
    peakinfo=cell(numel(peak)+1,6);
    peakinfo{1,6}='region name';
end
peakinfo{1,1}='cluster size'; 
peakinfo{1,2}='T/F-statistic'; 
peakinfo{1,3}='X';
peakinfo{1,4}='Y'; 
peakinfo{1,5}='Z'; 
if all(size(voxels)==[1 2])
    for ii=2:numel(peak)+1
        peakinfo{ii,1}=voxels{1}(peak(ii-1),1);
        peakinfo{ii,2}=voxels{1}(peak(ii-1),2);
        peakinfo{ii,3}=voxels{1}(peak(ii-1),3);
        peakinfo{ii,4}=voxels{1}(peak(ii-1),4);
        peakinfo{ii,5}=voxels{1}(peak(ii-1),5);
        peakinfo{ii,6}=voxels{1}(peak(ii-1),7);
        peakinfo{ii,7}=voxels{2}{peak(ii-1),1};
    end
else
    for ii=2:numel(peak)+1
        peakinfo{ii,1}=voxels{peak(ii-1),1};
        peakinfo{ii,2}=voxels{peak(ii-1),2};
        peakinfo{ii,3}=voxels{peak(ii-1),3};
        peakinfo{ii,4}=voxels{peak(ii-1),4};
        peakinfo{ii,5}=voxels{peak(ii-1),5};
        peakinfo{ii,6}=voxels{peak(ii-1),7};
    end
end
