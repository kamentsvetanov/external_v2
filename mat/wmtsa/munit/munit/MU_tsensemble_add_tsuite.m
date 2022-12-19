function [tse] = MU_tsensemble_add_tsuite(tse, ts)
      
if (isempty(ts.pathstr))
  p = which(ts.name);
  [pathstr, name, ext, versn] = fileparts(p);
else
  curpath = pwd;
  cd(pathstr);
  pathstr = pwd;
  p = fullfile(pathstr, [ts.name '.m']);
end

ts.pathstr = pathstr;

tse.tsuites = [tse.tsuites ts];
  
return
