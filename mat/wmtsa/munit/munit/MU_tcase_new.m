function tc = MU_tcase_new(name)
% MU_tcase_new -- Creates a new (empty) test case struct.
%
%****f* lib.tcase/MU_tcase_new
%
% NAME
%   MU_tcase_new -- Creates a new (empty) test case structure.
%
% SYNOPSIS
%   tc = MU_tcase_new(name)
%
% INPUTS
%   * name -- name of test case (string).
%
% OUTPUTS
%   * tc   -- an empty test case struct (tcase_s).
%
% SIDE EFFECTS
%   name must be specified and non-blank; otherwise error.
%
% DESCRIPTION
%   Function creates and returns a new (empty) test case structure tcase_s.
%
%   tcase_s structure has fields:
%   * name     -- name of test case (string).
%   * pathstr  -- optional path to location of tcase mfile (string).
%   * tests    -- cell array of function handles to test functions.
%   * tresults -- test case results (vector of tresult_s).
%
%   name is the only required argument.  
%   pathstr, tests, and tresults are initialized to empty.
%
% EXAMPLE
%   tc = MU_tcase_new('mytestcase');
%
% ERRORS
%   MUNIT:MissingRequiredArgument
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
%   2004-Apr-27
%
% COPYRIGHT
%
%
% CREDITS
%
%
% REVISION
%   $Revision: 112 $
%

%   $Id: MU_tcase_new.m 112 2005-09-13 05:53:51Z ccornish $

if(~exist('name', 'var') || isempty(name))
  error('MUNIT:MissingRequiredArgument', ...
        [mfilename, ' requires a name argument.']);
end


tc.name = name;
tc.pathstr = '';
tc.tests = {};
tc.tresults = [];

return
