function varargout=fl_load_compute(varargin)
% Callback functions for the FRACLAB Toolbox GUI load.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch(varargin{1})
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%  load file dialog   %%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'init'
		UpdateFields;
	
	
      case 'load'
	myp=fl_waiton;
	[directory, filter, name, type]=GetParam;
	varargout={LoadFile(directory, name, type, varargin{2})};
	fl_waitoff(myp);
      case 'close'
	closewindow('Fig_gui_fl_load');


	case 'filter'
		UpdateFields;
	case 'name_edit'
		UpdateFields;
		set(findobj(gcf,'Tag','Pushbutton1'),'Enable','on');

	case 'name_choose'
		hlistfile = findobj(gcf,'Tag','Listbox_fl_load_name');	
		listname = get(hlistfile,'String');
		namenum=get(hlistfile,'Value');
		set(findobj(gcf,'Tag','Pushbutton1'),'Enable','on');
		SetName(listname{namenum});
	
	case 'dir_edit'
		UpdateFields;
	case 'dir_choose'
		hlistdir = findobj(gcf,'Tag','Listbox_fl_load_dir');
		dirnum=get(hlistdir ,'Value');
		listdir = get(hlistdir,'String');
		curdir=GetDir;
		SetDir([curdir ,'/',listdir{dirnum}]);
		UpdateFields;

end;

function varargout=LoadFile(directory, name, type,whoisthere)
	
	filename = [directory '/' name];
	test =dir(filename);
	if (min(min(size(test)))~=0)
		switch(type)

			case 'image'
                [pathstr,namestr] = fileparts(filename);
				OutputName=[namestr,'_'];
				varname = fl_findname(OutputName,whoisthere);
				try
					eval(['global ' varname ';']);
					eval([varname '=imread(filename);']);
				catch
					fl_error([name ': uncorrect or unknown image format file']);
					varargout{1}='';
					return;
				end
				eval([varname '= ima2mat(' varname ');']);
				varargout{1}=varname;
				fl_addlist(0,varname) ;

			case 'mat file'
				varlist=whos('-file',filename);
				listvarname={varlist.name};
				if (length(listvarname)==0)
				   fl_error([name ' not a mat file!']);
				   varargout{1}='';
				   return;
				end
				nbvar = max(max(size(listvarname)));
				
				for i=1:nbvar
					varname = listvarname{i};
					eval(['global ' varname ';']);
					varargout{i}=listvarname{i};
					
				end;
				eval(['load(filename);']);
				for i=1:nbvar
					varname = listvarname{i};
					fl_addlist(0,varname) ;
				end;

			case 'ASCII'
			     pointpos = findstr('.',name);
			     dimpos = max(max(length(pointpos)));
			     if(dimpos == 0)
				varname = name;
			     else
				for i=1:(pointpos(1)-1)
				    varname(i) = name(i);
				end
			     end
			     varname = ['f' varname]; 
			     eval(['global ' varname ';']);
			     try
				eval([varname '= load(filename);']);
			     catch
				fl_error([name ': uncorrect format!']);
				varargout{1}='';
				return;
			     end
			     varargout{1}=varname;
			     fl_addlist(0,varname) ;
		end;
	end;


function [filelist,dirlist]=GetFileList(direct,filter)
	
	totalflist=dir([direct '/']);
	[tmp,idx] = sortrows(strvcat(totalflist.name));
	totalflist = totalflist(idx);
	
	isdir=[totalflist.isdir];
	indexdir = find(isdir==1);
	
	dirlist={totalflist.name};
	dirlist=dirlist(indexdir);
	

	flist=dir([direct '/' filter]);
	[tmp,idx] = sortrows(strvcat(flist.name));
	flist = flist(idx);
	filelist={flist.name};
	
	
	
	isdir=[flist.isdir];
	indexfile=find(isdir==0);
	filelist = filelist(indexfile);
	

function [directory,filter,name,type]=GetParam()

	hfilter = findobj(gcf,'Tag','EditText_fl_load_filter');
	filter = get(hfilter,'String');

	hdirectory = findobj(gcf,'Tag','EditText_fl_load_dir');
	directory = get(hdirectory ,'String');

	hname = findobj(gcf,'Tag','EditText_fl_load_name');
	name = get(hname ,'String');

	hpoptype = findobj(gcf,'Tag','PopupMenu_fl_load_type');
	typenum = get(hpoptype,'Value');
	typelist = get(hpoptype,'String');
	type = typelist{typenum};

function UpdateFields()

	[directory filter]=GetParam;

	[filelist, dirlist]=GetFileList(directory,filter);

	hlistfile = findobj(gcf,'Tag','Listbox_fl_load_name');
	set(hlistfile,'String', filelist);
	set(hlistfile,'Value',1);

	hlistdir = findobj(gcf,'Tag','Listbox_fl_load_dir');
	set(hlistdir,'String', dirlist);
	set(hlistdir,'Value',1);

function SetDir(directory)

	hdirectory = findobj(gcf,'Tag','EditText_fl_load_dir');
	set(hdirectory,'String',directory);

function [directory]=GetDir()

	hdirectory = findobj(gcf,'Tag','EditText_fl_load_dir');
	directory=get(hdirectory,'String');

function SetName(name)

	hname = findobj(gcf,'Tag','EditText_fl_load_name');
	set(hname,'String',name);


function closewindow(tag)
figh=findobj('Tag',tag);
close(figh);
