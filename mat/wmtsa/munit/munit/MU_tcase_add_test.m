function [tc] = MU_tcase_add_test(tc, tfh, test_location)
% MU_tcase_add_test -- Add a test to test case.
%
%****f* lib.tcase/MU_tcase_add_test
%
% NAME
%   MU_tcase_add_test -- Add a test to test case.
%
% SYNPOSIS
%   [tc] = MU_tcase_add_test(tc, tfh, [test_location])
%
% INPUTS
%   * tc            -- test case struct (tcase_s).
%   * tfh           -- function handle to the test function (@tfh).
%   * test_location -- (optional) location of test if different from tc.name
%                      (string).
%
% OUTPUTS
%   * tc            -- test case struct (tcase_s).
%
% EXAMPLE
%    tc = MU_tcase_add_test(tc, @test1)                  % Default
%    tc = MU_tcase_add_test(tc, @test2, test2_location)  % Specify test location.
%
% DESCRIPTION
%   Function adds a test to a test case by verifying that the function handle to
%   the test function exists, and, if successful, adds its test function handle
%   to the set of tests for the test case tc. To verify the existance of the 
%   function handle tfh, a check is made to determine if a function with a name
%   associated with the tfh is found in the test case file ( = tc.name).
%  
%   Alternatively, if test_location is specified, the test referenced by @tfh
%   may reside in a file other than the the tcase function file.
%   A check is made to verify that test function associated with @tfh exists 
%   in the file specitifed by test_location.
%
% ERRORS
%   MUNIT:UnknownTest  -- Test function not found.
%
% SEE ALSO
%   MU_tcase_create
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%   MUNIT Library:  TestCase Functions
%
%***

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2004-Apr-28
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

%   $Id: MU_tcase_add_test.m 97 2005-07-13 23:39:25Z ccornish $

% Verify that test tfh is within tc tcase file.
test_name = func2str(tfh);

if (~exist('test_location', 'var') || isempty(test_location))
  test_func_file = tc.name;
else
  if (isa(test_location, 'function_handle'))
    test_func_file = func2str(test_location);
  else
    test_func_file = test_location;
  end
end
    
s = which(test_name, 'in', test_func_file);



if (isempty(s))
  error('MUNIT:UnknownTest', ...
        ['Test (', test_name, ') does not exist in TestCase (', ...
         test_func_file, ') file']);
end

ntests = length(tc.tests);
tc.tests{ntests+1} = tfh;

return

