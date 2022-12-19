function [varargout]=fl_tools_choice(varargin)
% No help found
 
% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

 switch(varargin{1})
   
   case 'dilate'
     
     fl_callwindow('Fig_gui_fl_dilate','gui_fl_dilate') ;
     
   case 'fmt'
     
     fl_callwindow('Fig_gui_fl_fmt','gui_fl_fmt') ;
     
   case 'theospec'
     
     fl_callwindow('Fig_gui_fl_bp','gui_fl_bp') ;

 end
