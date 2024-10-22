function [hf] = VB_displayGrads(J,J2,flag,fname,flagFun)
% This is called only to eyeball the analytic gradients
try sfn = func2str(fname);catch, sfn = fname;end
switch flagFun
    case 'f'
        str = [' (evolution function: ',sfn,')'];
    case 'g'
        str = [' (observation function: ',sfn,')'];
    case 'fg'
        str = [' (N-lagged observation function: ',sfn,')'];
end
switch flag
    case 'Jacobian'
        hf0 = findobj('tag','checkGrads');
        set(hf0,'tag',' ');
        hf(1) = figure('name',[flag,str],'tag','checkGrads');
    case 'Gradients wrt parameters'
        hf(1) = figure('name',[flag,str]);
        hf1 = findobj('tag','checkGrads');
        if ~isempty(hf1)
            pos = get(hf1,'position');
            pos = [pos(1)-0.5*pos(3) pos(2) pos(3) pos(4)];
            set(hf1,'position',pos);
            pos2 = get(hf(1),'position');
            set(hf(1),'position',[1.02*sum(pos([1,3])), pos2(2:4)])
        end
end
ha = subplot(2,2,1,'parent',hf(1));
plot(ha,J(:),J2(:),'b.')
grid(ha,'on')
axis(ha,'tight')
xlabel(ha,'analytic')
ylabel(ha,'numerical')
ha = subplot(2,2,2,'parent',hf(1));
imagesc(J-J2,'parent',ha),colorbar
xlabel(ha,'analytic-numerical')
ha = subplot(2,2,3,'parent',hf(1));
imagesc(J,'parent',ha),colorbar
xlabel(ha,'analytic')
ha = subplot(2,2,4,'parent',hf(1));
imagesc(J2,'parent',ha),colorbar
xlabel(ha,'numerical')