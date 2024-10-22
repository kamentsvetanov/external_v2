function svrobj = svr_trainer(xdata,ydata, c, epsilon, kernel, varargin)
% SVR  Utilises Support Vector Regression to approximate 
%           the functional relationship from which the
%           the training data was generated.
%  Function call:
%
%    svrobj = svr_trainer(x_train,y_train,c,epsilon,kernel,varargin);
%    The training data, x_train and y_train must be column vectors.
%
% alpha   - is weight of each support vector (generated by the function on training) 
% beta    - is a linear constant (like an offset in the svr model - also generated on training) 
% c       - is the cost of the 'training errors' (user parameter that must be set) 
% epsilon - is the magnitude of the 'insensitive' region (user parameter that must be set)
% ntrain  - is number of training vectors
% 
%   Example usage:
%
%    svrobj = svr_trainer(x_train,y_train,400,0.000000025,'gaussian',0.5);
%    y = svrobj.predict(x_test);
%
    if strcmp(kernel,'gaussian')
        lambda = varargin{1};
        kernel_function = @(x,y) exp(-lambda*norm(x.feature-y.feature,2)^2);
    elseif strcmp(kernel,'spline')
        kernel_function = @(a,b) prod(arrayfun(@(x,y) 1 + x*y+x*y*min(x,y)-(x+y)/2*min(x,y)^2+1/3*min(x,y)^3,a.feature,b.feature));
    elseif strcmp(kernel,'periodic')
        l = varargin{1};
        p = varargin{2};
        kernel_function = @(x,y) exp(-2*sin(pi*norm(x.feature-y.feature,2)/p)^2/l^2); 
    elseif strcmp(kernel,'tangent')
        a = varargin{1};
        c = varargin{2};
        kernel_function = @(x,y) prod(tanh(a*x.feature'*y.feature+c)); 
    end
    
    ntrain = size(xdata,1);

    alpha0 = zeros(ntrain,1);
    
    for i=1:ntrain
    	for j=1:ntrain
            xi(i,j).feature = xdata(i,:);
            xj(i,j).feature = xdata(j,:);
        end
    end
    
    % *********************************
    % Set up the Gram matrix for the 
    % training data.
    % *********************************
    M = arrayfun(kernel_function,xi,xj);
    M = M + 1/c*eye(ntrain);
    
    % *********************************
    % Train the SVR by optimising the  
    % dual function ie. find a_i's 
    % *********************************
    
    options = optimoptions('quadprog','Algorithm','interior-point-convex');
    H = 0.5*[M zeros(ntrain,3*ntrain); zeros(3*ntrain,4*ntrain)];
    figure; imagesc(M); title('Inner product between training data (ie. K(x_i,x_j)'); xlabel('Training point #'); ylabel('Training point #');
   
    lb = [-c*ones(ntrain,1);	zeros(ntrain,1);	zeros(2*ntrain,1)];
    ub = [ c*ones(ntrain,1);	2*c*ones(ntrain,1); c*ones(2*ntrain,1)];
    f = [ -ydata; epsilon*ones(ntrain,1);zeros(ntrain,1);zeros(ntrain,1)];
    z = quadprog(H,f,[],[],[],[],lb,ub,[],options);
    
    alpha = z(1:ntrain);
    figure; stem(alpha); title('Visualization of the trained SVR'); xlabel('Training point #'); ylabel('Weight (ie. alpha_i - alpha_i^*)');
    % *********************************
    % Calculate b 
    % *********************************
    for m=1:ntrain
        bmat(m) = ydata(m);
        for n = 1:ntrain
            bmat(m) = bmat(m) - alpha(n)*M(m,n);
        end
        bmat(m) = bmat(m) - epsilon - alpha(m)/c;
    end
    b = mean(bmat);
    
    % *********************************
    % Store the trained SVR.
    % *********************************
    svrobj.alpha = alpha;
    svrobj.b = b;
    svrobj.kernel = kernel_function;
    svrobj.train_data = xdata;
    svrobj.predict = @(x) cellfun(@(u) svr_eval(u),num2cell(x,2));


function f = svr_eval(x)
    f = 0;
    n_predict = size(x,1);
    for i=1:n_predict
    	sx(i).feature = x(i,:);
    end
    n_train = size(xdata,1);
    for i=1:n_train
    	sy(i).feature = xdata(i,:);
    end   
    
    for i=1:n_train
        f = f + svrobj.alpha(i)*kernel_function(sx(1),sy(i));
    end
    f = f + b;
    f = f/2;
end

end