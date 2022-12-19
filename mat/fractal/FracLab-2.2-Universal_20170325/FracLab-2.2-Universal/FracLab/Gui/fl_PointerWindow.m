function fig = fl_PointerWindow
    if verLessThan('matlab', '8.4')     %if true then using hg1
        fig = get(0,'PointerWindow');
    else
        fig = matlab.ui.internal.getPointerWindow;
    end
    

