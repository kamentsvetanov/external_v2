function MU_fail_line(funcname, linenum, message)
% MU_fail_line -- Encode function name, line number and message of failure into error message string and call MU_fail.
%
%****f* lib.assert/MU_fail_line
%
% NAME
%   MU_fail_line -- Encode function name, line number and message of failure into error message string and call MU_fail.
%
% SYNPOSIS
%   MU_fail_line([funcname], [linenum], [message])
%
% INPUTS
%   * funcname    -- (optional) name of function that failed (assertion occurred)
%                    (string).
%   * linenum     -- (optional) line number where error occurred in funcname (integer).
%   * message     -- (optional) supplemental message (string).
%
% OUTPUTS
%   (none)
%
% DESCRIPTION
%   Function is a wrapper function that encodes the function name and line number 
%   where an assertion error occurred along with supplmental message into error 
%   string and then calls  MU_fail which throws an assertion error.
%
% ERRORS
%   MUNIT:AssertionFailedError  (via MU_fail).
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

%   $Id: MU_fail_line.m 83 2005-02-15 01:02:14Z ccornish $

msg = '';

if (exist('funcname', 'var') && ~isempty(funcname))
  msg = [msg, funcname];
end

if (exist('linenum', 'var') && ~isempty(linenum))
  msg = [msg, ': line ', int2str(linenum)];
end

if (exist('message', 'var') && ~isempty(message))
  msg = [msg, ': ', message];
end

MU_fail(msg);
  
return

