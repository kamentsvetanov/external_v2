function MU_assert_fuzzy_diff(expected_value, actual_value, fuzzy_tol, message, mode)
% MU_assert_fuzzy_diff -- Assert that expected and actual values are equal within fuzzy diff tolerance.
%
%****f* lib.assert/MU_assert_fuzzy_diff
%
% NAME
%   MU_assert_fuzzy_diff -- Assert that expected and actual values are within fuzzy diff tolerance.
%
% SYNOPSIS
%   MU_assert_fuzzy_diff(expected_value, actual_value, [fuzzy_tol], [message])
%
% INPUTS
%   * expected_value -- vector or array of expected values (number).
%   * actual_value   --  vector or array of actual values (number).
%   * fuzzy_tol      -- (optional) minimum tolerance or threshold
%                       Valid values:  >= 0
%                       Default: 0
%   * message        -- (optional) supplemental message (string).
%
% DESCRIPTION
%   Function checks that expected and actual values are equal within
%   fuzzy tolerance.  If not, it calls MU_fail to throw 
%   MUNIT:AssertionFailedError.
%
% ERRORS
%   MUNIT:AssertionFailedError  (via MU_fail).
%
% SEE ALSO
%   fuzzy_diff
%
% TOOLBOX
%    munit/munit
%
% CATEGORY
%    MUNIT Library:  Assert Functions
%
%***

% AUTHOR
%   Charlie Cornish
%
% CREATION DATE
%   2004-Apr-27
%
% COPYRIGHT
%   (c) 2004, 2005 Charles R. Cornish
%
% CREDITS
%
%
% REVISION
%   $Revision: 111 $
%

%   $Id: MU_assert_fuzzy_diff.m 111 2005-08-03 00:51:53Z ccornish $
  
default_fuzzy_tol = 0;
default_mode = 'normal';


if (~exist('fuzzy_tol', 'var') || isempty(fuzzy_tol))
  fuzzy_tol = default_fuzzy_tol;
end

if (fuzzy_tol < 0)
    error(['fuzzy_tol = ', num2str(fuzzy_tol), ' must be >= 0.']);
end

if (~exist('mode', 'var') || isempty(mode))
  mode = default_mode;
end

if (MU_lookup_mode_num_by_name(mode) >= 5)
  str = ['Asserting fuzzy_diff between ', inputname(1), ' and ', inputname(2), ' ...'];
  disp(str);
end

if (size(expected_value) ~= size(actual_value))
  error(['Size of expected value (', inputname(1), ...
         ', size = ', num2str(size(expected_value)), ')  ', ... 
         'must equal size of actual value  (', ...
         inputname(2), ', size = ', num2str(size(actual_value)), ').']);
end

ndiffs = fuzzy_diff(expected_value, actual_value, fuzzy_tol, 'summary');

if (exist('mode', 'var') & MU_lookup_mode_num_by_name(mode) >= 5)
   max_diff = norm(expected_value - actual_value, Inf);
   disp(['Fuzzy Diff results: ']);
   disp([' Expected variable: ', inputname(1)]);
   disp([' Actual variable  : ', inputname(2)]);
   disp([' fuzzy tolerance  : ', num2str(fuzzy_tol)]);
   disp([' num of diffs     : ', num2str(ndiffs)]);
   disp([' largest diff     : ', num2str(max_diff)]);
end


if (ndiffs == 0)
  % Passed test
else
  % Failed test
  [S] = dbstack;
  if (length(S) > 1)
    funcname = S(2).name;
    linenum = S(2).line;
  else
    funcname = '';
    linenum = [];
  end
  msg = mfilename;

  msg = [msg, ': Expected value of (', inputname(1), ') ', ...
         'not equal within fuzzy diff tolerance of actual value of (', ...
         inputname(2), ').  ndiffs = ', int2str(ndiffs), ...
         ' for fuzzy tolerance = ', ...
         num2str(fuzzy_tol), '.'];

  if (exist('message', 'var') && ~isempty(message))
    msg = [msg, ': ', message]
  end
  
  MU_fail_line(funcname, linenum, msg);

end
    
return
    

function result = fuzzy_diff(a, b, fuzzy_tol, mode)
% fuzzy_diff --  Compare two arrays and identify or summarize those elements with differences exceeding the fuzzy tolerance.
%
%****f* MU_assert_fuzzy_diff/fuzzy_diff
%
% NAME
%   fuzzy_diff --  Compare two arrays and identify or summarize those elements with differences exceeding the fuzzy tolerance.
%
% USAGE
%   result = fuzzy_diff(a, b, [fuzzy_tol], [mode])
%
% INPUTS
%   * a             -- first array or vector of values
%   * b             -- second array or vector of values
%   * fuzzy_tol     -- (optional) minimum tolerance or threshold
%                      Valid values:  >= 0
%                      Default: 0
%   * mode          -- (optional) format of returned result
%                      Valid Values:  'detailed', 'summary'
%                      Default:  'detailed'
%
% OUTPUTS
%   result           = array or scalar containing the result of comparison.
%
% DESCRIPTION
%   fuzzy_diff compares two arrays and allows approximate equality when strict
%   equality may not exist due to minor differences due to rounding errors.  
%   fuzzy_diff subtracts two arrays and identifies those elements whose 
%   differences exceed the fuzzy tolerance threshold.  
%
%   The function has 2 modes of operation specified via mode:
%      detailed  = return an array of size(a) with elements 
%                   = 0,   for differences between a and b <  fuzzy_tolerance
%                   = a-b, for differences between a and b >= fuzzy_tolerance
%      summary   = return a number whose values 
%                   = 0, for no differences within fuzzy_tolerance
%                   > 0, number of elements >= fuzzy_tolerance
%
%***

if (size(a) ~= size(b))
  error(['size of a (', inputname(1), ', size = ', num2str(size(a)), ')  ', ... 
         'must be equal size of b  (', inputname(2), ', size = ', num2str(size(b)), ').']);
end

default_fuzzy_tol = 0;
default_mode = 'details';

if (~exist('fuzzy_tol', 'var') || isempty(fuzzy_tol))
  fuzzy_tol = default_fuzzy_tol;
end

if (fuzzy_tol < 0)
    error(['fuzzy_tol = ', num2str(fuzzy_tol), ' must be >= 0.']);
end

if (~exist('mode', 'var') || isempty(mode))
  mode = default_mode;
end

result = [];

fuzzy_locations = find( abs( a - b ) <= fuzzy_tol);

switch mode
 case {'detailed', 'details'}
  abdiff = a - b;
  abdiff(fuzzy_locations) = 0;
  result = abdiff;
 case 'summary'
  abdiff = ones(size(a));
  abdiff(fuzzy_locations) = 0;
  diff_sum = sum(abdiff(:));
  result = diff_sum;
 otherwise
  error(['Unknown mode']);
end

return
