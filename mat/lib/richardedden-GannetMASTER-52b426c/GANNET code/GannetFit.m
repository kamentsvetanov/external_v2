function [MRS_struct] = GannetFit(MRS_struct)
%function [MRS_struct] = MRSGABAfit(MRS_struct)
%
% Keep input and output structure names the same to add output data to
% the exisiting MRS data structure.
%Inputs:
% MRS_struct = structure with data loaded from MRSLoadPfiles

% Dec 09: based on FitSeries.m:  Richard's GABA Fitting routine
%     Fits using GaussModel
% Feb 10: Change the quantification method for water.  Regions of poor homogeneity (e.g. limbic)
%     can produce highly asymetric lineshapes, which are fitted poorly.  Don't fit - integrate
%     the water peak.
% March 10: 100301
%           use MRS_struct to pass loaded data data, call MRSGABAinstunits from here.
%           scaling of fitting to sort out differences between original (RE) and my analysis of FEF data
%           change tolerance on gaba fit
% 110308:   Keep definitions of fit functions in MRSGABAfit, rather
%               than in separate .m files
%           Ditto institutional units calc
%           Include FIXED version of Lorentzian fitting
%           Get Navg from struct (need version 110303, or later of
%               MRSLoadPfiles
%           rejig the output plots - one fig per scan.
% 110624:   set parmeter to choose fitting routine... for awkward spectra
%           report fit error (100*stdev(resid)/gabaheight), rather than "SNR"
%           can estimate this from confidence interval for nlinfit - need
%               GABA and water estimates

% 111111:   RAEE To integrate in Philips data, which doesn't always have
% water spectr, we need to add in referenceing to Cr... through
% MRS_struct.Reference_compound

%111214 integrating CJE's changes on water fitting (pre-init and revert to
%linear bseline). Also investigating Navg(ii)



FIT_LSQCURV = 0;
FIT_NLINFIT = 1;

fit_method = FIT_NLINFIT; %FIT_NLINFIT;
waterfit_method = FIT_NLINFIT;

GABAData=MRS_struct.gabaspec;
freq=MRS_struct.freq;
if strcmp(MRS_struct.Reference_compound,'H2O')
    WaterData=MRS_struct.waterspec;
end
MRS_struct.versionfit = '120222a';
disp(['GABA Fit Version is ' MRS_struct.versionfit ]);
fitwater=1;
numscans=size(GABAData);
numscans=numscans(1);

%110624
epsdirname = [ 'MRSfit_' datestr(clock,'yymmdd') ];


for ii=1:numscans
    MRS_struct.pfile{ii};
    %%%%%%%%%%%% GABA fit (Gaussian) %%%%%%%%%%%%%%%
    % Originally (RE version)  gabadata was rescaled to the max across all spectra
    % in the dataset.  Now I normalised the data with a const
    % ... work in progress
    % ...from GaussModel;
    % x(1) = gaussian amplitude
    % x(2) = 1/(2*sigma^2)
    % x(3) = centre freq of peak
    % x(4) = amplitude of linear baseline
    % x(5) = constant amplitude offset

    %Need to set the bounds from the data parameters...
    %MRS_struct.freq(17342)
    %MRS_struct.freq(18000)
    %Hard code it to fit from 2.75 ppm to 3.55 ppm
    z=abs(MRS_struct.freq-3.55);
    lowerbound=find(min(z)==z)
    z=abs(MRS_struct.freq-2.79);%2.75
    upperbound=find(min(z)==z)
    %lowerbound=17342;
    %upperbound=17961;
    %upperbound=18000;
    freqbounds=lowerbound:upperbound;
    plotbounds=(lowerbound-150):(upperbound+150);

    maxinGABA=max(real(GABAData(freqbounds)));
    %maxinGABA=1;

    % smarter estimation of baseline params, Krish's idea (taken from Johns
    % code; NAP 121211
    grad_points = (real(GABAData(ii,upperbound)) - real(GABAData(ii,lowerbound))) ./ ...
        (upperbound - lowerbound); %in points
    LinearInit = grad_points ./ (MRS_struct.freq(1) - MRS_struct.freq(2)); %in ppm
    constInit = (real(GABAData(ii,upperbound)) + real(GABAData(ii,lowerbound))) ./2;
    xval = [ 1:(upperbound-lowerbound+1) ];
    linearmodel = grad_points .* xval + GABAData(ii,lowerbound);
    %End copy code

    resnorm=zeros([numscans size(freqbounds,2)]);
    %residuals=resnorm;
    size(resnorm);


    %  GaussModelInit = [10*maxinGABA -90 3.026 0 0];
    % NP; but taken from Johns code, now initialise with parameters declared above
    GaussModelInit = [10*maxinGABA -90 3.026 LinearInit constInit]; %default in 110624

    %OLD INITS; WHY NOT CUT THESE OUT (NP)
    %GaussModelInit = [4.1314 -140.0000 3.0005 -0.8776 0.5684]; %from MINLSQ
    %GaussModelInit = [1 -140.0000 3.0005 -0.8776 0.5684]; %works
    %GaussModelInit = [maxinGABA -90 3.026 0 0]; %works
    %GaussModelInit = [ 1 -90 3.026 0 0]; %fails
    %GaussModelInit = [ 1 -90 3.026 -0.8776 0.5684]; %works

    lb = [0 -200 2.87 -40*maxinGABA -2000*maxinGABA]; %NP; our bounds are 0.03 less due to creatine shift
    ub = [4000*maxinGABA -40 3.12 40*maxinGABA 1000*maxinGABA];



    %NP; From Johns code, initialising steps, just copied over
    options = optimset('lsqcurvefit');
    options = optimset(options,'Display','off','TolFun',1e-10,'Tolx',1e-10,'MaxIter',1e5);
    nlinopts = statset('nlinfit');
    nlinopts = statset(nlinopts, 'MaxIter', 1e5);


    [GaussModelParam(ii,:),resnorm(ii), residg] = lsqcurvefit(@(xdummy,ydummy) GaussModel_area(xdummy,ydummy), ...
        GaussModelInit, ...
        freq(freqbounds),...
        real(GABAData(ii,freqbounds)), ...
        lb,ub,options);
    residg = -residg;

    if(fit_method == FIT_NLINFIT)
        %else  % it's FIT_NLINFIT
        GaussModelInit = GaussModelParam(ii,:);
        % 1111013 restart the optimisation, to ensure convergence

        for fit_iter = 1:100
            [GaussModelParam(ii,:), residg, J, COVB, MSE] = nlinfit(freq(freqbounds), real(GABAData(ii,freqbounds)), ... % J, COBV, MSE edited in
                @(xdummy,ydummy) GaussModel_area(xdummy,ydummy), ...
                GaussModelInit, ...
                nlinopts);
            MRS_struct.fitparams_iter(fit_iter,:,ii) = GaussModelParam(ii,:);
            GaussModelInit = GaussModelParam(ii,:);
            ci = nlparci(GaussModelParam(ii,:), residg,'covar',COVB); %copied over
        end
    end
    %NP end copy Johns code


    %NP; This bit below is now stated above, make sure our own changes are copied in as well
    %Bit below copied out
    %   if(fit_method == FIT_LSQCURV)
    %
    %       options = optimset('lsqcurvefit');
    %       options = optimset(options,'Display','off','TolFun',1e-10,'Tolx',1e-10,'MaxIter',1e5);
    %
    %       % pass function handle to GaussModel to lsqcurvefit
    %       [GaussModelParam(ii,:),resnorm(ii), residg] = lsqcurvefit(@(xdummy,ydummy) GaussModel_area(xdummy,ydummy), ...
    %           GaussModelInit, ...
    %           freq(freqbounds),...
    %           real(GABAData(ii,freqbounds)), ...
    %           lb,ub,options);
    %       residg = -residg;
    %
    %   else  % it's FIT_NLINFIT
    %       nlinopts = statset('nlinfit');
    %       nlinopts = statset(nlinopts, 'MaxIter', 1e5);
    %
    %       [GaussModelParam(ii,:), residg,J,COVB,MSE] = nlinfit(freq(freqbounds), real(GABAData(ii,freqbounds)), ...
    %           @(xdummy,ydummy) GaussModel_area(xdummy,ydummy), ...
    %           GaussModelInit, ...
    %           nlinopts);
    %       ci = nlparci(GaussModelParam(ii,:), residg,'covar',COVB)
    %   end
    %
    GABAheight = GaussModelParam(ii,1);
    % FitSTD reports the standard deviation of the residuals / gaba HEIGHT
    %MRS_struct.GABAFitError(ii)  =  (ci(1,2)-ci(1,1))/sum(ci(1,:),2)*100;
    MRS_struct.GABAFitError(ii)  =  100*std(residg)/GABAheight;
    % x(2) = 1/(2*sigma^2).  Convert from points to Hz

    % area under gaussian is a * (2 * pi * sigma^2)^(1/2), and
    % GaussModelParam(:,2) = 1 / (2 * sigma^2)
    % This sets GabaArea as the area under the curve.
    MRS_struct.gabaArea(ii)=GaussModelParam(ii,1)./sqrt(-GaussModelParam(ii,2))*sqrt(pi);

    sigma = ( 1 / (2 * (abs(GaussModelParam(ii,2)))) ).^(1/2);
    MRS_struct.GABAFWHM(ii) =  abs( (2* 42.576*3) * sigma);
    MRS_struct.GABAModelFit(ii,:)=GaussModelParam(ii,:);

    if(ishandle(102))
        close(102)
    end
    fignum = 102;
    h=figure(fignum);
    figTitle = ['GannetFit Output'];
    set(gcf,'Name',figTitle,'Tag',figTitle, 'NumberTitle','off');
    % GABA plot
    subplot(2, 2, 1)
    % find peak of GABA plot... plot residuals above this...
    gabamin = min(real(GABAData(ii,plotbounds)));
    %  resid = -resid;   % set resid to data-fit rather than fit-data
    resmax = max(residg);
    residg = residg + gabamin - resmax;
    plot(freq(freqbounds),GaussModel_area(GaussModelParam(ii,:),freq(freqbounds)),'r',...
        freq(plotbounds),real(GABAData(ii,plotbounds)), 'b', ...
        freq(freqbounds),residg,'b');
    legendtxt = regexprep(MRS_struct.pfile{ii}, '_','-');
    title(legendtxt);
    set(gca,'XDir','reverse');
    %set(gca,'YTick',[], 'Xgrid', 'on');
    oldaxis = axis;
    axis( [2.6 3.6 oldaxis(3) oldaxis(4) ] )

    %     R2(ii)=1-(resnorm(ii,1)/norm(real(GABAData(freqbounds))-mean(real(GABAData(freqbounds))))^2);
    %     GaussModelParam(ii,1)./sqrt(-GaussModelParam(ii,2))*sqrt(pi);




    %NP changing this to fit water and creatine for GE
    if strcmp(MRS_struct.Reference_compound,'H2O')
        %%%%%%%%%%%%%% Water Fit %%%%%%%%%%%%%%%%%%
        T1=20;
        %LGModelInit = [1500 T1 4.6845 0 0 -10*T1 ];
        % overestimating amplitude seems to work better...
        %LGModelInit = [20*maxinWater 10*T1 4.6845 0 0 -10*T1 ];
        %LGModelInit = [3000 200 4.8 0 1 -50 ]; %fails
        %estimate height and baseline from data
        maxinWater=max(real(WaterData(:)));
        waterbase = mean(real(WaterData(1:500))); % avg

        %REmove this
        %Philips data do not phase well based on first point, so do a preliminary
        %fit, then adjust phase of WaterData accordingly
        if(strcmpi(MRS_struct.vendor,'Philips'))
            %Run preliminary Fit of data
            LGModelInit = [maxinWater 20 4.7 0.0 waterbase -50 ]; %works

            lblg = [0.01*maxinWater 1 4.6 0 0 -50 ];
            ublg = [40*maxinWater 100 4.8 0.000001 1 0 ];
            %Fit from 5.6 ppm to 3.8 ppm RE 110826
            z=abs(MRS_struct.freq-5.6);
            waterlow=find(min(z)==z);
            z=abs(MRS_struct.freq-3.8);
            waterhigh=find(min(z)==z);
            freqbounds=waterlow:waterhigh;
            % Do the water fit (Lorentz-Gauss)
            nlinopts = statset('nlinfit');
            nlinopts = statset(nlinopts, 'MaxIter', 1e5);
            [LGModelParam(ii,:),residw] = nlinfit(freq(freqbounds), real(WaterData(ii,freqbounds)),...
                @(xdummy,ydummy)	LorentzGaussModel(xdummy,ydummy),...
                LGModelInit, nlinopts);
            ii;
            LGModelInit;
            LGModelParam(ii,:);
            residw = -residw;
            %Then use this for phasing
            error=zeros([120 1]);
            for jj=1:120
                Data=WaterData(ii,freqbounds)*exp(1i*pi/180*jj*3);
                Model=LorentzGaussModel(LGModelParam(ii,:),freq(freqbounds));
                error(jj)=sum((real(Data)-Model).^2);
            end
            [number index]=min(error);
            WaterData=WaterData*exp(1i*pi/180*index*3);
        end

        % 110624 - linear baseline term removed - causes nlinfit to fail
        % sometimes
          %LGModelInit = [maxinWater 20 4.7  waterbase -50 ] %works
  % 111209 need to change order to get linear term back in 
  % x(1) = Amplitude of (scaled) Lorentzian
% x(2) = 1 / hwhm of Lorentzian (hwhm = half width at half max)
% x(3) = centre freq of Lorentzian
% x(4) = linear baseline amplitude
% x(5) = constant baseline amplitude
% x(6) =  -1 / 2 * sigma^2  of gaussian
    LGModelInit = [maxinWater 20 4.7 0 waterbase -50 ]; %works

        lblg = [0.01*maxinWater 1 4.6 0 0 -50 ];
        ublg = [40*maxinWater 100 4.8 0.000001 1 0 ];
        %Fit from 5.6 ppm to 3.8 ppm RE 110826
        z=abs(MRS_struct.freq-5.6);
        waterlow=find(min(z)==z);
        z=abs(MRS_struct.freq-3.8);
        waterhigh=find(min(z)==z);
        freqbounds=waterlow:waterhigh;
        % Do the water fit (Lorentz-Gauss)
        % 111209 Always do the LSQCURV fitting - to initialise

            %Lorentz-Gauss Starters
            options = optimset('lsqcurvefit');
            options = optimset(options,'Display','off','TolFun',1e-10,'Tolx',1e-10,'MaxIter',10000);

            % 110308 - change the plotting.  one plot per SCAN with GABA,
            % water
            fignum = 102;
            h=figure(fignum);
            figTitle = ['GannetFit Output'];
            set(gcf,'Name',figTitle,'Tag',figTitle, 'NumberTitle','off');
            [LGModelParam(ii,:),residual(ii), residw] = lsqcurvefit(@(xdummy,ydummy) ...
                LorentzGaussModel(xdummy,ydummy),...
                LGModelInit, freq(freqbounds),real(WaterData(ii,freqbounds)),...
                lblg,ublg,options);
            LGModelInit;
            LGModelParam(ii,:);

            residw = -residw;
            if(waterfit_method == FIT_NLINFIT)
                LGModelInit = LGModelParam(ii,:); % CJE 4 Jan 12
        
                % nlinfit options
                nlinopts = statset('nlinfit');
                nlinopts = statset(nlinopts, 'MaxIter', 1e5);

                %%%Additional plot added in by RE to test Philips water fit
                %commented out now water fit is fixed.

                h1=subplot(2, 2, 3);


                %plot(freq(freqbounds),real(LorentzGaussModel(LGModelInit,freq(freqbounds))), 'r', ...
                %    freq(freqbounds),real(WaterData(ii,freqbounds)),'b');
                %set(gca,'XDir','reverse');
                %set(gca,'YTick',[], 'Xgrid', 'on');
                %xlim([4.2 5.2]);





                [LGModelParam(ii,:),residw] = nlinfit(freq(freqbounds), real(WaterData(ii,freqbounds)),...
                    @(xdummy,ydummy)	LorentzGaussModel(xdummy,ydummy),...
                    LGModelInit, nlinopts);
                ii;
                LGModelInit;
                LGModelParam(ii,:);
                residw = -residw;
            end

        MRS_struct.WaterModelParam(ii,:) = LGModelParam(ii,:);


        h1=subplot(2, 2, 3);

        waterheight = LGModelParam(ii,1);
        watmin = min(real(WaterData(ii,:)));
        %  resid = -resid;   % set resid to data-fit rather than fit-data
        resmax = max(residw);
        MRS_struct.WaterFitError(ii)  =  100 * std(residw) / waterheight; %raee changed to residw
        residw = residw + watmin - resmax;
        stdevresidw=std(residw);
        MRS_struct.GABAIU_Error_w = (MRS_struct.GABAFitError .^ 2 + ...
            MRS_struct.WaterFitError .^ 2 ) .^ 0.5;

        plot(freq(freqbounds),real(LorentzGaussModel(LGModelParam(ii,:),freq(freqbounds))), 'r', ...
            freq(freqbounds),real(WaterData(ii,freqbounds)),'b', ...
            freq(freqbounds), residw, 'b');
        set(gca,'XDir','reverse');
        %set(gca,'YTick',[], 'Xgrid', 'on');
        xlim([4.2 5.2]);

        baselineparams = [ LGModelParam(ii,3) 0 LGModelParam(ii,4)];

        Baseline(ii,:)=BaselineModel(baselineparams,freq(freqbounds));
        %WaterArea(ii)=sum(real(LorentzGaussModel(LGModelParam(ii,:),freq(freqbounds))) ...
        %    - BaselineModel(LGModelParam(ii,3:5),freq(freqbounds)),2);
        %This changed when CJE changed the LG model - Baseline no longer
        %appropriate....
        %WaterArea(ii)=sum(real(LorentzGaussModel(LGModelParam(ii,:),freq(freqbounds))) ...
        %    - LGModelParam(ii,4),2);
        %CJE fixes water baseline code - baseline model as before...
        WaterArea(ii)=sum(real(LorentzGaussModel(LGModelParam(ii,:),freq(freqbounds))) ...
      - BaselineModel(LGModelParam(ii,3:5),freq(freqbounds)),2);

        % convert watersum to integral
        MRS_struct.waterArea(ii)=WaterArea(ii) * (freq(1) - freq(2));
        % 110308 - assume we get this from the loaded file
        %MRS_struct.Navg=Navg;
        MRS_struct.H20 = MRS_struct.waterArea(ii) ./ std(residw);


        %generate scaled spectrum (for plotting) CJE Jan2011
        MRS_struct.gabaspec_scaled(ii,:) = MRS_struct.gabaspec(ii,:) .* ...
            repmat((1 ./ MRS_struct.waterArea(ii)), [1 32768]);

        [MRS_struct]=MRSGABAinstunits(MRS_struct, ii);



        %THIS IS VERY MESSY BUT WORKS FOR NOW (NP 17-11-11) needs to be integrated
        %more nicely but this will work too simple copy pasted of section below

        %First establish which data to fit - i.e. the sum of the OFF.
        Cr_OFF=MRS_struct.OFFspec(ii,:);

        %Initialise fitting pars
        z=abs(MRS_struct.freq-3.12);
        lb=find(min(z)==z);
        z=abs(MRS_struct.freq-2.72);
        ub=find(min(z)==z);
        Cr_initx = [max(real(Cr_OFF(lb:ub))) 0.05 3.0 0 0 0 ];
                
        freqrange = MRS_struct.freq(lb:ub);
        h2=subplot(2, 2, 4);
        plot(freqrange,real(Cr_OFF(lb:ub)));
        %Then use the same function as the Cr Fit in GannetLoad
        


        nlinopts=statset('nlinfit');
        nlinopts = statset(nlinopts, 'MaxIter', 1e5, 'Display','Off');
        %[CrFitParams, rejectframes,residCr] = FitPeaksByFrames(freqrange, real(Cr_OFF(lb:ub).'), Cr_initx);
        [CrFitParams(ii,:), residCr] = nlinfit(freqrange, real(Cr_OFF(lb:ub)), ...
            @(xdummy, ydummy) LorentzModel(xdummy, ydummy),Cr_initx, nlinopts);

        Crheight = CrFitParams(ii,1);
        Crmin = min(real(Cr_OFF(lb:ub)));
        %  resid = -resid;   % set resid to data-fit rather than fit-data
        resmaxCr = max(residCr);
        stdresidCr = std(residCr);
        MRS_struct.CrFitError(ii)  =  100 * stdresidCr / Crheight;
        MRS_struct.GABAIU_Error_cr(ii) = (MRS_struct.GABAFitError(ii) .^ 2 + ...
            MRS_struct.CrFitError(ii) .^ 2 ) .^ 0.5;
        MRS_struct.CrArea(ii)=sum(real(LorentzModel(CrFitParams(ii,:),freqrange)-LorentzModel([0 CrFitParams(ii,2:end)],freqrange))) * (freq(1) - freq(2));
% CJE 120131
        MRS_struct.gabaiuCr(ii)=MRS_struct.gabaArea(ii)./MRS_struct.CrArea(ii)/2.0; %Factor of 2.0 account for CR coming from OFF not all data, and sum not average...
        % effective editing efficiency of both Cr and GABA is 0.5, 
        % Cr 3.0 has 3 spins, GABA 3.0 has 2.  Cr is from SUM, so
        % need factor (1/2)...
        %MRS_struct.gabaiuCr(ii)= MRS_struct.gabaArea(ii)./ ...
	    %MRS_struct.CrArea(ii) * (3/2) * (1/2); 
%change removed raee 120222 gabaiuCr is an integral ratio - no need for scaling.            
        %alter resid Cr for plotting.
        residCr = residCr + Crmin - resmaxCr;
        %Plot the Cr fit
        h2=subplot(2, 2, 4);
        %debugging changes
        plot(freqrange,real(LorentzModel(CrFitParams(ii,:),freqrange)), 'r', ...
            MRS_struct.freq,real(Cr_OFF(:)),'b', ...
            freqrange, residCr, 'b');
        %     plot(freqrange,real(LorentzModel(CrFitParams,freqrange)), 'r');
        % plot(MRS_struct.freq,real(Cr_OFF(:)),'b');
        % plot(freqrange, residCr, 'b');

        set(gca,'XDir','reverse');
        set(gca,'YTick',[], 'Xgrid', 'on');
        xlim([2.6 3.6]);


        subplot(2,2,3)
        [h_m h_i]=inset(h1,h2);
        set(h_i,'fontsize',6)


    elseif strcmp(MRS_struct.Reference_compound,'Cr')
        %First establish which data to fit - i.e. the sum of the OFF.
        Cr_OFF=MRS_struct.OFFspec(ii,:);

        %Initialise fitting pars
        z=abs(MRS_struct.freq-3.12);
        lb=find(min(z)==z);
        z=abs(MRS_struct.freq-2.72);
        ub=find(min(z)==z);
        Cr_initx = [max(real(Cr_OFF(lb:ub))) 0.05 3.0 0 0 0 ];
        
        freqrange = MRS_struct.freq(lb:ub);
        subplot(2, 2, 3)
        plot(freqrange,real(Cr_OFF(lb:ub)));
        %Then use the same function as the Cr Fit in GannetLoad


        nlinopts=statset('nlinfit');
        nlinopts = statset(nlinopts, 'MaxIter', 1e5, 'Display','Off');
        %[CrFitParams, rejectframes,residCr] = FitPeaksByFrames(freqrange, real(Cr_OFF(lb:ub).'), Cr_initx);
        [CrFitParams(ii,:), residCr] = nlinfit(freqrange, real(Cr_OFF(lb:ub)), ...
            @(xdummy, ydummy) LorentzModel(xdummy, ydummy),Cr_initx, nlinopts);

        Crheight = CrFitParams(ii,1);
        Crmin = min(real(Cr_OFF(lb:ub)));
        %  resid = -resid;   % set resid to data-fit rather than fit-data
        resmaxCr = max(residCr);
        stdresidCr = std(residCr);
        MRS_struct.CrFitError(ii)  =  100 * stdresidCr / Crheight;
        MRS_struct.GABAIU_Error_cr(ii) = (MRS_struct.GABAFitError(ii) .^ 2 + ...
            MRS_struct.CrFitError(ii) .^ 2 ) .^ 0.5;
        MRS_struct.CrArea(ii)=sum(real(LorentzModel(CrFitParams(ii,:),freqrange)-LorentzModel([0 CrFitParams(ii,2:end)],freqrange))) * (freq(1) - freq(2));
        MRS_struct.gabaiuCr(ii)=MRS_struct.gabaArea(ii)./MRS_struct.CrArea(ii)/2.0; %Factor of 2.0 account for CR coming from OFF not all data, and sum not average...
        %alter resid Cr for plotting.
        residCr = residCr + Crmin - resmaxCr;
        %Plot the Cr fit
        subplot(2, 2, 3)
        %debugging changes
        plot(freqrange,real(LorentzModel(CrFitParams(ii,:),freqrange)), 'r', ...
            MRS_struct.freq,real(Cr_OFF(:)),'b', ...
            freqrange, residCr, 'b');
        %     plot(freqrange,real(LorentzModel(CrFitParams,freqrange)), 'r');
        % plot(MRS_struct.freq,real(Cr_OFF(:)),'b');
        % plot(freqrange, residCr, 'b');

        set(gca,'XDir','reverse');
        set(gca,'YTick',[], 'Xgrid', 'on');
        xlim([2.6 3.6]);

    end
    % GABA fitting information
    if(MRS_struct.FreqPhaseAlign)
        tmp2 = '1';
    else
        tmp2 = '0';
    end

    if fit_method == FIT_NLINFIT
        tmp3 = 'NLINFIT, ';
    else
        tmp3 = 'LSQCURVEFIT, ';
    end
    if waterfit_method == FIT_NLINFIT
        tmp4 = [tmp3 'NLINFIT'];
    else
        tmp4 = [tmp3 'LSQCURVEFIT' ];
    end


    %and running the plot
    subplot(2,2,2)
    axis off
    tmp =       [ 'pfile        : ' MRS_struct.pfile{ii} ];
    tmp = regexprep(tmp, '_','-');
    text(0,0.9, tmp, 'FontName', 'Courier');
    tmp =       [ 'Navg         : ' num2str(MRS_struct.Navg(ii)) ];
    text(0,0.8, tmp, 'FontName', 'Courier');
    tmp = sprintf('GABA+ FWHM   : %.2f Hz', MRS_struct.GABAFWHM(ii) );
    text(0,0.7, tmp, 'FontName', 'Courier');
    tmp = sprintf('GABA+ Area   : %.4f', MRS_struct.gabaArea(ii) );
    text(0,0.6, tmp, 'FontName', 'Courier');
    if strcmp(MRS_struct.Reference_compound,'H2O')
        tmp = sprintf('H2O/Cr Area   :%.3f/%.3f ', MRS_struct.waterArea(ii),MRS_struct.CrArea(ii) );
        text(0,0.5, tmp, 'FontName', 'Courier');
        %tmp = sprintf('Cr Area      : %.4f', MRS_struct.CrArea(ii) );
        %text(0,0.4, tmp, 'FontName', 'Courier');
        tmp = sprintf('%.2f, %.2f ',  MRS_struct.GABAIU_Error_w(ii),  MRS_struct.GABAIU_Error_cr(ii));
        tmp = [tmp '%'];
        tmp = ['FtErr (H/Cr) : ' tmp];
        text(0,0.4, tmp, 'FontName', 'Courier');
        tmp = sprintf('GABA+ / H_2O  : %.4f inst. units.', MRS_struct.gabaiu(ii) );
        text(0,0.3, tmp, 'FontName', 'Courier');
        tmp = sprintf('GABA+/Cr i.r.: %.4f', MRS_struct.gabaiuCr(ii) );
        text(0,0.2, tmp, 'FontName', 'Courier');
        tmp =       [ 'Ver(Load/Fit): ' MRS_struct.versionload ',' tmp2 ',' MRS_struct.versionfit];
        text(0,0.1, tmp, 'FontName', 'Courier');
        tmp = sprintf('%.2f, %.2f',  MRS_struct.phase(ii),  MRS_struct.phase_firstorder(ii) );
        tmp =        ['Phase  \phi_0,\phi_1 : ' tmp];
        text(0, -0.0, tmp, 'FontName', 'Courier');
        tmp =        ['GABA, Water fit alg. :' tmp4 ];
        text(0,-0.1, tmp, 'FontName', 'Courier');
    else
        tmp = sprintf('Cr Area      : %.4f', MRS_struct.CrArea(ii) );
        text(0,0.5, tmp, 'FontName', 'Courier');
        tmp = sprintf('FitError (Cr): %.2f%%', MRS_struct.GABAIU_Error_cr);
        text(0,0.4, tmp, 'FontName', 'Courier');
        tmp = sprintf('GABA+/Cr i.r.: %.4f', MRS_struct.gabaiuCr(ii) );
        text(0,0.3, tmp, 'FontName', 'Courier');
        tmp =       [ 'Ver(Load/Fit): ' MRS_struct.versionload ',' tmp2 ',' MRS_struct.versionfit];
        text(0,0.2, tmp, 'FontName', 'Courier');
        if (~strcmp(MRS_struct.vendor, 'Siemens'))
            tmp = sprintf('%.2f, %.2f',  MRS_struct.phase(ii),  MRS_struct.phase_firstorder(ii) );
            tmp =        ['Phase  \phi_0,\phi_1 : ' tmp];
            text(0, 0.1, tmp, 'FontName', 'Courier');
        end
        tmp =        ['GABA, Water fit alg. :' tmp4 ];
        text(0,0.0, tmp, 'FontName', 'Courier');
    end
    %   if strcmp(MRS_struct.Reference_compound,'H2O')
    %     tmp = sprintf('GABA+ / H_2O  : %.4f inst. units.', MRS_struct.gabaiu(ii) );
    %     text(0,0.3, tmp, 'FontName', 'Courier');
    %   else
    %     tmp = sprintf('GABA+/Cr i.r.: %.4f', MRS_struct.gabaiu(ii) );
    %     text(0,0.3, tmp, 'FontName', 'Courier');
    %   end


    %   tmp = sprintf('%.2f, %.2f',  MRS_struct.phase(ii),  MRS_struct.phase_firstorder(ii) );
    %   tmp =        ['Phase  \phi_0,\phi_1 : ' tmp];
    %   text(0, 0.2, tmp, 'FontName', 'Courier'



    subplot(2,2,4,'replace')
    axis off;
    script_path=which('GannetLoad');
    Gannet_circle=[script_path(1:(end-12)) 'GANNET_circle.png'];
    Gannet_circle_white=[script_path(1:(end-12)) 'GANNET_circle_white.jpg'];
    A=imread(Gannet_circle);
    A_2=imread(Gannet_circle_white);
    hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
    %set(gca,'Units','normalized');set(gca,'Position',[0.05 0.05 1.85 0.15]);
    image(A);axis off; axis square;

    %%%%  Save EPS %%%%%
    pfil_nopath = MRS_struct.pfile{ii};

    %for philips .data
    if(strcmpi(MRS_struct.vendor,'Philips_data'))
        fullpath = MRS_struct.pfile{ii};
        fullpath = regexprep(fullpath, '\./', '');
        fullpath = regexprep(fullpath, '/', '_');
    end

    %pfil_nopath = pfil_nopath( (length(pfil_nopath)-15) : (length(pfil_nopath)-9) );
    tmp = strfind(pfil_nopath,'/');
    tmp2 = strfind(pfil_nopath,'\');
    if(tmp)
        lastslash=tmp(end);
    elseif (tmp2)
        %maybe it's Windows...
        lastslash=tmp2(end);
    else
        % it's in the current dir...
        lastslash=0;
    end


    if(strcmpi(MRS_struct.vendor,'Philips'))
        tmp = strfind(pfil_nopath, '.sdat');
        tmp1= strfind(pfil_nopath, '.SDAT');
        if size(tmp,1)>size(tmp1,1)
            dot7 = tmp(end); % just in case there's another .sdat somewhere else...
        else
            dot7 = tmp1(end); % just in case there's another .sdat somewhere else...
        end
    elseif(strcmpi(MRS_struct.vendor,'GE'))
        tmp = strfind(pfil_nopath, '.7');
        dot7 = tmp(end); % just in case there's another .7 somewhere else...
    elseif(strcmpi(MRS_struct.vendor,'Philips_data'))
        tmp = strfind(pfil_nopath, '.data');
        dot7 = tmp(end); % just in case there's another .data somewhere else...
    elseif(strcmpi(MRS_struct.vendor,'Siemens'))
        tmp = strfind(pfil_nopath, '.rda');
        dot7 = tmp(end); % just in case there's another .data somewhere else...
    end
    pfil_nopath = pfil_nopath( (lastslash+1) : (dot7-1) );


    %Save pdf output
    hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
    image(A_2);axis off; axis square;
    set(gcf, 'PaperUnits', 'inches');
    set(gcf,'PaperSize',[8.5 6.5]);
    set(gcf,'PaperPosition',[.25 .25 8 6]);
    if(strcmpi(MRS_struct.vendor,'Philips_data'))
        pdfname=[ epsdirname '/' fullpath '.pdf' ];
    else
        pdfname=[ epsdirname '/' pfil_nopath  '.pdf' ];
    end
    if(exist(epsdirname,'dir') ~= 7)
        mkdir(epsdirname)
    end
%     saveas(gcf, pdfname);
    hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
    %set(gca,'Units','normalized');set(gca,'Position',[0.05 0.05 1.85 0.15]);
    image(A);axis off; axis square;

end

% end of MRSGABAfit

%%%%%%%%%%%%%%%%%%%%%%%% GAUSS MODEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function F = GaussModel_area(x,freq)

% x(1) = gaussian amplitude
% x(2) = 1/(2*sigma^2)
% x(3) = centre freq of peak
% x(4) = amplitude of linear baseline
% x(5) = constant amplitude offset

%F = x(1)*sqrt(-x(2)/pi)*exp(x(2)*(freq-x(3)).*(freq-x(3)))+x(4)*(freq-x(3))+x(5);
F = x(1)*exp(x(2)*(freq-x(3)).*(freq-x(3)))+x(4)*(freq-x(3))+x(5);



%%%%%%%%%%%%%%%%  OLD LORENTZGAUSSMODEL %%%%%%%%%%%%%%%%%%%%
%function F = LorentzGaussModel(x,freq)
%Lorentzian Model multiplied by a Gaussian.  gaussian width determined by
%x(6). x(7) determines phase.
%F = ((ones(size(freq))./(x(2)^2*(freq-x(3)).*(freq-x(3))+1)*x(1))*cos(x(7))+(ones(size(freq))./(x(2)^2*(freq-x(3)).*(freq-x(3))+1)*x(2).*(freq-x(3)))*sin(x(7))).*(exp(x(6)*(freq-x(3)).*(freq-x(3))))+x(4)*(freq-x(3))+x(5);


%%%%%%%%%%%%%%%%  NEW LORENTZGAUSSMODEL %%%%%%%%%%%%%%%%%%%%
function F = LorentzGaussModel(x,freq)
% CJE 24Nov10 - removed phase term from fit - this is now dealt with
% by the phasing of the water ref scans in MRSLoadPfiles
%Lorentzian Model multiplied by a Gaussian.
% x(1) = Amplitude of (scaled) Lorentzian
% x(2) = 1 / hwhm of Lorentzian (hwhm = half width at half max)
% x(3) = centre freq of Lorentzian
% x(4) = constant baseline amplitude
% x(5) =  -1 / 2 * sigma^2  of gaussian

% 110624; remove linear baseline term
% OBSOLETE:
% x(4) = linear baseline amplitude
% x(5) = constant baseline amplitude
% x(6) =  -1 / 2 * sigma^2  of gaussian

% Lorentzian  = (1/pi) * (hwhm) / (deltaf^2 + hwhm^2)
% Peak height of Lorentzian = 4 / (pi*hwhm)
% F is a normalised Lorentzian - height independent of hwhm
%   = Lorentzian / Peak

%F =((ones(size(freq))./(x(2)^2*(freq-x(3)).*(freq-x(3))+1)*x(1))*cos(x(7))+(ones(size(freq))./(x(2)^2*(freq-x(3)).*(freq-x(3))+1)*x(2).*(freq-x(3)))*sin(x(7))).*(exp(x(6)*(freq-x(3)).*(freq-x(3))))+x(4)*(freq-x(3))+x(5);
% remove phasing
F = (x(1)*ones(size(freq))./(x(2)^2*(freq-x(3)).*(freq-x(3))+1))  ...
    .* (exp(x(6)*(freq-x(3)).*(freq-x(3)))) ... % gaussian
    + x(4)*(freq-x(3)) ... % linear baseline
    +x(5); % constant baseline

% 110624 removed:
% + x(4)*(freq-x(3)) ... % linear baseline
% 111214 replaced:

%%%%%%%%%%%%%%% BASELINE %%%%%%%%%%%%%%%%%%%%%%%
function F = BaselineModel(x,freq)
F = x(2)*(freq-x(1))+x(3);


%%%%%%%%%%%%%%%%%%% INST UNITS CALC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MRS_struct] = MRSGABAinstunits(MRS_struct,ii)
% function [MRS_struct] = MRSGABAinstunits(MRS_struct)
% Convert GABA and Water amplitudes to institutional units
% (pseudo-concentration in mmol per litre).
% March 10: use MRS_struct.

PureWaterConc = 55000; % mmol/litre
WaterVisibility = 0.65; % This is approx the value from Ernst, Kreis, Ross
EditingEfficiency = 0.5;
T1_GABA = 0.80 ; % "empirically determined"...! Gives same values as RE's spreadsheet
% ... and consistent with Cr-CH2 T1 of 0.8 (Traber, 2004)
%Not yet putting in measured GABA T1, but it is in the pipeline - 1.35ish

T2_GABA = 0.13; % from occipital Cr-CH2, Traber 2004
T2_GABA = 0.088; % from JMRI paper 2011 Eden et al.

T1_Water = 1.100; % average of WM and GM, estimated from Wansapura 1999
T2_Water = 0.095; % average of WM and GM, estimated from Wansapura 1999
MM=0.45;  % MM correction: fraction of GABA in GABA+ peak. (In TrypDep, 30 subjects: 55% of GABA+ was MM)
%This fraction is platform and implementation dependent, base on length and
%shape of editing pulses and ifis Henry method. 
%
TR=1.8;
TE=0.068;
N_H_GABA=2;
N_H_Water=2;
Nspectra = length(MRS_struct.pfile);
%Nwateravg=8;

T1_factor = (1-exp(-TR./T1_Water)) ./ (1-exp(-TR./T1_GABA));
T2_factor = exp(-TE./T2_Water) ./ exp(-TE./T2_GABA);

MRS_struct.gabaiu(ii) = (MRS_struct.gabaArea(ii)  ./  MRS_struct.waterArea(ii))  ...
    * PureWaterConc*WaterVisibility*T1_factor*T2_factor*(N_H_Water./N_H_GABA) ...
    * MM * (MRS_struct.Nwateravg ./ MRS_struct.Navg(ii)) ./ EditingEfficiency;

%%%%%%%%%%%%%%% INSET FIGURE %%%%%%%%%%%%%%%%%%%%%%%
function [h_main, h_inset]=inset(main_handle, inset_handle,inset_size)

% The function plotting figure inside figure (main and inset) from 2 existing figures.
% inset_size is the fraction of inset-figure size, default value is 0.35
% The outputs are the axes-handles of both.
%
% An examle can found in the file: inset_example.m
%
% Moshe Lindner, August 2010 (C).

if nargin==2
    inset_size=0.35;
end

inset_size=inset_size*.5;
%figure
new_fig=gcf;
main_fig = findobj(main_handle,'Type','axes');
h_main = copyobj(main_fig,new_fig);
set(h_main,'Position',get(main_fig,'Position'))
inset_fig = findobj(inset_handle,'Type','axes');
h_inset = copyobj(inset_fig,new_fig);
ax=get(main_fig,'Position');
set(h_inset,'Position', [1.3*ax(1)+ax(3)-inset_size 1.001*ax(2)+ax(4)-inset_size inset_size*0.7 inset_size*0.9])







