function trstatus = MU_lookup_tresult_status_by_name(name)
% MU_lookup_tresult_status_by_name -- Return the numeric test result status code by test result status name.
%
%****f* lib.utils/MU_lookup_tresult_status_by_name
%
% NAME
%   MU_lookup_tresult_status_by_name -- Return the numeric test result status code by test result status name.
%
% SYNOPSIS
%   trstatus = MU_lookup_tresult_status_by_name(name)
%
% INPUTS
%   * name        -- test result status name (string).
%
% OUTPUTS
%   * trstatus    -- numeric test result status code (integer)
%
% DESCRIPTION
%   Function lookups and returns the numeric test result status code for 
%   specified test result status name as follows:
%
%     * 'SUCCESS'  = 1
%     * 'FAIL'     = 0
%     * 'ERROR'    = -1
%     *  otherwise = NaN;
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
%   $Revision: 62 $
%

%   $Id: MU_lookup_tresult_status_by_name.m 62 2004-11-17 04:27:11Z ccornish $

switch(upper(name))
 case 'SUCCESS'
  trstatus = 1;
 case 'FAIL'
  trstatus = 0;
 case 'ERROR'
  trstatus = -1;
 otherwise
  trstatus = NaN;
end

return
  
