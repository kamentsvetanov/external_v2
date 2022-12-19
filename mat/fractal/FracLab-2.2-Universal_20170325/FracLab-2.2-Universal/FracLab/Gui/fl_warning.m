function fl_warning(string,ForegroundColor,Prefix)
%FL_WARNING Displays warning message in the FracLab's warning message box. 
%
% Usage: fl_warning(string,ForegroundColor)

% Modified by Christian Choque Cortez, April 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

ShowHiddenHandlesInit = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fraclabhandle=findobj('Tag','FRACLAB Toolbox');
set(0,'ShowHiddenHandles',ShowHiddenHandlesInit);

if ~isempty(fraclabhandle)
    sth=findobj(figure(fraclabhandle),'Tag','StaticText_error');
    if nargin<3;Prefix='Error : ';end
    if nargin<2;ForegroundColor=[];end
    if isempty(ForegroundColor);ForegroundColor=[1 0 0];end
    if isempty(sth)
        fraclabhandle=findobj('Tag','FRACLAB Toolbox');
        sth=findobj(fraclabhandle,'Tag','StaticText_error');
    end
    if ischar(ForegroundColor)
        switch(ForegroundColor)
            case 'black'
                set(sth,'ForegroundColor',[0 0 0]);
            case 'white'
                set(sth,'ForegroundColor',[1 1 1]);
            case 'red'
                set(sth,'ForegroundColor',[1 0 0]);
            case 'green'
                set(sth,'ForegroundColor',[0 1 0]);
            case 'blue'
                set(sth,'ForegroundColor',[0 0 1]);
            otherwise
                Warning('Unknown ForeGroundColor Option')
                set(sth,'ForegroundColor',[0 0 0]);
        end
    else
        set(sth,'ForegroundColor',ForegroundColor);
    end
    set(sth,'String',[Prefix,string]);
else
    warning(string); %#ok<WNTAG>
end
