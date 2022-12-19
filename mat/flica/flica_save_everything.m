function flica_save_everything(outdir, M, fileinfo)
% Save everything important for the model
% In the same style as the output of cpHere.
% What it DOESN'T do is generate any images!
% Those can be generated after-the-fact from the saved data.
%

K = length(M.X);
L = size(M.H, 1);
R = size(M.H, 2);

disp 'Saving small files...'

%% Save the handy short names to a text file
fid = fopen([outdir 'shortNames.txt'], 'w'); assert(fid>0);
for k=1:K
    try
        fprintf(fid, 'mi%g: %s\n', k, fileinfo.shortNames{k});
    catch  % fileinfo.shortNames{k} might be missing or wrong, so don't crash
        fprintf(fid, 'mi%g: Modality%g\n', k, k);
    end
end
fclose(fid);

%% Check it's "standardized" (should store W somewhere if it isn't)
assert(isempty(M.W) || all(all(vertcat(M.W{:})==1)))

%% Save H matrix to a text (or vest?) file
save_vest(M.H', [outdir 'subjectCoursesOut.txt'])

%% Save lambda matrices too -- useful for diagnosis actually.
clear tmp*
for k=1:K
    tmp(:,k) = makesize(M.lambda{k}.^-0.5, [R 1]) / fileinfo.transforms{k,3}; %#ok<AGROW>
end
save_vest(tmp, [outdir 'noiseStdevOut.txt']);
save_vest(tmp.^-2, [outdir 'noisePrecisionOut.txt']); % A more useful plot to find extremely low-noise subjects (likely duplicate data!)

clf
plot(0:R-1, tmp, '.-')
set(gca, 'xgrid', 'on')
plot_drawdiag 1 horzk--
plot_annotate('Noise estimates by subject','Subject index','Noise standard deviation')
print_png([outdir '/noiseStdev.png']);
clear tmp*



%% Save summary information to appropriate files
% M.H_PCs (absolute/relative info from each modality) or weight (total variance explained)
save_vest_pretty([(0:L-1)' round(desomething(M.H_PCs,1,'scalesum')'*100)], [outdir '/subjectCoursesFractions.txt'])

%%
L = size(M.H_PCs,2);
clf
pc = desomething(M.H_PCs(1:end-1,:),1,'scalesum');
barh(0:L-1, pc', 1, 'stacked')
axis ij; axis([0 1 -0.5 L-0.5])
alpha=0.7;
colormap(jet*alpha+1-alpha)
hold on
plot([zeros(1,L+1);ones(1,L+1)], [1;1]*(-.5:L-.5),'k');
%plot([1;1]*sum(pc(1:3,:)),[-.5:L-1.5;.5:L-.5],'k','linewidth',3)
dividers=[];
for d = dividers(:)'
    plot(sum(pc(1:d,:)),0:L-1,'kd','linewidth',2)
end
hold off
plot_annotate('Relative weight of modalities in each component','Fraction of weight','Component index')

outfile = [outdir '/PCbars.png'];
print_png(outfile);

%%
subjDom = max(M.H'.^2) ./ sum(M.H'.^2);
clf
plot(0:L-1, subjDom, '*-')
null = randn(R,1000);
null = max(null.^2)./sum(null.^2);
plot_drawdiag(prctile(null, [95]), 'horzr--')
plot_drawdiag(prctile(null, [100-5/L]), 'horzr')
plot_annotate('Components dominated by a single subject', 'Component number', 'Fraction of energy from max subject')
set(gca, 'xgrid', 'on')
set(gca, 'xtick', 0:5:L)

outfile = [outdir '/subjectDominance.png'];
print_png(outfile);

%% Save free energy plot
clear tmp*
tmp = [1:length(M.F_history); M.F_history];
tmp(:,isnan(tmp(2,:))) = [];
tmp(3,2:end) = diff(tmp(2,:)) ./ diff(tmp(1,:));
save_vest(tmp', [outdir 'convergenceRate.txt'])
loglog(tmp(1,:), tmp(3,:), '.-')
clear tmp*

%% Save H-course correlations plot

try
    clf
    irange = 0:length(order)-1;
    ds = @(x) desomething(x,1,'scalesum2');
    ds(Hmean_reordered')'*ds(Hmean_reordered');
    tril(ans) + triu(normalize_diagonal(inv(ans)));
    imagesc(irange,irange,ans, [-1 1])
    axis square
    colormap((hotcool))
    plot_annotate('Correlation\\NormPrecision of subject-courses')
    colorbar
    print_png([outdir '/Hcorr.png']);
catch
    lasterr
    warning 'Failed to make Hcorr.png for some reason -- see lasterr above.  Keeping calm and carrying on.'
end





























%% Convert X*W*rms(H)*sqrt(lambda) into pseudo-Z-stats
Z = flica_Zmaps(M);

%% Convert Z matrices back into input-sized files and save them
flica_save(Z, fileinfo, outdir);

%% Save things needed to do upsampling: transformations, {beta, mu, pi} or {betaprior}

M.transforms = fileinfo.transforms;
saveFields = {'beta', 'mu', 'pi','transforms','opts'};
save([outdir '/spatialPriors'],'-struct','M',saveFields{:},'-v7.3')

%% NOT GENERATED:
% lightbox: create (using scripts?) from saved & nifti files?
% lightbox2: create using scripts from saved mgh files
% correlation: plots from saved H & design

% explained_variance.txt: is misleading and not useful
% Hcorr.png and Hcorr_orthAge.png: can be generated from saved H
% PCbars.png: can be generated from saved H_PCs
% prefix.txt: redundant... but maybe should save options as a string?
% subjectCoursesCorrelations: requires design & saved H
% subjectCoursesDescriptions: ditto
% subjectCoursesPrecisions.txt: can be generated from saved H_PCs
% subjectCoursesTstats.txt: not used; [(0:L-1)' table2t table2p table2z]?

disp 'Done saving everything.'
