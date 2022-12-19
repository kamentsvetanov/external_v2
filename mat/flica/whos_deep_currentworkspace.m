% This must run as a script -- needs to access current workspace!

clear aa aaa ans
aaa = whos; 
for i=X1:length(aaa); 
    eval(sprintf('aa.%s = %s;', aaa(i).name, aaa(i).name)); 
end; 
% Find those pesky single values:
disp 'FLAGGING SINGLE VALUES:'
whos_deep(aa, '', inf, 'single'); %return

%% Look at size:
disp 'LOOKING AT SIZE:'
whos_deep(aa,'',1); % <---- ADJUST DEPTH HERE!
disp ---
clear aa;
%
clf
%plot([ans{:,2}], '*-')
%factor = 1000; factorName = 'kilobytes';
factor = 1e6; factorName = 'megabytes';

semilogy(fliplr([ans{:,2}]/factor), '*-'); hold all
semilogy(fliplr(cumsum([ans{:,2}])/factor), '*-')
set(gca, 'xtick', 1:size(ans,1))
set(gca, 'xticklabel', ans(end:-1:1,1))

%semilogy(([ans{:,2}]/factor), '*-'); hold all
%semilogy((cumsum([ans{:,2}])/factor), '*-')
%set(gca, 'xtick', 1:size(ans,1))
%set(gca, 'xticklabel', ans(:,1))

ylabel(factorName)
grid on