%(c) 2012, Ameera X. Patel, University of Cambridge

function [] = scrub(tsmat,dvars,frd,power,save)

pref=strtok(tsmat,'.');

dv=load(dvars);
fd=load(frd);
ts=load(tsmat);
tso=ts;

if str2num(power)==0
   dv_t=3;
   dvc=dv;
   dvc(find(dvc==0))=[];
   dv_min=min(dvc);
   dv_th=dv_min+dv_t;
   fprintf('\nScrubbing frames if FD > 0.5 mm and DVARS > 0.3 percent above DVARS baseline')
else
   dv_th=5;
   fprintf('\nScrubbing frames if FD > 0.5 mm and DVARS > 0.5 percent')
end

fd_th=0.5;

cdv=find(dv>dv_th);
cfd=find(fd>fd_th);

dvomit=[];
dvstart=cdv-1;
dvstop=cdv+2;
dvstart(find(dvstart<1))=1;
dvstop(find(dvstop>length(dv)))=length(dv);
for ii=1:length(dvstart);
    dvomit=union(dvomit,dvstart(ii):dvstop(ii));
end

fdomit=[];
fdstart=cfd-1;
fdstop=cfd+2;
fdstart(find(fdstart<1))=1;
fdstop(find(fdstop>length(fd)))=length(fd);
for ii=1:length(fdstart);
    fdomit=union(fdomit,fdstart(ii):fdstop(ii));
end

sc=intersect(dvomit,fdomit);

%sc=union(cdv,cfd); sc1=sc+1; scp=union(sc1,sc);

scrub=sort(sc,'descend');
    
ts(scrub,:)=[];     

dlmwrite(sprintf('%s_scrub.txt',pref),ts);

len=(size(scrub,2)/size(tso,1));

fprintf('\nTotal number of frames removed: %d',size(scrub,2))

if str2double(save)==1
   fprintf('\n\nSaving number of scrubbed frames and their indices as %s_scrub_frames.txt',pref)
   dlmwrite(sprintf('%s_scrub_frames.txt',pref),size(scrub,2));
   dlmwrite(sprintf('%s_scrub_frames.txt',pref),sort(scrub,'ascend'),'-append');
end

end