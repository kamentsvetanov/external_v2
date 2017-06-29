function StrFin = CatStruct2(Struct1, Struct2, SortOption)
% CatStruct2 - concatenate 2 structures
%
%   FinalStruct = CatStruct2(S1,S2) concates the structures S1 and S2 into one
%   structure FinalStruct. 
%
%   Example:
%     A.field1.sub1 = 1;
%     A.field1.sub2 = 'Char5'; 
%     A.field3 = 4;
%
%     B.field1.sub1 = [4,6,2];
%     B.field1.sub3 = {'a';'b'};
%     B.field2.sub7 = 6; 
%
%     FinalStruct = CatStruct2(A,B) 
%     % -> FinalStruct.field1.sub1 = [4,6,2];
%     %    FinalStruct.field1.sub2 = 'Char5';
%     %    FinalStruct.field1.sub3 = {'a';'b'};
%     %    FinalStruct.field3 = 4;
%     %    FinalStruct.field2.sub7 = 6;
%
%   CatStruct2(S1,S2,'sorted') will sort the fieldnames alphabetically.
%
%   All fieldnames will appear in the final structure, even the sub-structure 
%   fieldnames will appear. The fieldnames at each level will be compared, in 
%   case the field name is found in both structs, then the second occurence will
%   overwrite the value of the first. 
%
%   To sort the fieldnames of a structure A use:
%     A = CATSTRUCT(A,'sorted') ;
%
%   To concatenate two similar array of structs use simple concatenation:
%     A = dir('*.mat') ; B = dir('*.m') ; C = [A ; B] ;
%
%   When there is nothing to concatenate, the result will be an empty
%   struct (0x0 struct array with no fields). 
%
%   See also CAT, STRUCT, FIELDNAMES, STRUCT2CELL

% for Matlab R13 and up
% version 2.2 (oct 2008)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History
% Created:  2005
% Revisions
%   2.0 (sep 2007) removed bug when dealing with fields containing cell
%                  arrays (Thanks to Rene Willemink) 
%   2.1 (sep 2008) added warning and error identifiers
%   2.2 (oct 2008) fixed error when dealing with empty structs (Thanks to
%                  Lars Barring)






sorted = 0;
depth = 0;

if ~isstruct(Struct1) || ~isstruct(Struct2)
    error('CatStruct2:InvalidArgument','Input variables should be structures.');
end

if exist('SortOption','var')
    if strcmpi(SortOption,'sorted')
        sorted = 1;
    else
        error('CatStruct2:InvalidArgument','Third argument should be the string "sorted".');
    end    
end


while(1)
    FN1 = fieldnames(Struct1);
    Val1 = struct2cell(Struct1);
    FN2 = fieldnames(Struct2);
    Val2 = struct2cell(Struct2);
    
    % find non-common files
    [FN1d,ind1d] = setdiff(FN1,FN2);
    [FN2d,ind2d] = setdiff(FN2,FN1);
    
    % working register
    FN_W = [FN1d;FN2d];
    Val_W = [Val1(ind1d);Val2(ind2d)];
    
    % delete non-common fields from the initial structs
    FN1(ind1d)=[]; 
    Val1(ind1d)=[];
    FN2(ind2d)=[]; 
    Val2(ind2d)=[];
    
    % sorting common fields
    [FN1,IX1]=sort(FN1); 
    Val1=Val1(IX1);
    [FN2,IX2]=sort(FN2); 
    Val2=Val2(IX2);
    
    % finding non-struct fields
    indNS = find(~cellfun(@isstruct,Val2));
    
    % adding it to the final struct and deleting it from common fields
    FN_W =[FN_W;FN2(indNS)];
    Val_W=[Val_W;Val2(indNS)];
    
    FN1(indNS)=[]; 
    Val1(indNS)=[];
    FN2(indNS)=[]; 
    Val2(indNS)=[];
    
    if isempty(FN1)
        StrFin = cell2struct(Val_W, FN_W);
        StrFinFN{1,depth}(end+1,1)=StrCmpFN{1,depth}(1);
        StrFinVal{1,depth}(end+1,1)={StrFin};
        StrCmpFN{1,depth}(1)=[];
        StrCmpVal1{1,depth}(1)=[];
        StrCmpVal2{1,depth}(1)=[];
        
        while(1)
            if isempty(StrCmpVal1{1,depth})
                StrFin = cell2struct(StrFinVal{1,depth}, StrFinFN{1,depth});
                StrFinFN{1,depth}=[];
                StrFinVal{1,depth}=[];
                StrCmpFN{1,depth}=[];
                StrCmpVal1{1,depth}=[];
                StrCmpVal2{1,depth}=[];
                depth = depth-1;
                if depth~=0
                    StrFinFN{1,depth}(end+1,1)=StrCmpFN{1,depth}(1);
                    StrFinVal{1,depth}(end+1,1)={StrFin};
                    StrCmpFN{1,depth}(1)=[];
                    StrCmpVal1{1,depth}(1)=[];
                    StrCmpVal2{1,depth}(1)=[];
                else
                    break
                end
            else
                break
            end
        end
        if depth == 0
            break
        end
        Struct1=StrCmpVal1{1,depth}{1};
        Struct2=StrCmpVal2{1,depth}{1};
        
    else
        depth = depth+1;
        
        StrFinFN{1,depth}=FN_W;
        StrFinVal{1,depth}=Val_W;

        StrCmpFN{1,depth}=FN1;
        StrCmpVal1{1,depth}=Val1;
        StrCmpVal2{1,depth}=Val2;

        Struct1=StrCmpVal1{1,depth}{1};
        Struct2=StrCmpVal2{1,depth}{1};
    end
end

if sorted
    FNsort = fieldnames(StrFin);
    Valsort = struct2cell(StrFin);
    
    [FNfin,Isort]=sort(FNsort);
    Valsort = Valsort(Isort);
    
    StrFin = cell2struct(Valsort,FNfin);    
end