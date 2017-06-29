function MRSplotnoalign(MRS_struct, specno)
%function MRSplotprepostalign(MRS_struct, specno)
% Plots pre and post alignment spectra in MRSLoadPfiles
% 110214:  Scale spectra by the peak _height_ of water
%          Plot multiple spectra as a stack - baselines offset
%            by mean height of GABA

%numspec = length(MRS_struct.gabaspec(:,1));
numspec = 2;

SpectraToPlot = [MRS_struct.gabaspec(specno,:)];

%Water scaling is touhg if we have no water scans! Comment out
% % Find Water amplitude max, across all Pfiles
% waterheight = abs(max(MRS_struct.waterspec(specno,:),[],2));
% waterheight = repmat(waterheight, [2 1]);
% heightrescale = repmat((1./waterheight), [1 length(MRS_struct.gabaspec(1,:))]);
% SpectraToPlot = SpectraToPlot .* heightrescale;

% Estimate baseline from between Glx and GABA
%specbaseline = mean(real(SpectraToPlot(1,17250:17650)),2);

%figure(99)
plot(MRS_struct.freq, real(SpectraToPlot));
%legendtxt = regexprep(MRS_struct.pfile{specno}, '_','-');
set(gca,'XDir','reverse');
set(gca,'XLim',[0 5]);


