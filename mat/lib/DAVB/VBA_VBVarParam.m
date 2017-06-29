function [posterior,suffStat] = ...
            VBA_VBVarParam(y,posterior,suffStat,dim,options)
% VB update of the precision hyperparameters
% function [posterior,suffStat] = ...
%             VBA_VBVarParam(y,posterior,suffStat,dim,options)
%
% This function computes the natural parameters of the Gamma variational
% posterior pdf of the variance parameters (measurement noise and
% stochastic innovations).

%---- Measurement noise precision ----%
if ~options.binomial
    
    % first store variance over predicted data
    suffStat.vy = suffStat.vy - posterior.b_sigma./posterior.a_sigma;
    
    % Posterior on measurement noise precision
    posterior.a_sigma = options.priors.a_sigma ...
        + 0.5*dim.p*dim.n_t;
    posterior.b_sigma = options.priors.b_sigma ...
        + 0.5*suffStat.dy2 ...
        + 0.5*suffStat.SXd2gdx2;
    if dim.n_phi > 0
        posterior.b_sigma = posterior.b_sigma ...
            + 0.5*suffStat.Sphid2gdphi2;
        if dim.n > 0
            posterior.b_sigma = posterior.b_sigma ...
                + 0.5*suffStat.Sphid2gdphidx;
        end
    end
    
    % update variance over predicted data (approx. fix)
    suffStat.vy = suffStat.vy + posterior.b_sigma./posterior.a_sigma;
    
    % Entropy term
    suffStat.Ssigma = gammaln(posterior.a_sigma) ...
        - log(posterior.b_sigma) ...
        + (1-posterior.a_sigma).*psi(posterior.a_sigma) ...
        + posterior.a_sigma;
    
end

%---- State noise precision ----%
if dim.n > 0 % only if hidden states
    
    % Posterior on stochastic innovations precision
    posterior.a_alpha = options.priors.a_alpha ...
        + 0.5*dim.n*dim.n_t;
    posterior.b_alpha = options.priors.b_alpha ...
        + 0.5*suffStat.dx2 ...
        + 0.5*suffStat.SXd2fdx2 ...
        + 0.5*suffStat.SXtdfdx ...
        + 0.5*suffStat.trSx;
    if dim.n_theta >0
        posterior.b_alpha = posterior.b_alpha...
            +0.5*suffStat.Sthetad2fdthetadx;
    end
    if posterior.b_alpha <=0
        posterior.b_alpha = posterior.b_alpha ...
            -0.5*suffStat.SXtdfdx;
    end
    
    % Entropy term
    suffStat.Salpha = gammaln(posterior.a_alpha) ...
        - log(posterior.b_alpha) ...
        + (1-posterior.a_alpha).*psi(posterior.a_alpha) ...
        + posterior.a_alpha;

end




