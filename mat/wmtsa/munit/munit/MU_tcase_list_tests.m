function MU_tcase_list_tests(tc)
% MU_tcase_list_tests_run  -- List the tests in a test case.
%
%****f* lib.tcase/MU_tcase_list_tests
%
% NAME
%   MU_tcase_list_tests  -- List the tests in a test case.
%
% SYNOPSIS
%   MU_tcase_list_tests(tc)
%
% INPUTS
%   * tc         -- a loaded test case struct (tcase_s).
%
% OUTPUTS
%   (none)
%
% DESCRIPTION
%   Function prints the tests for the specified test.
%
% SEE ALSO
%   
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%   MUNIT Library:  Test Case Functions
%
%***

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2004-Nov-12
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

%   $Id: MU_tcase_list_tests.m 97 2005-07-13 23:39:25Z ccornish $

  
% List all tests
for (i = 1:length(tc.tests))
  disp(func2str(tc.tests{i}));
end
  
return
 
