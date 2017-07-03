function y_MaskShrink(Maskfilename,OutMaskFileName,dilate_degree)
% FORMAT y_MaskShrink(Maskfilename,OutMaskFileName,dilate_degree)
%   Input:
%     Maskfilename - The mask file want to be shrinked
%     OutMaskFileName - The shrinked mask output
%     dilate_degree - How many voxels to be shrinked. E.g., 2 means shrink 2 voxels
%   Output:
%     OutMaskFileName - The shrinked mask output
%___________________________________________________________________________
% Written by YAN Chao-Gan 100424.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

%  loading the Mask file
[Mask_img, Mask_hdr]   = rest_ReadNiftiImage(Maskfilename);
RawImageDims =Mask_hdr.dim;

BinaryMaskTemp=~(Mask_img); %set voxels outside mask to 1, and enlarge "dilate_degree" voxel
[x,y,z] =ind2sub(RawImageDims, find(BinaryMaskTemp==1));
for i=1:dilate_degree
    % -x
    y(x==1)=[];z(x==1)=[]; x(x==1)=[];
    Coordinates_XYZ=[x,y,z];
    Growed_Coordinates_XYZ=[Coordinates_XYZ(:,1)-1, Coordinates_XYZ(:,2), Coordinates_XYZ(:,3)];
    [Index] =sub2ind(RawImageDims, Growed_Coordinates_XYZ(:,1), Growed_Coordinates_XYZ(:,2), Growed_Coordinates_XYZ(:,3));
    BinaryMaskTemp(Index)=1;
    % +x
    y(x==RawImageDims(1))=[];z(x==RawImageDims(1))=[]; x(x==RawImageDims(1))=[];
    Coordinates_XYZ=[x,y,z];
    Growed_Coordinates_XYZ=[Coordinates_XYZ(:,1)+1, Coordinates_XYZ(:,2), Coordinates_XYZ(:,3)];
    [Index] =sub2ind(RawImageDims, Growed_Coordinates_XYZ(:,1), Growed_Coordinates_XYZ(:,2), Growed_Coordinates_XYZ(:,3));
    BinaryMaskTemp(Index)=1;
    % -y
    x(y==1)=[]; z(y==1)=[]; y(y==1)=[];
    Coordinates_XYZ=[x,y,z];
    Growed_Coordinates_XYZ=[Coordinates_XYZ(:,1), Coordinates_XYZ(:,2)-1, Coordinates_XYZ(:,3) ];
    [Index] =sub2ind(RawImageDims, Growed_Coordinates_XYZ(:,1), Growed_Coordinates_XYZ(:,2), Growed_Coordinates_XYZ(:,3));
    BinaryMaskTemp(Index)=1;
    % +y
    x(y==RawImageDims(2))=[];z(y==RawImageDims(2))=[]; y(y==RawImageDims(2))=[];
    Coordinates_XYZ=[x,y,z];
    Growed_Coordinates_XYZ=[Coordinates_XYZ(:,1), Coordinates_XYZ(:,2)+1, Coordinates_XYZ(:,3)];
    [Index] =sub2ind(RawImageDims, Growed_Coordinates_XYZ(:,1), Growed_Coordinates_XYZ(:,2), Growed_Coordinates_XYZ(:,3));
    BinaryMaskTemp(Index)=1;
    % -z
    x(z==1)=[]; y(z==1)=[];z(z==1)=[];
    Coordinates_XYZ=[x,y,z];
    Growed_Coordinates_XYZ=[Coordinates_XYZ(:,1), Coordinates_XYZ(:,2), Coordinates_XYZ(:,3)-1 ];
    [Index] =sub2ind(RawImageDims, Growed_Coordinates_XYZ(:,1), Growed_Coordinates_XYZ(:,2), Growed_Coordinates_XYZ(:,3));
    BinaryMaskTemp(Index)=1;
    % +z
    x(z==RawImageDims(3))=[]; y(z==RawImageDims(3))=[];z(z==RawImageDims(3))=[];
    Coordinates_XYZ=[x,y,z];
    Growed_Coordinates_XYZ=[Coordinates_XYZ(:,1), Coordinates_XYZ(:,2), Coordinates_XYZ(:,3)+1];
    [Index] =sub2ind(RawImageDims, Growed_Coordinates_XYZ(:,1), Growed_Coordinates_XYZ(:,2), Growed_Coordinates_XYZ(:,3));
    BinaryMaskTemp(Index)=1;

    [x,y,z] =ind2sub(RawImageDims, find(BinaryMaskTemp==1) );
end

MaskData=double(~BinaryMaskTemp);
rest_WriteNiftiImage(MaskData,Mask_hdr,OutMaskFileName);

