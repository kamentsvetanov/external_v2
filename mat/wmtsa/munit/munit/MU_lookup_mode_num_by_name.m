function mode_num = MU_lookup_mode_num_by_name(mode)
% MU_lookup_mode_num_by_name -- Return the numeric mode code by mode name.
%
%****f* lib.utils/MU_lookup_mode_num_by_name
%
% NAME
%   MU_lookup_mode_num_by_name -- Return the numeric mode code by mode name.
%
% SYNOPSIS
%   mode_num = MU_lookup_mode_num_by_name(mode)
%
% INPUTS
%   * mode       -- mode name (string).
%
% OUTPUTS
%   * mode_num   -- numeric mode code (integer)
%
% DESCRIPTION
%   Function lookups and returns the numeric mode code for 
%   for specified mode as follows:
%
%    * 'silent'        = 1
%    * 'minimal'       = 2
%    * 'normal'        = 3
%    * 'verbose'       = 4
%    * 'details'       = 5
%    * 'stoponerror'   = 6
%
%   stoponerror mode always execution to stop upon error and display the stack
%   leading up to the error.
%
% SEE ALSO
%   
%
% TOOLBOX
%   munit/munit
%
% CATEGORY
%   MUNIT Library:  Test Result Functions
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
%   $Revision: 107 $
%

%   $Id: MU_lookup_mode_num_by_name.m 107 2005-08-01 22:05:53Z ccornish $

switch (lower(mode))
 case 'silent'
  mode_num = 1;
 case 'minimal'
  mode_num = 2;
 case 'normal'
  mode_num = 3;
 case 'verbose'
  mode_num = 4;
 case 'details'
  mode_num = 5;
 case 'stoponerror'
  mode_num = 6;
 otherwise
  mode_num = 0;
end

return
  
