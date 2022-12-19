function returnString=fl_segSpectrum(cmd,segPanel,context);
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

  ud = get(segPanel,'UserData');
  returnString = '';
  
  switch (cmd)
  
    % ---------------------------------------------------------------------------------------
    % ---------------------------------------------------------------------------------------
    %         SPECTRUM INITIALIZATION
    % ---------------------------------------------------------------------------------------
    % ---------------------------------------------------------------------------------------

    case 'hausdorff'
      prefix = 'hSpectrum_';
      
      hEdit_minBoxes = findobj(segPanel,'Tag','hEdit_minBoxes');
      minBox = str2num(get(hEdit_minBoxes,'String'));
    
      hEdit_maxBoxes = findobj(segPanel,'Tag','hEdit_maxBoxes');
      maxBox = str2num(get(hEdit_maxBoxes,'String'));

      % CC --> FRED --> j'ai mis un pas de 2
      B = [minBox:2:maxBox];

      % ******************************************
      % *********** CALCUL DU SPECTRE ************
      % ******************************************
      if ((ud.Hoelder == 0) | isempty(get(findobj(segPanel,'Tag','EditText_hoelderImg'),'String')))
	returnString = fl_segmentation('computeHoelder',context);
	ud = get(segPanel,'UserData');
      end
      
      % CC --> FRED --> pas fini: a completer
      [alpha fd2d_alpha] = fd2d(ud.Hoelder,B);

      % CC --> FRED --> j'ai mis les xlabel et ylabel
      title='Hausdorff spectrum';
      xlabel='Hölder exponents: \alpha';
      ylabel='spectrum: f_h(\alpha)';
      
      spectrum = struct('type','graph', ...
	  'data1',alpha, ...
	  'data2', fd2d_alpha, ...
	  'title',title, ...
	  'xlabel',xlabel, ...
	  'ylabel',ylabel);
      
      newUd = struct('Image',ud.Image,...
	  'Reference',ud.Reference,...
	  'Hoelder',ud.Hoelder,...
	  'Spectrum',spectrum,...
	  'Segmentation',0);
      
      set(segPanel,'UserData',newUd);
     
      input = get(findobj(segPanel,'Tag','EditText_input'),'String');
 
      % ******************************************
      % ***************** RETURN *****************
      % ******************************************
      
      varname = fl_findname([prefix input '_fd2d_alpha'],context);
      eval(['global ' varname ';']);
      eval([varname '= spectrum;']);
      fl_addlist(0,varname) ;
      returnString = [varname ' ' returnString];
      set(findobj(segPanel,'Tag','EditText_spectrumImg'),'String',varname);
      
    case 'deviations'
      prefix = 'gSpectrum_';
      
      ldPpm_adaptation = findobj(segPanel,'Tag','ldPpm_adaptation');
      adapt = get(ldPpm_adaptation,'Value');
      
      ldPpm_kernel = findobj(segPanel,'Tag','ldPpm_kernel');
      kernel = get(ldPpm_kernel,'Value');
      
      ldEdit_grainResolution = findobj(segPanel,'Tag','ldEdit_grainResolution');
      grainResolution = str2num(get(ldEdit_grainResolution,'String'));
    
      % CC --> Fred : meme remarque que pour Legendre (en gros y a du boulot) 
      m=ud.Image;
      [alpha, fgc2d_alpha]=mcfg2d(m);
    
      title='Large deviation spectrum';
      xlabel='Hölder exponents: \alpha';
      ylabel='spectrum: f_g^c(\alpha)';
      
      gspectrum = struct('type','graph', ...
	  'data1',alpha, ...
	  'data2', fgc2d_alpha, ...
	  'title',title, ...
	  'xlabel',xlabel, ...
	  'ylabel',ylabel);
      
      newUd = struct('Image',ud.Image,...
	  'Reference',ud.Reference,...
	  'Hoelder',ud.Hoelder,...
	  'Spectrum',gspectrum,...
	  'Segmentation',0);
      
      set(segPanel,'UserData',newUd);
      
      input = get(findobj(segPanel,'Tag','EditText_input'),'String');
 
      % ******************************************
      % ***************** RETURN *****************
      % ******************************************
      
      varname = fl_findname([prefix input '_fgc2d_alpha'],context);
      eval(['global ' varname ';']);
      eval([varname '= gspectrum;']);
      fl_addlist(0,varname) ;
      returnString = [varname ' ' returnString];
      set(findobj(segPanel,'Tag','EditText_spectrumImg'),'String',varname);
      
    case 'legendre'
      prefix = 'lSpectrum_'; 
      
      % CC --> Fred : C'est pas la version finale et c'est assez long
      % mais ca marche !!!
      m=ud.Image;
      m=m/sum(sum(m));
      q=[-10:.5:+10];
      [zaq, a]=mdzq2d(m,q);
      tq=reynitq(zaq,q,a);
      [alpha, fl2d_alpha]=linearlt(q,tq);
    
      title='Legendre spectrum';
      xlabel='Hölder exponents: \alpha';
      ylabel='spectrum: f_l(\alpha)';
      
      lspectrum = struct('type','graph', ...
	  'data1',alpha, ...
	  'data2', fl2d_alpha, ...
	  'title',title, ...
	  'xlabel',xlabel, ...
	  'ylabel',ylabel);
      
      newUd = struct('Image',ud.Image,...
	  'Reference',ud.Reference,...
	  'Hoelder',ud.Hoelder,...
	  'Spectrum',lspectrum,...
	  'Segmentation',0);
      
      set(segPanel,'UserData',newUd);
      
      input = get(findobj(segPanel,'Tag','EditText_input'),'String');
 
      % ******************************************
      % ***************** RETURN *****************
      % ******************************************
      
      varname = fl_findname([prefix input '_fl2d_alpha'],context);
      eval(['global ' varname ';']);
      eval([varname '= lspectrum;']);
      fl_addlist(0,varname) ;
      returnString = [varname ' ' returnString];
      set(findobj(segPanel,'Tag','EditText_spectrumImg'),'String',varname);
      
  end % switch






