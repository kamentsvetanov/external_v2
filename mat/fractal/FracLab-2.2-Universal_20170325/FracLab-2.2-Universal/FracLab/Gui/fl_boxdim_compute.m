function [dim]=fl_boxdim_compute(command)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

varOutstring=[];

boxdim_fig = gcf;
if ((isempty(boxdim_fig)) | (~strcmp(get(boxdim_fig,'Tag'),'Fig_gui_fl_boxdim')))
  boxdim_fig = findobj ('Tag','Fig_gui_fl_boxdim');
end
%%%% Get GUI handles %%%%%%% 
handles=guidata(boxdim_fig);

switch(command)    
case('editScaleNumber');
case('editTextMinSize');
case('editTextMaxSize');
case('editRatio');
case('editPopupMin');
    Choix=get(handles.PopupMin,'Value');
    if Choix<=12
        set(handles.TextMin,'String',['1/',num2str(2^Choix)])
    else
        str=get(handles.TextMin,'String');
        for clignote=1:3
            if ishandle(handles.TextMin);set(handles.TextMin,'String','Click here');end
            pause(0.3);
            if ishandle(handles.TextMin);set(handles.TextMin,'String','');end
            pause(0.3);
        end
        if ishandle(handles.TextMin);set(handles.TextMin,'String','Click here');end
        pause(0.5);
        if ishandle(handles.TextMin);set(handles.TextMin,'String',str);end       
    end
case('editPopupMax');
    Choix=get(handles.PopupMax,'Value');
    if Choix<=12
        set(handles.TextMax,'String',['1/',num2str(2^Choix)])
    else
        str=get(handles.TextMax,'String');
        for clignote=1:3
            if ishandle(handles.TextMax);set(handles.TextMax,'String','Click here');end
            pause(0.3);
            if ishandle(handles.TextMax);set(handles.TextMax,'String','');end
            pause(0.3);
        end
        if ishandle(handles.TextMax);set(handles.TextMax,'String','Click here');end
        pause(0.5);
        if ishandle(handles.TextMax);set(handles.TextMax,'String',str);end       
    end
case('refresh');
	fl_clearerror;
	[input_sig flag_error]=fl_get_input('matrix');
    if flag_error
        [input_sig flag_error]=fl_get_input('vector');
    end
    if flag_error
        fl_warning('input signal must be a vector or a matrix !');
    else
        % Get input signal
        SignIn=evalin('base',input_sig);

        %%%%%%%%%%%%%%%% Compute default values %%%%%%%%%%%%%%%%%%%%%%%
        % The calculation depends on the input type
        TypeEntree=handles.TypeEntree;
        switch(TypeEntree)
            case 'Signal'
                % Compute defaut aspect ratio
                taille_SignIn=size(SignIn);
                taille_SignIn=taille_SignIn(find(taille_SignIn>1));
                ratio_initial=ones(1,length(taille_SignIn)+1);
                % Compute default scales
                MinSize_initiale=1/2;
                MaxSize_initiale=2^(-floor(max(log2(taille_SignIn))));
                if MaxSize_initiale>=MinSize_initiale
                    MaxSize_initiale=16*MinSize_initiale;
                end
                Nscale_initiale=-log2(MaxSize_initiale);
                Nscale_initiale=max(2,Nscale_initiale);
                NormData=1;
            case 'List'
                % Compute default aspect ratio
                ratio_initial=ones(1,size(SignIn,2));
                % Compute default scales
                MaxSize_initiale=1/2;
                MinSize_initiale=2^(-10);
                Nscale_initiale=-log2(MinSize_initiale);
                NormData=0;
            case 'Binary'
                % Compute defaut aspect ratio
                taille_SignIn=size(SignIn);
                taille_SignIn=taille_SignIn(find(taille_SignIn>1));
                ratio_initial=ones(1,length(taille_SignIn));
                % Compute default scales
                MinScale_initiale=2;
                MaxScale_initiale=2^floor(max(log2(size(SignIn))));
                Nscale_initiale=log2(MaxScale_initiale);
                Nscale_initiale=max(2,Nscale_initiale);
                NormData=0;
        end
        set(handles.EditText_sig_nname,'String',input_sig);
        set(handles.EditText_Ratio,'String',num2str(ratio_initial,4));
        set(handles.TextMin,'String',['1/',num2str(2^Nscale_initiale)]);
        set(handles.TextMax,'String','1/2');
        set(handles.ScaleNumber,'String',num2str(Nscale_initiale));
        set(handles.NormData,'Value',NormData);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute boxdim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'compute_boxdim'
    %%%% Clear error messages %%%%%%%
    fl_clearerror;
    
    %%%%% Get input arguments                       %%%%%%%%%
    TypeEntree=handles.TypeEntree;
    input_sig=get(handles.EditText_sig_nname,'String');
    ScaleNumber=get(handles.ScaleNumber,'String');
    MinSize=get(handles.TextMin,'String');
    MaxSize=get(handles.TextMax,'String');
    AspectRatio=get(handles.EditText_Ratio,'String');
    reg=get(handles.Radiobutton_reg,'Value');
    RegType=get(handles.PopupMenu_regtype,'Value');
    prog_type=get(handles.progression,'Value');
    NormData=get(handles.NormData,'Value');
    % Convert strings to numerical values
    ScaleNumber=str2num(ScaleNumber);
    MinSize=str2num(MinSize);
    MaxSize=str2num(MaxSize);
    AspectRatio=str2num(AspectRatio);
    err=0;
    % Converts Regtype to RegParam    
    RegParam=fl_getregparam(RegType,ScaleNumber);
    %%%%%%%%%%%%%%%%%     Check inputs separately    %%%%%%%%%%%%%%%%%%%%%%
    % Check Scale Numbers       
    if isempty(ScaleNumber)
        fl_warning('Number of Sizes must be a integer >=2');err=1;
    elseif max(size(ScaleNumber))>1
        fl_warning('Number of Scales must be a >=2 integer');err=1;
    elseif ScaleNumber>floor(ScaleNumber)|(ScaleNumber<2)
        fl_warning('Number of Sizes must be a >=2 integer');err=1;
    end
    % Check MinSize
    if isempty(MinSize)
        fl_warning('min size must be a number >0');err=1;
    elseif max(size(MinSize))>1
        fl_warning('min size must be a >0 number');err=1;
    elseif (MinSize<=0)
        fl_warning('min size must be a >0 number');err=1;
    end
    % Check MaxScale
    if isempty(MaxSize)
        fl_warning('max size must be a >0 number');err=1;
    elseif max(size(MaxSize))>1
        fl_warning('max size must be a >0 number');err=1;
    elseif (MaxSize<=0)
        fl_warning('max size must be a >0 number');err=1;
    end
    % Check AspectRatio and eventually reshape it (to tolerate column vector)
    if isempty(AspectRatio)
        fl_warning('Aspect Ratio must be a Vector');err=1;
    else
        AspectRatio=shiftdim(AspectRatio)';
        if size(AspectRatio,1)>1
            fl_warning('Aspect Ratio must be a Vector');err=1;
        elseif prod(double(AspectRatio>0))==0
            fl_warning('Aspect Ratio elements must be positive');err=1;
        end
    end
    % Check and get GLOBAL Input Signal
    ws=whos('global');
    if sum(strcmp(input_sig,{ws.name}))==0;
        fl_warning('Input signal must be initialized: Refresh!');err=1;
    else
        SignIn=evalin('base',input_sig);
    end

    %%%%%%%%%%%%% Check relations between inputs  %%%%%%%%%%%%%%%%%%%%%%%%%
    if err==0                       % Every input must be correct 
        % Check Scales
        if MaxSize<=MinSize
            fl_warning('Max Size must be larger than Min Size');err=1;
        end
        % Check relation between Aspect Ratio and Input Signal sizes
        % The relation depends on the Input Signal type
        switch(TypeEntree)
        case 'Signal'
            taille_SignIn=size(SignIn);
            taille_SignIn=taille_SignIn(find(taille_SignIn>1));
            Size_compatibility=(length(AspectRatio)==length(taille_SignIn)+1);
        case 'List'
            Size_compatibility=(length(AspectRatio)==size(SignIn,2));
        case 'Binary'
            taille_SignIn=size(SignIn);
            taille_SignIn=taille_SignIn(find(taille_SignIn>1));
            Size_compatibility=(length(AspectRatio)==length(taille_SignIn));
        end
        if ~Size_compatibility
             fl_warning('Aspect Ratio must be the right length');err=1;
        end
    end

    %%%%%%%%%%%%%%  Eventually normalize input signal %%%%%%%%%%%%%%%%%%%%
    if NormData
        switch(TypeEntree)
            case {'Binary','Signal'}
                SignIn=frac_normalize(SignIn,0,1);
            case 'List'
                SignIn=normalize_list(SignIn,0,1);
        end
    end
    
    %%%%%%%%%%%%%%  Computes function arguments %%%%%%%%%%%%%%%%%%%%%%
    if err==0                       % Every input must be correct 
        if prog_type==1
            echelles=linspace(-log2(MinSize),-log2(MaxSize),ScaleNumber);
            box_size=2.^(-echelles);
        elseif prog_type==2
            box_size=linspace(MinSize,MaxSize,ScaleNumber);
        end

        %%%%% Where to display the result %%%%%
        obj=handles.EditText_boxdim;
        %%%%% Disable close and compute %%%%%%%%
        set(handles.Pushbutton_wclose,'enable','off');
        set(handles.Pushbutton_boxdim_compute,'enable','off');
        %%%%%  Display Warnings %%%%%%%
        switch(TypeEntree)
            case 'List'
            case 'Signal'
                if max(reshape(SignIn,[],1))-min(reshape(SignIn,[],1))~=1
                    fl_warning('It is generally advised to normalize the signal','black','Warning: ')
                end
            case 'Binary'
                if size(find(abs(SignIn-1/2)-1/2))>0
                    fl_warning('All non-zero points are treated as ones','black','Warning: ')
                end
        end    
        
        %%%%% Perform the computation %%%%%
        switch(TypeEntree)
        case 'Signal'
            [dim,nb,handlefig]=boxdim_classique(SignIn,box_size,AspectRatio,[],1,reg,RegParam{:});
        case 'List'
            [dim,nb,handlefig]=boxdim_listepoints(SignIn,box_size,AspectRatio,1,reg,RegParam{:});
        case 'Binary'
            [dim,nb,handlefig]=boxdim_binaire(SignIn,box_size,AspectRatio,[],1,reg,RegParam{:});
        end

        %%%%% Display the result %%%%%%%%%
        set(obj,'String',num2str(dim)) ;
        if reg~=0;
            h=guidata(handlefig);
            h.HandleOut=obj;
            guidata(handlefig,h);
        end
        
        %%%%% store the figure handles %%%%%
        global handlefig_boxdim
        handlefig_boxdim=[handlefig_boxdim,handlefig];
        
        %%%%%% Enable close and compute %%%%%%%%
        set(handles.Pushbutton_wclose,'enable','on');
        set(handles.Pushbutton_boxdim_compute,'enable','on');
    end

%%%%%%%%% LOCAL SCALING PARAMETERS %%%%%%%%%%%%
  case 'radiobutton_reg'
	Reg = get(gcbo,'Value') ;
	if Reg == 1 
	  set(gcbo,'String','Specify') ;
	elseif Reg == 0
	  set(gcbo,'String','Automatic') ;
	end
	
  case 'close'
	global handlefig_boxdim
        for i=1:length(handlefig_boxdim)
	  %%%%%%check for non already closed handle%%%
	  if ishandle(handlefig_boxdim(i))
	    close(handlefig_boxdim(i));
	  end
	end
	clear handlefig_boxdim
  case 'help'
      fl_doc Box_Dimension_Box_Method_Graphic;
end

