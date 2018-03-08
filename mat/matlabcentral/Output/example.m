% This script shows how to use the Output class.

Output.INFO('Starting script.\n');

Output.INFO('We will loop for the first time: \n');

% This messages won't show, because default output level is INFO!
for k=1:10
  Output.DEBUG('On for loop, k = %d.\n',k);
  for m=1:2
    Output.VERBOSE('Inner for loop, m = %d.\n',m);
  end
end

Output.INFO(['Nothing was displayed, now we change output to' ... 
  'display debug messages. \n']);
Output.level(Output.DISP_DEBUG)

Output.INFO('We will loop for the second time: \n');
for k=1:10
  Output.DEBUG('On for loop, k = %d.\n',k);
  for m=1:2
    Output.VERBOSE('Inner for loop, m = %d.\n',m);
  end
end

Output.INFO(['Now we see debug messages. But we may want'...
  ' more information, let''s display verbose messages: \n']);
Output.level(Output.DISP_VERBOSE)

Output.INFO('We will loop for the third time: \n');
for k=1:10
  Output.DEBUG('On for loop, k = %d.\n',k);
  for m=1:2
    Output.VERBOSE('Inner for loop, m = %d.\n',m);
  end
end

Output.level(Output.DISP_WARNING)
Output.INFO('This message won''t be displayed!\n');

Output.WARNING('Only warnings and errors can be seen!.\n');

Output.level(Output.MUTE)

Output.WARNING('This message won''t be displayed!.\n');

try
  Output.ERROR('script:error',['Only error messages will be displayed'...
    ' now.']);
catch ext
  disp(ext.getReport)
end

Output.level(Output.DISP_INFO)
Output.INFO(['Set output level back to info. Will change '...
  'output place to test.log!.\n']);

Output.place('test.log');

Output.INFO('This message will be print into the log file x).\n');

Output.place(1);

Output.INFO(['One message was print into the log file '...
  '''test.log''.\n']);

