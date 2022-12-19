%% function: fin_ml
function [d, sigma] = fin_ml_standalone(wsum, va, N, NJ, range, params)
        
    J1 = range(1);
    J2 = range(2);     
    Js = J1:J2;

    wsize = N;
    
    %wsum = wsum/max(wsum(:));

    % initial parameters
    lb = params.lb(1);
    ub = params.ub(1);

    dnew = params.init(1);
    switch params.omegamode
        case {'cov','lin'}
            B1 = (1 - 2.^(2*dnew-1))./(1-2*dnew);  
            signew2 = va/(2*B1*(2*pi)^(1-2*dnew)*sum(2.^((2*dnew-1)*(Js))));
        case 'sdf'
            sdf = bfn_finsdf(dnew,[J1,J2],NaN);
            signew2 = sum(wsum(Js)./sdf)/wsize;
    end

    % iteration
    it = 1;
    sigold2 = signew2/(1-params.abstol)+10;                    
    while ((abs(1-signew2/sigold2)>params.abstol)) && (it<=params.maxit) 
        sigold2 = signew2;
        if isempty(params.options)
            options = optimset('MaxFunEvals'    ,1000,...
                               'MaxIter'        ,500,...
                               'TolFun'         ,1e-10,...
                               'TolX'           ,1e-10,...
                               'Diagnostics'    ,'on',...
                               'Display'        ,'on');
        else
            options = params.options;
        end
        f = @(x)likelihood(x,wsum,NJ,[J1,J2],signew2);
        [est,fval] = fminbnd(f,lb,ub,options);
        dnew = est(1);

        switch params.omegamode
            case {'cov','lin'}
                B1 = (1 - 2.^(2*dnew-1))./(1-2*dnew);    
                signew2 = va/(2*B1*(2*pi)^(1-2*dnew)*sum(2.^((2*dnew-1)*(Js))));
            case 'sdf'
                sdf = bfn_finsdf(dnew,[J1,J2],NaN);
                signew2 = sum(wsum(Js)./sdf)/wsize; 
        end

        if params.verbose                            
            disp(strcat('Rep. ',num2str(it),...
                        ': Signew2= ',num2str(signew2),...
                        ': fval= ',num2str(fval),...
                        ', d= ',num2str(dnew)));
        end
        it = it+1;
    end

    if it>1
        d = dnew;
        sigma = signew2; 
    else
        d = NaN;
        sigma = NaN;
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
