function MU_fail(msg)
% MU_fail -- Throw error for a failed assertion.
%
%****f* lib.assert/MU_fail
%
% NAME
%   MU_fail -- Throw error for a failed assertion.
%
% SYNPOSIS
%   MU_fail([msg])
%
% INPUTS
%   * msg         -- (optional) error message (string).
%
% OUTPUTS
%   (none)
%
% SIDE EFFECTS
%   MUNIT:AssertionFailedError is thrown.
% 
% DESCRIPTION
%   Function throws the MUNIT:AssertionFailedError and passes the
%   specified message.
%
% ERRORS
%   MUNIT:AssertionFailedError  
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%    MUNIT Library:  Error Assert Functions
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
%   $Revision: 83 $
%

%   $Id: MU_fail.m 83 2005-02-15 01:02:14Z ccornish $

if (~exist('msg', 'var'))
  msg = '';
end

error('MUNIT:AssertionFailedError', msg);
  
return

