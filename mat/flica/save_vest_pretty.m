% Prettier version of save_vest, using %g instead of %e.

function save_vest_pretty(x,filename)

% write_vest(x,filename)
%
% writes x in vest format where size(x) is ntpts*nevs (NumPoints*NumWaves)

fp=fopen(filename,'w');

dims = size(x);

fprintf(fp,'! VEST-Waveform File\n');
fprintf(fp,'/NumWaves\t%i\n',dims(2));
fprintf(fp,'/NumPoints\t%i\n',dims(1));
fprintf(fp,'/Skip\n');
fprintf(fp,'\n/Matrix\n');

for t=1:dims(1),
  for e=1:dims(2),
    fprintf(fp,'%g\t',x(t,e));
  end;
  fprintf(fp,'\n');
end;

fclose(fp);
