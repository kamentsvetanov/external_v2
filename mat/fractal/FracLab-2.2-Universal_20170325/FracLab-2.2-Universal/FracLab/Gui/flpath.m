function flpath()
% FLPATH Adds into the Matlab path all the FRACLAB directories.

% Modified by Christian Choque Cortez, January 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

MYDIR = fl_getOption('FracLabRoot');
addpath(fullfile(MYDIR,'Data'));
addpath(fullfile(MYDIR,'Demos'));
addpath(fullfile(MYDIR,'Gui'));
addpath(fullfile(MYDIR,'Help','matlab-html-help'));
addpath(fullfile(MYDIR,'Help','matlab-html-help','matlab-help'));
addpath(fullfile(MYDIR,'Programs'));
addpath(fullfile(MYDIR,'Programs','IAE'));
addpath(fullfile(MYDIR,'Programs','wavelab'));
s=warning('off','all'); 
% Un et un seul des 4 repertoires ci-dessous est effectivement présent.
% Il dépend de l'installation de Fraclab.
addpath(fullfile(MYDIR,'Binaries'));
addpath(fullfile(MYDIR,'Binaries','windows32'));
addpath(fullfile(MYDIR,'Binaries','windows64'));
addpath(fullfile(MYDIR,'Binaries','linux32'));
addpath(fullfile(MYDIR,'Binaries','linux64'));
addpath(fullfile(MYDIR,'Binaries','osx32intel'));
addpath(fullfile(MYDIR,'Binaries','osx64intel'));
savepath;
warning(s);
disp('Fraclab successfully added to Matlab path');
end
