
%% function : fin_mr
function [d, sigma] = fin_mr_standalone(wsum, va, N, NJ, range, params)

    J1 = range(1);
    J2 = range(2); 
    Js = J1:J2;

    wsize = N; 

    % initial parameters
    lb = params.lb(1);
    ub = params.ub(1);

    % estimation
    if isempty(params.options)
        options = optimset('MaxFunEvals'    ,300,...
                           'MaxIter'        ,50,...
                           'TolFun'         ,1e-10,...
                           'TolX'           ,1e-10,...
                           'Diagnostics'    ,'off',...
                           'Display'        ,'off');                      
    else
        options = params.options;
    end            
    f = @(x)likelihood_reduced(x,wsum,NJ,N,[J1,J2]);
    est = fminbnd(f,lb,ub,options);
    d = est(1);

    switch params.omegamode
        case 'sdf'
            sdf   = bfn_finsdf(d,[J1,J2],NaN);
            sigma = sum(wsum(Js)./sdf)/wsize; 
        case 'cov'            
            B1    = (1 - 2.^(2*d-1))./(1-2*d);    
            sigma = va/(2*B1*(2*pi)^(1-2*d)*sum(2.^((2*d-1)*(Js))));
    end                      
end

%% function : likelihood
function L = likelihood(x,wsum,Nj,range,sig)

    d   = x(1);  
    
    sdf = bfn_finsdf(d,range,NaN); 
    Js  = (range(1):range(2))';
    S   = sum(wsum(Js)./sdf);
    L   = sum(Nj(Js)'.*log(sdf)) + S/sig;
    
end

%% function : likelihood_reduced
function L = likelihood_reduced(x,wsum,Nj,N,range)

    d   = x(1);  
    
    sdf = bfn_finsdf(d,range,NaN); 
    Js  = (range(1):range(2))';
    S   = sum(wsum(Js)./sdf);    
    L   = N*log(S/N) + sum(Nj(Js)'.*log(sdf));
    
end

function Wq = getWq(W,q)

    J = length(W);
    
    Wq = {};
    for j=1:J
        Wj    = W{j};
        Wq{j} = squeeze(Wj(:,q));
    end

end
