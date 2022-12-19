function ts = sample_tsuite
  ts = MU_tsuite_new(mfilename);
  
  tc = MU_tcase_create(@sample_tcase);
  ts = MU_tsuite_add_tcase(ts, tc);
  
return

