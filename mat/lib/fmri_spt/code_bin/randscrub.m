%(c) 2012, Ameera X. Patel, University of Cambridge

function [] = randscrub(tsmat,framesno)

pref=strtok(tsmat,'.');

ts=load(tsmat);
tso=ts;

frames=str2double(framesno);

lb=1;
ub=size(ts,1);

if  frames>=ub
    fprintf('\nThe number of frames to be removed is greater than or equal the number of time points \nin the dataset. Please select a smaller number of frames\n')
else

    rem=lb+(ub-lb).*rand(frames*10,1);
    rem=round(rem);

    [u,I]=unique(rem,'first');
    rem=rem(sort(I));

    del=rem((1:frames),1);

    scrub=sort(del,'descend');    
    ts(scrub,:)=[];     

    dlmwrite(sprintf('%s_randscrub.txt',pref),ts);

    len=(length(scrub)/ub)*100;

    fprintf('\n\nTotal number of frames removed: %d\n',length(scrub)) 
end

end
