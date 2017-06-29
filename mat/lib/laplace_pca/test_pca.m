% Runs the experiments in Minka (2000).
% Written by Tom Minka

clear
global show_score
show_score = 1;

laplace_k = 0;
bic_k = 0;
rrn_k = 0;
rru_k = 0;
er_k = 0;
cv_k = 0;
ard_k = 0;

task = 3;

for iter = 1:1

if task == 3
  % experiment 3
  lambdas = [10:-2:2];
  true_k = 5;
  lambdas = [lambdas repmat(0.25, 1, 95)];
  n = 60;
elseif task == 1
  % experiment 1
  %lambdas = [10:-1:1];
  lambdas = [10:-2:2];
  true_k = 5;
  lambdas = [lambdas repmat(1, 1, 5)];
  n = 100;
elseif task == 2
  % experiment 2
  lambdas = [10:-2:2];
  true_k = 5;
  lambdas = [lambdas repmat(0.1, 1, 10)];
  n = 10;
else
  % pathological case
  lambdas = [10:-1:1];
  %lambdas = [lambdas 1];
  n = 10000;
end
v = diag(lambdas);
d = rows(v);
m = zeros(d,1);
data = randnorm(n, m, [], v)';

if 0
  figure(1)
  plot(1:length(lambdas), lambdas, '-')
  %title('True eigenvalues')
  v = axis;
  v(3) = 0;
  axis(v)
  set(gcf,'PaperPosition',[0.25 2.5 5 3.75])
  %print -dps true_spectrum.ps
  figure(2)
  m = mean(data,2);
  s = moment2(data,m);
  [v,e] = sorted_eig(s);
  e = diag(e);
  plot(1:length(e), e, '-')
  v = axis;
  v(3) = 0;
  v(4) = 11;
  axis(v)
  %title('Observed eigenvalues')
  set(gcf,'PaperPosition',[0.25 2.5 5 3.75])
  %print -dps obs_spectrum.ps
  return
end

kmax = min([d-1 n-2]);
if kmax > 10
  style = '-';
else
  style = 'o-';
end

[laplace_k(iter),s] = laplace_pca(data);
fprintf('Laplace = %d\n', laplace_k(iter))
if show_score
  figure(1)
  plot(1:length(s), s, style)
  xlabel('dimensionality k')
  set(gcf,'PaperPosition',[0.25 2.5 5 3.75])
  title('Laplace evidence')
end

[bic_k(iter),s] = bic_pca(data);
fprintf('BIC = %d\n', bic_k(iter))
if show_score
  figure(2)
  plot(1:length(s), s, style)
  xlabel('dimensionality k')
  set(gcf,'PaperPosition',[0.25 2.5 5 3.75])
  title('BIC evidence')
end

if 0
  [rrn_k(iter),s] = rrn_pca(data);
  fprintf('RRN = %d\n', rrn_k(iter))
  if show_score
    figure(3)
    plot(1:length(s), s, style)
    xlabel('dimensionality k')
    set(gcf,'PaperPosition',[0.25 2.5 5 3.75])
  end
end

if 0
  [rru_k(iter),s] = rru_pca(data);
  fprintf('RRU = %d\n', rru_k(iter))
  %er_k(iter) = er_pca(data)
  if show_score
    figure(4)
    plot(1:length(s), s, style)
    xlabel('dimensionality k')
    set(gcf,'PaperPosition',[0.25 2.5 5 3.75])
  end
end

if 0
  [cv_k(iter),s] = cv_pca(data);
  fprintf('CV = %d\n', cv_k(iter))
  if show_score
    figure(5)
    plot(1:length(s), s, style)
    xlabel('dimensionality k')
    title('Cross-validation score')
    set(gcf,'PaperPosition',[0.25 2.5 5 3.75])
  end
end

if 0
  ard_k(iter) = ard_pca(data);
  fprintf('ARD = %d\n', ard_k(iter));
end

end

%save results.mat laplace_k bic_k rrn_k rru_k er_k cv_k ard_k

results = [
  sum(laplace_k == true_k)
  sum(bic_k == true_k)
  sum(rrn_k == true_k)
  sum(rru_k == true_k)
  sum(er_k == true_k)
  sum(cv_k == true_k)
  sum(ard_k == true_k)
  ]'

return
d = rows(data);
obj = pca_density(zeros(d,k), 1, m);
obj = train(obj, data);
sum(logProb(obj, data))

[k,p_old] = laplace_pca(data);
[k,p] = laplace_pca(data);
max(abs(p-p_old))
