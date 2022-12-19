function VBA_disp(str,options)

% Conditional display function

if options.verbose
    disp(str)
end