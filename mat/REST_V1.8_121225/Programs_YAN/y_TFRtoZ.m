function [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1,Df2)
% FORMAT [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1,Df2)
%   Input:
%     ImgFile - T, F or R statistical image which wanted to be converted to Z statistical value
%     OutputName - The output name
%     Flag   - 'T', 'F' or 'R'. Indicate the type of the input statsical image
%     Df1 - the degree of freedom of the statistical image. For F statistical image, there is also Df2
%     Df2 - the second degree of freedom of F statistical image
%   Output:
%     Z - Z statistical image. Also output as .img/.hdr.
%     P - The corresponding P value
%___________________________________________________________________________
% Written by YAN Chao-Gan 100424.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

[Data VoxelSize Header]=rest_readfile(ImgFile);

[nDim1,nDim2,nDim3]=size(Data);

rest_waitbar;
Z=zeros(nDim1,nDim2,nDim3);
P=ones(nDim1,nDim2,nDim3);
fprintf('\n\tT/F/R to Z Calculating...\n');
for i=1:nDim1
    rest_waitbar(i/nDim1, 'T/F/R to Z Calculating...', 'T/F/R to Z','Parent');
    fprintf('.');
    for j=1:nDim2
        for k=1:nDim3
            if Data(i,j,k)~=0;
                if strcmp(Flag,'F')
                    F=Data(i,j,k);
                    PTemp =1-fcdf(abs(F),Df1,Df2);
                    ZTemp=norminv(1 - PTemp/2)*sign(F);
                    P(i,j,k)=PTemp;
                    Z(i,j,k)=ZTemp;
                elseif strcmp(Flag,'T')
                    T=Data(i,j,k);
                    PTemp=2*(1-tcdf(abs(T),Df1));
                    ZTemp=norminv(1 - PTemp/2)*sign(T);
                    P(i,j,k)=PTemp;
                    Z(i,j,k)=ZTemp;
                elseif strcmp(Flag,'R')
                    R=Data(i,j,k);
                    PTemp=2*(1-tcdf(abs(R).*sqrt((Df1)./(1-R.*R)),Df1));
                    ZTemp=norminv(1 - PTemp/2)*sign(R);
                    P(i,j,k)=PTemp;
                    Z(i,j,k)=ZTemp;
                end
                
            end

        end
    end
end
Z(isnan(Z))=0;
P(isnan(P))=1;

Header.descrip=sprintf('{Z_[%.1f]}',1);
rest_writefile(Z,OutputName,[nDim1,nDim2,nDim3],VoxelSize, Header,'double');
% rest_WriteNiftiImage(Z,Header,OutputName);
% Header.descrip=sprintf('REST{P_[%.1f]}',Df_E);
% rest_WriteNiftiImage(P,Header,[OutputName(1:end-4),'_P','.img']);

rest_waitbar;
fprintf('\n\tT/F/R to Z Calculation finished.\n');