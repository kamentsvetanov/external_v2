% Demo script
% version 1.0


% Generate data
K_true=6 % number of sources
interval=[2:10]; % Number of IC components interval to search

% Generate mixed signals from artificial super Gaussian sources and mixing matrix
Atrue=randn(20,K_true);
Strue=sinh(randn(K_true,1000))/.1;
X=Atrue*Strue;



% - 1th Part - Finding best model wrt. number of components using BIC

%BIC
P=icaML_bic(X,interval,1);

[most_prop,most_prop_k]=max(P);
most_prop
most_prop_k=interval(most_prop_k)

% Draw
figure(1)
clf
bar(interval,P);
drawnow;



% - 2nd Part - finding ICA components using BIC estimat of K (number of source components)

% ICA
[S,Aica,U] = icaML( X , most_prop_k , [] , 1);
A = U(:,1:most_prop_k) * Aica;

% Draw first two IC components in scatterplot
figure(2)
clf
plot(S(1,:),S(2,:),'.')
drawnow;


