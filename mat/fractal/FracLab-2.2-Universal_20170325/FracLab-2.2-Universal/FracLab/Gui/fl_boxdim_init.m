function fl_boxdim_init(TypeEntree)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

fl_clearerror;
global handlefig_boxdim;

fl_callwindow(['Fig_gui_fl_boxdim_',TypeEntree],'gui_fl_boxdim');

handlefig_boxdim=[gcf];
% Save the input type in the figure GUIdata
handles=guihandles(handlefig_boxdim);
handles.TypeEntree=TypeEntree;
guidata(handlefig_boxdim,handles);

switch(TypeEntree)
    case 'Signal'
        typeentreee='Grayscale data';
        nameee = 'gd';
    case 'List'
        typeentreee='List of points';
        nameee = 'lp';
    case 'Binary'
        typeentreee='Binary Data';
        nameee = 'bd';
end

set(handles.StaticText6,'String',['Box Dimension : ',typeentreee]);
set(handles.Fig_gui_fl_boxdim,'Name',[nameee,' box Dimension']);
fl_boxdim_compute('refresh');
