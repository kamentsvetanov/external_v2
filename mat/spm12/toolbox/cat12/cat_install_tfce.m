function varargout = cat_install_tfce(install)
% 
% This function will connect to the SBM server and install
% the TFCE toolbox
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
% $Id: cat_install_tfce.m 1791 2021-04-06 09:15:54Z gaser $

if nargin == 0
  install = spm_input('Install TFCE toolbox',1,'yes|no',[1 0],1);
end

if install
  try
    fprintf('          Download and install TFCE...\n');
    d0 = spm('Dir');
    d = fullfile(spm('Dir'),'toolbox'); 
    lastwarn('');
    s = unzip('http://www.neuro.uni-jena.de/tfce/tfce_latest.zip', d);
    fprintf('         Success: %d files have been downloaded.\n',numel(s));
    addpath(d0);
    rehash
    rehash toolboxcache;
    toolbox_path_cache
    eval(['spm fmri;clear cat_version;spm_cat12']);
  catch
    le = lasterror;
    switch le.identifier
        case 'MATLAB:checkfilename:urlwriteError'
            fprintf('          Update failed: cannot download file.\n');
        otherwise
            fprintf('\n%s\n',le.message);
    end
  end
  
  [warnmsg, msgid] = lastwarn;
  switch msgid
    case ''
    case 'MATLAB:extractArchive:unableToCreate'
        fprintf('          Update failed: check folder permission.\n');
    case 'MATLAB:extractArchive:unableToOverwrite'
        fprintf('          Update failed: check file permissions.\n');
    otherwise
        fprintf('          Update failed: %s.\n',warnmsg);
  end
end