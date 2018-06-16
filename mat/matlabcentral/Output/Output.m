classdef Output
%
% Class Output.
%   Class to determine output.
%
% --- Usage Instructions ---
%
% At your files, use the methods: 
%
%     - Output.VERBOSE
%     - Output.DEBUG
%     - Output.INFO
%     - Output.WARNING
%     - Output.ERROR
%
% as you would do with sprintf. I.e:
%
%     Output.DEBUG(['Display Message with %d and'...
%       %s.'],integer_output,string_output);
%
%   And to see that message, change the output level using level
% function:
%
%     Output.level(Output.DISP_DEBUG)
%
% Possible levels are:
%
%   - DISP_VERBOSE: All possible output.
%   - DISP_DEBUG: Debug mLvl.
%   - DISP_INFO: Info mLvl (default).
%   - DISP_WARNING: Only warnings.
%   - MUTE: Only fatal outputs will be displayed.
%
%
%   Finally, if you want the output to go to some file instead of
% the screen, use: 
%
%     Output.place('fileName')
%
% or 
%
%     Output.place('fileName',true)
%
% when you want to replace the log file (beware not to use a file name
% that contains any kind of data, it will be replace by the log
% file!!).
%
%     You can reset the output to the screen by doing:
%     
%     Output.place(1)
% 

% Author: W.S.Freund <wsfreund_at_gmail_dot_com> 

  enumeration
    DISP_VERBOSE(0)
    DISP_DEBUG(1)
    DISP_INFO(2)
    DISP_WARNING(3)
    MUTE(4)
  end

  properties
    mLvl
  end
  
  properties(Constant)
    methodLen = 30;
  end

  methods 
    function out = Output(lvl)
      out.mLvl = lvl;
    end
    function out = le(in1,in2)
      out = in1.mLvl <= in2.mLvl;
    end
  end

  methods (Static)
    function out = level(tLevel)
      persistent mLvl;
      if nargin > 0
        if(~isa(tLevel,'Output'))
          error('Output:level:WrongInputs',...
            'Argument tLevel must be an Output object.');
        else
          mLvl = tLevel;
        end
      end
      if isempty(mLvl)
        mLvl = Output.DISP_INFO;
      end
      if nargout == 1
        out = mLvl;
      end
    end

    function out = place(inPlace,replace)
      persistent mPlace;
      if isempty(mPlace)
        mPlace = 1;
      end
      if nargin > 0
        if nargin < 2
          replace = false;
        end
        if(ischar(inPlace))
          % Set new file using char
          try 
            if ~replace
              fExist = exist(inPlace,'file');
              if fExist
                warning('Output:place:FileExist',...
                  ['Tried to change output place, but file already'...
                  ' exists. If you want to replace it, use:\n\n'...
                  '   Output.place(''your_file_path'',true).\n\n'...
                  'Output will keep old output place.\n']);
                return
              end
              inPid=fopen(inPlace,'w');
            else
              inPid=fopen(inPlace,'w');
            end
          catch ext
            rethrow(ext);
          end
          % Close old file:
          try 
            switch mPlace
            case {1,2}
              % Do nothing
            otherwise
              fclose(mPlace);
            end
          catch ext
            warning(ext.getReport);
          end
          mPlace = inPid;
        else
          try 
            % Close old file:
            switch mPlace
            case {1,2}
              % Do nothing
            otherwise
              fclose(mPlace);
            end
          catch ext
            warning(ext.getReport);
          end
          switch inPlace
          case {1,2}
            mPlace = inPlace;
          otherwise
            warning('Output:place:WrongInput',...
              ['If you want to set output to a file, use it path '...
              'as input.']);
          end
        end
      end
      if nargout == 1
        out = mPlace;
      end
    end

    function VERBOSE(varargin)
      if Output.level<=Output.DISP_VERBOSE
        if nargin>0
          try
            mfile = dbstack; mfile = mfile(2).name;
          catch
            mfile = 'MATLAB.INTERPRETER';
          end
          len = numel(mfile);
          if len>Output.methodLen
            mfile = [mfile(1:Output.methodLen-3) ...
              '...'];
          else
            mfile = [mfile repmat(' ',1,...
              Output.methodLen-len)];
          end
          if nargin>1
            fprintf(Output.place,['VERBOSE: ' mfile '\t' varargin{1}],...
              varargin{2:end});
          else
            fprintf(Output.place,['VERBOSE: ' mfile '\t' varargin{1}]);
          end
        else
          error('Output:VERBOSE:WrongInputs',...
            'Too few inputs.');
        end
      end
    end

    function DEBUG(varargin)
      if Output.level<=Output.DISP_DEBUG
        if nargin>0
          try
            mfile = dbstack; mfile = mfile(2).name;
          catch
            mfile = 'MATLAB.INTERPRETER';
          end
          len = numel(mfile);
          if len>Output.methodLen
            mfile = [mfile(1:Output.methodLen-3) ...
            '...'];
          else
            mfile = [mfile repmat(' ',1,...
              Output.methodLen-len)];
          end
          if nargin>1
            fprintf(Output.place,['DEBUG:   ' mfile '\t' varargin{1}],...
              varargin{2:end});
          else
            fprintf(Output.place,['DEBUG:   ' mfile '\t' varargin{1}]);
          end
        else
          error('Output:DEBUG:WrongInputs',...
            'Too few inputs.');
        end
      end
    end

    function INFO(varargin)
      if Output.level<=Output.DISP_INFO
        if nargin>0
          try
            mfile = dbstack; mfile = mfile(2).name;
          catch
            mfile = 'MATLAB.INTERPRETER';
          end
          len = numel(mfile);
          if len>Output.methodLen
            mfile = [mfile(1:Output.methodLen-3) '...'];
          else
            mfile = [mfile repmat(' ',1,...
              Output.methodLen-len)];
          end
          if nargin>1
            fprintf(Output.place,['INFO:    ' mfile '\t' varargin{1}],...
              varargin{2:end});
          else
            fprintf(Output.place,['INFO:    ' mfile '\t' varargin{1}]);
          end
        else
          error('Output:INFO:WrongInputs',...
            'Too few inputs.');
        end
      end
    end


    function WARNING(varargin)
      if Output.level<=Output.DISP_WARNING
        if nargin>0
          if nargin>2
            switch Output.place
            case {1,2}
              warning(varargin{1},varargin{2},varargin{3:end});
            otherwise
              try
                mfile = dbstack; mfile = mfile(2).name;
              catch
                mfile = 'MATLAB.INTERPRETER';
              end
              len = numel(mfile);
              if len>Output.methodLen
                mfile = [mfile(1:Output.methodLen-3) ...
                  '...'];
              else
                mfile = [mfile repmat(' ',1,...
                  Output.methodLen-len)];
              end
              fprintf(Output.place,['WARNING: ' mfile '\t'...
                varargin{2}],varargin{3:end});
            end
          elseif nargin==2
            switch Output.place
            case {1,2}
              warning(varargin{1},varargin{2});
            otherwise
              try
                mfile = dbstack; mfile = mfile(2).name;
              catch
                mfile = 'MATLAB.INTERPRETER';
              end
              len = numel(mfile);
              if len>Output.methodLen
                mfile = [mfile(1:Output.methodLen-3) ...
                  '...'];
              else
                mfile = [mfile repmat(' ',1,...
                  Output.methodLen-len)];
              end
              fprintf(Output.place,['WARNING: ' mfile '\t'...
                varargin{2}]);
            end
          else
            try
              mfile = dbstack; mfile = mfile(2).name;
            catch
              mfile = 'MATLAB.INTERPRETER';
            end
            len = numel(mfile);
            if len>Output.methodLen
              mfile = [mfile(1:Output.methodLen-3) ...
                '...'];
            else
              mfile = [mfile repmat(' ',1,...
                Output.methodLen-len)];
            end
            fprintf(Output.place,['WARNING: ' mfile '\t' varargin{1}]);
          end
        end
      end
    end

    function ERROR(varargin)
      if nargin>0
        if nargin>2
          ext = MException(varargin{1},varargin{2},varargin{3:end});
          switch Output.place
          case {1,2}
            % Don't show, it will already print the message on screen.
          otherwise
            try
              mfile = dbstack; mfile = mfile(2).name;
            catch
              mfile = 'MATLAB.INTERPRETER';
            end
            len = numel(mfile);
            if len>Output.methodLen
              mfile = [mfile(1:Output.methodLen-3) ...
                '...'];
            else
              mfile = [mfile repmat(' ',1,...
                Output.methodLen-len)];
            end
            fprintf(Output.place,['ERROR:   ' mfile '\t' varargin{2}],...
              varargin{3:end});
          end
          throw(ext);
        elseif nargin==2
          ext = MException(varargin{1},varargin{2});
          switch Output.place
          case {1,2}
            % Don't show, it will already print the message on screen.
          otherwise
            try
              mfile = dbstack; mfile = mfile(2).name;
            catch
              mfile = 'MATLAB.INTERPRETER';
            end
            len = numel(mfile);
            if len>Output.methodLen
              mfile = [mfile(1:Output.methodLen-3) ...
                '...'];
            else
              mfile = [mfile repmat(' ',1,...
                Output.methodLen-len)];
            end
            fprintf(Output.place,['ERROR:   ' mfile '\t' varargin{2}]);
          end
          throw(ext);
        else
          try
            mfile = dbstack; mfile = mfile(2).name;
          catch
            mfile = 'MATLAB.INTERPRETER';
          end
          len = numel(mfile);
          if len>Output.methodLen
            mfile = [mfile(1:Output.methodLen-3) ...
              '...'];
          else
            mfile = [mfile repmat(' ',1,...
              Output.methodLen-len)];
          end
          fprintf(Output.place,['ERROR:   ' mfile '\t' varargin{1}]);
        end
      end
    end
  end

end
