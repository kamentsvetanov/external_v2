function [data, label, run] = generateSpiralDataWithLabels(Nc,Ns,h,r,option)
% Generate 3D, Nc classes data, each with Ns observation

if nargin < 5
    option.display = 1;
end

if nargin < 1
    Nc = 5;
    Ns = 200;
    h = 10;
    r = 2;
    option.display = 1;
end

% Come up with the mu and sigma for each Gaussian
degree_sepa = linspace(0,360,Nc+1);
rad_sepa = degree_sepa(1:end-1)'*pi/180; % make it radian
h_sepa = linspace(0,h,Nc)';

Mu = [r*cos(rad_sepa) r*sin(rad_sepa) h_sepa];

% If you want to input each Gaussian model's parameter manually, just do it
% here.
Sigma = zeros(3,3,Nc);
n = zeros(Nc,1);
for i = 1:Nc
    Sigma(:,:,i) = eye(3);
    n(i) = Ns;
end

% Generate the Gaussian distributed data
% The way the data is added is NOT efficient yet, but it's OK
label = [];
data = [];
run = [];
for i = 1:Nc
    tmp = mvnrnd(Mu(i,:), Sigma(:,:,i), n(i));
    data = [data; tmp];
    label = [label; i*ones(n(i),1)];
    run = [run; (1:n(i))'];
end

if option.display == 1
    % figure; scatter3(Mu(:,1), Mu(:,2), Mu(:,3), 30, h_sepa/h);
    % Plot the data set
    colorList = generateColorList(Nc);
    colorPlot = colorList(label,:);
    figure; scatter3(data(:,1), data(:,2), data(:,3), 30, colorPlot,'filled');
end
