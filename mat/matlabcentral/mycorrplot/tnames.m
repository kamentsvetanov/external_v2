% show variable names in table
%
% Syntax:
%          out  = tnames(tablein)

function out  = tnames(tablein)
out = tablein.Properties.VariableNames;