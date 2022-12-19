function tc = tsuite_tcase
% tsuite_tcase -- munit test case to test tsuite functions.
%
%****f*  munit.Test/tsuite_tcase.m
%
% NAME
%   tsuite_tcase -- munit test case to test tsuite functions.
%
% USAGE
%
%
% INPUTS
%
%
% OUTPUTS
%   tc            = tsuite structure for tsuite_tcase.
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
%   $Revision: 80 $
%
%***

%   $Id: tsuite_tcase.m 80 2004-11-18 00:51:07Z ccornish $

  
tc = MU_tcase_new(mfilename);

tc = MU_tcase_add_test(tc, @test_tsuite_new_normal);
tc = MU_tcase_add_test(tc, @test_tsuite_new_noname);
tc = MU_tcase_add_test(tc, @test_tsuite_new_blankname);

tc = MU_tcase_add_test(tc, @test_tsuite_create_normal);
tc = MU_tcase_add_test(tc, @test_tsuite_create_noname);
tc = MU_tcase_add_test(tc, @test_tsuite_create_blankname);
tc = MU_tcase_add_test(tc, @test_tsuite_create_unknown_tsuite);

tc = MU_tcase_add_test(tc, @test_tsuite_add_tcase);
tc = MU_tcase_add_test(tc, @test_tsuite_run);


return

function test_tsuite_new_normal(varargin)
  % Test Description:  
  %    Expected result:  No error
  name = mfilename;
  ts = MU_tsuite_new(name);

  MU_assert_isequal(name, ts.name);
  
return

function test_tsuite_new_noname(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:MissingRequiredArgument

  try
    ts = MU_tsuite_new;
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:MissingRequiredArgument'
      % Success -- Expected result
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
  
return

function test_tsuite_new_blankname(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:MissingRequiredArgument

  try
    ts = MU_tsuite_new('');
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:MissingRequiredArgument'
      % Success -- Expected result
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
  
return


function test_tsuite_create_normal(varargin)
  % Test Description:  
  %    Expected result:  No error
  name = 'sample_tsuite';
  ts = MU_tsuite_create(name);

  MU_assert_isequal(name, ts.name);
  
return

function test_tsuite_create_noname(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:MissingRequiredArgument

  try
    ts = MU_tsuite_create;
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:MissingRequiredArgument'
      % Success -- Expected result
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
  
return

function test_tsuite_create_blankname(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:MissingRequiredArgument

  try
    ts = MU_tsuite_create('');
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:MissingRequiredArgument'
      % Success -- Expected result
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
  
return

function test_tsuite_create_unknown_tsuite(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:UnknownTestSuite

  try
    tc = MU_tsuite_create('not_a_tsuite');
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:UnknownTestSuite'
      % Success -- Expected result
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
  
return

function test_tsuite_add_tcase(varargin)
% Test Description:  
  %    Expected result:  normal executions

  name = mfilename;
  ts = MU_tsuite_new(name);

  tc1 = MU_tcase_create('sample_tcase');
  ts = MU_tsuite_add_tcase(ts, tc1);

  tc2 = MU_tcase_create(@sample_tcase);
  ts = MU_tsuite_add_tcase(ts, tc2);

  MU_assert_isequal(length(ts.tcases), 2);
  
  
return


function test_tsuite_run(varargin)
% Test Description:  
%    Expected result:  normal executions

  name = 'sample_tsuite';
  ts = MU_tsuite_create(name);

  ts = MU_tsuite_run(ts, 'details');
  
return


function tc = tcase1(varargin)
  name = 'tcase1'
  tc = MU_tcase_create(name);

  tc = MU_tcase_add_test(tc, @test1);
  tc = MU_tcase_add_test(tc, @test2);

return
  
function tc = tcase2(varargin)
  name = 'tcase2'
  tc = MU_tcase_create(name);

  tc = MU_tcase_add_test(tc, @test_pass);
  tc = MU_tcase_add_test(tc, @test_fail);
  tc = MU_tcase_add_test(tc, @test_error);

return

function test1(varargin)
  disp('This is test1');
return

function test2(varargin)
  disp('This is test2');
return

function test_pass(varargin)
  disp('This test passes.');
return

function test_fail(varargin)
  disp('This test fails.');
  error('MUNIT:AssertionFailedError', 'Assertion failed error');
return

function test_error
  disp('This test errors.');
  error('MUNIT:UnknownError', 'General error');
return
