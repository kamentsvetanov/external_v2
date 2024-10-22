function [fx,J,dfdP,d2fdxdP] = VBA_evalFun(flagFun,Xt,P,ut,options,dim)
% smart wrapper for evolution and observation functions
% function [fx,J,dfdP,d2fdxdP] =
% VBA_evalFun(flagFun,posterior,u,options,dim)
%
% This function evaluates the evolution or observation function (eof) at
% the mode of the posterior densities of hidden states and parameters. It
% also outputs the derivatives wrt the states, the parameters, and the
% double derivatives wrt the states and the parameters (if necessary).
% NB: If the eof does not ouput the derivatives, VBA_evalFun calls a
% numerical derivation routine for evaluating it. You can specify variable
% output for the eof to be evaluated, ie [fx], [fx,dfdx], [fx,dfdx,dfdp] or
% [fx,dfdx,dfdp,d2fdxdp]. VBA_evalFun checks the existence of the output
% and numerically computes the missing derivatives.
%
% IN:
%   - flagFun: 'g' (observation) or 'f' (evolution).
%   - Xt: the hidden states value at which the eof is evaluated
%   - P: the parameters value at which the eof is evaluated
%   - ut: the matrix of inputs to the system
%   - options: the options structure (this contains the eof names)
%   - dim: the dim structure
%   [ see VBA_NLStateSpaceModel.m ]
% OUT:
%   - fx: the eof evaluated at posterior.muX(:,t) and
%   posterior.muTheta/posterior.muPhi
%   - J: Jacobian (derivatives of the eof wrt to hidden states)
%   - dfdP: the derivatives of the eof wrt the parameters
%   - d2fdxdP: the double derivatives of the eof wrt the hidden states and
%   the parameters.

% Number of output arguments?
nout0 = nargout;

% Get input arguments of the eof
switch flagFun
    case 'f'
        fname = options.f_fname;
        in = options.inF;
        d = [dim.n,dim.n_theta,dim.n];
        nout = options.f_nout;
        N = options.decim;
    case 'g'
        fname = options.g_fname;
        in = options.inG;
        d = [dim.n,dim.n_phi,dim.p];
        nout = options.g_nout;
        N = 1;
end

% Evaluate function, Jacobian and gradients
[fx,J,dfdP,d2fdxdP] = EvalFunN(...
    fname,Xt,P,ut,in,dim,nout,nout0,options,d,N);

% Check Jacobian and gradients?
if options.checkGrads && ...
        ~isequal(fname,@VBA_odeLim) && ...
        ~isequal(fname,@VBA_smoothNLSS)
    mayPause = 0;
    if ~isempty(Xt) && nout > 1
        J2 = numericDiff(...
            @EvalFunN,2,fname,Xt,P,ut,in,dim,nout,nout0,options,d,N);
        [hf(1)] = VB_displayGrads(...
            J,J2,'Jacobian',fname,flagFun);
        mayPause = 1;
    end
    if ~isempty(P) && nout > 2
        dfdP2 = numericDiff(...
            @EvalFunN,3,fname,Xt,P,ut,in,dim,nout,nout0,options,d,N);
        [hf(2)] = VB_displayGrads(...
            dfdP,dfdP2,'Gradients wrt parameters',fname,flagFun);
        mayPause = 1;
    end
    if mayPause
        pause
        close(setdiff(hf,0))
    end
end


function [fx,J,dfdP,d2fdxdP] = EvalFunN(...
    fname,Xt,P,ut,in,dim,nout,nout0,options,d,N)
% loops over micro-time and evaluates function, Jacobian and gradients
if options.microU && N > 1
    ut = reshape(ut,dim.u,N);
else
    ut = repmat(ut,1,N);
end
[fx,J,dfdP,d2fdxdP] = ...
    EvalFun(fname,Xt,P,ut(:,1),in,dim,nout,nout0,options,d);
for i=2:N
    [fx,dfdx,dfdp,d2fdxdp] = ...
        EvalFun(fname,fx,P,ut(:,i),in,dim,nout,nout0,options,d);
    if ~isempty(dfdx)
        J = J*dfdx;
    end
    if ~isempty(dfdp)
        dfdP = dfdp + dfdP*dfdx;
    end
    if ~isempty(d2fdxdp)
        d2fdxdP = reshape(...
            dfdx*reshape(d2fdxdp,d(1),d(2)*d(3)) + ...
            J*reshape(d2fdxdP,d(1),d(2)*d(3)),...
            d(1),d(2),d(3));
    end
end


function [fx,dfdx,dfdp,d2fdxdp] = EvalFun(...
    fname,Xt,P,ut,in,dim,nout,nout0,options,d)
% evaluates function, Jacobian and gradients (numerically if necessary)
dfdx = [];
dfdp = [];
d2fdxdp = [];
deriv = [1 1 1];
switch nout
    case 4
        [fx,dfdx,dfdp,d2fdxdp] = feval(fname,Xt,P,ut,in);
        if isempty(dfdx)
            deriv(1) = 0;
        end
        if isempty(dfdp)
            deriv(2) = 0;
        end
        if isempty(d2fdxdp)
            deriv(3) = 0;
        end
    case 3
        [fx,dfdx,dfdp] = feval(fname,Xt,P,ut,in);
        deriv(3) = 0;
        if isempty(dfdx)
            deriv(1) = 0;
        end
        if isempty(dfdp)
            deriv(2) = 0;
        end
    case 2
        [fx,dfdx] = feval(fname,Xt,P,ut,in);
        deriv(2:3) = 0;
        if isempty(dfdx)
            deriv(1) = 0;
        end
    case 1
        [fx] = feval(fname,Xt,P,ut,in);
        deriv(1:3) = 0;
end
if ~deriv(1) && dim.n>0 && nout0>=2
    dfdx = numericDiff(fname,1,Xt,P,ut,in);
end
if d(2) > 0
    if ~deriv(2) && nout0>=3
        dfdp = numericDiff(fname,2,Xt,P,ut,in);
    end
    if ~deriv(3) && nout0==4 && ~options.ignoreMF && dim.n > 0
        d2fdxdp = numericDiff(@numericDiff,3,fname,2,Xt,P,ut,in);
        d2fdxdp = reshape(d2fdxdp,d(1),d(2),d(3));
    end
end


