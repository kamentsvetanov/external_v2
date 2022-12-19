%****m* MUnit-API/Variables
%
% NAME
%   MUnit Variables
%
% DESCRIPTION
%   Description of variables used in MUnit.
%
% TOOLBOX
%    munit/munit
%
% CATEGORY
%
%
%***
%****v* Variables/tcase
%
% NAME
%   tcase -- test case.
%
% DESCRIPTION
%   The tcase variable specifies a test case and can be one of the 
%   following types:
%     * a string containing name of a test case function
%     * a function handle (@tcase) to a test case function
%     * a test case struct (tcase_s).
%
%***
%****v* Variables/tsuite
%
% NAME
%   tsuite -- test suite
%
% DESCRIPTION
%   The tsuite variable specifies a test suite and can be one of the 
%   following types:
%     * a string containing name of a test suite function
%     * a function handle (@tsuite) to a test suite function
%     * a test suite struct (tsuite_s).
%***
%****v* Variables/mode
%
% NAME
%   mode -- mode for level of detail of print output.
%
% DESCRIPTION
%   mode controls the level of detail of print output as follows:
%    * 'silent'    -- no output.
%                       * errors
%    * 'minimal'   -- print
%                       * errors
%                       * test case and/or test suite summaries.
%    * 'normal'    -- print 
%                       * errors
%                       * test results report of failed  tests
%                       * test case and/or test suite summaries.
%    * 'verbose'   -- print 
%                       * errors
%                       * full test results report.
%                       * test case and/or test suite summaries.
%    * 'details'   -- print
%                       * errors
%                       * diagnostics while running tests
%                       * full test results report.
%                       * test case and/or test suite summaries.
%
%   Note: For all modes, info printed durning execution of tested functions 
%         is displayed to command window.
%***
%****v* Variables/trstatus
%
% NAME
%   trstatus -- numeric status code of a test result.
%
% DESCRIPTION
%   trstatus can take on the following values: 
%     *  1   --  'SUCCESS'
%     *  0   --  'FAIL'
%     * -1   --  'ERROR'
%     * NaN  --  otherwise
%
% SEE ALSO
%   MU_lookup_tresult_status_by_name
%
%***

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%
%
% COPYRIGHT
%
%
% CREDITS
%
%
% REVISION
%   $Revision: 84 $
%

%   $Id: MUnit_Variables.m 84 2005-02-15 01:03:48Z ccornish $
