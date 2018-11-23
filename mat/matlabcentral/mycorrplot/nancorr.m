%% Remove NaN and pass to corr function
%
% Rows containing NaN will be removed for each pair of variable, so sample size n might differ for each
% correlation.
% 
% Syntax :
%              [Rout  , Pout, Nout] = nancorr(X)
%              [Rout  , Pout, Nout] = nancorr(X, Y)
%
%              Nout : the numbe of valid paired (not NaN) used in correlation
%
% input X, Y could be array or table
% (usage as in corr(X) and corr(Y))
% 
% Wei-Ting Lin, 2015/10/30
% update 2015/11/06 : add output Nout
%%
function [Rout  , Pout, Nout] = nancorr(X, Y)

% Add compatibility to data type "table"
  if istable(X)
          X = X{:,strcmp(varfun(@class, X,'OutputFormat','Cell'), 'double')} ;         
  end
  if (nargin == 2) && istable(Y)
           Y = Y{:,strcmp(varfun(@class,X,'OutputFormat','Cell'), 'double')} ;  
  end
 
% Calculate R and Pvalue using corr 
if (nargin < 2) % corr(X)
            [n, p] = size(X);
        Rout = ones(p);
        Pout = ones(p);
        Nout = ones(p);
        for i = 1 : (p-1)
              for j = (i+1) : p
                      ind = ~any(isnan(X(:,[i,j])),2);
                      [r, pval] = corrcoef(X(ind,[i, j]));
                      Nout(i,j) = sum(ind);  Nout(j,i) = sum(ind);
                      Rout(i,j) = r(2);         Rout(j,i) = r(2);
                      Pout(i,j) = pval(2);     Pout(j,i) = pval(2);
              end
        end
else % corr(X,Y)        
                     [n1, p1] = size(X);
                     [n2, p2] = size(Y);
                     if n1~=n2
                             error('X and Y must have the same number of rows.')
                     end
            Rout = ones(p1, p2);
            Pout = ones(p1, p2);
            Nout = ones(p1, p2);
            for i = 1 : p1
                 for j = 1:p2
                      ind = ~any(isnan([X(:, i)  Y(:, j)]) ,2);
                      [r, pval] = corrcoef([X(ind, i)  Y(ind, j)]);
                      Nout(i,j) = sum(ind);
                      Rout(i,j) = r(2);        
                      Pout(i,j) = pval(2);     
                 end
            end
end

