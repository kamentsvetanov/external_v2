function tse_summary = run_tsensemble(tsensemble, mode, logfile)
  
usage_str = ['Usage:  ', mfilename, ...
             '(tsensemble, [mode], [logfile])'];
  
if (nargin < 1 || nargin > 3)
  error(usage_str);
end

if (isa(tsensemble, 'function_handle'))
  tse = MU_tsensemble_create(tsensemble);
elseif (isa(tsensemble, 'char'))
  tse = MU_tsensemble_create(tsensemble);
elseif (isa(tsensemble, 'struct'))
  tse = tsensemble;
else
  error('MUNIT:UnknownTestSuiteEnsemble', ...
        ['tsensemble is not a valid name, function handle, or struct', ...
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

if (~strcmp(mode, 'silent'))
  disp(['Start Test Suite Ensemble: ', tse.name]);
  disp(['              at: ', datestr(now, 31)]);
  disp(' ');
end

% Start timer
tstart = clock;

% ts_summaries = struct;

for (i = 1:length(tse.tsuites))
  ts = tse.tsuites(i);
  ts_results = MU_tsuite_run(ts, mode);
  ts_summary = MU_summarize_ts_results(ts.name, ts_results);
  ts_summaries(i) = ts_summary;
  MU_print_tsuite_summary(ts_summary, mode);
end

tse_summary = MU_summarize_ts_summaries(tse.name, ts_summaries);
MU_print_tsensemble_summary(tse_summary, mode)

diary off;

% Stop timer
tstop = clock;

if (~strcmp(mode, 'silent'))
  disp(' ');
  disp(['Finished Test Suite Ensemble: ', ts.name]);
  disp(['                          at: ', datestr(now, 31)]);
  disp(['                Elapsed Time: ', num2str(etime(tstop, tstart)), ' sec.']);
  disp(' ');
end

return
