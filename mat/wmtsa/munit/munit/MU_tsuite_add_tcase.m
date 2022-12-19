function [ts] = MU_tsuite_add_tcase(ts, tc)
% MU_tsuite_add_tcase -- Add a test case struct to test suite struc.
%
%****f* lib.tsuite/MU_tsuite_add_tcase
%
% NAME
%   MU_tsuite_add_tcase -- Add a test case struct to test suite struc.
%
% USAGE
%   [ts] = MU_tsuite_add_tcase(ts, tc)
%
% INPUTS
%   * ts          -- test suite struct (tsuite_s).
%   * tc          -- test case struct (tcase_s).
%
% OUTPUTS
%   * ts          -- test suite struct (tsuite_s).
%
% DESCRIPTION
%   Function adds a tcase to a tsuite structure.
%
% SEE ALSO
%   MU_tsuite_create
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
%   2004-Apr-28
%
% COPYRIGHT
%
%
% CREDITS
%
%
% REVISION
%   $Revision: 83 $
%

%   $Id: MU_tsuite_add_tcase.m 83 2005-02-15 01:02:14Z ccornish $
  
ts.tcases = [ts.tcases tc];

return
