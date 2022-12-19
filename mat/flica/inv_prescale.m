% out = inv_prescale(in)
% A more stable version of inverse for positive-definite matrices.
% First removes the scaling of each row and column so that the diagonal
% elements are all 1, then inverts, then puts the scaling back.
function out = inv_prescale(in)

assert(all(diag(in)>0)) 
prescale = diag(diag(in).^-.5);

out = prescale*inv(prescale*in*prescale)*prescale;
