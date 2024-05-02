%
% nets_nodepartial - replace node timeseries with node partial timeseries
% Steve Smith, 2013
%
% [new_ts] = nets_nodepartial(ts); 
% ts can either be a single matrix or an FSLNets structure
%

function [newts] = nets_nodepartial(ts);

if size(ts,1) ~=1

  newts=ts;
  for i=1:size(ts,2)
    newts(:,i) = nets_unconfound( ts(:,i) , ts(:,setdiff(1:size(ts,2),i)) );
  end

else

  newts=ts; newts.ts=[];

  for s=1:ts.Nsubjects
    disp(sprintf('doing subject %d of %d\b\b\b',s,ts.Nsubjects))
    grot=nets_demean(ts.ts((s-1)*ts.NtimepointsPerSubject+1:s*ts.NtimepointsPerSubject,:));
    grot2=grot;
    for i=1:size(grot,2)
      grot2(:,i) = nets_unconfound( grot(:,i) , grot(:,setdiff(1:size(grot,2),i)) );
    end
    newts.ts=[newts.ts;grot2];
  end

end

