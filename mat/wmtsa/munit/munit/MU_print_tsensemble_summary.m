function MU_print_tsensemble_summary(summary, mode)

if (strcmpi(mode, 'silent'))
  return
end

tsename = summary.tsename;

nsuites = summary.nsuites;
ntcases = summary.ntcases;
ntests = summary.ntests;
npass = summary.npass;
nfails = summary.nfails;
nerrs = summary.nerrs;
percentPassed = summary.percentPassed;

disp(['***** Summary Report for Test Suite Ensemble:  ', tsename, ' *****']);

  str = '';
  str = [str, int2str(percentPassed), '%'];
  str = [str, ', ', 'TSuites: ', int2str(nsuites)];
  str = [str, ', ', 'TCases: ', int2str(ntcases)];
  str = [str, ', ', 'Tests: ', int2str(ntests)];
  str = [str, ', ', 'Pass: ', int2str(npass)];
  str = [str, ', ', 'Failures: ', int2str(nfails)];
  str = [str, ', ', 'Errors: ', int2str(nerrs)];
  
  disp(str);
  
return
  
  
  
