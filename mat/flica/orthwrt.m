% Aorth = orthwrt(A, B)
% Return A orthogonalized wrt B; you should probably demean B first!
% Multiple columns in A: [Aorth1 Aorth2 Aorth3] = orthwrt([A1 A2 A3],B)
% Multiple columns in B: recursively calls itself to orth wrt all cols of B
% simultaneously.
function A = orthwrt(A, B)

if numel(B)==0, return; end
%assert(all(rms(B,1)>0)) % orth wrt 0 is a BAD idea (could skip redundant columns?)
if ~all(rms(B,1)>0)
    warning 'All-zero column(s) removed!'
    B(:,rms(B,1)==0) = []; 
end

if size(A,1) ~= size(B,1) % size mismatch
    size(A)
    size(B)
    error 'First dimensions must match!'
end
assert(size(A,1) > size(B,2)) % result will be all zeros (or error)

if all(rms(demean(B),1)>0) && any(abs(mean(B)./rms(B,1))>1e-12)
    warning 'No demeaning vector, but B columns are not demeaned -- is that a mistake?'
end

Aorig = A; % So we can assess remaining scale below

while size(B,2)>0
    % Eliminate one B vector at a time
    A = orthwrt_vector(A, B(:,1));
    B = desomething(B,1,'scalerms'); % So we can assess remaining scale below
    B = orthwrt_vector(B(:,2:end), B(:,1)); % To avoid reintroducing correlation later
    
    toosmall = rms(B,1) < 1e-12;
    if any(toosmall)
        warning 'orthwrt:redundantB' 'Redundant columns of B... eliminating.'
        B = B(:,~toosmall);
    end
end

toosmall = rms(A,1)./rms(Aorig,1) < 1e-12;
if any(toosmall)
    warning 'Some columns of A close to zero -- setting to exactly zero!'
    A(:,toosmall) = 0;
end

return

function Aorth = orthwrt_vector(A, B)
Aorth = A - B*(B'*A)/(B'*B);
return
