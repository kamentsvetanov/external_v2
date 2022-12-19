function returnString=fl_segmentation(cmd,context);
% No help found

% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[objTmp,segPanel] = gcbo;
if ((isempty(segPanel)) | (~strcmp(get(segPanel,'Tag'),'gui_segmentation_control_panel')))
  segPanel = findobj ('Tag','gui_segmentation_control_panel');
end
ud = get(segPanel,'UserData');
returnString = '';

switch (cmd)

 
% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------
%         INPUT SECTION
% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------


    % --------------------------
  case 'refresh_input'
    % --------------------------
  
    % [input flag_error] = fl_get_input('matrix');
    % [name flag_error] = fl_get_details;
    [name flag_error] = fl_get_input('matrix');
    if flag_error
      fl_warning('input signal must be a matrix !');
      return;
    end
    
    if ~exist (strtok(name,'.'))
      varname = strtok(name,'.');
      eval (['global ' varname]);
    end
    var = eval (name);
    
    % ajuste le max pour le spectre de Hausdorff
    
    N = min(size(var));
    hMaxBox = findobj(segPanel,'Tag','hEdit_maxBoxes');
    %set(hMaxBox,'Max',N);
    set(hMaxBox,'String',num2str(min(round(N/4), 32)))

%    if (N <  M)
%      set(hMaxBox,'Max',N);
%      set(hMaxBox,'String',num2str(min(round(N/4), 32)))
%    else
%      set(hMaxBox,'Max',M);
%      set(hMaxBox,'String',num2str(min(round(M/4), 32)))
%    end
    
    newUd = struct('Image',var,'Reference',ud.Reference,'Hoelder',0,'Spectrum',0,'Segmentation',0);
    
    set(segPanel,'UserData',newUd);
    edit_input = findobj(segPanel,'Tag','EditText_input');
    set(edit_input,'String',name);

    set(findobj(segPanel,'Tag','StaticText_reference'),'Enable','on');
    set(findobj(segPanel,'Tag','EditText_reference'),'Enable','on');
    set(findobj(segPanel,'Tag','Pushbutton_refreshReference'),'Enable','on');
    set(findobj(segPanel,'Tag','StaticText_spectrumImg'),'Enable','on');
    set(findobj(segPanel,'Tag','EditText_spectrumImg'),'Enable','on');
    set(findobj(segPanel,'Tag','Pushbutton_refreshSpectrumImg'),'Enable','on');
    set(findobj(segPanel,'Tag','computeAll'),'Enable','on');

    if get(findobj(segPanel,'Tag','ppm_Spectrum'), 'Value') == 1
      set(findobj(segPanel,'Tag','computeHoelder'),'Enable','on');
      set(findobj(segPanel,'Tag','StaticText_hoelderImg'),'Enable','on');
      set(findobj(segPanel,'Tag','EditText_hoelderImg'),'Enable','on');
      set(findobj(segPanel,'Tag','Pushbutton_refreshHoelderImg'),'Enable','on');
    end

    set(findobj(segPanel,'Tag','computeSpectrum'),'Enable','on');
    
    
    % --------------------------
  case 'refresh_reference'
    % --------------------------

    [reference flag_error] = fl_get_details;
    if flag_error
      fl_warning('Reference must be a matrix !');
      return;
    end
    
    if ~exist (strtok(reference,'.'))
      varRef = strtok(reference,'.');
      eval (['global ' varRef]);
    end
    var = eval (reference);

    if (size(var) ~= size(ud.Image))
      fl_warning('Image and reference must have same size.');
      return;
    end
    
    newUd = struct('Image',ud.Image,'Reference',var,'Hoelder',0,'Spectrum',0,'Segmentation',0);

    set(segPanel,'UserData',newUd);
    
    edit_reference = findobj(segPanel,'Tag','EditText_reference');
    set(edit_reference,'String',reference);
    
    % Active the reference checkbox ...
    set(findobj(segPanel,'Tag','cb_reference'),'Enable','on');
    set(findobj(segPanel,'Tag','text_useReferenceImage'),'Enable','on');
    
    % --------------------------
  case 'refresh_hoelderImg'
    % --------------------------

    [hoelderImg flag_error] = fl_get_details;
    if flag_error
      fl_warning('Hoelder Image must be a matrix !');
      return;
    end
    
    if ~exist (strtok(hoelderImg,'.'))
      varRef = strtok(hoelderImg,'.');
      eval (['global ' varRef]);
    end
    var = eval (hoelderImg);

    if (size(var) ~= size(ud.Image))
      fl_warning('Image and hoelder image must have same size.');
      return;
    end
    
    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',var,'Spectrum',ud.Spectrum,'Segmentation',0);

    set(segPanel,'UserData',newUd);
    
    edit_hoelderImg = findobj(segPanel,'Tag','EditText_hoelderImg');
    set(edit_hoelderImg,'String',hoelderImg);

    % --------------------------
  case 'refresh_spectrumImg'
    % --------------------------

    [spectrumImg flag_error] = fl_get_details;
    % if flag_error
    %  fl_warning('Spectrum must be a matrix !');
    %   return;
    % end
    
    if ~exist (strtok(spectrumImg,'.'))
      varRef = strtok(spectrumImg,'.');
      eval (['global ' varRef]);
    end
    var = eval (spectrumImg);

    % if (size(var) ~= size(ud.Image))
    %   fl_warning('Image and spectrum must have same size.');
    %   return;
    % end
    
    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',ud.Hoelder,'Spectrum',var,'Segmentation',0);

    set(segPanel,'UserData',newUd);
    
    edit_spectrumImg = findobj(segPanel,'Tag','EditText_spectrumImg');
    set(edit_spectrumImg,'String',spectrumImg);
    set(findobj(segPanel,'Tag','computeSeg'),'Enable','on');

% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------
%         Hoelder SECTION
% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------
    
    % --------------------
  case 'ppm_HoelderMax'
    % --------------------
    set(findobj(segPanel,'Tag','EditText_hoelderImg'),'String','');
    
    minH = findobj(segPanel,'Tag','ppm_HoelderMin');
    val = get(minH,'Value');
    minVal = 2*val-1;

    maxH = findobj(segPanel,'Tag','ppm_HoelderMax');
    val = get(maxH,'Value');
    maxVal = 2*val+1;

    if (maxVal < minVal)
      set(minH,'Value',val+1);
    end
    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',0,'Spectrum',0,'Segmentation',0);
    set(segPanel,'UserData',newUd);
    
    % --------------------
  case 'ppm_HoelderMin'
    % --------------------
    set(findobj(segPanel,'Tag','EditText_hoelderImg'),'String','');
    
    maxH = findobj(segPanel,'Tag','ppm_HoelderMax');
    val = get(maxH,'Value');
    maxVal = 2*val+1;

    minH = findobj(segPanel,'Tag','ppm_HoelderMin');
    val = get(minH,'Value');
    minVal = 2*val-1;

    if (maxVal < minVal)
      set(maxH,'Value',val-1);
    end
    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',0,'Spectrum',0,'Segmentation',0);
    set(segPanel,'UserData',newUd);
    
    % --------------------
  case 'cb_reference'
    % --------------------
    set(findobj(segPanel,'Tag','EditText_hoelderImg'),'String','');    
    
    cb_hdl = findobj(segPanel,'Tag','cb_reference');
    cb = get(cb_hdl,'Value');
    if (cb == 1) % => use reference image
      set(cb_hdl,'String','use');
      set(findobj(segPanel,'Tag','StaticText_reference'),'Enable','on');
      set(findobj(segPanel,'Tag','EditText_reference'),'Enable','on');
      set(findobj(segPanel,'Tag','Pushbutton_refreshReference'),'Enable','on');
    else
      set(cb_hdl,'String','do not use');
      set(findobj(segPanel,'Tag','StaticText_reference'),'Enable','off');
      set(findobj(segPanel,'Tag','EditText_reference'),'Enable','off');
      set(findobj(segPanel,'Tag','Pushbutton_refreshReference'),'Enable','off');
    end
    

    % --------------------
  case 'computeHoelder'
    % --------------------

    % ud = get(segPanel,'UserData');
    mouse = fl_waiton;

    maxH = findobj(segPanel,'Tag','ppm_HoelderMax');    
    valMax = get(maxH,'Value')*2+1;
    minH = findobj(segPanel,'Tag','ppm_HoelderMin');
    valMin = get(minH,'Value')*2-1;
    S=[valMin:2:valMax];
    cap = findobj(segPanel,'Tag','ppm_HoelderCapacity');
    valCap = get(cap,'Value');
    capStr = get(cap,'String');
    
    % CC --> Fred : pour prendre en compte la capacite adaptive iso
    % (sous UNIX, je ne peux pas avoir d'espace et j'utilise 'adapiso'
    % et je ne veux pas changer le .h ...:)
    
    if strcmp(capStr{valCap}, 'adaptive iso')
      capa = 'adapiso';
    else
      capa = capStr{valCap};
    end
    
    % Do I use Reference Image ?
    if ((ud.Reference == 0) | (get(findobj(segPanel,'Tag','cb_reference'),'Value') == 0))
      ref = 0;
    else
      ref = 1;
    end
    
    % appel des routines de Christophe
    if ref == 0
      output = mph2d(ud.Image,capa,S);
    else
      output = mph2d(ud.Image,capa,S,ud.Reference);
    end
    outputName=['hld2dCoef_' get(findobj(segPanel,'Tag','EditText_input'),'String')];
    varname = fl_findname(outputName,context);
    
    returnString=varname;
    eval(['global ' varname ';']);

    eval([varname '= output;']);
    newUd =  struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',output,'Spectrum',ud.Spectrum,'Segmentation',0);
    set(segPanel,'UserData',newUd);
    set(findobj(segPanel,'Tag','EditText_hoelderImg'),'String',varname);
    fl_addlist(0,varname) ;
    fl_waitoff(mouse);

% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------
%         SPECTRUM SECTION
% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------

    % --------------------
  case 'ppmSpectrum'
    % --------------------
    set(findobj(segPanel,'Tag','EditText_spectrumImg'),'String','');
    set(findobj(segPanel,'Tag','computeSeg'),'Enable','off');
    
    spectrum = findobj(segPanel,'Tag','ppm_Spectrum');
    
    hText_minBoxes = findobj(segPanel,'Tag','hText_minBoxes');
    hText_maxBoxes = findobj(segPanel,'Tag','hText_maxBoxes');
    hEdit_minBoxes = findobj(segPanel,'Tag','hEdit_minBoxes');
    hEdit_maxBoxes = findobj(segPanel,'Tag','hEdit_maxBoxes');

    ldText_adaptation = findobj(segPanel,'Tag','ldText_adaptation');
    ldPpm_adaptation = findobj(segPanel,'Tag','ldPpm_adaptation');
    ldText_kernel = findobj(segPanel,'Tag','ldText_kernel');
    ldPpm_kernel = findobj(segPanel,'Tag','ldPpm_kernel');
    ldText_grainResolution = findobj(segPanel,'Tag','ldText_grainResolution');
    ldEdit_grainResolution = findobj(segPanel,'Tag','ldEdit_grainResolution');
    
    %lText = findobj(segPanel,'Tag','lText');
    %lEdit = findobj(segPanel,'Tag','lEdit');
    
    edit_input = get(findobj(segPanel,'Tag','EditText_input'),'String');

    val = get(spectrum,'Value');
    switch val
      case 1 % Hausdorff
	set(ldText_adaptation,'Enable','off');
	set(ldText_adaptation,'Visible','off');
	set(ldPpm_adaptation,'Enable','off');
	set(ldPpm_adaptation,'Visible','off');
	set(ldText_kernel,'Enable','off');
	set(ldText_kernel,'Visible','off');
	set(ldPpm_kernel,'Enable','off');
	set(ldPpm_kernel,'Visible','off');
	set(ldText_grainResolution,'Enable','off');
	set(ldText_grainResolution,'Visible','off');
	set(ldEdit_grainResolution,'Enable','off');
	set(ldEdit_grainResolution,'Visible','off');

	%set(lText,'Enable','off');
	%set(lText,'Visible','off');
	%set(lEdit,'Enable','off');
	%set(lEdit,'Visible','off');

	set(hEdit_minBoxes,'Enable','on');
	set(hEdit_minBoxes,'Visible','on');
	set(hEdit_maxBoxes,'Enable','on');
	set(hEdit_maxBoxes,'Visible','on');
	set(hText_minBoxes,'Enable','on');
	set(hText_minBoxes,'Visible','on');
	set(hText_maxBoxes,'Enable','on');
	set(hText_maxBoxes,'Visible','on');

	useReference('on', segPanel);
	useHoelder('on', segPanel);

	
      case 3 % grd deviation
	set(hEdit_minBoxes,'Enable','off');
	set(hEdit_minBoxes,'Visible','off');
	set(hEdit_maxBoxes,'Enable','off');
	set(hEdit_maxBoxes,'Visible','off');
	set(hText_minBoxes,'Enable','off');
	set(hText_minBoxes,'Visible','off');
	set(hText_maxBoxes,'Enable','off');
	set(hText_maxBoxes,'Visible','off');

	%set(lText,'Enable','off');
	%set(lText,'Visible','off');
	%set(lEdit,'Enable','off');
	%set(lEdit,'Visible','off');

	set(ldText_adaptation,'Enable','on');
	set(ldText_adaptation,'Visible','on');
	set(ldPpm_adaptation,'Enable','on');
	set(ldPpm_adaptation,'Visible','on');
	set(ldText_kernel,'Enable','on');
	set(ldText_kernel,'Visible','on');
	set(ldPpm_kernel,'Enable','on');
	set(ldPpm_kernel,'Visible','on');
	set(ldText_grainResolution,'Enable','on');
	set(ldText_grainResolution,'Visible','on');
	set(ldEdit_grainResolution,'Enable','on');
	set(ldEdit_grainResolution,'Visible','on');

	useReference('off', segPanel);
	%useHoelder('off', segPanel);
	useHoelder('on', segPanel);
	
      case 2 % legendre
	set(hEdit_minBoxes,'Enable','off');
	set(hEdit_minBoxes,'Visible','off');
	set(hEdit_maxBoxes,'Enable','off');
	set(hEdit_maxBoxes,'Visible','off');
	set(hText_minBoxes,'Enable','off');
	set(hText_minBoxes,'Visible','off');
	set(hText_maxBoxes,'Enable','off');
	set(hText_maxBoxes,'Visible','off');
	
	set(ldText_adaptation,'Enable','off');
	set(ldText_adaptation,'Visible','off');
	set(ldPpm_adaptation,'Enable','off');
	set(ldPpm_adaptation,'Visible','off');
	set(ldText_kernel,'Enable','off');
	set(ldText_kernel,'Visible','off');
	set(ldPpm_kernel,'Enable','off');
	set(ldPpm_kernel,'Visible','off');
	set(ldText_grainResolution,'Enable','off');
	set(ldText_grainResolution,'Visible','off');
	set(ldEdit_grainResolution,'Enable','off');
	set(ldEdit_grainResolution,'Visible','off');
	
	%set(lEdit,'Enable','on');
	%set(lEdit,'Visible','on');
	%set(lText,'Enable','on');
	%set(lText,'Visible','on');

	useReference('off', segPanel);
	%useHoelder('off', segPanel);
	useHoelder('on', segPanel);
	
    end
    
    % --------------------
  case 'computeSpectrum'
    % --------------------
    
    % ud = get(segPanel,'UserData');
    mouse = fl_waiton;
    spectrum = findobj(segPanel,'Tag','ppm_Spectrum');
    val = get(spectrum,'Value');

    switch(val)
      case 1 % Hausdorff
	returnString = fl_segSpectrum('hausdorff',segPanel,context);
      case 3 % grd deviations
	returnString = fl_segSpectrum('deviations',segPanel,context);
      case 2 % Legendre
	returnString = fl_segSpectrum('legendre',segPanel,context);
    end
    set(findobj(segPanel,'Tag','computeSeg'),'Enable','on');
    
    %% ATTENTION : ici, on doit bien conserver le ud = get(...) car le 
    %% user data a changé : on y a mis le spectre => il faut le RE-charger
    ud = get(segPanel,'UserData');
    falpha = ud.Spectrum.data2;
    set(findobj(segPanel,'Tag','EditText_minDim'),'String',num2str(min(falpha),3));
    set(findobj(segPanel,'Tag','EditText_maxDim'),'String',num2str(max(falpha),3));
    fl_waitoff(mouse);

    
% ---------------------------------------------------------------------------------------
%	Hausdorff
% ---------------------------------------------------------------------------------------
  
    % ----------------------
  case 'hEdit_maxBoxes'
    % ----------------------
    set(findobj(segPanel,'Tag','EditText_spectrumImg'),'String','');
    set(findobj(segPanel,'Tag','computeSeg'),'Enable','off');
    
    maxB = findobj(segPanel,'Tag','hEdit_maxBoxes');
    maxVal = get(maxB,'Max');
    val = str2num(get(maxB,'String'));
    if ( (~isnumeric(val)) | (isempty(val)) | (val > maxVal) | (val < 1))
      fl_error(['Error with max boxes :( => must be in {1,2, ..., ' num2str(maxVal) '}']);
      set(maxB,'String',num2str(round(maxVal/4)));
      val = round(maxVal/4);
    else
      val = round(val);
      set(maxB,'String',num2str(val));
    end
    
    minB = findobj(segPanel,'Tag','hEdit_minBoxes');
    valMin = str2num(get(minB,'String'));
    if (valMin > val)
      fl_warning('max boxes : must be superior to min boxes');
      set(minB,'String',num2str(val));
    end
    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',ud.Hoelder,'Spectrum',0,'Segmentation',0);
    set(segPanel,'UserData',newUd);
    
    % ----------------------
  case 'hEdit_minBoxes'
    % ----------------------
    set(findobj(segPanel,'Tag','EditText_spectrumImg'),'String','');
    set(findobj(segPanel,'Tag','computeSeg'),'Enable','off');
    
    minB = findobj(segPanel,'Tag','hEdit_minBoxes');
    val = str2num(get(minB,'String'));

    maxB = findobj(segPanel,'Tag','hEdit_maxBoxes');
    maxVal = get(maxB,'Max');
    
    if ( (~isnumeric(val)) | (isempty(val)) | (val > maxVal) | (val < 1))
      fl_error(['Error with max boxes :( => must be in {1,2, ..., ' num2str(maxVal-1) '}']);
      set(minB,'String','1');
      val = 1;
    else
      val = round(val);
      set(minB,'String',num2str(val));
    end
    
    
    valMax = str2num(get(maxB,'String'));
    if (val > valMax)
      fl_warning('min boxes : must be inferior to max boxes');
      set(maxB,'String',num2str(val));
    end
    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',ud.Hoelder,'Spectrum',0,'Segmentation',0);
    set(segPanel,'UserData',newUd);
	
% ---------------------------------------------------------------------------------------
%	LARGE DEVIATION
% ---------------------------------------------------------------------------------------
    
    % ----------------------
  case 'ldPpm_adaptation'
    % ----------------------
    set(findobj(segPanel,'Tag','EditText_spectrumImg'),'String','');
    set(findobj(segPanel,'Tag','computeSeg'),'Enable','off');    

    if get(findobj('Tag','ldPpm_adaptation'),'Value')==1 % diagonal
      fl_warning('Not implemented yet: Choose another');
    end
    if get(findobj('Tag','ldPpm_adaptation'),'Value')==2 % double kernel
      fl_warning('Not implemented yet: Choose another');
    end 
    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',ud.Hoelder,'Spectrum',0,'Segmentation',0);
    set(segPanel,'UserData',newUd);
    
    % ----------------------
  case 'ldPpm_kernel'
    % ----------------------
    set(findobj(segPanel,'Tag','EditText_spectrumImg'),'String','');
    set(findobj(segPanel,'Tag','computeSeg'),'Enable','off');
    
    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',ud.Hoelder,'Spectrum',0,'Segmentation',0);
    set(segPanel,'UserData',newUd);
  
    % ----------------------
  case 'ldEdit_grainResolution'
    % ----------------------
    set(findobj(segPanel,'Tag','EditText_spectrumImg'),'String','');
    set(findobj(segPanel,'Tag','computeSeg'),'Enable','off');
    
    grain = findobj(segPanel,'Tag','ldEdit_grainResolution');
    val = str2num(get(grain,'String'));
    if ( (~isnumeric(val)) | (isempty(val)) | (val > 10) | (val < 1))
      fl_warning('Error with resolution :( => must be in [1,10]');
      set(grain,'String','1');
      val = 1;
    else
      val = round(val);
      set(grain,'String',num2str(val));
    end
    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',ud.Hoelder,'Spectrum',0,'Segmentation',0);
    set(segPanel,'UserData',newUd);
    
% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------
%         SEGMENTATION SECTION
% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------


    % ----------------------
  case 'edit_minmaxDim'
    % ----------------------
    
    ed_minDim = findobj(segPanel,'Tag','EditText_minDim');
    ed_maxDim = findobj(segPanel,'Tag','EditText_maxDim');
    
    minDim = str2num(get(ed_minDim,'String'));
    maxDim = str2num(get(ed_maxDim,'String'));
    
    falpha = ud.Spectrum.data2;
    
    if ((isempty(minDim)) | (~isnumeric(minDim)) | (isempty(maxDim)) | (~isnumeric(maxDim)) | (minDim > maxDim) | (maxDim < minDim) | (minDim<min(falpha)) | (maxDim>max(falpha)))
      set(ed_minDim,'String', num2str(min(falpha),3));
      set(ed_maxDim,'String', num2str(max(falpha),3));
    end

    newUd = struct('Image',ud.Image,'Reference',ud.Reference,'Hoelder',ud.Hoelder,'Spectrum',ud.Spectrum,'Segmentation',0);
    set(segPanel,'UserData',newUd);

    % --------------------
  case 'computeSegmentation'
    % --------------------
    
    mouse = fl_waiton;

    ed_minDim = findobj(segPanel,'Tag','EditText_minDim');
    ed_maxDim = findobj(segPanel,'Tag','EditText_maxDim');
    minDim = str2num(get(ed_minDim,'String'));
    maxDim = str2num(get(ed_maxDim,'String'));

    % calcul de l'image de Hoelder
    if ((ud.Hoelder == 0) | isempty(get(findobj(segPanel,'Tag','EditText_hoelderImg'),'String')))
      returnString = fl_segmentation('computeHoelder',context);
      ud = get(segPanel,'UserData');
    end


    [w h] = size(ud.Hoelder);
    alpha = ud.Spectrum.data1;
    falpha = ud.Spectrum.data2;
    seg = zeros(w, h);

    %% En fait, comme les falpha et les alpha sont triés dans l'ordre
    %% croisssant, on ne se fait pas chier : on prend le premier et le
    %% dernier :)))

    %if (minDim <= min(falpha) & min(falpha) <= maxDim)
    %if (minDim <= min(falpha))
    if (minDim <= falpha(1) & falpha(1) <= maxDim)
	seg(find(ud.Hoelder <= alpha(1))) = 1;
    end
    
    %if (minDim <= max(falpha) & max(falpha) <= maxDim)
    %if (max(falpha) <= maxDim)
    if (minDim <= max(falpha) & max(falpha) <= maxDim)
	seg(find(ud.Hoelder >= max(alpha))) = 1;
    end
    
    for i = 1 : w
	for j = 1 : h
	  
	  if seg(i, j) ~= 1
	    a = ud.Hoelder(i,j);
	    pos = max(find(alpha <= a));
	    
	    % ~isempty(pos) se produit si ud.Hoelder(i,j) est plus
	    % petit que le plus petit des alpha dans le spectre (échantillonage)
	    % pos < max(size(alpha)) => dans le cas où ud.Hoelder(i,j)
	    % est supérieur au dernier des alpha dans le spectre
	    if (~isempty(pos) & pos < max(size(alpha)))
	      t = (alpha(pos+1)-a)/(alpha(pos+1) - alpha(pos));
	      fa = t*falpha(pos)+(1-t)*falpha(pos+1);
	      if (minDim <= fa & fa <= maxDim)
		seg(i,j) = 1;
	      end
	    end
	  end
	end
    end
    
    
    % Dirty trick to avoid color normalization
    % since all the image contains 1
    if (min(min(seg)) == 1)
      seg(1,1) = 0;
    end
    
    % ne pas oublier de creer le userdata.
    newUd = struct('Image',ud.Image,...
	'Reference',ud.Reference,...
	'Hoelder',ud.Hoelder,...
	'Spectrum',ud.Spectrum,...
	'Segmentation',seg);
    set(segPanel,'UserData',newUd);

    outputName=['seg_' get(findobj(segPanel,'Tag','EditText_input'),'String')];
    varname = fl_findname(outputName,context);
    eval(['global ' varname ';']);
    eval([varname '= seg;']);
    fl_addlist(0,varname) ;
    fl_waitoff(mouse);
    returnString=[varname ' ' returnString];
    
    
% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------
%         GENERAL SECTION
% ---------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------

    % --------------------
  case 'computeAll'
    % --------------------
    
    ud = get(segPanel,'UserData');
    if (isempty(ud))
      fl_error('Error : restart the segmentation panel');
      close (segPanel);
      return;
    end

    fl_segmentation('computeHoelder',context)
    fl_segmentation('computeSpectrum',context);
    fl_segmentation('computeSegPanel',context);
    
    % --------------------
  case 'help'
    % --------------------
    
    % --------------------
  case 'close'
    % --------------------

    fl_clearerror;
    close (segPanel);
  
  
end % switch general


function useReference(flag, segPanel)

  if isempty(get(findobj(segPanel,'Tag','EditText_input'),'String'))
    flag = 'off';
  end
  set(findobj(segPanel, 'Tag', 'StaticText_reference'), 'Enable', flag);
  set(findobj(segPanel, 'Tag', 'EditText_reference'), 'Enable', flag);
  set(findobj(segPanel, 'Tag', 'Pushbutton_refreshReference'), 'Enable', flag);


  
function useHoelder(flag, segPanel) 

  flag2 = flag;
  if isempty(get(findobj(segPanel,'Tag','EditText_input'),'String'))
    flag2 = 'off';
  end
  set(findobj(segPanel,'Tag','StaticText_hoelderImg'),'Enable', flag2);
  set(findobj(segPanel,'Tag','EditText_hoelderImg'),'Enable', flag2);
  set(findobj(segPanel,'Tag','Pushbutton_refreshHoelderImg'),'Enable', flag2);
  set(findobj(segPanel,'Tag','computeHoelder'),'Enable', flag2);
  
  set(findobj(segPanel,'Tag','StaticText_HoelderCoef'),'Enable', flag);
  set(findobj(segPanel,'Tag','text_HoelderMin'),'Enable', flag);
  set(findobj(segPanel,'Tag','ppm_HoelderMin'),'Enable', flag);
  set(findobj(segPanel,'Tag','text_HoelderMax'),'Enable', flag);
  set(findobj(segPanel,'Tag','ppm_HoelderMax'),'Enable', flag);
  set(findobj(segPanel,'Tag','StaticText_HoelderCapacity'),'Enable', flag);
  set(findobj(segPanel,'Tag','ppm_HoelderCapacity'),'Enable', flag);

  if isempty(get(findobj(segPanel,'Tag','EditText_reference'),'String'))
    flag2 = 'off';
  end
  set(findobj(segPanel,'Tag','cb_reference'),'Enable', flag2);
  set(findobj(segPanel,'Tag','text_useReferenceImage'),'Enable', flag2);

