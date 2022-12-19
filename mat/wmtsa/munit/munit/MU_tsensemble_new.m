function tse = MU_tsensemble_new(name)

if(~exist('name', 'var') || isempty(name))
  error('MUNIT:MissingRequiredArgument', ...
        [mfilename, ' requires a name argument.']);
end

tse.name = name;
tse.tsuites = [];

return
