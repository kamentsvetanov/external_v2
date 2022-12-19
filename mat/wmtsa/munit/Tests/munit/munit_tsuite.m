function ts = munit_tsuite

  ts = MU_tsuite_new(mfilename);

  tc = MU_tcase_create(@tcase_tcase);
  ts = MU_tsuite_add_tcase(ts, tc);

  tc = MU_tcase_create(@tc_summary_tcase);
  ts = MU_tsuite_add_tcase(ts, tc);

  tc = MU_tcase_create(@tsuite_tcase);
  ts = MU_tsuite_add_tcase(ts, tc);

  tc = MU_tcase_create(@assert_tcase);
  ts = MU_tsuite_add_tcase(ts, tc);
  
return
  
