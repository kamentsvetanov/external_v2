%%%% Example on how to use the bramila_ttest2_np function
%
%   Enrico Glerean - enrico.glerean@aalto.fi - 2014-01-13
%
%%%%

%% DATA
% Let's suppose we have data for 50 patients and 48 controls, let's assume
% the data as a gaussian variable with higher mean for the controls in half of the
% datapoints. We consider 1000 datapoints for each subject. For each
% subject we also have the age as a confounding factor, here it is simulated as a
% random integer between 18 and 58


dataPatients=randn(1000,50);
agePatients=round(40*rand(1,50)+18);

dataControls_part1=randn(500,48)+1;
dataControls_part2=randn(500,48);

dataControls=[
    dataControls_part1; 
    dataControls_part2
    ];

ageControls=round(40*rand(1,48)+18);

% we merge both datasets, 1 column per subject
data=[dataControls dataPatients];
age=[ageControls agePatients];
temp=data;
% we regress out the confounding variable age using linear regression
for n=1:size(data,1)    % for each data point
    y=data(n,:);
    [B,BINT,R]=regress(y',[age' ones(length(age),1)]);
    data(n,:)=R; % we keep only the residual
end

% we specify the design: 48 controls and 50 patients
design=[ones(1,48) 2*ones(1,50)];

% we use the paralell computing toolbox
matlabpool open

% we run the ttest2
stats=bramila_ttest2_np(data,design,5000);

% we are interested in the cases where controls > patients, i.e. positive
% tvals, i.e. right tail of our distribution, i.e. first column of stats.pvals. 
% We control for multiple comparisons using the flase discovery rate procedur 
% as introduced by Benjamini and Hochberg (1995)

pvals_corrected=mafdr(stats.pvals(:,1),'BHFDR','true');

H=find(pvals_corrected<0.05); % indices of the comparisons where we can reject the null hypothesis 









