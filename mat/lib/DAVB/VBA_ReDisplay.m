function [hfp] = VBA_ReDisplay(posterior,out)
% re-creates the graphical output of the VBA inversion + diagnostics
% function [hfp] = VBA_ReDisplay(posterior,out)
% NB: hfp is the figure handle. Note that VBA_ReDisplay first looks for a
% figure with a tag 'VBNLSS', i.e. a figure that was already opened to
% review a model inversion, and clears it if it finds it.

if isempty(out.u)
    error('No input?')
    return
end

options = out.options;
options.DisplayWin = 1;
hfp = findobj('tag','VBNLSS');
if isempty(hfp)
    pos0 = get(0,'screenSize');
    pos = [0.51*pos0(3),0.05*pos0(4),0.45*pos0(3),0.9*pos0(4)];
    hfp = figure(...
        'position',pos,...
        'color',[1 1 1],...
        'name','VB-Laplace approximate Bayesian inference',...
        'tag','VBNLSS',...
        'Renderer','OpenGL');
else
    clf(hfp)
    set(hfp,'name',options.figName);
end

ud.posterior = posterior;
ud.out = out;
ud.diagnostics = getDiagnostics(posterior,out);

set(hfp,'userdata',ud);
if ~isempty(ud.diagnostics.kernels)
    if ~isinf(out.options.priors.a_alpha) ...
            && ~isequal(out.options.priors.b_alpha,0) ...
            && ~out.options.OnLine
        labels = {'summary','VB inversion','diagnostics','kernels',...
            'conv','priors','deterministic'};
        callbacks = {@mySummary,@myVB,@myDiagnostics,@myKernels,...
            @myConv,@myPriors,@myDeterministic};
    else
        labels = {'summary','VB inversion','diagnostics','kernels',...
            'conv','priors'};
        callbacks = {@mySummary,@myVB,@myDiagnostics,@myKernels,...
            @myConv,@myPriors};
    end
else
    labels = {'summary','VB inversion','diagnostics',...
        'conv','priors'};
    callbacks = {@mySummary,@myVB,@myDiagnostics,...
        @myConv,@myPriors};
end
[handles] = spm_uitab(hfp,labels,callbacks,'diagnostics_tabs',1);
set(handles.htab,'backgroundcolor',[1 1 1])
set(handles.hh,'backgroundcolor',[1 1 1])
set(handles.hp,'HighlightColor',0.8*[1 1 1])
set(handles.hp,'backgroundcolor',[1 1 1])
set(handles.htab(1),...
    'tooltipstring','summary description of the VB inversion')
set(handles.htab(2),...
    'tooltipstring','results of the VB inversion (posterior pdfs)')
set(handles.htab(3),...
    'tooltipstring',...
    'VB inversion diagnostics (residuals and parameters covariance matrices)')
if ~isempty(ud.diagnostics.kernels)
    if ~isinf(out.options.priors.a_alpha) ...
            && ~isequal(out.options.priors.b_alpha,0) ...
            && ~out.options.OnLine
        set(handles.htab(4),...
            'tooltipstring',...
            'impulse response of the system to deterministic inputs')
        set(handles.htab(5),...
            'tooltipstring',...
            'history of free energy values along VB optimization')
        set(handles.htab(6),...
            'tooltipstring',...
            'priors and associated predictive densities (under the Laplace assumption)')
        set(handles.htab(7),...
            'tooltipstring',...
            'results of the VB inversion of the deterministic system')
    else
        set(handles.htab(4),...
            'tooltipstring',...
            'impulse response of the system to deterministic inputs')
        set(handles.htab(5),...
            'tooltipstring',...
            'history of free energy values along VB optimization')
        set(handles.htab(6),...
            'tooltipstring',...
            'priors and associated predictive densities (under the Laplace assumption)')
    end
else
    set(handles.htab(4),...
        'tooltipstring',...
        'history of free energy values along VB optimization')
    set(handles.htab(5),...
        'tooltipstring',...
        'priors and associated predictive densities (under the Laplace assumption)')
end
feval(@mySummary,hfp)


function mySummary(hfp)

try
    hf = hfp;
catch
    hf = get(gco,'parent');
end
hc = ...
    intersect(findobj('tag','VBLaplace'),get(hf,'children'));
if ~isempty(hc)
    delete(hc)
end

ud = get(hf,'userdata');
out = ud.out;
diagnostics = ud.diagnostics;

try F = out.F(end); catch, F = '?'; end

str{1} = sprintf(['Date: ',datestr(out.date),'\n ']);
if ~out.options.OnLine
    s0 = ['VB converged in ',num2str(out.it),' iterations'];
else
    s0 = ['Online VB algorithm'];
end
try
    mins = floor(out.dt/60);
    if mins >= 1
        str{2} = sprintf([s0,' (took ~',num2str(mins),' min)','\n']);
    else
        str{2} = sprintf([s0,' (took <1 min)','\n']);
    end
catch
    str{2} = sprintf([s0,'\n']);
end
str{3} = sprintf(['Dimensions of the model:','\n ',...
    '    - data: p=',num2str(out.dim.p),'\n ',...
    '    - time samples: t=',num2str(out.dim.n_t),'\n ',...
    '    - hidden states: n=',num2str(out.dim.n),'\n ',...
    '    - evolution parameters: n_theta=',num2str(out.dim.n_theta),'\n ',...
    '    - observation parameters: n_phi=',num2str(out.dim.n_phi),'\n ']);
if out.options.binomial
    tmp = ' (binomial data)';
else
    tmp = [];
end
if out.dim.n >= 1
    if isinf(out.options.priors.a_alpha) ...
            && isequal(out.options.priors.b_alpha,0)
        str{4} = 'This was a deterministic dynamical system';
    else
        str{4} = 'This was a stochastic dynamical system';
        if out.options.priors.AR
            str{4} = [str{4},' [AR(1) state noise]'];
        end
    end
    if isa(out.options.g_fname,'function_handle')
        gfn = func2str(out.options.g_fname);
    else
        gfn = out.options.g_fname;
    end
    if isequal(gfn,'g_embed')
        gfn0 = out.options.inG.g_fname;
        if isa(gfn0,'function_handle')
            gfn0 = func2str(gfn0);
        end
        gfn = [gfn,' (',gfn0,')'];
        str{4} = [str{4},' (with delay embedding)'];
    end
    if isa(out.options.f_fname,'function_handle')
        ffn = func2str(out.options.f_fname);
    else
        ffn = out.options.f_fname;
    end
    if isequal(ffn,'f_embed')
        ffn0 = out.options.inF.f_fname;
        if isa(ffn0,'function_handle')
            ffn0 = func2str(ffn0);
        end
        ffn = [ffn,' (',ffn0,')'];
    end
    str{5} = sprintf(['    - observation function: ',gfn,tmp,'\n',...
        '    - evolution function: ',ffn,'\n ']);
else
    str{4} = 'The model was static (no hidden states)';
    if isa(out.options.g_fname,'function_handle')
        gfn = func2str(out.options.g_fname);
    else
        gfn = out.options.g_fname;
    end
    str{5} = sprintf(['    - observation function: ',gfn,tmp,'\n ']);
end
str{6} = ['Log model evidences:'];
str{7} = ['    - full model: log p(y|m) > ',num2str(F,'%4.3e')];
str{8} = ['    - null hypothesis: log p(y|m) = ',...
    num2str(diagnostics.LLH0,'%4.3e')];
if ~out.options.OnLine ...
        && out.dim.n >= 1 ...
        && ~isinf(out.options.priors.a_alpha) ...
        && ~isequal(out.options.priors.b_alpha,0)
    str{9} = sprintf(['    - deterministic variant: log p(y|m) > ',...
        num2str(out.options.init.out.F,'%4.3e'),'\n ']);
else
    str{9} = [' '];
end
str{10} = sprintf(['Estimation efficiency (minus posterior entropies):','\n ']);
str{11} = sprintf(['Kullback-Leibler divergences (DKL{prior||posterior}):','\n ']);
if ~isnan(diagnostics.efficiency.X)
    str{10} = sprintf([str{10},...
        '    - hidden states: ',num2str(diagnostics.efficiency.X,'%4.3e'),'\n ']);
    str{11} = sprintf([str{11},...
        '    - hidden states: ',num2str(diagnostics.DKL.X,'%4.3e'),'\n ']);
end
if ~isnan(diagnostics.efficiency.X0)
    str{10} = sprintf([str{10},...
        '    - initial conditions: ',num2str(diagnostics.efficiency.X0,'%4.3e'),'\n ']);
    str{11} = sprintf([str{11},...
        '    - initial conditions: ',num2str(diagnostics.DKL.X0,'%4.3e'),'\n ']);
end
if ~isnan(diagnostics.efficiency.Theta)
    str{10} = sprintf([str{10},...
        '    - evolution parameters: ',num2str(diagnostics.efficiency.Theta,'%4.3e'),'\n ']);
    str{11} = sprintf([str{11},...
        '    - evolution parameters: ',num2str(diagnostics.DKL.Theta,'%4.3e'),'\n ']);
end
if ~isnan(diagnostics.efficiency.Phi)
    str{10} = sprintf([str{10},...
        '    - observation parameters: ',num2str(diagnostics.efficiency.Phi,'%4.3e'),'\n ']);
    str{11} = sprintf([str{11},...
        '    - observation parameters: ',num2str(diagnostics.DKL.Phi,'%4.3e'),'\n ']);
end
if ~isnan(diagnostics.efficiency.alpha)
    str{10} = sprintf([str{10},...
        '    - state noise precision hyperparameter: ',num2str(diagnostics.efficiency.alpha,'%4.3e'),'\n ']);
    str{11} = sprintf([str{11},...
        '    - state noise precision hyperparameter: ',num2str(diagnostics.DKL.alpha,'%4.3e'),'\n ']);
end
if ~isnan(diagnostics.efficiency.sigma)
    str{10} = sprintf([str{10},...
        '    - data noise precision hyperparameter: ',num2str(diagnostics.efficiency.sigma,'%4.3e'),'\n ']);
    str{11} = sprintf([str{11},...
        '    - data noise precision hyperparameter: ',num2str(diagnostics.DKL.sigma,'%4.3e'),'\n ']);
end
uicontrol(...
    'parent',hf,...
    'style','text',...
    'tag','VBLaplace',...
    'units','normalized',...
    'position',[0.1,0.1,0.8,0.8],...
    'backgroundcolor',[1,1,1],...
    'HorizontalAlignment','left',...
    'fontsize',11,...
    'string',str);


function myDeterministic(hfig)

try
    hfig;
catch
    hfig = get(gco,'parent');
end
% first: clear diagnostics display
hc = ...
    intersect(findobj('tag','VBLaplace'),get(hfig,'children'));
if ~isempty(hc)
    delete(hc)
end

% Second: re-display VB-Laplace inversion output
ud = get(hfig,'userdata');
y = ud.out.y;
posterior = ud.out.options.init.posterior;
out = ud.out.options.init.out;



options = out.options;
options.noPause = 1;
options.DisplayWin =1;
dim = out.dim;
suffStat = out.suffStat;
suffStat.dx0 = out.options.priors.muX0 - posterior.muX0;
suffStat.dtheta = out.options.priors.muTheta - posterior.muTheta;
suffStat.dphi = out.options.priors.muPhi - posterior.muPhi;
posterior.a_alpha = Inf;
posterior.b_alpha = 0;

try F = out.F; catch, F = '?'; end


% Initialize display figure
options.display.hfp = hfig;
options.figName = get(hfig,'name');
[options] = VBA_initDisplay(options,1);
delete(options.display.hpause)
delete(options.display.hm)
delete(options.display.ho)
if options.dim.n == 0 || isinf(posterior.a_alpha(end))
    try delete(options.display.ha(8)); end
end
hfig = options.display.hfp;
drawnow

% Display data and hidden states (if any)
if options.dim.n > 0
    VBA_updateDisplay(F,posterior,suffStat,options,y,0,'X')
end

% Display precision hyperparameters
VBA_updateDisplay(F,posterior,suffStat,options,y,0,'precisions')
if ~options.OnLine && ~options.binomial
    xlabel(options.display.ha(6),' ')
    try
        xlabel(options.display.ha(8),' ')
    end
end

% Display model evidence
VBA_updateDisplay(F,posterior,suffStat,options,y,0,'F')

% Display parameters
if dim.n_theta >= 1
    VBA_updateDisplay(F,posterior,suffStat,options,y,0,'theta')
end
if dim.n_phi >= 1
    VBA_updateDisplay(F,posterior,suffStat,options,y,0,'phi')
end

try
    getSubplots
end


function myPriors(hfig)

try
    hfig;
catch
    hfig = get(gco,'parent');
end
% first: clear diagnostics display
hc = ...
    intersect(findobj('tag','VBLaplace'),get(hfig,'children'));
if ~isempty(hc)
    delete(hc)
end

% Second: re-display VB-Laplace inversion output
ud = get(hfig,'userdata');
out = ud.out;
y = out.y;
posterior = out.options.priors;

options = out.options;
options.noPause = 1;
options.DisplayWin =1;
dim = out.dim;
suffStat = out.suffStat;
suffStat.gx = ud.diagnostics.pgx;
% set dx = -prior.muX (for display purposes)
suffStat.dx0 = -posterior.muX0;
suffStat.dtheta = -posterior.muTheta;
suffStat.dphi = -posterior.muPhi;

try F = out.F; catch, F = '?'; end


% Initialize display figure
options.display.hfp = hfig;
options.figName = get(hfig,'name');
[options] = VBA_initDisplay(options,1);
delete(options.display.hpause)
delete(options.display.hm)
delete(options.display.ho)
if options.dim.n == 0 || isinf(posterior.a_alpha(end))
    try delete(options.display.ha(8)); end
end
hfig = options.display.hfp;
drawnow

% Display data and hidden states (if any)
if options.dim.n > 0
    VBA_updateDisplay(F,posterior,suffStat,options,y,0,'X')
end

% Display precision hyperparameters
VBA_updateDisplay(F,posterior,suffStat,options,y,0,'precisions')
if ~options.OnLine && ~options.binomial
    xlabel(options.display.ha(6),' ')
    try
        xlabel(options.display.ha(8),' ')
    end
end

% Display model evidence
VBA_updateDisplay(F,posterior,suffStat,options,y,0,'F')

% Display parameters
if dim.n_theta >= 1
    VBA_updateDisplay(F,posterior,suffStat,options,y,0,'theta')
end
if dim.n_phi >= 1
    VBA_updateDisplay(F,posterior,suffStat,options,y,0,'phi')
end

try
    getSubplots
end



function myConv(hfp)

try
    hf = hfp;
catch
    hf = get(gco,'parent');
end
hc = ...
    intersect(findobj('tag','VBLaplace'),get(hf,'children'));
if ~isempty(hc)
    delete(hc)
end

ud = get(hf,'userdata');
out = ud.out;
diagnostics = ud.diagnostics;

if ~out.options.OnLine && length(out.suffStat.F)>2
    ha = axes(...
        'parent',hf,...
        'units','normalized',...
        'tag','VBLaplace',...
        'position',[0.15,0.6,0.5,0.3],...
        'nextplot','add',...
        'xlim',[0,length(out.suffStat.F)-1],...
        'xtick',[0,length(out.suffStat.F)-1],...
        'xticklabel',{'prior','approx posterior'},...
        'xgrid','on',...
        'ygrid','on');
    plot(ha,[0:length(out.suffStat.F)-1],out.suffStat.F)
    plot(ha,[0:length(out.suffStat.F)-1],out.suffStat.F,'.')
    title(ha,'VB optimization: F values','fontsize',11)
    xlabel(ha,'inner (Gauss-Newton) iterations')
    ylabel(ha,'Free energy')
    box(ha,'on')
    ha = axes(...
        'parent',hf,...
        'units','normalized',...
        'tag','VBLaplace',...
        'position',[0.15,0.15,0.5,0.3],...
        'nextplot','add',...
        'xlim',[0,length(out.suffStat.F)-2],...
        'xtick',[0,length(out.suffStat.F)-2],...
        'xticklabel',{'first iteration','last iteration'},...
        'xgrid','on',...
        'ygrid','on');
    plot(ha,[0:length(out.suffStat.F)-2],diff(out.suffStat.F))
    plot(ha,[0:length(out.suffStat.F)-2],diff(out.suffStat.F),'.')
    title(ha,'VB optimization: F increments','fontsize',11)
    xlabel(ha,'inner (Gauss-Newton) iterations')
    ylabel(ha,'Free energy differences')
    box(ha,'on')
    try
        getSubplots
    end
end


options = orderfields(out.options);
finames = fieldnames(options);
nopt = length(finames);
str = {'Optional fields:';' '};
for i=1:nopt
    tmp = getfield(options,finames{i});
    if ~isempty(tmp) && isnumeric(tmp)
        str{end+1} = [finames{i},' = ',num2str(max(tmp))];
    end
end
uicontrol(...
    'parent',hf,...
    'style','text',...
    'tag','VBLaplace',...
    'units','normalized',...
    'position',[0.75,0.1,0.2,0.8],...
    'backgroundcolor',[1,1,1],...
    'HorizontalAlignment','left',...
    'fontsize',11,...
    'string',str);



function myKernels()
% first: clear VB-Laplace inversion output display
hf = get(gco,'parent');
hc = ...
    intersect(findobj('tag','VBLaplace'),get(hf,'children'));
if ~isempty(hc)
    delete(hc)
end
ud = get(hf,'userdata');
dim = ud.out.options.dim;
unames = cell(dim.u,1);
for i=1:dim.u
    unames{i} = ['#',num2str(i)];
end
handles(1) = uicontrol('style','popupmenu',...
    'parent',hf,...
    'tag','VBLaplace',...
    'units','normalized',...
    'position',[0.85 0.9 0.10 0.02],...
    'fontsize',12,...
    'string',unames,...
    'callback',@myKerneli);
handles(2) = uicontrol('style','text',...
    'parent',hf,...
    'tag','VBLaplace',...
    'BackgroundColor',get(hf,'color'),...
    'units','normalized',...
    'position',[0.82 0.93 0.16 0.02],...
    'fontsize',12,...
    'string','display input...');
feval(@myKerneli,handles(1),[])



function myKerneli(hObject,evt)
hf = get(hObject,'parent');
ind = get(hObject,'Value');
ud = get(hf,'userdata');
try
    delete(ud.handles.hkernels)
end
out = ud.out;
kernels = ud.diagnostics.kernels;

% input effects - hidden states
kx = kernels.K1(:,:,ind);
handles.hkernels(1) = subplot(2,1,1,...
    'parent',hf,...
    'nextplot','add',...
    'tag','VBLaplace');
plot(handles.hkernels(1),kernels.tgrid,kx)
set(handles.hkernels(1),'XLim',[min(kernels.tgrid) max(kernels.tgrid)])
pos = get(handles.hkernels(1),'position');
set(handles.hkernels(1),'position',[0.2 pos(2) 0.6 pos(4)])
title(handles.hkernels(1),...
    ['states impulse responses to input #''' num2str(ind) ''''],...
    'fontsize',12)
grid(handles.hkernels(1),'on')
xlabel(handles.hkernels(1),'time')

% input effects - observables
ky = kernels.H1(:,:,ind);
handles.hkernels(2) = subplot(2,1,2,...
    'parent',hf,...
    'nextplot','add',...
    'tag','VBLaplace');
pos = get(handles.hkernels(2),'position');
set(handles.hkernels(2),'position',[0.2 pos(2) 0.6 pos(4)])
plot(handles.hkernels(2),kernels.tgrid,ky)
set(handles.hkernels(2),'XLim',[min(kernels.tgrid) max(kernels.tgrid)])
title(handles.hkernels(2),...
    ['observables impulse responses to input #''' num2str(ind) ''''],...
    'fontsize',12)
grid(handles.hkernels(2),'on')
xlabel(handles.hkernels(2),'time')

ud.handles = handles;
set(hf,'userdata',ud);
try getSubplots; end



function myDiagnostics()

% first: clear VB-Laplace inversion output display
hf = get(gco,'parent');
hc = ...
    intersect(findobj('tag','VBLaplace'),get(hf,'children'));
if ~isempty(hc)
    delete(hc)
end

% Second: display diagnostics
ud = get(hf,'userdata');
out = ud.out;
y = out.y;
diagnostics = ud.diagnostics;
try F = out.F(end); catch, F = '?'; end

% display micro-time hidden-states
if ~isempty(diagnostics.MT_x)
    display.ha(1) = subplot(4,2,1,...
        'parent',hf,...
        'nextplot','add',...
        'tag','VBLaplace',...
        'box','on');
    title(display.ha(1),'micro-time resolution predicted data',...
        'fontsize',11)
    xlabel(display.ha(1),'time',...
        'fontsize',8)
    ylabel(display.ha(1),'g(x)',...
        'fontsize',8)
    plot(display.ha(1),diagnostics.microTime,diagnostics.MT_gx')
    plot(display.ha(1),...
        diagnostics.microTime(diagnostics.sampleInd),...
        diagnostics.MT_gx(:,diagnostics.sampleInd)','.')
    plot(display.ha(1),...
        diagnostics.microTime(diagnostics.sampleInd),y,'k.')
    axis(display.ha(1),'tight')
    grid(display.ha(1),'on')
    display.ha(2) = subplot(4,2,2,...
        'parent',hf,...
        'nextplot','add',...
        'tag','VBLaplace',...
        'box','on');
    title(display.ha(2),'micro-time resolution hidden states',...
        'fontsize',11)
    xlabel(display.ha(2),'time',...
        'fontsize',8)
    ylabel(display.ha(2),'x',...
        'fontsize',8)
    plot(display.ha(2),diagnostics.microTime,diagnostics.MT_x')
    plot(display.ha(2),...
        diagnostics.microTime(diagnostics.sampleInd),...
        diagnostics.MT_x(:,diagnostics.sampleInd)','.')
    axis(display.ha(2),'tight')
    grid(display.ha(2),'on')
end

% display data noise
xlim = [diagnostics.dy.nx(1)-diagnostics.dy.d,...
    diagnostics.dy.nx(end)+diagnostics.dy.d];
display.ha(3) = subplot(4,2,5,...
    'parent',hf,...
    'nextplot','add',...
    'xlim',xlim,...
    'tag','VBLaplace',...
    'box','on');
title(display.ha(3),'residuals empirical distribution',...
    'fontsize',11)
xlabel(display.ha(3),'e(t) = y(t)-g(x(t))',...
    'fontsize',8)
ylabel(display.ha(3),'p(e|y)',...
    'fontsize',8)
bar(diagnostics.dy.nx,diagnostics.dy.ny,...
    'facecolor',[.8 .8 .8],...
    'parent',display.ha(3))
plot(display.ha(3),diagnostics.dy.grid,diagnostics.dy.pg,'r')
if ~out.options.binomial
    plot(display.ha(3),diagnostics.dy.grid,diagnostics.dy.pg2,'g')
end
grid(display.ha(3),'on')
if ~out.options.binomial
    legend(display.ha(3),...
        {'empirical histogram','Gaussian approx','posterior approx'})
else
    legend(display.ha(3),{'empirical histogram','Gaussian approx'})
end

if out.options.dim.n > 0
    gri = diagnostics.microTime(diagnostics.sampleInd);
    ti = 'time';
else
    if out.options.dim.n_t>1
        gri = 1:out.options.dim.n_t;
        ti = 'time';
    else
        gri = 1:out.options.dim.p;
        ti = 'data dimensions';
    end
end
display.ha(7) = subplot(4,2,3,...
    'parent',hf,...
    'nextplot','add',...
    'tag','VBLaplace',...
    'box','on');
plot(display.ha(7),gri,out.suffStat.dy')
axis(display.ha(7),'tight')
grid(display.ha(7),'on')
title(display.ha(7),'residuals time series',...
    'fontsize',11)
xlabel(display.ha(7),ti,...
    'fontsize',8)
ylabel(display.ha(7),'e(t) = y(t)-g(x(t))',...
    'fontsize',8)



% display state noise
if ~isempty(diagnostics.dx.dx)
    xlim = [diagnostics.dx.nx(1)-diagnostics.dx.d,...
        diagnostics.dx.nx(end)+diagnostics.dx.d];
    display.ha(4) = subplot(4,2,6,...
        'parent',hf,...
        'nextplot','add',...
        'xlim',xlim,...
        'xgrid','on',...
        'ygrid','off',...
        'tag','VBLaplace',...
        'box','on');
    title(display.ha(4),'state noise empirical distribution',...
        'fontsize',11)
    xlabel(display.ha(4),'eta(t) = x(t+1)-f(x(t))',...
        'fontsize',8)
    ylabel(display.ha(4),'p(eta|y)',...
        'fontsize',8)
    bar(diagnostics.dx.nx,diagnostics.dx.ny,...
        'facecolor',[.8 .8 .8],...
        'parent',display.ha(4))
    plot(display.ha(4),diagnostics.dx.grid,diagnostics.dx.pg,'r')
    plot(display.ha(4),diagnostics.dx.grid,diagnostics.dx.pg2,'g')
    grid(display.ha(4),'on')
    
    display.ha(8) = subplot(4,2,4,...
        'parent',hf,...
        'nextplot','add',...
        'tag','VBLaplace',...
        'box','on');
    try
        plotUncertainTimeSeries(...
            out.suffStat.dx,out.suffStat.vdx,...
            diagnostics.microTime(diagnostics.sampleInd),display.ha(8));
        
    catch
        plot(display.ha(8),...
            diagnostics.microTime(diagnostics.sampleInd),out.suffStat.dx')
    end
    axis(display.ha(8),'tight')
    grid(display.ha(8),'on')
    title(display.ha(8),'state noise time series',...
        'fontsize',11)
    xlabel(display.ha(8),'time',...
        'fontsize',8)
    ylabel(display.ha(8),'eta(t) = x(t+1)-f(x(t))',...
        'fontsize',8)
    
end

% display posterior correlation matrix (ODE limit)
if ~isequal(sum(diagnostics.C0(:)),0)
    display.ha(5) = subplot(4,2,7,...
        'parent',hf);
    imagesc(diagnostics.C0,'parent',display.ha(5))
    if ~isempty(diagnostics.dx.dx)
        ti = 'posterior correlation matrix (ODE limit)';
    else
        ti = 'posterior correlation matrix';
    end
    title(display.ha(5),ti,...
        'fontsize',11)
    set(display.ha(5),...
        'tag','VBLaplace',...
        'xtick',diagnostics.ltick,...
        'ytick',diagnostics.ltick,...
        'xticklabel',diagnostics.ticklabel,...
        'yticklabel',diagnostics.ticklabel,...
        'box','off',...
        'nextplot','add');
    for i=1:length(diagnostics.tick)
        plot(display.ha(5),...
            [0.5 size(diagnostics.C0,1)+0.5],...
            [diagnostics.tick(i) diagnostics.tick(i)],...
            'k--',...
            'linewidth',2)
        plot(display.ha(5),...
            [diagnostics.tick(i) diagnostics.tick(i)],...
            [0.5 size(diagnostics.C0,1)+0.5],...
            'k--',...
            'linewidth',2)
    end
    grid(display.ha(5),'off')
    axis(display.ha(5),'square')
    set(display.ha(5),'clim',[0 1]);
    try display.hc(1) = colorbar('peer',display.ha(5)); end
end

% display posterior correlation matrix (SDE)
if ~isempty(diagnostics.dx.dx)
    display.ha(6) = subplot(4,2,8,...
        'parent',hf);
    imagesc(diagnostics.C,'parent',display.ha(6))
    title(display.ha(6),'posterior correlation matrix (mean-field SDE)',...
        'fontsize',11)
    set(display.ha(6),...
        'tag','VBLaplace',...
        'xtick',diagnostics.ltick,...
        'ytick',diagnostics.ltick,...
        'xticklabel',diagnostics.ticklabel,...
        'yticklabel',diagnostics.ticklabel,...
        'box','off',...
        'nextplot','add');
    for i=1:length(diagnostics.tick)
        plot(display.ha(6),...
            [0.5 size(diagnostics.C,1)+0.5],...
            [diagnostics.tick(i) diagnostics.tick(i)],...
            'k--',...
            'linewidth',2)
        plot(display.ha(6),...
            [diagnostics.tick(i) diagnostics.tick(i)],...
            [0.5 size(diagnostics.C,1)+0.5],...
            'k--',...
            'linewidth',2)
    end
    grid(display.ha(6),'off')
    axis(display.ha(6),'square')
    set(display.ha(6),'clim',[0 1]);
    try display.hc(2) = colorbar('peer',display.ha(6)); end
end

try
    getSubplots
end


function myVB(hfig)

try
    hfig;
catch
    hfig = get(gco,'parent');
end
% first: clear diagnostics display
hc = ...
    intersect(findobj('tag','VBLaplace'),get(hfig,'children'));
if ~isempty(hc)
    delete(hc)
end

% Second: re-display VB-Laplace inversion output
ud = get(hfig,'userdata');
out = ud.out;
y = out.y;
posterior = ud.posterior;

options = out.options;
options.noPause = 1;
options.DisplayWin =1;
suffStat = out.suffStat;
try F = out.F; catch, F = '?'; end
dim = out.dim;

% Initialize display figure
options.display.hfp = hfig;
options.figName = get(hfig,'name');
[options] = VBA_initDisplay(options);
delete(options.display.hpause)
delete(options.display.hm)
delete(options.display.ho)
if options.dim.n == 0 || isinf(posterior.a_alpha(end))
    try delete(options.display.ha(8)); end
end
hfig = options.display.hfp;
drawnow

% Display data and hidden states (if any)
if options.dim.n > 0
    VBA_updateDisplay(F,posterior,suffStat,options,y,0,'X')
end

% Display precision hyperparameters
VBA_updateDisplay(F,posterior,suffStat,options,y,0,'precisions')
if ~options.OnLine && ~options.binomial
    xlabel(options.display.ha(6),' ')
    try
        xlabel(options.display.ha(8),' ')
    end
end

% Display model evidence
VBA_updateDisplay(F,posterior,suffStat,options,y,0,'F')

% Display parameters
if dim.n_theta >= 1
    VBA_updateDisplay(F,posterior,suffStat,options,y,0,'theta')
end
if dim.n_phi >= 1
    VBA_updateDisplay(F,posterior,suffStat,options,y,0,'phi')
end

try
    getSubplots
end



function diagnostics = getDiagnostics(posterior,out)

if out.options.verbose
    fprintf(1,['Deriving diagnostics ...'])
end

u = out.u;
y = out.y;

% get kernels
[kernels.H1,kernels.K1,kernels.tgrid] = getKernels(posterior,out,0);

% get null model (H0) evidence
[LLH0] = VBA_LMEH0(y);



% Entropies and KL divergences
if ~out.options.binomial
    efficiency.sigma = -out.suffStat.Ssigma;
    m0 = out.options.priors.a_sigma./out.options.priors.b_sigma;
    v0 = out.options.priors.a_sigma./out.options.priors.b_sigma^2;
    m = posterior.a_sigma(end)./posterior.b_sigma(end);
    v = posterior.a_sigma(end)./posterior.b_sigma(end)^2;
    DKL.sigma = VB_KL(m0,v0,m,v,'Gamma');
else
    efficiency.sigma = NaN;
    DKL.sigma = NaN;
end

if out.dim.n > 0 % hidden states and initial conditions
    % first get prior predicted data
    priors = out.options.priors;
    pgx = zeros(out.dim.p,out.dim.n_t);
    for t=1:out.dim.n_t
        pgx(:,t) = VBA_evalFun('g',...
            priors.muX(:,t),priors.muPhi,out.u(:,t),out.options,out.dim);
    end
    efficiency.X = -out.suffStat.SX;
    efficiency.X0 = -out.suffStat.SX0;
    if isinf(out.options.priors.a_alpha) ...
            && isequal(out.options.priors.b_alpha,0)
        efficiency.alpha = NaN;
        DKL.alpha = NaN;
    else
        efficiency.alpha = -out.suffStat.Salpha;
        m0 = out.options.priors.a_alpha./out.options.priors.b_alpha;
        v0 = out.options.priors.a_alpha./out.options.priors.b_alpha^2;
        m = posterior.a_alpha(end)./posterior.b_alpha(end);
        v = posterior.a_alpha(end)./posterior.b_alpha(end)^2;
        DKL.alpha = VB_KL(m0,v0,m,v,'Gamma');
    end
    try
        DKL.X = 0;
        for t=1:out.dim.n_t
            m0 = out.options.priors.muX(:,t);
            v0 = out.options.priors.SigmaX.current{t};
            m = posterior.muX(:,t);
            v = posterior.SigmaX.current{t};
            DKL.X = DKL.X + VB_KL(m0,v0,m,v,'Normal');
        end
    catch
        DKL.X = NaN;
    end
    m0 = out.options.priors.muX0;
    v0 = out.options.priors.SigmaX0;
    m = posterior.muX0;
    v = posterior.SigmaX0;
    DKL.X0 = VB_KL(m0,v0,m,v,'Normal');
else
    % first get prior predicted data
    priors = out.options.priors;
    pgx = zeros(out.dim.p,out.dim.n_t);
    for t=1:out.dim.n_t
        pgx(:,t) = VBA_evalFun('g',...
            [],priors.muPhi,out.u(:,t),out.options,out.dim);
    end
    efficiency.X = NaN;
    efficiency.X0 = NaN;
    efficiency.alpha = NaN;
    DKL.X = NaN;
    DKL.X0 = NaN;
    DKL.alpha = NaN;
end
if out.dim.n_phi > 0 % observation parameters
    efficiency.Phi = -out.suffStat.Sphi;
    m0 = out.options.priors.muPhi;
    v0 = out.options.priors.SigmaPhi;
    if ~out.options.OnLine
        m = posterior.muPhi;
        v = posterior.SigmaPhi;
    else
        m = posterior.muPhi(:,end);
        v = posterior.SigmaPhi{end};
    end
    DKL.Phi = VB_KL(m0,v0,m,v,'Normal');
else
    efficiency.Phi = NaN;
    DKL.Phi = NaN;
end
if out.dim.n_theta > 0 % evolution parameters
    efficiency.Theta = -out.suffStat.Stheta;
    m0 = out.options.priors.muTheta;
    v0 = out.options.priors.SigmaTheta;
    if ~out.options.OnLine
        m = posterior.muTheta;
        v = posterior.SigmaTheta;
    else
        m = posterior.muTheta(:,end);
        v = posterior.SigmaTheta{end};
    end
    DKL.Theta = VB_KL(m0,v0,m,v,'Normal');
else
    efficiency.Theta = NaN;
    DKL.Theta = NaN;
end


% get micro-time hidden-states
try
    [MT_x,MT_gx,microTime,sampleInd] = ...
        VBA_microTime(posterior,u,out);
catch
    MT_x = [];
    MT_gx = [];
    microTime = [];
    sampleInd = [];
end

% get residuals: data noise
dy.dy = out.suffStat.dy(:);
dy.m = mean(dy.dy);
dy.v = var(dy.dy);
[dy.ny,dy.nx] = hist(dy.dy,10);
dy.ny = dy.ny./sum(dy.ny);
d = diff(dy.nx);
d = abs(d(1));
dy.d = d;
spgy = sum(exp(-0.5.*(dy.m-dy.nx).^2./dy.v));
dy.grid = dy.nx(1):d*1e-2:dy.nx(end);
dy.pg = exp(-0.5.*(dy.m-dy.grid).^2./dy.v);
dy.pg = dy.pg./spgy;
if  ~out.options.binomial
    shat = posterior.a_sigma(end)./posterior.b_sigma(end);
    spgy = sum(exp(-0.5.*shat.*dy.nx.^2));
    dy.pg2 = exp(-0.5.*shat.*dy.grid.^2);
    dy.pg2 = dy.pg2./spgy;
end

% get residuals: data noise
dx.dx = out.suffStat.dx(:);
if ~isempty(dx.dx)
    dx.m = mean(dx.dx);
    dx.v = var(dx.dx);
    [dx.ny,dx.nx] = hist(dx.dx,10);
    dx.ny = dx.ny./sum(dx.ny);
    d = diff(dx.nx);
    d = abs(d(1));
    dx.d = d;
    spgy = sum(exp(-0.5.*(dx.m-dx.nx).^2./dx.v));
    dx.grid = dx.nx(1):d*1e-2:dx.nx(end);
    dx.pg = exp(-0.5.*(dx.m-dx.grid).^2./dx.v);
    dx.pg = dx.pg./spgy;
    ahat = posterior.a_alpha(end)./posterior.b_alpha(end);
    spgy = sum(exp(-0.5.*ahat.*dx.nx.^2));
    dx.pg2 = exp(-0.5.*ahat.*dx.grid.^2);
    dx.pg2 = dx.pg2./spgy;
end

% get posterior correlation matrix (ODE limit)
try
    if  ~out.options.binomial && size(posterior.a_sigma,2) > 1 % online version
        C0 = zeros(out.dim.n+out.dim.n_theta+out.dim.n_phi);
    else
        try
            try
                C0 = abs(cov2corr(out.suffStat.ODE_posterior.SigmaPhi));
            catch
                C0 = abs(cov2corr(...
                    out.options.init.out.suffStat.ODE_posterior.SigmaPhi));
            end
        catch
            C0 = abs(cov2corr(posterior.SigmaPhi));
        end
    end
    tick = [0];
    ltick = [];
    ticklabel = cell(0,0);
    if out.dim.n_phi > 0
        ltick = [ltick,tick(end)+out.dim.n_phi/2];
        tick = [tick,out.dim.n_phi];
        ticklabel{end+1} = 'phi';
    end
    if out.dim.n_theta > 0
        ltick = [ltick,tick(end)+out.dim.n_theta/2];
        tick = [tick,tick(end)+out.dim.n_theta];
        ticklabel{end+1} = 'theta';
    end
    if out.dim.n > 0 && out.options.updateX0
        ltick = [ltick,tick(end)+out.dim.n/2];
        tick = [tick,tick(end)+out.dim.n];
        ticklabel{end+1} = 'x0';
    end
    tick = tick +0.5;
    tick = tick(2:end-1);
    ltick = ltick + 0.5;
catch
    nn = out.dim.n_theta + out.dim.n_phi;
    if out.dim.n > 0 && out.options.updateX0
        nn = nn + out.dim.n;
    end
    C0 = sparse(nn,nn);
    ltick = nn/2 + 0.5;
    tick = [];
    ticklabel{1} = 'x0';
end

% get posterior correlation matrix (SDE)
if ~isempty(dx.dx)
    S = zeros(size(C0));
    ind = 0;
    if out.dim.n_phi > 0
        if iscell(posterior.SigmaPhi) % online version
            SP = posterior.SigmaPhi{end};
        else
            SP = posterior.SigmaPhi;
        end
        S(1:out.dim.n_phi,1:out.dim.n_phi) = SP;
        ind = out.dim.n_phi;
    end
    if out.dim.n_theta > 0
        if iscell(posterior.SigmaTheta) % online version
            SP = posterior.SigmaTheta{end};
        else
            SP = posterior.SigmaTheta;
        end
        S(ind+1:ind+out.dim.n_theta,ind+1:ind+out.dim.n_theta) = SP;
        ind = ind + out.dim.n_theta;
    end
    if out.dim.n > 0 && out.options.updateX0
        if iscell(posterior.SigmaX0) % online version
            SP = posterior.SigmaX0{end};
        else
            SP = posterior.SigmaX0;
        end
        S(ind+1:ind+out.dim.n,ind+1:ind+out.dim.n) = SP;
    end
    C = abs(cov2corr(S));
end

if ~isempty(kernels.tgrid)
    diagnostics.kernels = kernels;
else
    diagnostics.kernels = [];
end
diagnostics.pgx = pgx;
diagnostics.efficiency = efficiency;
diagnostics.DKL = DKL;
diagnostics.LLH0 = LLH0;
diagnostics.MT_x = MT_x;
diagnostics.MT_gx = MT_gx;
diagnostics.microTime = microTime;
diagnostics.sampleInd = sampleInd;
diagnostics.dy = dy;
diagnostics.dx = dx;
diagnostics.C0 = C0;
diagnostics.ltick = ltick;
diagnostics.tick = tick;
diagnostics.ticklabel = ticklabel;
if ~isempty(dx.dx)
    diagnostics.C = C;
end

if out.options.verbose
    fprintf(' OK.')
    fprintf('\n')
end


