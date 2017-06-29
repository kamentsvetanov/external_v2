function F = ThreeGaussModel(x,freq)

% x(1) = gaussian amplitude
% x(2) = 1/(2*sigma^2)
% x(3) = centre freq of peak
% x(4) = amplitude of linear baseline
% x(5) = constant amplitude offset
% x(6) = amplitude middle peak?

A = 0.058; %originally 5/128

F = x(6)*exp(x(2)*(freq-x(3)) .* (freq-x(3))) +...
x(1)*exp(x(2)*(freq-x(3)-A).*(freq-x(3)-A))+...
x(1)*exp(x(2)*(freq-x(3)+A).*(freq-x(3)+A))+...
x(4)*(freq-x(3))+x(5);

% F = x(1)*(...
%        x(6)*exp(x(2)*(freq-x(3)).*(freq-x(3)))+exp(x(2)*(freq-x(3)+A).*(freq-x(3)+A))+exp(x(2)*(freq-x(3)-A).*(freq-x(3)-A))...
%     )...
%     +x(4)*(freq-x(3))+x(5);


end

%Single Gauss--------------
%gaussian amplitude * exponential of 1/(2*sigma^2) * (frequency - the
%centre frequency of the peak) + the amplitude of the linear baseline *
%(frequency - frequency of centre peak) + amplitude offset
%F = x(1)*exp(x(2)*(freq-x(3)).*(freq-x(3)))+x(4)*(freq-x(3))+x(5);

%Double Gauss--------------
%Gaussian amplitude * exponential of 1/(2*sigma^2) * frequency - frequency
%middle peak - offset) .* (frequency - centre peak  - offset) +...
%Gaussian amplitude * exponential of 1/(2*sigma^2) * frequency - frequency
%middle peak + offset) .* (frequency - centre peak  + offset) +...
%Amplitude of baseline * (frequency - centre frequency) + constant amplitude
%offset

%For triple Gauss we need to add an additional peak centred at peak
%frequency






