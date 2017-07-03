function outStr = wfu_str_fix(inStr,option,varargin)
    
%   Modify string in various ways
%   FORMAT outStr = wfu_str_fix(inStr,option,varargin)
%   
%   outStr      -   modified string
%   inStr       -   string to modify 
%   option      -   string of option flags
%   varargin    -   (optional) see examples below 
%               
%   Options are:
%   
%   're     -   remove extension 
%               eg. wfu_str_fix('testfile.txt','re')
%               'testfile' is returned.
%               eg. wfu_str_fix('/home/dir/testfile.m','re')
%               '/home/dir/testfile' is returned
%
%   'rf'    -   removes file and suffix after last filesep
%               eg. wfu_str_fix('/home/dir/testfile.m','rf')
%               '/home/dir/testfile' is returned
%
%   'rp'    -   removes path, leaves file
%               eg. wfu_str_fix('/home/dir/testfile.m','rp')
%               'testfile.m' is returned
%   
%   'rlc'   -   removes n leading characters
%               eg. wfu_str_fix('testfile.txt','rlc',4)
%               'file.txt' is returned
%
%   'kf'    -   keep file, discard the rest
%               eg. wfu_str_fix('home/dir/testfile.m','kf')
%               'testfile' is returned
%
%   'ke'    -   keep extension, discard the rest
%               eg. wfu_str_fix('home/dir/testfile.m','ke')
%               '.m' is returned
%
%   'se'    -   swap extension
%               3rd argument must be an extension (string)
%               eg. wfu_str_fix('testfile.txt','se','m')
%               'testfile.txt' is returned
%
%   ##  v1.1, Aaron Baer, Wake Forest University        ##
%____________________________________________________________

switch option
    case 're'
        dotsIx  = find(inStr=='.');
        if isempty(dotsIx), outStr = inStr; return; end
        lastIx  = dotsIx(end);
        outStr  = inStr(1:lastIx-1);
        
    case 'rf'
        fsepIx  = find(inStr==filesep); 
        if isempty(fsepIx), outStr = inStr; return; end
        lastIx  = fsepIx(end); 
        outStr  = inStr(1:lastIx-1);
        
    case 'rp'
        fsepIx  = find(inStr==filesep); 
        if isempty(fsepIx), outStr = inStr; return; end
        lastIx  = fsepIx(end);
        outStr  = inStr(lastIx+1:end);
        
    case 'rlc'
        num2take = varargin{1}; 
        outStr   = inStr(num2take+1:end);
        
    case 'rtc'
        num2take = varargin{1}; 
        outStr   = inStr(1:end-num2take); 
        
    case 'kf'
        inStr   = wfu_str_fix(inStr,'rp');
        outStr  = wfu_str_fix(inStr,'re');
        
    case 'ke'
        dotsIx  = find(inStr=='.');
        if isempty(dotsIx), outStr = inStr; return; end
        lastIx  = dotsIx(end);
        outStr  = inStr(lastIx+1:end);
        
    case 'sf'
        dotsIx  = find(inStr=='.');
        if isempty(dotsIx), outStr = inStr; return; end
        lastIx  = dotsIx(end);
        ext     = inStr(lastIx:end);
        path    = wfu_str_fix(inStr,'rf');
        if nargin < 3, error('For type ''se'', 3rd argument must be new extension (eg. ''txt'')'); 
        else outStr  = fullfile(path,[varargin{1},ext]); 
        end
        
    case 'se'
        dotsIx  = find(inStr=='.');
        if isempty(dotsIx), outStr = inStr; return; end
        lastIx  = dotsIx(end);
        halfstr = inStr(1:lastIx);
        if nargin < 3, error('For type ''se'', 3rd argument must be new extension (eg. ''txt'')'); 
        else outStr  = [halfstr,varargin{1}]; 
        end
        
    otherwise
        warning(sprintf('String manipulation option (''%s'') invalid.',option));
        return
end
return 