function nrec = MU_print_tresults(tresults, mode)
% MU_print_tresults  -- Print test case results.
%
%****f* lib.report/MU_print_tresults
%
% NAME
%   MU_print_tresults  -- Print test case results.
%
% SYNOPSIS
%   MU_print_tresults(tresults, [mode])
%
% INPUTS
%   * tresults    -- vector of test result structs (tresult_s).
%   * mode        -- (optional) mode for level of detail of output.
%
% OUTPUTS
%   nrec          -- number of test result records printed (interger).
%
% SIDE EFFECTS
%   Test results printed to command window.
%
% DESCRIPTION
%   Function prints the test results in the tresults vector.
%
%   See MUnit_Variables for a description of mode.
%
% SEE ALSO
%   tresult_s
%
% TOOLBOX
%     munit/munit
%
% CATEGORY
%   MUNIT Library:  Reporting Functions
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
%   $Revision: 69 $
%

%   $Id: MU_print_tresults.m 69 2004-11-18 00:35:58Z ccornish $

nrec = 0;
  
switch(lower(mode))
 case {'silent'}
  nrec = print_errors(tresults);
 case {'minimal'}
  nrec = print_errors(tresults);
 case 'normal'
  nrec = print_failures(tresults);
 case 'verbose'
  nrec = print_all(tresults);
 case 'details'
  nrec = print_all(tresults);
 otherwise
   % Do nothing.
end
  
return

function nrec = print_errors(tresults)
  
  nrec = 0;
  for (i = 1:length(tresults))
    tr = tresults(i);

    switch tr.trstatus
     case MU_lookup_tresult_status_by_name('SUCCESS')
      % do nothing
     case MU_lookup_tresult_status_by_name('FAIL')
      % do nothing
     case MU_lookup_tresult_status_by_name('ERROR')
      msg = ['ERROR:    ', tr.tcname, ': ', func2str(tr.testfh)];
      disp(msg);
      if (~isempty(deblank(tr.message)))
        msg = ['   ', deblank(tr.message)];
        disp(msg);
      end
      msg = ['ERROR:    ', tr.tcname, ': ', func2str(tr.testfh)];
      nrec = nrec + 1;
     otherwise
      % do nothing
    end
  end
  
return

function nrec = print_failures(tresults)

  nrec = 0;
  for (i = 1:length(tresults))
    tr = tresults(i);

    switch tr.trstatus
     case MU_lookup_tresult_status_by_name('SUCCESS')
      % do nothing
     case MU_lookup_tresult_status_by_name('FAIL')
      msg = ['FAILED:   ', tr.tcname, ': ', func2str(tr.testfh)];
      disp(msg);
      if (~isempty(deblank(tr.message)))
        msg = ['   ', deblank(tr.message)];
        disp(msg);
      end
      nrec = nrec + 1;
     case MU_lookup_tresult_status_by_name('ERROR')
      msg = ['ERROR:    ', tr.tcname, ': ', func2str(tr.testfh)];
      disp(msg);
      if (~isempty(deblank(tr.message)))
        msg = ['   ', deblank(tr.message)];
        disp(msg);
      end
      nrec = nrec + 1;
     otherwise
      % do nothing
    end
  end
  
return
  
function nrec = print_all(tresults)

  nrec = 0;
  for (i = 1:length(tresults))
    tr = tresults(i);

    switch tr.trstatus
     case MU_lookup_tresult_status_by_name('SUCCESS')
      msg = ['SUCCESS:  ', tr.tcname, ': ', func2str(tr.testfh)];
     case MU_lookup_tresult_status_by_name('FAIL')
      msg = ['FAILED:   ', tr.tcname, ': ', func2str(tr.testfh)];
     case MU_lookup_tresult_status_by_name('ERROR')
      msg = ['ERROR:    ', tr.tcname, ': ', func2str(tr.testfh)];
     otherwise
      % do nothing
    end
    disp(msg);
    nrec = nrec + 1;

    if (~isempty(deblank(tr.message)))
      msg = ['   ', deblank(tr.message)];
      disp(msg);
    end
  end

return
