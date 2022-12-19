function fout = fl_waitbar(command,whichbar,i,n,varargin)
% FL_WAITBAR Displays the fraclab waitbar.
%
%   H = FL_WAITBAR('init') initializes the waitbar and returns the handle
%   of the current waitbar. If H does not exist a new waitbar is created
%   with handle H.
%
%   FL_WAITBAR('close',H) closes the waitbar with the handle H.
%
%   FL_WAITBAR('view',H,STEP,N) Displays the waitbar with the handle, H,
%   with a specific STEP and the length of the bar, N.
%
%   Examples
%
%       h_waitbar = fl_waitbar('init');
%       for i=1:100,
%           % computation here %
%           fl_waitbar('view',h_waitbar,i,100);
%       end
%       fl_waitbar('close',h_waitbar);
%
%       Or in case of multiple "for" loops :
%       h_waitbar = fl_waitbar('init');
%       for i1=1:100,
%           % computation here %
%           fl_waitbar('view',h_waitbar,0.5*i1,100);
%       end
%       for i2=1:1000,
%           % computation here %
%           fl_waitbar('view',h_waitbar,0.5*1000+0.5*i2,1000);
%       end
%       fl_waitbar('close',h_waitbar);
   
% Modified by Christian Choque Cortez, April 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

waiting_message_init = 'Please wait (initializing)';

fout = 0;
switch command
    case 'init'
        if fl_getOption('ShowWaitBars')
            fout = waitbar(0,waiting_message_init,'Color',fl_getOption('FrameColor'));
            set(fout,'Name','FracLab waitbar');
            set(get(get(fout,'children'),'Title'),'Color',fl_getOption('FontColor'));
            pause(0.1);
            donnees.heuredebut = now;
            guidata(fout,donnees);
            fout = double(fout);
            fout=[fout,1];
        else
            fprintf('Initializing...              ')
            fout = now;
            fout=[fout,0];
        end

    case 'view'
        %Just show one window out of 100;
        if mod(i,floor(n/100)+1)==0
            if whichbar(2)==1%fl_getOption('ShowWaitBars')
                whichbar=whichbar(1);
                donnees = guidata(whichbar);
                duree = (n-i)/max(1,i)*(now-donnees.heuredebut);
                [y,m,d,h,mi,s] = datevec(duree);
                waiting_message_view = sprintf('%2.0f%% - %1.0fh %1.0fm %1.0fs remaining', 100*i/n,24*d+h,mi,s);
                fout = waitbar(i/n, whichbar, waiting_message_view, 'Color',fl_getOption('FrameColor'), varargin);
                fout = double(fout);
            else
                whichbar=whichbar(1);
                duree = (n-i)/max(1,i)*(now-whichbar);
                [y,m,d,h,mi,s] = datevec(duree);
                nb_heures = min(9999,24*d+h); % The printed number of hours must have less than 4 digits.
                pcentage = min(99,100*i/n); % The printed percentage must have less than 2 digits.
                %pcentage=50;nb_heures=10;mi=10;s=10;
                waiting_message_view = sprintf('%2.0f%%%% - %4.0fh %2.0fm %2.0fs remaining', pcentage,nb_heures,mi,s);
                fprintf(['\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b',waiting_message_view]);
                fout = whichbar;
            end
        end

    case 'close'
        if fl_getOption('ShowWaitBars')
            close(whichbar(1));
        else
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\n');
        end
end