%(c) 2012, Ameera X. Patel, University of Cambridge

function [] = cloud(ts,sts,xyz,output)

ncorr=load(ts);
scorr=load(sts);
coord=load(xyz);

coord=coord';

dr=scorr-ncorr;

pd=pdist(coord);
euc=squareform(pd);

dr=triu(dr,1);
euc=triu(euc,1);

len=(size(euc,2)^2);
cl=zeros(len,2);

cl(:,1)=reshape(euc,len,1);
cl(:,2)=reshape(dr,len,1);

remove=(intersect(find(cl(:,1)==0),find(cl(:,2)==0)));
remove=sort(remove,'descend');

cl(remove,:)=[];

std=sortrows(cl,1);
ct=1;
fit=[];

for i=1:floor(size(std,1)/100);
    fit(i,1)=mean(std(ct:ct+99,1));
    fit(i,2)=mean(std(ct:ct+99,2));
    ct=ct+100;
end

dlmwrite(sprintf('%s.txt',output),cl,' ');
dlmwrite(sprintf('%s_fit.txt',output),fit,' ');

end