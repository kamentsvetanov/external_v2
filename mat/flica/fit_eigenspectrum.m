% Fit eigspectrum to the Wishart null distribution, in order to get DOF.
% 
% GAM = FIT_EIGENSPECTRUM(SPEC)
%   SPEC is an eigenspectrum (column vector), 
%   i.e. diag(S).^2 from [U,S,V] = svd(data).
% NOTE THE .^2 ABOVE!!!! 
% (XtX == USVVtStUt = USSUt)
% (eigs of XtX = eigs of USSUt = eigs of SS = diag(S).^2)
%
%   GAM(1) is gamma, the ratio of voxels/timepoints
%   so DOF = GAM(1) * length(SPEC).
%   GAM(2) is the scale (just a multiplicative factor used in the fit).
% 
% NOTE: any values of SPEC that are set to NaN are omitted and just not
% used in the fit.  This is handy for zeroing out the biggest eigenvalues
% to avoid fitting signal, and for zeroing out the smallest ones to ignore
% the effect of demeaning.
%
% Also:
% EST_SPEC = FIT_EIGENSPECTRUM(SPECLEN, GAM)
% will produce the null eigenspectrum of length SPECLEN and gamma GAM.
% GAM can also be [GAM SCALE], where SCALE scales the eigenspectrum.
%
function gam = fit_eigenspectrum(spec, gam)

if nargin==2
    assert(numel(spec)==1)
    gam = specest(spec, gam);
    return
end

% I guess a maximum-likelihood fit would be good, because with have the 
% PDF...
% But would you do that while excluding the top N points???

% Matlab's fminsearch allows you to set TolX, but it is always an absolute
% tolerance rather than relative, so it really only works sensibly when the
% parameters all have roughly the same scaling.  As a result, we prescale
% the spectrum to have a scale around 1 (rather than the 10^7 that Wooly
% keeps feeding me).

prescaleSpec = median(spec(isfinite(spec)));
spec = spec/prescaleSpec;

gam = [.1 1];
%exitflag = 0
%while exitflag == 0
%disp 'Nonlinear fit...'
%[gam junk exitflag] = fminsearch(@(gam) misfit(spec,gam), gam) %[0.5 spec(end/2)])
%end
gam = fminsearch(@(gam) misfit(spec,gam), gam);

gam = gam .* [1 prescaleSpec]; % Put the scaling back

    %misfit(spec, gam)

function ssd = misfit(spec, gam)

est = specest(length(spec), gam);

ssd = (spec-est).^2;
%ssd = abs(spec-est);
ssd = sum(ssd(isfinite(spec)));

function est = specest(speclen, gam)

if length(gam)==2
    scale = gam(2);
    gam = gam(1);
else
    scale = 1;
end

if gam<=0 || gam >= 1 || scale < 0, est=inf; return; end

% Note: in Johnstone[2001], gam <- 1/gam

stepSize = .001;
nurange = @(gam) (1-sqrt(gam)).^2 : stepSize : (1+sqrt(gam)).^2;
ifeta = @(gam) 1./(2*gam*pi*nurange(gam)).*sqrt( (nurange(gam)-min(nurange(gam))).*(max(nurange(gam))-nurange(gam)) );

nu = nurange(gam);
cif = cumsum(ifeta(gam))*stepSize;

xrange = linspace(0,1,speclen);
%xrange = conv(linspace(0,1,length(spec)+1), [.5 .5], 'valid'); % unbiased?
%for i = speclen:-1:1
%    est2(i) = nu(round(sum(cif<=xrange(i))));
%end

cif(end) = 1;
assert(all(isfinite([cif(:);nu(:);xrange(:)])))
est = interp1(cif, nu, xrange);
%assert(rms(est-est2)/rms(est)<1e-3))

est = flipud(est(:)) * scale;
