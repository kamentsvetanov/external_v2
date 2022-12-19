function res=RendementData(L,Type,Data)
N=length(Data);
M=round(N-L);
res=zeros(1,M);
    
if Type ==1
    for i=1:M
       res(i)=log(Data(i+L)/Data(i));
    end
end
if Type ==0
    for i=1:M
       res(i)=(Data(i+L)-Data(i))/Data(i);
    end
end
    res=res';
end