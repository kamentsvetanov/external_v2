function fl_doc(varargin)
% FL_DOC Display HTML documentation in the Help browser.
% 
%   FL_DOC, by itself, displays the FRACLAB Toolbox page for the online doc.
% 
%   FL_DOC FUNCTION displays the HTML documentation for the FRACLAB 
%   ToolBox function FUNCTION.
%  
%   FL_DOC('FUNCTION') displays the HTML documentation for the FRACLAB 
%   ToolBox function FUNCTION.
% 
%   Examples:
%       fldoc
%       fldoc('boxdim_classique')
%   
%   See also web
%
% Reference page in Help browser
%     <a href="matlab:fl_doc fl_doc">fl_doc</a>

% Author Christian Choque Cortez, November 2008

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin && ~iscellstr(varargin)
    error('MATLAB:help:NotAString', 'Argument to help must be a string.');
end

current_dir = pwd;
mydir = fl_getOption('FracLabRoot');
helpdir = fullfile(mydir,'Help','matlab-html-help'); cd(helpdir);

try
    htmlfile = ls([char(varargin) '.html']);
catch %#ok<CTCH>
    htmlfile = [];
end

if ismac && isdeployed
    if nargin && ~strcmp(varargin,'fraclab')
        if isempty(htmlfile)
            unix(['open ' 'nofoundpage.html'])
        else
            unix(['open ' htmlfile])
        end
    else
        unix(['open ' 'fraclab_product_page.html'])
    end
else
    if nargin && ~strcmp(varargin,'fraclab')
        if isempty(htmlfile)
            web 'nofoundpage.html' '-helpbrowser'
        else
            web(htmlfile, '-helpbrowser')
        end
    else
        web 'fraclab_product_page.html' '-helpbrowser'
    end
end
cd(current_dir);

end
