function ts_summary = run_tsuite(tsuite, mode, logfile, tcase_list)
% run_tsuite -- Run a MUnit test suite.
%
%****f* Drivers/run_tsuite
%
% NAME
%   run_tsuite -- Run a MUnit test suite.
%
% SYNOPSIS
%   run_tsuite(tsuite, [mode], [logfile])
%
% INPUTS
%   * tsuite     -- test suite.
%   * mode       -- (optional) level of detail for output diagnostics.
%   * logfile    -- (optional) name of log file for writing output.
%   * tcase_list -- (optional) name(s) or ordinal number(s) of specific tests
%                   to run.
%                   (string or integer, or cell array of strings or integer).
%
% OUTPUTS
%   * ts_summary -- a test suite summary struct (ts_summary_s).
%
% SIDE EFFECTS
%
%
% SYNOPSIS
%   run_tsuite(tsuite)                       % default
%   run_tsuite(tsuite, mode)                 % specify level of detail mode.
%   run_tsuite(tsuite, '', logfile)          % specify log file.
%   run_tsuite(tsuite, '', '', tcase_list)   % specify tcases to run.

% DESCRIPTION
%   run_tsuite is the main driver for running a test suite.
%
%   mode argument controls level of detail of output as follows:
%    * 'silent'    -- no output.
%    * 'minimal'   -- print test case summary.
%    * 'normal'    -- print names of failed  tests and test case summary.
%    * 'verbose'   -- print all test names and their status, and test case summary.
%    * 'details'   -- print diagnostics while running tests as well all test names 
%                     and their status, and test case summary.
%
%   If logfile is specified, output is written to logfile.
%   Note: Info printed by tested functions is still displayed to console.
%
% EXAMPLE
%
%
% WARNINGS
%
%
% ERRORS
%
%
% NOTES
%
%
% BUGS
%
%
% TODO
%
%
% ALGORITHM
%
%
% REFERENCES
%
%
% SEE ALSO
%
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%   Application Drivers
%

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2004-04-28
%
% COPYRIGHT
%   (c) 2004, 2005 Charles R. Cornish
%
% CREDITS
%
%
% REVISION
%   $Revision: 112 $
%
%***

%   $Id: run_tsuite.m 112 2005-09-13 05:53:51Z ccornish $
  
usage_str = ['Usage:  [ts_summary] = ', mfilename, ...
             '(tsuite, [mode], [logfile], [tcase_list])'];
  
if (nargin < 1 || nargin > 4)
  error(usage_str);
end

if (isa(tsuite, 'function_handle'))
  ts = MU_tsuite_create(tsuite);
elseif (isa(tsuite, 'char'))
  ts = MU_tsuite_create(tsuite);
elseif (isa(tsuite, 'struct'))
  ts = tsuite;
else
  error('MUNIT:UnknownTestSuite', ...
        ['tsuite is not a valid name, function handle, or struct', ...
         ' for a test case']);
end


if (~exist('mode', 'var') || isempty(mode))
  mode = 'normal';
end


if (exist('logfile', 'var') && ~isempty(logfile))
  if (exist('logfile', 'file'))
    delete(logfile);
  end
  diary(logfile);
end

run_all_tcases = 1;
if (exist('tcase_list', 'var') && ~isempty(tcase_list))
  run_all_tcases = 0;
  if (ischar(tcase_list))
    tcase_name_list = {tcase_list};
  elseif (iscellstr(tcase_list))
    tcase_name_list = tcase_list;
  elseif (isnumeric(tcase_list))
    tcase_name_list = {};
    ii = 0;
    for (i = 1:length(tcase_list))
      tcase_num = tcase_list(i);
      if (tcase_num <= length(ts.tcases))
        ii = ii + 1;
        tcase_name_list{ii} = ts.tcases(tcase_num).name;
      else
        warning(['Specified test number (', num2str(tcase_num), ...
                 ') is out of range of number of available tests', ...
                 '(', num2str(length(ts.tcases)), ')']);
      end
    end
  else
    error('MUNIT:invalidArgumentType', ...
          ['Argument (test_list) must be string or cell array of strings or', ...
           'a numeric scalar or array']);
  end
  if (isempty(tcase_name_list))
    warning(['No matches found for specified test cases.']);
    return
  end
end



if (~strcmp(mode, 'silent'))
  disp(['Start Test Suite: ', ts.name]);
  disp(['              at: ', datestr(now, 31)]);
  disp(' ');
end

% Start timer
tstart = clock;

if (run_all_tcases)
  ts_results = MU_tsuite_run(ts, mode);
else
  ts_results = MU_tsuite_run(ts, mode, tcase_name_list);
end

ts_summary = MU_summarize_ts_results(ts.name, ts_results);

MU_print_tsuite_summary(ts_summary, mode);

diary off;

% Stop timer
tstop = clock;

if (~strcmp(mode, 'silent'))
  disp(' ');
  disp(['Finished Test Suite: ', ts.name]);
  disp(['                 at: ', datestr(now, 31)]);
  disp(['       Elapsed Time: ', num2str(etime(tstop, tstart)), ' sec.']);
  disp(' ');
end

return

