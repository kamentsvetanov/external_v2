function VBA_updateDisplay(F,posterior,suffStat,options,y,it,flag)
% updates display of sufficient statistics
% function VBA_updateDisplay(F,posterior,suffStat,options,y,it,display,flag)
% This function deals with the screen display of iterative sufficient
% statistics updates of the VBA inversion algorithm

if ~options.DisplayWin
    if isequal(flag,'F') && ~options.OnLine
        % display free energy iterative scanning
        F = real(F);
        dF = diff(F);
        if it > 0 && options.verbose
            fprintf(['VB iteration #',...
                num2str(it),...
                '         F=','%e',...
                '         ... dF=','%4.3e'],F(end),dF(end))
            fprintf('\n')
        end
    end
    return
end

display = options.display;

% check whether 'pause' button is toggled on
VBA_pause(options)

% First check whether this is standard DCM or ODE limit
if ( isequal(options.g_fname,@VBA_odeLim) || ...
        isequal(options.g_fname,@VBA_smoothNLSS) ) && ~isequal(flag,'F')
    
    % Rebuild posterior from dummy 'ODE' posterior
    options0 = options;
    [posterior,options,dim,suffStat] = ...
        VBA_odeLim2NLSS(posterior,options,options.dim,suffStat,[],0);
    options.display = options0.display;
    
    % Then call VBA_updateDisplay again
    if ~isempty(it)
        VBA_updateDisplay(F,posterior,suffStat,options,y,it,'precisions')
    end
    if dim.n_phi > 0
        VBA_updateDisplay(F,posterior,suffStat,options,y,it,'phi')
    end
    if dim.n > 0
        VBA_updateDisplay(F,posterior,suffStat,options,y,it,'X')
    end
    if dim.n_theta > 0
        VBA_updateDisplay(F,posterior,suffStat,options,y,it,'theta')
    end
    
    return
    
end


% Get sufficient statistics to be displayed
dTime = [1:size(y,2)];
gx = suffStat.gx(:,dTime);
vy = suffStat.vy(:,dTime);
indEnd = length(dTime);
if  ~options.binomial
    if options.OnLine
        sigmaHat = posterior.a_sigma(dTime)./posterior.b_sigma(dTime);
        var_sigma = sigmaHat./posterior.b_sigma(dTime);
    else
        sigmaHat = posterior.a_sigma./posterior.b_sigma;
        var_sigma = sigmaHat./posterior.b_sigma;
    end
else
    ne = min([5,numel(y)]); % number of bins
    sortgx = sort(gx);   
    dn = numel(y)./ne;
    stacky = zeros(ne,1);
    stdy = zeros(ne,1);
    gridg = zeros(ne,1);
    for i=1:ne
        edges(i) = sortgx(floor((i-1)*dn+1));
        edges(i+1) = sortgx(floor(i*dn));
        ind = find(gx>=edges(i)&gx<=edges(i+1));
        stacky(i) = mean(y(ind));
        stdy(i) = std(y(ind));
        gridg(i) = mean(gx(ind));
    end
end
if options.dim.n > 0
    mux = posterior.muX(:,dTime);
    try
        vx = getVar(posterior.SigmaX.current,indEnd);
    catch
        vx = zeros(size(mux));
    end
    if ~any(isinf(posterior.a_alpha))
        if options.OnLine
            alphaHat = posterior.a_alpha(dTime)./posterior.b_alpha(dTime);
            var_alpha = alphaHat./posterior.b_alpha(dTime);
        else
            alphaHat = posterior.a_alpha./posterior.b_alpha;
            var_alpha = alphaHat./posterior.b_alpha;
        end
    else
        alphaHat = Inf;
        var_alpha = 0;
    end
    vx0 = getVar(posterior.SigmaX0);
    if options.updateX0
        dx0 = suffStat.dx0;
    else
        dx0 = posterior.muX0;
    end
end
if options.dim.n_theta > 0
    if options.OnLine
        dtheta = suffStat.dtheta(:,dTime);
    else
        dtheta = suffStat.dtheta;
    end
    vtheta = getVar(posterior.SigmaTheta,indEnd);
end
if options.dim.n_phi > 0
    if options.OnLine
        dphi = suffStat.dphi(:,dTime);
    else
        dphi = suffStat.dphi;
    end
    vphi = getVar(posterior.SigmaPhi,indEnd);
end

% check time dimension
if isequal(dTime,1) && size(y,1) > 1
    gx = gx';
    vy = vy';
    y = y';
    if options.dim.n > 0
        mux = mux';
        vx = vx';
    end
    dTime = [1:size(y,2)];
end



switch flag % What piece of the model to display?
    
    
    case 'X' % Hidden-states related quantities
        
        
        % update top-left subplot: predictive density
        cla(display.ha(1))
        plot(display.ha(1),dTime,y','.')
        plotUncertainTimeSeries(gx,vy,dTime,display.ha(1));
        grid(display.ha(1),'on')
        axis(display.ha(1),'tight')
        
        % update top-right subplot: predicted VS observed data
        cla(display.ha(2))
        if  ~options.binomial
            miy = min([gx(:);y(:)]);
            may = max([gx(:);y(:)]);
            plot(display.ha(2),[miy,may],[miy,may],'r')
            plot(display.ha(2),gx(:),y(:),'k.')
        else
            plot(display.ha(2),[0,1],[0,1],'r')
            errorbar(gridg,stacky,stdy,'k.','parent',display.ha(2))
        end
        grid(display.ha(2),'on')
        axis(display.ha(2),'tight')
        
        % get display indices if delay embedding
        if sum(options.delays) > 0
            ind = 1:options.inF.dim.n;
        else
            ind = 1:size(mux,1);
        end
        
        % update middle-left subplot: hidden states
        cla(display.ha(3))
        plotUncertainTimeSeries(mux,vx,dTime,display.ha(3),ind);
        grid(display.ha(3),'on')
        axis(display.ha(3),'tight')
        
        % update middle-right subplot: initial conditions
        if options.updateX0
            cla(display.ha(4))
            plotUncertainTimeSeries(-dx0,vx0,1,display.ha(4),ind);
        elseif isequal(it,0)
            plotUncertainTimeSeries(dx0,vx0,1,display.ha(4),ind);
        end
        
        displayDF(F,display)
        
    case 'phi' % Observation parameters
        
        
        % update top-left subplot: predictive density
        cla(display.ha(1))
        plot(display.ha(1),dTime,y','.')
        plotUncertainTimeSeries(gx,vy,dTime,display.ha(1));
        grid(display.ha(1),'on')
        axis(display.ha(1),'tight')
        
        % update top-right subplot: predicted VS observed data
        cla(display.ha(2))
        if  ~options.binomial
            miy = min([gx(:);y(:)]);
            may = max([gx(:);y(:)]);
            plot(display.ha(2),[miy,may],[miy,may],'r')
            plot(display.ha(2),gx(:),y(:),'k.')
        else
            plot(display.ha(2),[0,1],[0,1],'r')
            errorbar(gridg,stacky,stdy,'k.','parent',display.ha(2))
        end
        grid(display.ha(2),'on')
        axis(display.ha(2),'tight')
        
        % update bottom-left subplot: observation parameters
        if size(dphi,2) == 1 % for on-line wrapper
            dTime = 1;
        end
        cla(display.ha(5))
        plotUncertainTimeSeries(-dphi,vphi,dTime,display.ha(5));
        
        displayDF(F,display)
        
        
        
    case 'theta' % Evolution parameters
        
        % update bottom-right subplot: observation parameters
        
        if size(dtheta,2) == 1 % for on-line wrapper
            dTime = 1;
        end
        cla(display.ha(7))
        plotUncertainTimeSeries(-dtheta,vtheta,dTime,display.ha(7));
        
        displayDF(F,display)
        
        
    case 'precisions' % Precision hyperparameters
        
        % update top-left subplot: predictive density
        cla(display.ha(1))
        plot(display.ha(1),dTime,y','.')
        plotUncertainTimeSeries(gx,vy,dTime,display.ha(1));
        
        
        if options.updateHP || (isequal(it,0) && ~options.binomial)
            
            % update middle-left subplot: measurement noise
            if size(sigmaHat,2) > 1  % for on-line wrapper
                cla(display.ha(6))
            else
                dTime = it+1;
                set(display.ha(6),...
                    'xlim',[.2,it+1.8],...
                    'xtick',[])
            end
            logCI = log(sigmaHat+sqrt(var_sigma)) - log(sigmaHat);
            plotUncertainTimeSeries(log(sigmaHat),logCI.^2,dTime,display.ha(6));
            
            
            % update middle-right subplot: state noise
            if options.dim.n > 0 && ~any(isinf(alphaHat))
                if size(alphaHat,2) > 1  % for on-line wrapper
                    cla(display.ha(8))
                else
                    dTime = it+1;
                    set(display.ha(8),...
                        'xlim',[.2,it+1.8],...
                        'xtick',[])
                end
                logCI = log(alphaHat+sqrt(var_alpha)) - log(alphaHat);
                plotUncertainTimeSeries(log(alphaHat),logCI.^2,dTime,display.ha(8));
            end
            
            displayDF(F,display)
            
        end
        
    case 'F' % Free energy
        
        % Output in main matlab window
        dF = diff(F);
        if it > 0 && options.verbose
            fprintf(['VB iteration #',...
                num2str(it),...
                '         F=','%e',...
                '         ... dF=','%4.3e'],F(end),dF(end))
            fprintf('\n')
        end
        
end

drawnow



%--- subfunction ---%

function [] = displayDF(F,display)
if ~display.OnLine
    F = real(F);
    try
        dF = diff(F);
        set(display.ho,'string',...
            ['Model evidence: log p(y|m) >= ',num2str(F(end),'%4.3e'),...
            ' , dF= ',num2str(dF(end),'%4.3e')])
    catch
        try
            set(display.ho,'string',...
                ['Model evidence: log p(y|m) >= ',num2str(F(end),'%4.3e')])
        end
    end
end

