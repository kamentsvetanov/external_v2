% Print the current figure to a PNG file.
%
% First tries print -dpng outfile, then tries printing an EPS
% and converting that.  If that fails too, it gives up with a warning,
% rather than crashing!
%
% Optional return value: which method worked (if any).
function worked = print_png(outfile)

assert(~isempty(regexp(outfile, '\.png$')))

try
    print('-dpng', outfile)
    worked = 1;
catch
    lasterr
    warning 'Failed to print PNG... falling back to EPS version'
    try
        outfile(end-3:end) = '.eps';
        print('-depsc',outfile)
        dos(['convert ' outfile ' ' regexprep(outfile, 'eps$', 'png') ' && rm ' outfile]); if ans~=0, error 'epstopdf failed'; end
        dos(['epstopdf ' outfile '&& convert ' regexprep(outfile, 'eps$', 'pdf ') regexprep(outfile, 'eps$', 'png') ' && rm ' outfile ' ' regexprep(outfile, 'eps$', 'pdf')]); if ans~=0, error 'epstopdf failed'; end
        worked = 2;
    catch
        lasterr
        warning 'Also failed to make PCbars.eps -- giving up.'
        worked = 0
    end
end

if nargout<1, clear worked; end
