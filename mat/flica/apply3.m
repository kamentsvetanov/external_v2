% OUT = apply3(FCN, INPUT)
%
% Apply FCN to each layer of INPUT, so that OUT(:,:,i) = FCN(INPUT(:,:,i)).
function out = apply3(fcn, input)

for i=1:size(input,3)
    out(:,:,i) = fcn(input(:,:,i));
end