function tc = tcase_tcase
% tcase_tcase -- munit test case to test tcase functions.
%
%****f*  munit.Test/tcase_tcase
%
% NAME
%   tcase_tcase -- munit test case to test tcase functions.
%
% USAGE
%
%
% INPUTS
%
%
% OUTPUTS
%   tc            = tcase structure for tcase_tcase.
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
%   $Revision: 97 $
%
%***

%   $Id: tcase_tcase.m 97 2005-07-13 23:39:25Z ccornish $

  
tc = MU_tcase_new(mfilename);
tc = MU_tcase_add_test(tc, @test_tcase_new_normal);
tc = MU_tcase_add_test(tc, @test_tcase_new_noname);
tc = MU_tcase_add_test(tc, @test_tcase_new_blankname);
tc = MU_tcase_add_test(tc, @test_tcase_create_normal);
tc = MU_tcase_add_test(tc, @test_tcase_create_noname);
tc = MU_tcase_add_test(tc, @test_tcase_create_blankname);
tc = MU_tcase_add_test(tc, @test_tcase_create_unknown_tcase);
tc = MU_tcase_add_test(tc, @test_tcase_add_test);
tc = MU_tcase_add_test(tc, @test_tcase_add_test_test_location);
tc = MU_tcase_add_test(tc, @test_tcase_add_test_nonexistant);
tc = MU_tcase_add_test(tc, @test_tcase_run_test);
tc = MU_tcase_add_test(tc, @test_tcase_run);



return


function test_tcase_new_normal(varargin)
  % Test Description:  
  %    Expected result:  No error
  name = 'dummy_tcase';
  tc = MU_tcase_new(name);

  MU_assert_isequal(name, tc.name);
  
return

function test_tcase_new_noname(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:MissingRequiredArgument

  try
    tc = MU_tcase_new;
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

function test_tcase_new_blankname(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:MissingRequiredArgument

  try
    tc = MU_tcase_new('');
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

function test_tcase_create_normal(varargin)
  % Test Description:  
  %    Expected result:  No error
  name = mfilename;
  tc = MU_tcase_create(name);

  MU_assert_isequal(name, tc.name);
  
return

function test_tcase_create_noname(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:MissingRequiredArgument

  try
    tc = MU_tcase_create;
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

function test_tcase_create_blankname(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:MissingRequiredArgument

  try
    tc = MU_tcase_create('');
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

function test_tcase_create_unknown_tcase(varargin)
  % Test Description:  
  %    Expected result:  MUNIT:UnknownTestCase

  try
    tc = MU_tcase_create('not_a_tcase');
  catch
    [errmsg, msg_id] = lasterr;
    switch(msg_id)
     case 'MUNIT:UnknownTestCase'
      % Success -- Expected result
     otherwise
      % Should not reach here; if so, throw unknow error.
      error('MUNIT:UnknownError', ...
           [mfilename, ' should not reach here.']);
    end
  end
  
return

function test_tcase_add_test(varargin)
% Test Description:  
  %    Expected result:  normal executions

  name = mfilename;
  tc = MU_tcase_new(name);

  tfh1 = @test1;
  tc = MU_tcase_add_test(tc, tfh1);
return

function test_tcase_add_test_test_location(varargin)
% Test Description:  
  %    Expected result:  normal executions

  name = mfilename;
  tc = MU_tcase_new(name);

  tfh1 = @external_test;
  tc = MU_tcase_add_test(tc, tfh1, tfh1);
  
  tfh2 = @test2;
  tc = MU_tcase_add_test(tc, tfh2);

  MU_assert_isequal(length(tc.tests), 2);
  
  feval(tc.tests{1});
  feval(tc.tests{2});
  
return


function test_tcase_add_test_nonexistant(varargin)
% Test Description:  
  %    Expected result:  MUNIT:UnknownTest

  name = mfilename;
  tc = MU_tcase_new(name);

  tfh = @test_nonexistant;
  try
    tc = MU_tcase_add_test(tc, tfh);
  catch
    [errmsg, msg_id] = lasterr;
    
    switch(msg_id)
     case 'MUNIT:UnknownTest'
      % OK - Catch the assertion error
     otherwise
      [errmsg, err_id] = lasterr
      % Should not get to here
      s = dbstack;
      error('MUNIT:AssertionFailedError', ...
            [mfilename, ...
             ': ', ...
             s.name, ...
             ' -- test fail -- '...
             'should not get here']);
    end
  end
  
return

function test_tcase_run_test(varargin)
% Test Description:  
%    Expected result:  normal executions

  name = mfilename;
  tc = MU_tcase_new(name);

  tfhp = @test_pass;
  tc = MU_tcase_add_test(tc, tfhp);
  
  tfhf = @test_fail;
  tc = MU_tcase_add_test(tc, tfhf);

  tfhe = @test_error;
  tc = MU_tcase_add_test(tc, tfhf);

  tfhext = @external_test;
  tc = MU_tcase_add_test(tc, tfhext);

  MU_assert_isequal(length(tc.tests), 4);

  mode = 'details';
  disp(['test_tcase_run_test', ': setting mode to ''', mode, '''']);
  % test pass
  try
    tr = MU_tcase_run_test(tc, tc.tests{1}, mode);
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

  % test fail
  try
    tr = MU_tcase_run_test(tc, tc.tests{2}, 'details');
  catch
    [errmsg, msg_id] = lasterr;
    
    switch(msg_id)
     case 'MUNIT:AssertionFailedError'
      % OK - Catch the assertion error
     otherwise
      [errmsg, err_id] = lasterr
      % Should not get to here
      error('MUNIT:AssertionFailedError', ...
            [mfilename, ...
             ':test_tcase_run_test -- test fail -- '...
             'should not get here']);
    end
  end
  
  % test error
  try
    tr = MU_tcase_run_test(tc, tc.tests{3}, 'details');
  catch
    [errmsg, msg_id] = lasterr;
    
    switch(msg_id)
     case 'MUNIT:AssertionFailedError'
      % OK - Catch the assertion error
     otherwise
      % Should not get to here
      [errmsg, err_id] = lasterr
      error('MUNIT:UnknownError', ...
            [mfilename, ...
             ':test_tcase_run_test -- test fail -- '...
             'should not get here']);
    end
  end

  % external test
  try
    tr = MU_tcase_run_test(tc, tc.tests{4}, 'details');
  catch
    [errmsg, err_id] = lasterr
    % Should not get to here
      error('MUNIT:AssertionFailedError', ...
            [mfilename, ...
             ': ', ...
             s.name, ...
             ' -- test fail -- '...
             'should not get here']);
  end
  
return

function test_tcase_run(varargin)
% Test Description:  
%    Expected result:  normal executions
  
  name = 'sample_tcase';
  tc = MU_tcase_create(name);

  tresults = MU_tcase_run(tc);
return


function test1(varargin)
  disp('test1:   This is test1.');
return

function test2(varargin)
  disp('test2:   This is test2.');
return

function test_pass(varargin)
  disp('test_pass:   This test passes.');
return

function test_fail(varargin)
  disp('test_fail:   This test fails.');
  error('MUNIT:AssertionFailedError', 'Assertion failed error');
return

function test_error(varargin)
  disp('test_error:   This this errors.');
  error('MUNIT:UnknownError', 'General error');
return

