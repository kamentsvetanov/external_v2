function playbackdemo_fraclab(demo_name)
%This is a video which will play in your system web browser.

%Modified version of playbackddemo.m :
%PLAYBACKDEMO  Launch demo playback device
%   This utility is used to launch playback demos.
%   PLAYBACKDEMO(DEMO_NAME)
%     DEMO_NAME = name of playback demo in 
%                 matlabroot/demos/.
%
%   For example:
%   playbackdemo('desktop')

%   $Revision: 1.11.4.3 $  $Date: 2004/08/16 01:38:34 $
%   Copyright 1984-2004 The MathWorks, Inc.

% Define constants.
filefltool = which('fltool');
pathfltool = fileparts(filefltool);
lastsep = find(filesep == pathfltool,1,'last');
flroot = pathfltool(1:lastsep);
REL_PATH = 'Demos';

% Assemble file paths
html_file = strcat(fullfile(flroot,REL_PATH,demo_name),'.swf.html');

% Error out if the file doesn't exist
if exist(html_file,'file')==0
    errordlg(sprintf('Can''t find %s',html_file));
    return
end

% Convert the filename to a URL.
url = ['file:///' strrep(html_file,'\','/')];

% Launch browser
evalc('stat = web(url,''-browser'');');
if (stat==2)
   errordlg(['Could not launch Web browser. Please make sure that'  sprintf('\n') ...
   'you have enough free memory to launch the browser.']);
elseif (stat)
   errordlg(['Could not load HTML file into Web browser. Please make sure that'  sprintf('\n') ...
   'you have a Web browser properly installed on your system.']);
end
