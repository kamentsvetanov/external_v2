function [parameter,list_out] = checkforargument(list_in,varargin)
% CHECKFORARGUMENT Look for necessary arguments into varargin input
%
%   [PARAMETER,LIST_ARGUMENT] = CHECKFORARGUMENT(LIST_VARARGIN,ARGUMENT,DEFAULT)
%   returns the value of the PARAMETER for the corresponding ARGUMENT which
%   has been passed into the list of arguments LIST_VARARGIN. If the
%   ARGUMENT is not present in the list the PARAMETER takes the DEFAULT
%   value.
%
%   The default value can be a numeric or a chararacter parameter
%   The ARGUMENT can be a single 'ARGUMENT' or a list of arguments
%   ARGUMENT = {'ARGUMENT1' , 'ARGUMENT2' ,'ARGUMENT3'}
%
%   [PARAMETER,LIST_ARGUMENT] = CHECKFORARGUMENT(...,'WO')
%   returns a PARAMETER as a cell. Use this option If the ARGUMENT must be
%   accompanied "With Other" parameter. If not specified, "No Other",'NO'
%   is applied.

% Author Christian Choque Cortez, November 2008
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,4)
nargoutchk(2,2)

parameter_in = varargin{1};
list_out = list_in;

if nargin == 4
    if ~ischar(varargin{3}), error('Invalid input property %d',varargin{3});end
    if ~(strcmp(varargin{3},'no') || strcmp(varargin{3},'wo'))
    error('Invalid input property %s',varargin{3});end
    option = varargin{3};
else
    option = 'no';
end

if isnumeric(varargin{2}), default = varargin{2};
else default = varargin(2); end

if ~iscell(parameter_in)
    switch option
        case 'no'
            pos_arg = find(strcmp(list_in,parameter_in));
            if ~isempty(pos_arg)
                if pos_arg == length(list_in) || (~iscell(list_in{pos_arg+1}) && ~isnumeric(list_in{pos_arg+1}))
                    parameter = list_in(pos_arg);
                    list_out(pos_arg) = [];
                else 
                    parameter = list_in{pos_arg+1};
                    list_out(pos_arg:pos_arg+1) = [];
                end
            else
                parameter = default;
            end
            
        case 'wo'
            pos_arg = find(strcmp(list_in,parameter_in));
            if ~isempty(pos_arg)
                if pos_arg == length(list_in) || (~iscell(list_in{pos_arg+1}) && ~isnumeric(list_in{pos_arg+1}))
                    parameter = list_in(pos_arg);
                    list_out(pos_arg) = [];
                else
                    parameter = list_in(pos_arg+1);
                    parameter = parameter{:};
                    list_out(pos_arg:pos_arg+1) = [];
                end
            else
                parameter = default;
            end
    end
end

if iscell(parameter_in)
    switch option
        case 'no'
            for ii = 1:length(parameter_in)
                pos_arg = find(strcmp(list_in,parameter_in{ii}));
                if ~isempty(pos_arg)
                    parameter = list_in(pos_arg);
                    list_out(pos_arg) = [];
                    break
                else
                    parameter = default;
                end
            end
        case 'wo'
            for ii = 1:length(parameter_in)
                pos_arg = find(strcmp(list_in,parameter_in(ii)));
                if ~isempty(pos_arg)
                    if pos_arg == length(list_in) || (~iscell(list_in{pos_arg+1}) && ~isnumeric(list_in{pos_arg+1}))
                        parameter = list_in(pos_arg);
                        list_out(pos_arg) = [];
                    else
                        parameter = list_in(pos_arg:pos_arg+1);
                        list_out(pos_arg:pos_arg+1) = [];
                    end
                    break
                else
                    parameter = default;
                end
            end
    end
end
