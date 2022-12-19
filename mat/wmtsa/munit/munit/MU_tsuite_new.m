function ts = MU_tsuite_new(name)
% MU_tsuite_new -- Creates a new (empty) test suite structure.
%
%****f* lib.tsuite/MU_tsuite_new
%
% NAME
%   MU_tsuite_new -- Creates a new (empty) test suite structure.
%
% SYNOPSIS
%   tc = MU_tsuite_new(name)
%
% INPUTS
%   * name -- name of test suite (string).
%
% OUTPUTS
%   * ts  -- an empty test suitestruct (tsuite_s).
%
% DESCRIPTION
%   Function creates and returns a new test suite structure.
%   name must be specified and non-blank.
%
%   tsuite_s struct has fields:
%     * name        -- name of test suite (string).
%     * tcases      -- vector of tcase structures (tcase_s).
%     * trsummaries -- vector of trsummary structs (trsummary_s).
%     
%   Note: length(ts.trsummaries) = length(ts.tscases)
%   after run of tsuite.
%
% EXAMPLE
%   ts = MU_tsuite_new('mytestsuite');
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
%   MUNIT Library:  Test Suite Functions
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

%   $Id: MU_tsuite_new.m 112 2005-09-13 05:53:51Z ccornish $

if(~exist('name', 'var') || isempty(name))
  error('MUNIT:MissingRequiredArgument', ...
        [mfilename, ' requires a name argument.']);
end

ts.name = name;
ts.pathstr = '';
ts.tcases = [];
% tc.trsummaries = [];
  
return
  

