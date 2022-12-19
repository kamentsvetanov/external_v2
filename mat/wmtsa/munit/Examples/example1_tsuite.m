function ts = example1_tsuite
  ts = MU_tsuite_new(mfilename);
  
  tc = MU_tcase_create(@example1_tcase_1);
  ts = MU_tsuite_add_tcase(ts, tc);
  tc = MU_tcase_create(@example1_tcase_2);
  ts = MU_tsuite_add_tcase(ts, tc);
  
return

