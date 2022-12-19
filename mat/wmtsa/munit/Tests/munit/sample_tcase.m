function tc = sample_tcase

  tc = MU_tcase_new(mfilename);
  tc = MU_tcase_add_test(tc, @test_pass);
  tc = MU_tcase_add_test(tc, @test_fail);
  tc = MU_tcase_add_test(tc, @test_error);
  
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

function test_fail(varargin)
  mode = '';
  if (nargin > 0)
    mode = varargin{1};
  end
  mode_num = MU_lookup_mode_num_by_name(mode);
  if (mode_num > 2)
    disp('test_fail:   This test fails.');
  end
  error('MUNIT:AssertionFailedError', 'Assertion failed error');
return
  
function test_error(varargin)
  mode = '';
  if (nargin > 0)
    mode = varargin{1};
  end
  mode_num = MU_lookup_mode_num_by_name(mode);
  if (mode_num > 2)
    disp('test_error:   This test errors.');
  end
  error('MUNIT:UnknownError', 'General error');
return

