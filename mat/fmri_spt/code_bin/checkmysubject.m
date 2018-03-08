%(c) 2012, Ameera X. Patel, University of Cambridge

function [] = checkmysubject(tsmat,dvars,frd,rej,power)

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
   fprintf('\nUsing thresholds FD > 0.5 mm and DVARS > 0.3 percent above DVARS baseline')
else
   dv_th=5;
   fprintf('\nUsing thresholds FD > 0.5 mm and DVARS > 0.5 percent')
end

fd_th=0.5;

cdv=find(dv>dv_th);
cfd=find(fd>fd_th);

sc=union(cdv,cfd);

scrub=sort(sc,'descend');
ts(scrub,:)=[];     

len=(size(scrub,1)/size(tso,1));

fprintf('\nNumber of bad frames: %d',size(scrub,1))
fprintf('\nFraction of bad frames in dataset: %d',len)

reject=str2double(rej);

if len<reject;
    fprintf('\n\nKeep Dataset.')
else
    fprintf('\n\nReject dataset.\n')
end

end