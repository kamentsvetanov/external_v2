function tc = example1_tcase_1

  tc = MU_tcase_new(mfilename);
  tc = MU_tcase_add_test(tc, @dummy_test1);
  tc = MU_tcase_add_test(tc, @dummy_test2);
  
return

function dummy_test1(varargin)
  s = dbstack;
  disp(['This is ', s(1).name]);
return
  
function dummy_test2(varargin)
  s = dbstack;
  disp(['This is ', s(1).name]);
return
  

