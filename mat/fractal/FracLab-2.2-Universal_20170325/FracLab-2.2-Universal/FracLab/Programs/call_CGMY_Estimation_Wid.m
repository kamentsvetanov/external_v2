function res=call_CGMY_Estimation_Wid()

fl_callwindow('Fig_gui_fl_CGMY_Estimation','gui_fl_CGMY_Estimation') ;

culloch_fig = findobj ('Tag','Fig_gui_fl_CGMY_Estimation');
fl_clearerror;
[input_sig flag_error]=fl_get_input('vector');
if flag_error
fl_warning('input signal must be a vector !');
else 
        %%%%%%%%%%%%%%% input frame %%%%%%%%%%%
set(findobj(culloch_fig,'Tag','EditText_sig_nname'), ... 
'String',input_sig);
end
end