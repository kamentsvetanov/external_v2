function [] = VBA_pause(options)
% used to pause the VB inversion from the GUI interactively

try
    hpause = options.display.hpause;
    if ~isempty(hpause) && ishandle(hpause)
        if get(hpause,'value')
            set(hpause,'string','PAUSED!',...
                'backgroundColor',[1 0.5 0.5])
            stop = 0;
            s = dbstatus;
            if isempty(s)
                dbstop if error % this allows to have a look...
            end
            while ~stop
                pause(2)
                if ~get(hpause,'value')
                    stop = 1;
                    set(hpause,'string','pause?',...
                        'backgroundColor',0.8*[1 1 1])
                end
            end
        end
    end
end
    

