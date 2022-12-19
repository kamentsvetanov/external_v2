function summary = MU_summarize_ts_summaries(tsename, ts_summaries)

nsuites = 0;
ntcases = 0;
ntests = 0;
npass = 0;
nfails = 0;
nerrs = 0;
percentPassed = 0;


for (i = 1:length(ts_summaries))
  nsuites = nsuites + 1;
  ntcases = ts_summaries(i).ntcases + ntcases;
  ntests = ts_summaries(i).ntests + ntests;
  npass = ts_summaries(i).npass + npass;
  nfails = ts_summaries(i).nfails + nfails;
  nerrs = ts_summaries(i).nerrs + nerrs;
end
  
percentPassed = 100 * (npass / ntests);
  
summary.tsename = tsename;
summary.nsuites = nsuites;
summary.ntcases = ntcases;
summary.ntests = ntests;
summary.npass = npass;
summary.nfails = nfails;
summary.nerrs = nerrs;
summary.percentPassed = percentPassed;
  
return
  
