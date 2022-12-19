function MU_tsuite_list_tcases(ts)
% MU_tsuite_list_tests  -- List the test cases in a test suite.
%
%****f* lib.tsuite/MU_tsuite_list_tests
%
% NAME
%   MU_tsuite_list_tests  -- List the tests in a test case.
%
% SYNOPSIS
%   MU_tsuite_list_tests(tc)
%
% INPUTS
%   * ts         -- a loaded test case struct (tsuite_s).
%
% OUTPUTS
%   (none)
%
% DESCRIPTION
%   Function prints the test cases for the specified test suite.
%
% SEE ALSO
%   
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%   MUNIT Library:  Test Suite Functions
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
%   $Revision: 81 $
%

%   $Id: MU_tsuite_list_tcases.m 81 2004-11-18 00:51:34Z ccornish $

  
% List all tests
for (i = 1:length(ts.tcases))
  disp(ts.tcases(i).name);
end
  
return
 
