function MU_assert_numsigdig_diff(expected_value, actual_value, numsigdig, message, mode)
% MU_assert_numsigdig_diff -- Assert that expected and actual values are equal within number of significant digits.
%
%****f* lib.assert/MU_assert_numsigdig_diff
%
% NAME
%   MU_assert_numsigdig_diff -- Assert that expected and actual values are equal within number of significant digits.
%
% SYNOPSIS
%   MU_assert_numsigdig_diff(expected_value, actual_value, [numsigdig], [message])
%
% INPUTS
%   * expected_value -- expected value.
%   * actual_value   -- actual value.
%   * numsigdig      -- (optional) minimum tolerance or threshold
%                       Valid values:  integers >= 0
%                       Default: 0
%   * message        -- (optional) supplemental message (character string).
%   * mode           -- (optional) level of detail for output diagnostics.
%
% OUTPUTS
%   (none)
%
% DESCRIPTION
%   Function checks that expected and actual values are equal within
%   numsigdig sigificiant digits.  If not, it calls MU_fail to throw 
%   MUNIT:AssertionFailedError.
%
%   mode argument controls level of detail of output as follows:
%    'details'   = print diagnostics while running tests as well all test names 
%                  and their status, and test case summary.
%    otherwise, no output printed.
%
% ERRORS
%   MUNIT:AssertionFailedError  (via MU_fail).
%
% SEE ALSO
%   numsigdig_diff
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
%
%
% CREDITS
%
%
% REVISION
%   $Revision: 111 $
%

%   $Id: MU_assert_numsigdig_diff.m 111 2005-08-03 00:51:53Z ccornish $

default_numsigdig = 15;
default_mode = 'normal';

if (~exist('numsigdig', 'var') || isempty(numsigdig))
  numsigdig = default_numsigdig;
end

if (numsigdig < 0)
    error(['numsigdig = ', num2str(numsigdig), ' must be >= 0.']);
end

if (~exist('mode', 'var') || isempty(mode))
  mode = default_mode;
end

if (MU_lookup_mode_num_by_name(mode) >= 5)
  str = ['Asserting numsigdig_diff between ', inputname(1), ' and ', inputname(2), ' ...'];
  disp(str);
end

ndiffs = numsigdig_diff(expected_value, actual_value, numsigdig, 'summary');

if (MU_lookup_mode_num_by_name(mode) >= 5)
   max_diff = norm(expected_value - actual_value, Inf);
   max_numsigdig = norm(round(log10(abs((expected_value - actual_value) ./ expected_value))), Inf);
   disp(['Number of Signifcant Digits Diff results: ']);
   disp([' Expected variable       : ', inputname(1)]);
   disp([' Actual variable         : ', inputname(2)]);
   disp([' Num significant digits  : ', num2str(numsigdig)]);
   disp([' num of diffs            : ', num2str(ndiffs)]);
   disp([' largest diff            : ', num2str(max_diff)]);
   disp([' largest numsigdig dif   : ', num2str(max_numsigdig)]);
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
         'not equal within number of significant digits tolerance of actual value of (', ...
         inputname(2), ').  ndiffs = ', int2str(ndiffs), ...
         ' for numsigdig = ', ...
         num2str(numsigdig), '.'];

  if (exist('message', 'var') && ~isempty(message))
    msg = [msg, ': ', message]
  end
  
  MU_fail_line(funcname, linenum, msg);

end
    
return
    

function result = numsigdig_diff(x, y, numsigdig, mode)
% numsigdig_diff --  Find differences in two arrays exceedning number of significant digits.
%
%****f* wmtsa.utils/numsigdig_diff
%
% NAME
% numsigdig_diff --  Find differences in two arrays exceedning number of significant digits.
%
% USAGE
%   result = numsigdig_diff(a, b, [numsigdig], [mode])
%
% INPUTS
%   x                = first array or vector of values
%   y                = second array or vector of values
%   numsigdig            = (optional) number of significant digits threshold
%                      Valid values:  >= 0
%                      Default: 0
%   mode             = (optional) format of returned result
%                      Valid Values:  'details', 'summary'
%                      Default:  'details'
%
% OUTPUT
%   result           = array or number containing the result of comparison.
%
% DESCRIPTION
%   numsigdig_diff compares two arrays and allows approximate equality when strict
%   equality may not exist due to minor differences due to rounding errors.  
%   numsigdig_diff subtracts two arrays and identifies those elements whose 
%   differences exceed the given number of significant digits.
%
%   The function has 2 modes of operation:
%      details   = return an array of size(a) with elements 
%                   = 0,   for differences between a and b <  number of significant digits
%                   = a-b, for differences between a and b >= number of significant digits
%      summary   = return a number whose values 
%                   = 0, for no differences >  number of significant digits
%                   > 0, number of elements >= number of significant digits.
%

  
defaults.numsigdig = 15;
defaults.mode = 'details';
  
if (size(x) ~= size(y))
  error(['size(x) must be equal size(y)']);
end

if (~exist('numsigdig', 'var') || isempty(numsigdig))
  numsigdig = defaults.numsigdig;
end

if (numsigdig < 0)
    error(['numsigdig = ', num2str(numsigdig), ' must be >= 0.']);
end

if (~exist('mode', 'var') || isempty(mode))
  mode = defaults.mode;
end

result = [];

% Find array elements that are within numsigdig tolerance.
% numsigdig_locations = ...
%    find( round(log10(abs( (x - y) ./ x))) + numsigdig <= 0)

% Find array elements with differences less than numsigdig tolerance.
xx = x;
xx(find(xx == 0)) = 1;
% lt_numsigdig_diff_locations = ...
%    find( (log10(abs( (x - y) ./ abs(x)))) +  numsigdig <= 0)

lt_numsigdig_diff_locations = ...
    find( round(log10(abs( (xx - y) ./ xx))) + numsigdig <= 0)

% lt_numsigdig_diff_locations = ...
%     find( round(log10(abs( (x - y))) - log10(y)) + numsigdig <= 0)



switch mode
 case {'details', 'detailed'}
  xydiff = x - y;
  xydiff(lt_numsigdig_diff_locations) = 0;
  result = xydiff;
 case 'summary'
  xydiff = ones(size(x));
  xydiff(lt_numsigdig_diff_locations) = 0;
  diff_sum = sum(xydiff(:));
  result = diff_sum;
 otherwise
  error(['Unknown mode']);
end


return
