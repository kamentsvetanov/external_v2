function [e] = designEfficiency(f_fname,g_fname,dim,options,u,flag)
% computes the design efficiency for param estimation or model comparison
% function [e] = designEfficiency(f_fname,g_fname,dim,options,u,flag)
% This function expects a state-space model of the form:
%   y_t = g(x_t,P,u_t)
%   x_t = f(x_t-1,P,u_t)
% where y is the experimental measure, u is the design control variable, x
% is the internal state of the system and P are the parameters of the
% evolution and observation functions.
% A model m is considered to be a set {f,g,priors}, where the priors
% include the dimensions of the model and some internal optional arguments.
% IN:
%   - f_fname/g_fname: the handles of the evolution/observation functions
%   - dim/options: [see VBA_NLStateSpaceModel.m]
%   - u: the history of experimental control variables (inputs) that
%   defines the design.
%   - flag: {'parameters'} or 'models'. This is because the design
%   efficiency can be optimized wrt parameter estimation or model
%   comparison. In the latter case, the entries f_fname, g_fname, dim and
%   options are cell arrays whose sizes is the number of models to be
%   compared.
% OUT:
%   - e: the design efficiency measure, for the the given set of parameters
%   (parameter estimation) or models (model comparison).

try,flag;catch,flag='parameters';end

switch flag
    
    case 'models'
        
        try,binomial=options{1}.binomial;catch,binomial=0;end
        
        nm = length(dim);
        if ~iscell(f_fname)
            f_fname0 = f_fname;
            f_fname = cell(nm,1);
            for j=1:nm
                f_fname{j} = f_fname0;
            end
        end
        if ~iscell(g_fname)
            g_fname0 = g_fname;
            g_fname = cell(nm,1);
            for j=1:nm
                g_fname{j} = g_fname0;
            end
        end
        fprintf(1,'\n')
        fprintf(1,['model       '])
        for j=1:nm % loops over models
            % get prior predictive density
            fprintf(1,'\b\b\b\b\b\b')
            fprintf(1,[num2str(j),'/',num2str(nm),'...'])
            [muy{j},Vy{j}] = getLaplace(...
                u,f_fname{j},g_fname{j},dim{j},options{j});
        end
        fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b\b\b')
        fprintf(1,[' : OK.'])
        fprintf(1,'\n\n')
        
        % computes Jensen-Shannon divergence of models
        ps = ones(nm,1);
        ps = ps./sum(ps);
        [DJS,b] = JensenShannon(muy,Vy,ps,binomial);
        e = DJS;
        
    case 'parameters'
        
        try,binomial=options.binomial;catch,binomial=0;end
        
        % get prediced model parameter precision matrix
        [muy,Vy,iVp] = getLaplace(u,f_fname,g_fname,dim,options);
        % compute the trace of predicted posterior variance
        e = -trace(pinv(iVp));
        
        
end


