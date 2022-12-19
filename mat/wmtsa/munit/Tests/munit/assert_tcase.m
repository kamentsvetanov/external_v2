function tc = assert_tcase
% assert_tcase -- munit test case to test assert functions.
%
%****f*  TestCases/assert_tcase
%
% NAME
%   assert_tcase -- munit test case to test assert functions.
%
% USAGE
%   run_tcase(@assert_tcase)
%
% INPUTS
%   (none)
%
% OUTPUTS
%   tc            = tcase structure for assert_tcase.
%
% SIDE EFFECTS
%
%
% DESCRIPTION
%
%

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2004-Apr-27 
%
% COPYRIGHT
%
%
% CREDITS
%
%
% REVISION
%   $Revision: 91 $
%
%***

%   $Id: assert_tcase.m 91 2005-03-01 00:37:24Z ccornish $

  
tc = MU_tcase_new(mfilename);
tc = MU_tcase_add_test(tc, @test_fail);
tc = MU_tcase_add_test(tc, @test_fail_line);
tc = MU_tcase_add_test(tc, @test_assert_isequal_equal);
tc = MU_tcase_add_test(tc, @test_assert_isequal_notequal);
tc = MU_tcase_add_test(tc, @test_assert_isequalwithequalnans_equal_nonans);
tc = MU_tcase_add_test(tc, @test_assert_isequalwithequalnans_equal_withnans);
tc = MU_tcase_add_test(tc, @test_assert_isequalwithequalnans_notequal_nansdiff);
tc = MU_tcase_add_test(tc, @test_assert_fuzzy_diff);
tc = MU_tcase_add_test(tc, @test_assert_numsigdig_diff);
% tc = MU_tcase_add_test(tc, @test_assert_isequalwithequalnans_notequal_nansdiff);


return

function test_fail(varargin)
  % Test Description:   Test MU_fail function.
  % Expected error:     AssertionFailedError
  expected_msg_id = 'MUNIT:AssertionFailedError';
  try
    MU_fail('This is a message');
  catch
    [errmsg, msg_id] = lasterr
    
    if (expected_msg_id == msg_id)
      % Passed test
    else
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
            'MU_fail did not return expected error');
    end
  end
return

function test_fail_line(varargin)
  % Test Description:   Test MU_fail_line function.
  % Expected error:     AssertionFailedError
  expected_msg_id = 'MUNIT:AssertionFailedError';
  funcname = mfilename;
  linenum = 999;
  message = 'This is a test error meesage.';
  try
    MU_fail_line(funcname, linenum, message);
  catch
    [errmsg, msg_id] = lasterr;
    if (expected_msg_id == msg_id)
      % Passed test
    else
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
            'MU_fail did not return expected error');
    end
  end
return

function test_assert_isequal_equal(varargin)
  % Test Description:   Test MU_assert_isequal function, values are equal.
  % Expected result:    No error
  try
    MU_assert_isequal(1, 1);
  catch
    % Should not reach here; if so, throw unknow error.
    error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
  end
return

function test_assert_isequal_notequal(varargin)
  % Test Description:    Test MU_assert_isequal function, values are not equal.
  %    Expected result:  MUNIT:AssertionFailedError
  try
    MU_assert_isequal(1, 2);
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:AssertionFailedError'
      % Success -- Expected resutl
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
return

function test_assert_isequalwithequalnans_equal_nonans(varargin)
  % Test Description:   Test MU_assert_isequalwithequalnans, values are equal.
  % Expected result:    No error
  x = [1:10];
  y = [1:10];
  try
    MU_assert_isequalwithequalnans(x, y);
  catch
    % Should not reach here; if so, throw unknown error.
    error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
  end
return

function test_assert_isequalwithequalnans_equal_withnans(varargin)
  % Test Description:   Test MU_assert_isequalwithequalnans, values are NaNs.
  % Expected result:    No error
  x = [1:10];
  y = [1:10];
  x(2) = NaN;
  y(2) = NaN;
  try
    MU_assert_isequalwithequalnans(x, y);
  catch
    % Should not reach here; if so, throw unknown error.
    error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
  end
return


function test_assert_isequalwithequalnans_notequal_nansdiff(varargin)
  % Test Description:   Test MU_assert_isequalwithequalnans, some values are NaNs.
  % Expected result:    AssertionFailedError

  x = [1:10];
  y = [1:10];
  x(2) = NaN;
  try
    MU_assert_isequalwithequalnans(x, y);
    
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:AssertionFailedError'
      % Success -- Expected result
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
return


function test_assert_fuzzy_diff(varargin)
  % Test Description:   Test MU_assert_fuzzy_diff function.
  % Expected result:    No error
    
  if (nargin > 0)
    mode = varargin{1};
  end
  

  % Setup
  fuzzy_tol = 0;
  message = '';
  x = [1:10];
  y = x;
  
  % Try equal within tolerance
  try
    MU_assert_fuzzy_diff(x, y, fuzzy_tol, message)
    if (strcmpi(mode, 'details'))
      disp('PASSED: fuzzy diff:  a == b, fuzzy_tol = 0.0');
    end
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
  
  
  % Try not equal within tolerance
  x = [1:10];
  y = x;

  x(1) = 2;
  try
    MU_assert_fuzzy_diff(x, y, fuzzy_tol, message)
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:AssertionFailedError'
      % Success -- Expected result
      if (strcmpi(mode, 'details'))
        disp('PASSED: fuzzy diff:  a ~= b, fuzzy_tol = 0.0');
      end
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
  

  % Try equal -- within tolerance.
  x = [1:10];
  y = x;

  x = x + .000002;
  y = y + .0000025;
  fuzzy_tol = .0000025;
  
  try
    MU_assert_fuzzy_diff(x, y, fuzzy_tol, message)
    if (strcmpi(mode, 'details'))
      disp('PASSED: fuzzy diff:  a == b, within fuzzy_tol = 0.0000025;');
    end
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:AssertionFailedError'
      % Success -- Expected result
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
  
  % Try equal -- out of tolerance.
  x = [1:10];
  y = x;
  x = x + .000002;
  y = y + .0000025;
  fuzzy_tol = .0000005;
  
  try
    MU_assert_fuzzy_diff(x, y, fuzzy_tol, message)
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:AssertionFailedError'
      % Success -- Expected result
      if (strcmpi(mode, 'details'))
        disp('PASSED: fuzzy diff:  a == b, out of fuzzy_tol = 0.0000005;');
      end
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end

return


function test_assert_numsigdig_diff(varargin)
  % Test Description:   Test MU_assert_numsigdig_diff function.
  % Expected result:    No error
    
  if (nargin > 0)
    mode = varargin{1};
  end
  

  % Setup
  numsigdig = 0;
  message = '';
  x = [1:10];
  y = x;
  y(2) = 0;
  
  % Try equal.
  try
    MU_assert_numsigdig_diff(x, y, numsigdig, message)
    if (strcmpi(mode, 'details'))
      disp('PASSED: numsigdig diff:  a == b, numsigdig = 0');
    end
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end

  return

  % Try equal -- within numsigdig.
  x = [1:10];
  y = x;
  x = x + .000002;
  y = y + .0000025;
  numsigdig = 6;
  
  try
    MU_assert_numsigdig_diff(x, y, numsigdig, message)
    if (strcmpi(mode, 'details'))
      disp('PASSED: fuzzy diff:  a == b, within numsigdig = 0.0000025;');
    end
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:AssertionFailedError'
      % Success -- Expected result
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end

  return
  % Try equal -- out of tolerance.
  x = [1:10];
  y = [1:10];
  x = x + .000002;
  y = y + .0000025;
  numsigdig = .0000005;
  
  try
    MU_assert_numsigdig_diff(x, y, numsigdig, message)
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:AssertionFailedError'
      % Success -- Expected result
      if (strcmpi(mode, 'details'))
        disp('PASSED: fuzzy diff:  a == b, out of numsigdig = 0.0000005;');
      end
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end

return
