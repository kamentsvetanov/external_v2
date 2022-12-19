function ts_summary = runts(tsuite, mode, logfile, tcase_list)
  
usage_str = ['Usage:  [ts_summary] = ', mfilename, ...
             '(tsuite, [mode], [logfile], [tcase_list])'];

if (nargin < 1 || nargin > 4)
  error(usage_str);
end

switch nargin
 case 1
  ts_summary = run_tsuite(tsuite);
 case 2
  ts_summary = run_tsuite(tsuite, mode);
 case 3
  ts_summary = run_tsuite(tsuite, mode, logfile);
 case 4
  ts_summary = run_tsuite(tsuite, mode, logfile, tcase_list);
 otherwise
  error('Too many arguments.');
end

  
return
  
