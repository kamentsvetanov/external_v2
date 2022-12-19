function tc = tc_summary_tcase
% tc_summary_tcase -- munit test case to test tcase summary functions.
%
%****f*  munit.Test/tc_summary_tcase
%
% NAME
%   tc_summary_tcase -- munit test case to test tcase summary functions.
%
% USAGE
%
%
% INPUTS
%
%
% OUTPUTS
%   tc            = tcase structure for tc_summary_tcase.
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
%   $Revision: 92 $
%
%***

%   $Id: tc_summary_tcase.m 92 2005-03-03 00:13:54Z ccornish $

  
tc = MU_tcase_new(mfilename);
tc = MU_tcase_add_test(tc, @test_summarize_testresults);
tc = MU_tcase_add_test(tc, @check_error_fail_test_nums);


return

function test_summarize_testresults(varargin)
  
  mode = varargin{1};
  
  name = mfilename;
  tc = MU_tcase_new(name);

  tfhp1 = @test_pass1;
  tc = MU_tcase_add_test(tc, tfhp1);
  
  tfhf1 = @test_fail1;
  tc = MU_tcase_add_test(tc, tfhf1);

  tfhe1 = @test_error1;
  tc = MU_tcase_add_test(tc, tfhe1);
  
  tfhp2 = @test_pass2;
  tc = MU_tcase_add_test(tc, tfhp2);
  
  tfhf2 = @test_fail2;
  tc = MU_tcase_add_test(tc, tfhf2);

  tfhe2 = @test_error2;
  tc = MU_tcase_add_test(tc, tfhe2);

  tfhp3 = @test_pass3;
  tc = MU_tcase_add_test(tc, tfhp3);
  
  tfhp4 = @test_pass4;
  tc = MU_tcase_add_test(tc, tfhp4);

  try
    tr = MU_tcase_run(tc);                       ;
  catch
    [errmsg, err_id] = lasterr
    % Should not get to here
      error('MUNIT:AssertionFailedError', ...
            [mfilename, ...
             ': ', ...
             name, ...
             ' -- test fail -- '...
             'should not get here']);
  end

  tc_summary = MU_summarize_tresults(tc, tr);

  % Display tc_summary
  if (MU_lookup_mode_num_by_name(mode) >= 2)
    tc_summary
  end
  
  MU_assert_isequal(tc_summary.npass, 4);
  MU_assert_isequal(tc_summary.nfails, 2);
  MU_assert_isequal(tc_summary.nerrs, 2);
  MU_assert_isequal(tc_summary.percentPassed, 50);
  MU_assert_isequal(length(tc_summary.failedTests), 2);
  MU_assert_isequal(tc_summary.failedTestNums, [2 5]);
  MU_assert_isequal(length(tc_summary.erroredTests), 2);
  MU_assert_isequal(tc_summary.erroredTestNums, [3 6]);

  
  
return

function check_error_fail_test_nums(varargin)
% Check that error and failed test nums are coreact
  
  mode = varargin{1};
  
  name = mfilename;
  tc = MU_tcase_new(name);

  test1 = @test_pass1;
  tc = MU_tcase_add_test(tc, test1);
  
  test2 = @test_fail1;
  tc = MU_tcase_add_test(tc, test2);

  test3 = @test_error1;
  tc = MU_tcase_add_test(tc, test3);
  
  test4 = @test_pass2;
  tc = MU_tcase_add_test(tc, test4);
  
  test5 = @test_fail2;
  tc = MU_tcase_add_test(tc, test5);

  test6 = @test_error2;
  tc = MU_tcase_add_test(tc, test6);

  test7 = @test_pass3;
  tc = MU_tcase_add_test(tc, test7);
  
  test8 = @test_pass4;
  tc = MU_tcase_add_test(tc, test8);

  errored_test_nums = [3, 6];
  errored_tests = {'test_error1', 'test_error2'};

  failed_test_nums = [2, 5];
  failed_tests = {'test_fail1', 'test_fail2'};

  try
    tr = MU_tcase_run(tc);                       ;
  catch
    [errmsg, err_id] = lasterr
    % Should not get to here
      error('MUNIT:AssertionFailedError', ...
            [mfilename, ...
             ': ', ...
             name, ...
             ' -- test fail -- '...
             'should not get here']);
  end

  tc_summary = MU_summarize_tresults(tc, tr);

  % Display tc_summary
  if (MU_lookup_mode_num_by_name(mode) >= 2)
    tc_summary
  end
  
  MU_assert_isequal(tc_summary.failedTestNums, failed_test_nums);
  MU_assert_isequal(all(strcmp(tc_summary.failedTests, failed_tests)), 1);

  MU_assert_isequal(tc_summary.erroredTestNums, errored_test_nums);
  MU_assert_isequal(all(strcmp(tc_summary.erroredTests, errored_tests)), 1);

  
  
return

function test_pass1(varargin)
  disp('test_pass1:   This test passes.');
return

function test_fail1(varargin)
  disp('test_fail1:   This test fails.');
  error('MUNIT:AssertionFailedError', 'Assertion failed error');
return

function test_error1(varargin)
  disp('test_error1:   This this errors.');
  error('MUNIT:UnknownError', 'General error');
return

function test_pass2(varargin)
  disp('test_pass2:   This test passes.');
return

function test_fail2(varargin)
  disp('test_fail2:   This test fails.');
  error('MUNIT:AssertionFailedError', 'Assertion failed error');
return

function test_error2(varargin)
  disp('test_error2:   This this errors.');
  error('MUNIT:UnknownError', 'General error');
return

function test_pass3(varargin)
  disp('test_pass3:   This test passes.');
return

function test_pass4(varargin)
  disp('test_pass4:   This test passes.');
return
