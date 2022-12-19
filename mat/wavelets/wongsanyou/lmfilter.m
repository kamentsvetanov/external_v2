function Y = lmfilter(X, d, varargin)
    % lmfilter -- Long memory filtering.
    %
    % DESCRIPTION
    %  It fast filters multiple time series with long memory filtering with
    %  the given memory parameters.
    %
    % USAGE
    %   Y = lmfilter(X, d, 'PropertyName', PropertyValue, ...)
    %
    % INPUTS
    %   X : a column vector or matrix of multiple time series.
    %   d : a scalar or vector of memory parameters.
    %
    %   OPTIONS
    %    1. method : the method of long memory filtering. Default is 'fip'.
    %       (1) 'fip' : Generation of a fractionally integrated process.
    %
    % OUTPUTS
    %   Y : a vector or matrix of the filtered time series with the same
    %       dimension with X.
    %
    % DETAILS
    %
    % EXAMPLE
    %   X = normrnd(0,1,1024,2);
    %   Y = lmfilter(X, 0.3);
    %
    % REFERENCES
    %   Achard, S., Bassett, D. S., Meyer-Lindenberg, A., & Bullmore, E.
    %   (2008). Fractal connectivity of long-memory networks. 
    %   Physical Review E, 77(3), 1-12.
    %
    %  
    % AUTHOR(S)
    %   Wonsang You (wsgyou@gmail.com)
    % 
    % CREATION DATE
    %   2012-02-10
    %
    % VERSION
    %   Version: 0.03
    %
    % ------------------------------------------------------------------
    %   Copyright (C) 2011-2012, Wonsang You
    %   The software lmfilter by Wonsang You is licensed under a Creative
    %   Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
    %
    
    T = size(X, 1); % the length of time series
    N = size(X, 2); % the number of time series

    params = struct('method','fip');
    params = parseArgs2(varargin,params);
    
    if length(d) ~= N
        d = d(1)*ones(1,N);
    end

    Y = zeros(size(X));
    switch params.method 
        case 'fip'
            for p = 1:N
                x = X(:,p);
                
                infi =100; h=zeros(infi+1,1);
                for s=0:infi
                    h(s+1)=gamma(s+d(p))/(gamma(s+1)*gamma(d(p)));
                end
                
                y = zeros(T,1);
                for t=1:T
                    y(t)=0;
                    for s=0:infi
                        if t > s
                            y(t)= y(t)+ h(s+1)*x(t-s);
                        end
                    end
                end               

                Y(:,p) = y(1:T);
            end
            
        otherwise
    end   
    
end
