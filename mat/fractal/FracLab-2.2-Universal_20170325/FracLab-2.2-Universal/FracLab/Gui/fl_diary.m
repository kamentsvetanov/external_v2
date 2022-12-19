function[]=fl_diary(chaine)
% No help found

% Author Pierrick Legrand, January 2005.
% Modified by Olivier Barrière, February 2005
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

f=clock;
fyear = num2str(f(1));
fmonth = num2str(f(2));
	if f(2)<10 fmonth = ['0' fmonth]; end;
fday = num2str(f(3));
	if f(3) <10 fday = ['0' fday]; end;
fhour = num2str(f(4));
	if f(4) <10 fhour = ['0' fhour]; end;
fminute = num2str(f(5)); 
	if f(5) <10 fminute = ['0' fminute]; end;
fsecond = num2str(floor(f(6)));
	if f(6) <10 fsecond = ['0' fsecond]; end;

ftime = ['%%-- ', fday, '/', fmonth, '/', fyear, ' ' fhour, ':', fminute, ':', fsecond, ' --%%'];


if fl_getOption('SaveLog')
	flroot = fl_getOption('FracLabRoot');
	try
		fid = fopen(fullfile(flroot,'Data','FracLab.log'),'at+');
			fprintf(fid,['\n' ftime]);
			fprintf(fid,['\n',chaine,'\n']);
		fclose(fid);	
	catch
		warning(['Unable to save diary in ' fullfile(flroot,'Data','FracLab.log')]);
	end
end

p=version;
if str2num(p(1))>=7
	%com.mathworks.mde.cmdhist.CmdHistory.getInstance.add(chaine);
    cmd = com.mathworks.mlservices.MLCommandHistoryServices;
    cmd.add(chaine)
end
