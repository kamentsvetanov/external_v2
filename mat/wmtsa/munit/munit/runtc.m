function tc_summary = runtc(tcase, mode, logfile, test_list)
  
usage_str = ['Usage:  ', mfilename, ...
             '(tcase, [mode], [logfile], [test_list])'];

if (nargin < 1 || nargin > 4)
  error(usage_str);
end

switch nargin
 case 1
  tc_summary = run_tcase(tcase);
 case 2
  tc_summary = run_tcase(tcase, mode);
 case 3
  tc_summary = run_tcase(tcase, mode, logfile);
 case 4
  tc_summary = run_tcase(tcase, mode, logfile, test_list);
 otherwise
  error('Too many arguments.');
end

  
return
  
