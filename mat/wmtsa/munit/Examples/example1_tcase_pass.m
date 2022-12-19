function tc = example1_tcase_pass

  tc = MU_tcase_new(mfilename);
  tc = MU_tcase_add_test(tc, @test_pass);
  
return

function test_pass(varargin)
  mode = '';
  if (nargin > 0)
    mode = varargin{1};
  end
  mode_num = MU_lookup_mode_num_by_name(mode);
  if (mode_num > 3)
    disp('test_pass:   This test passes.');
  end
return
  
  

