function ts = XXX_tsensemble
% XXX_tsensemble -- munit test suite to test XXX.
%
%****f*  toolbox.subdirectory/function_name.m
%
% NAME
%   XXX_tsensemble -- munit test suite to test XXX.
%
% USAGE
%
%
% INPUTS
%
%
% OUTPUTS
%   ts            = tsensemble structure for XXX testsensemble.
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

  
tse = MU_tsensemble_new(mfilename);

tse1 = MU_tsensemble_create('XXX_tsensemble');
tse = MU_tsensemble_add_tsensemble(tse, tse1);


ts = MU_tsuite_create(@YYY_t);
tse = MU_tsensemble_add_tsuite(tse, ts);


return

