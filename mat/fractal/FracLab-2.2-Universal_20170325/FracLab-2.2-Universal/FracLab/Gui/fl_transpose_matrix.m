function [varargout] = fl_create_structures(varargin)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch (varargin{1})

    case 'refresh'
        fl_clearerror;
        [inputName flag_error]=fl_get_input('matrix');
        if flag_error
            fl_warning('input signal must be a matrix !');
        else
            eval(['global ' inputName]);
            sth = findobj ('Tag','Text_transpose_matrix');
            set (sth,'String',inputName);

        end

    case 'transpose'
        fl_clearerror;
        sth = findobj ('Tag','Text_transpose_matrix');
        inputName=get(sth,'String');
        if isempty(inputName)
            fl_warning('Input signal must be initiated: Refresh!');
        else
            eval(['global ' inputName]);
            OutputName=['tr_' inputName];
            varname = fl_findname(OutputName,varargin{2});
            eval(['global ' varname]);
            varargout{1}=varname;

            eval([varname '=' inputName, ''';']);
            chaine=[varname '=' inputName ''';'];
            fl_diary(chaine);
            fl_addlist(0,varname) ;
        end
end