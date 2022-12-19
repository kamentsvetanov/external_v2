function Z = flica_Zmaps(M)
% Make spatial Z-stat maps

R = size(M.H,2);
K = length(M.X);

for k = 1:K
    lambda_R = M.lambda{k} .* ones(R,1);
    weight_L = sqrt(M.H.^2 * lambda_R);
    if ~isempty(M.W)
        weight_L = weight_L .* M.W{k}';
    end
        
    Z{k} = M.X{k} * diag(weight_L);
end
    
