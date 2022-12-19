function ts = XXX_tsuite
% XXX_tsuite -- munit test suite to test XXX.
%
%****f*  toolbox.subdirectory/function_name.m
%
% NAME
%   XXX_tsuite -- munit test suite to test XXX.
%
% USAGE
%
%
% INPUTS
%
%
% OUTPUTS
%   ts            = tsuite structure for XXX testsuite.
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
%   
%
% COPYRIGHT
%
%
% CREDITS
%
%
% REVISION
%   $Revision$
%
%***

%   $Id$

  
ts = MU_tsuite_new(mfilename);
  
tc = MU_tcase_create(@YYY_tcase);
ts = MU_tsuite_add_tcase(ts, tc);


return

