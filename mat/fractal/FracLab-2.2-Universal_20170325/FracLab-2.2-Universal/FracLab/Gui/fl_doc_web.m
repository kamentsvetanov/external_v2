function []=fl_doc_web()
% No help found

% Author Christian Choque Cortez, November 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if ispc
    !start http://fraclab.saclay.inria.fr/download
else
    web('http://fraclab.saclay.inria.fr/download','-browser')
end