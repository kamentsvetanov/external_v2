function [Data_Corrected, ClusterSize]=y_GRF_Threshold(StatsImgFile,VoxelPThreshold,IsTwoTailed,ClusterPThreshold,OutputName,MaskFile,Flag,Df1,Df2)
% function [Data_Corrected]=y_GRF_Threshold(StatsImgFile,VoxelPThreshold,IsTwoTailed,ClusterPThreshold,OutputName,MaskFile,Flag,Df1,Df2)
% Function to perform Gaussian Random Field theory multiple comparison correction like easythresh in FSL.
% References:
% Flitney, D.E., & Jenkinson, M. 2000. Cluster Analysis Revisited. Tech. rept. Oxford Centre for Functional Magnetic Resonance Imaging of the Brain, Department of Clinical Neurology, Oxford University, Oxford, UK. TR00DF1.
% K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.
% Input:
%     StatsImgFile      - The statistical image file name. Could be either Z, T, F or R statistical image. T/F/R images will transformed into Z image (according to their degree of freedom Df1, Df2) to perform further smoothness estimation and cluster thresholding.
%     VoxelPThreshold   - P threshold for each voxel. Will be transformed into Z threshold in two-tailed way or one-tailed way. Note: FSL's Z>2.3 corresponds to one-tailed VoxelPThreshold = 0.0107. |Z|>2.3 corresponds to two-tailed VoxelPThreshold = 0.0214.
%     IsTwoTailed       - 0: in one-tailed way. 1: converting voxel P threshold to z threshold in two-tailed way. Correct positive values to Cluster P at ClusterPThreshold/2, and correct negative values to Cluster P at ClusterPThreshold/2. Together the Cluster P < ClusterPThreshold.
%     ClusterPThreshold - The final cluster-level P threshold
%     OutputName        - The output file name. Will be suffixed by'Z_ClusterThresholded_'.
%     MaskFile          - The mask file name. If empty (i.e., ''), then all voxels are included.
%     Flag              - 'Z', 'T', 'F' or 'R'. Indicate the type of the input statistical image
%     Df1               - The degree of freedom of the statistical image. For F statistical image, there is also Df2
%     Df2               - The second degree of freedom of F statistical image
% Output:
%     The image file (Z statistical image) after correction.
%     Data_Corrected    - The Data matrix after correction
%     ClusterSize       - The cluster size for cluster-level p threshold and can be used in REST Slice Viewer. (Note: corner connection is used in FSL)
%___________________________________________________________________________
% Written by YAN Chao-Gan 120120.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


[OutPath, OutName,OutExt]=fileparts(OutputName);
if isempty(OutPath)
    OutPath='.';
end

if strcmp(Flag,'Z')
    [dLh,resels,FWHM, nVoxels]=y_Smoothest(StatsImgFile, MaskFile);
else
    if ~exist('Df2','var')
        Df2=0;
    end
    [Z P] = y_TFRtoZ(StatsImgFile,[OutPath,filesep,'Z_BeforeThreshold_',OutName,OutExt],Flag,Df1,Df2);
    [dLh,resels,FWHM, nVoxels]=y_Smoothest([OutPath,filesep,'Z_BeforeThreshold_',OutName,OutExt], MaskFile);
end

if IsTwoTailed
    zThrd=norminv(1 - VoxelPThreshold/2);
else
    zThrd=norminv(1 - VoxelPThreshold);
end
fprintf('The voxel Z threshold for voxel p threshold %f is: %f.\n',VoxelPThreshold,zThrd);

% Note: If two-tailed way is used, then correct positive values to Cluster P at ClusterPThreshold/2, and correct negative values to Cluster P at ClusterPThreshold/2. Together the Cluster P < ClusterPThreshold.
fprintf('The Minimum cluster size for voxel p threshold %f and cluster p threshold %f is: ',VoxelPThreshold,ClusterPThreshold);
if IsTwoTailed
    ClusterPThreshold = ClusterPThreshold/2;
end

% Calculate Expectations of m clusters Em and exponent Beta for inference.
D=3;
Em = nVoxels * (2*pi)^(-(D+1)/2) * dLh * (zThrd*zThrd-1)^((D-1)/2) * exp(-zThrd*zThrd/2);
EN = nVoxels * (1-normcdf(zThrd)); %In Friston et al., 1994, EN = S*Phi(-u). (Expectation of N voxels)  % K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.
Beta = ((gamma(D/2+1)*Em)/(EN)) ^ (2/D); % K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.

% Get the minimum cluster size
pTemp=1;
ClusterSize=0;
while pTemp >= ClusterPThreshold
    ClusterSize=ClusterSize+1;
    pTemp = 1 - exp(-Em * exp(-Beta * ClusterSize^(2/D))); %K. Friston, K. Worsley, R. Frackowiak, J. Mazziotta, and A. Evans. Assessing the significance of focal activations using their spatial extent. Human Brain Mapping, 1:214?220, 1994.
end

fprintf('%f voxels\n',ClusterSize);

ConnectivityCriterion = 26; % Corner connection is used in FSL.

if strcmp(Flag,'Z')
    [BrainVolume, VoxelSize, Header]=rest_readfile(StatsImgFile);
else
    [BrainVolume, VoxelSize, Header]=rest_readfile([OutPath,filesep,'Z_BeforeThreshold_',OutName,OutExt]);
end

if ClusterSize > 0
    if IsTwoTailed % If Two Tailed, then correct negative values to Cluster P at ClusterPThreshold/2 first.
        BrainVolumeNegative = BrainVolume .* (BrainVolume <= -1*zThrd);
        [theObjMask, theObjNum]=bwlabeln(BrainVolumeNegative,ConnectivityCriterion);
        for x=1:theObjNum,
            theCurrentCluster = theObjMask==x;
            if length(find(theCurrentCluster)) < ClusterSize,
                BrainVolumeNegative(logical(theCurrentCluster))=0;
            end
        end
    else
        BrainVolumeNegative = 0;
    end
    
    % Correct positive values to Cluster P
    BrainVolume = BrainVolume .* (BrainVolume >= zThrd);
    [theObjMask, theObjNum]=bwlabeln(BrainVolume,ConnectivityCriterion);
    for x=1:theObjNum,
        theCurrentCluster = theObjMask==x;
        if length(find(theCurrentCluster)) < ClusterSize,
            BrainVolume(logical(theCurrentCluster))=0;
        end
    end
    
    BrainVolume = BrainVolume + BrainVolumeNegative;
end

Data_Corrected=BrainVolume;
[nDim1,nDim2,nDim3]=size(BrainVolume);
rest_writefile(BrainVolume,[OutPath,filesep,'Z_ClusterThresholded_',OutName,OutExt],[nDim1,nDim2,nDim3],VoxelSize, Header,'double');


