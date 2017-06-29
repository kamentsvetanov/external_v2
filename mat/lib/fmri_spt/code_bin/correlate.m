%(c) 2012, Ameera X. Patel, University of Cambridge

function [] = correlate(ts)

nts=load(ts);
p=strtok(ts,'.');

ncorr=corr(nts);

dlmwrite(sprintf('%s_corr.txt',p),ncorr,' ');

end