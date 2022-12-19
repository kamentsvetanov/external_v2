function fl_save_compute(varargin)
% Callback functions for the FRACLAB Toolbox GUI load.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch(varargin{1})
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%  save file dialog   %%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'init'
		UpdateFields;
	
	case 'save'
		[directory, filter, fname, varname, type]=GetParam;
		SaveFile(directory, fname, varname, type);

	case 'close'
		closewindow('Fig_gui_fl_save');

	case 'filter'
		UpdateFields;

	case 'format'
		%%%% Replace the file extension by the appropraite one %%%%
		edith=findobj('Tag','EditText_fl_save_name');
		fcell=get(edith,'String');
		if(iscell(fcell))
			fname=fcell{1};	
		else
			fname=fcell;
		end;
		temp=findstr(fname,'.');
		if(length(temp)>0)
			pointpos=max(temp);
			for(i=1:pointpos)
				newfname(i)=fname(i);
			end
		else
			newfname=strcat(fname,'.');
		end
		poph=findobj('Tag','PopupMenu_fl_save_type');
		value=get(poph,'Value');
		string=get(poph,'String');
		switch(value)
			
			case 1
			newfname=strcat(newfname,'jpg');

			case 2
			newfname=strcat(newfname,'mat');

			case 3
			newfname=strcat(newfname,'dat');
		end
		set(edith,'String',newfname);

	case 'name_edit'
		UpdateFields;

	case 'name_choose'
		hlistfile = findobj(gcf,'Tag','Listbox_fl_save_name');	
		listname = get(hlistfile,'String');
		namenum=get(hlistfile,'Value');
		SetName(listname{namenum});

	case 'dir_edit'
		UpdateFields;

	case 'dir_choose'
		hlistdir = findobj(gcf,'Tag','Listbox_fl_save_dir');
		dirnum=get(hlistdir ,'Value');
		listdir = get(hlistdir,'String');
		curdir=GetDir;
		SetDir([curdir ,'/',listdir{dirnum}]);
		UpdateFields;

end; %%% switch(varargin{1})




function SaveFile(directory, fname, varname, type)
	filename = [directory '/' fname];
	test =dir(filename);
	if (min(min(size(test)))~=0)
	   choice=menu([fname ' already exists. Overwrite it?'],'Yes','No');
	   if(choice==2)
		return;
	   end  %%% if(choice==2)
	end  %%% if (min(min(size(test)))~=0)

	myp=fl_waiton;
	eval(['global  ' varname ';']);
	switch(type)
		case 'image'
		     try
			eval(['imwrite(varname,filename);']);
		     catch
			fl_error(lasterr);
			fl_waitoff(myp);
			return;
		     end  %%% try

		case 'mat file'
		     try
			eval(['save(filename, varname);'])
		     catch
			fl_error(lasterr);
			fl_waitoff(myp);
			return;
		     end  %%% try

		case 'ASCII'
		     try
			eval(['save(filename, varname,''-ASCII'');'])
		     catch
			fl_error(lasterr);
			fl_waitoff(myp);
			return;
		     end  %%% try

	end;  %%% switch(type)
	fl_waitoff(myp);
	closewindow('Fig_gui_fl_save');



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
	

function [directory,filter,fname,varname,type]=GetParam()

	hfilter = findobj(gcf,'Tag','EditText_fl_save_filter');
	filter = get(hfilter,'String');

	hdirectory = findobj(gcf,'Tag','EditText_fl_save_dir');
	directory = get(hdirectory ,'String');

	hname = findobj(gcf,'Tag','EditText_fl_save_name');
	temp = get(hname ,'String');
	if(iscell(temp))
		fname=temp{1};
	else
		fname=temp;
	end

	temp=get(gcf,'UserData');
	if(iscell(temp))
		varname=temp{1};
	else
		varname=temp;
	end

	hpoptype = findobj(gcf,'Tag','PopupMenu_fl_save_type');
	typenum = get(hpoptype,'Value');
	typelist = get(hpoptype,'String');
	type = typelist{typenum};

function UpdateFields()

	[directory filter]=GetParam;

	[filelist, dirlist]=GetFileList(directory,filter);

	hlistfile = findobj(gcf,'Tag','Listbox_fl_save_name');
	set(hlistfile,'String', filelist);
	set(hlistfile,'Value',1);

	hlistdir = findobj(gcf,'Tag','Listbox_fl_save_dir');
	set(hlistdir,'String', dirlist);
	set(hlistdir,'Value',1);

function SetDir(directory)

	hdirectory = findobj(gcf,'Tag','EditText_fl_save_dir');
	set(hdirectory,'String',directory);

function [directory]=GetDir()

	hdirectory = findobj(gcf,'Tag','EditText_fl_save_dir');
	directory=get(hdirectory,'String');

function SetName(name)

	hname = findobj(gcf,'Tag','EditText_fl_save_name');
	set(hname,'String',name);


function closewindow(tag)
figh=findobj('Tag',tag);
close(figh);
