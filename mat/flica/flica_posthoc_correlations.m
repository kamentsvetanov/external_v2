function sigs = flica_posthoc_correlations(outdir, des)

oldwarn = warning('query');
warning off stats:glmfit:IllConditioned
warning off stats:glmfit:IterationLimit

H = read_vest([outdir '/subjectCoursesOut.txt'])';

L = size(H,1);
fs = fieldnames(des);

bgIt = '';

fid = fopen([outdir '/significantComponents.txt'], 'w');

for fi=1:length(fs)
    fn = fs{fi};
    fprintf(fid,'%s: ', fn);
    
    if isnumeric(des.(fn))
        des.(fn) = struct('values',des.(fn));
    else
        % Some values
        assert(isnumeric(des.(fn).values))
    end
    if ~isfield(des.(fn), 'dithered'), des.(fn).dithered = des.(fn).values; end
    if ~isfield(des.(fn), 'style'), des.(fn).style = '.'; end
    
    isSig = nan(L,2);
    corrString = cell(L,2);
    
    for i=1:L
        outfile = [outdir '/correlation_' num2str(i-1) '_' fn '.eps'];
        fprintf('%s, component %g...', fn, i-1)
        x = des.(fn).dithered;
        y = H(i,:);
        
        clf
        if isfield(des.(fn), 'groups')
            for z = unique(des.(fn).groups(:))'
                plot(x(z==des.(fn).groups), y(z==des.(fn).groups), des.(fn).style)
                %plot(x(z==des.(fn).groups), y(z==des.(fn).groups), des.(fn).style{z}{:})
                hold all
            end
        else
            plot(x, y, des.(fn).style)
            hold on
        end
        if ~isfield(des.(fn), 'prettyName')
            des.(fn).prettyName = regexprep(fn, '_', ' ');
        end
        plot_annotate(...
		sprintf('%s vs. component %g subject-loadings',des.(fn).prettyName,i-1),...
		des.(fn).prettyName,...
		sprintf('Subject loading for component #%g', i-1))
        if isfield(des.(fn),'xtick')
            set(gca, 'xtick', des.(fn).xtick);
            if isfield(des.(fn),'xticklabel')
                set(gca, 'xticklabel', des.(fn).xticklabel)
            end
        end
        
        %% Anything else to superimpose?
        x = des.(fn).values;
        plot(xlim, [0 0], 'k')
        [beta,~,stats] = glmfit(x(:), y(:));
        corrString{i,1} = sprintf('p=%.2g', stats.p(2));
        if stats.p(2) < 0.05
            if stats.p(2) < 0.05/length(fs)/length(L)
                style = {'r-','linewidth',2};
                isSig(i,1) = stats.p(2);
                corrString{i,1} = ['<b>' corrString{i,1} '**</b>'];
            elseif stats.p(2) < 0.05/length(fs)
                style = {'r:','linewidth',2};
            else
                style = {'r:'};
            end
            plot(xlim, xlim*beta(2)+beta(1), style{:})
            plot(xlim, xlim*beta(2)+beta(1), style{:})
        end
        
        [beta,~,stats] = glmfit([x(:) x(:).^2], y(:));
        corrString{i,2} = sprintf('p=%.2g', stats.p(3));
        if stats.p(3) < 0.05
            if stats.p(3) < 0.05/length(fs)/length(L)
                style = {'r-','linewidth',2};
                isSig(i,2) = stats.p(3);
                corrString{i,2} = ['<b>' corrString{i,2} '**</b>'];
            elseif stats.p(3) < 0.05/length(fs)
                style = {'r:','linewidth',2};
            else
                style = {'r:'};
            end
            xlim;linspace(ans(1),ans(2),1000);
            plot(ans, ans*beta(2)+beta(1)+ans.^2*beta(3), style{:})
        end
        
        %% Save image output 
        fprintf(' EPS...')
        print('-depsc',outfile);
        % EPS -> PDF (also crops nicely)
        %dos(['epstopdf ' outfile ' && rm ' outfile bgIt]); if ans~=0, error 'epstopdf failed'; end
        % EPS -> PNG (doesn't crop, but doesn't matter for this?)
        fprintf(' PNG...')
        dos(['convert ' outfile ' ' regexprep(outfile, 'eps$', 'png') ' && rm ' outfile bgIt]); if ans~=0, error 'epstopdf failed'; end
        bgIt = ' &'; % Trust that the remaining ones will succeed -> faster
        fprintf('%s\n', [bgIt repmat(' done',1,isempty(bgIt))])
        
        %if isSig(i,:), fprintf(fid, ' %g', i); end
    end
    isSig(isnan(isSig)) = inf;
    isSig = min(isSig(:,1),isSig(:,2));
    [s,o] = sort(isSig);
    comma = ' ';
    for oo = o(isfinite(s))'
        fprintf(fid, '%s#%g (%s, %s)', comma, oo-1, corrString{oo,:});
        comma = ', ';
    end
    fprintf(fid, '\n');
end

warning(oldwarn)
fclose(fid);

