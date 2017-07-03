%(c) 2012, Ameera X. Patel, University of Cambridge

function [] = loess(motfd,dpbold,output)

fd=load(motfd);
dbold=load(dpbold);

[u,I]=sort(fd);

dbolds=zeros(size(dbold));

frames=length(fd);

for i=1:frames
    ind=I(i,1);
    dbolds(ind,:)=dbold(i,:);
end

len=size(dbold,1)*size(dbold,2);
dboldsv=reshape(dbolds,len,1);

loess=[];
step=size(dbold,2);

col=2.*round((5000/step)/2);
np=col*step;

counter=1;

for ii=1:step:(len-np);
    loess(counter,1)=mean(dboldsv((ii:(ii+np)),1));
    counter=counter+1;
end

nloess=zeros(frames,2);

for i=1:col/2
    nloess(i,2)=loess(1,1);
end

ncount=1;

for i=col/2:length(loess)
    nloess(i,2)=loess(ncount,1);
    ncount=ncount+1;
end

for i=length(loess):length(nloess);
      nloess(i,2)=loess(length(loess),1);
end

nloess(:,1)=sort(fd);

dlmwrite(sprintf('%s.txt',output),nloess,' ');