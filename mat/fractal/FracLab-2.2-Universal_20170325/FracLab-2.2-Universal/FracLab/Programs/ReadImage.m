function Image = ReadImage(Name)
% ReadImage -- Read Image file in 8-bit raw binary format
%  Usage
%    Image = ReadImage(Name)
%  Inputs
%    Name    'Barton', 'Canaletto', 'Coifman', 'Daubechies',
%            'Fingerprint', 'Lincoln', 'Lenna', 'MRIScan', 'Phone'
%  Outputs
%    Image    2-d signal, n by n, n dyadic
%
%  Side Effects
%    A descriptor file for the data is printed

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

	global WAVELABPATH        % set by WavePath.m
	global PATHNAMESEPARATOR  % set by WavePath.m
%
	if strcmp(Name,'Barton'),
	    filename = 'barton.raw';
	    par = [512,512];
	    source = 'barton.doc';
	elseif strcmp(Name,'Canaletto'),
	    filename = 'canaletto.raw';
	    par = [512,512];
	    source = 'canaletto.doc';
	elseif strcmp(Name,'Coifman'),
	    filename = 'coifman.raw';
	    par = [256,256];
	    source = 'coifman.doc';
	elseif strcmp(Name,'Daubechies'),
	    filename = 'daubechies.raw';
	    par = [256,256];
	    source = 'daubechies.doc';
	elseif strcmp(Name,'Fingerprint'),
	    filename = 'fingerprint.raw';
	    par = [512,512];
	    source = 'fingerprint.doc';
	elseif strcmp(Name,'Lenna'),
		filename = 'lenna.raw';
		par = [256,256];
		source = 'lenna.doc';
	elseif strcmp(Name,'Lincoln'),
	    filename = 'lincoln.raw';
	    par = [64,64];
	    source = 'lincoln.doc';
	elseif strcmp(Name,'MRIScan'),
	    filename = 'mriscan.raw';
	    par = [256,256];
	    source = 'mriscan.doc';
	elseif strcmp(Name,'Phone'),    
	    filename = 'phone.raw';
	    par = [128,128];
	    source = 'phone.doc';
	else
	    disp('I only know how to read the datasets:            ');
	    disp('   Barton, Canaletto, Coifman, Daubechies,       ');
	    disp('   Fingerprint, Lincoln, Lenna, MRIScan, Phone   ');
	    filename = 'BOGUS';
	end
	
	if ~strcmp(filename,'BOGUS'),
	    %filename = [filename];
	    fid = fopen(filename,'r');
	    if fid < 0,
	        disp('I was unable to open the dataset you requested        ');
	        disp('Practically the only way this error could occur       ');
	        disp('is by the failure of the WavePath.m file to reflect   ');
	        disp('the actual name of the root WaveLab directory.        ');
	        disp('Solution: quit Matlab, edit WavePath, restart Matlab. ');
	        disp('In our experience this always works.                  ');
	    else
	        fprintf('Reading %s\n', filename)
	        fprintf('It is an array of size [%4.0f,%4.0f]\n',par(1),par(2))
	        docfile = [WAVELABPATH 'Datasets'  ...
	               PATHNAMESEPARATOR source];
		    type(source)
	        Image = fread(fid,par);
	        fclose(fid);
	    end
	end
 
%
% Copyright (c) 1993-5. Jonathan Buckheit and David Donoho
%     
    
    
%   
% Part of WaveLab Version .701
% Built Tuesday, January 30, 1996 8:25:59 PM
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail wavelab@playfair.stanford.edu
%   
    
