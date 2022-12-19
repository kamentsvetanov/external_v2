function M = optimizeGA(GA)
% M = optimizeGA(GA)
%
% outputs a pseudo-random list of condition codes that optimizes
% multiple fitness measures for fMRI task designs
%
% more help can be found in ga_example_script.m
% and in Genetic_Algorithm_readme.rtf
%
% Tor Wager 2/10/01

% Edited 11/17/01
% Edited 11/8/09    - add check for designs with missing trial types;
%                          - output and error checking a bit more
%                          informative
% Edited 8/15/10    - fixed minor bug in contrast length checking with
%                       trans2block option

N = fieldnames(GA);
for i = 1:length(N)
    eval([N{i} ' = GA.' N{i} ';'])
end

% d-optimality flag - compute d rather than a-optimality
if ~exist('dflag')==1,dflag = 0; end

clockStart = cputime;			  	% keeps track of starting time


disp('OptimizeGA')
disp('===============================')
disp(['Saturation threshold = ' num2str(nonlinthreshold)])

% Set up variables and organisms
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
disp('Setting up variables')


% ----------------------------------------------------------------
% * jitter setup
% ----------------------------------------------------------------  

dojitter = 0;
if size(freqConditions,2) == size(conditions,2) + 1
    conditions = [conditions max(conditions)+1];   % insert 0 as last condition if jitter
    dojitter = 1;
elseif size(freqConditions,2) == size(conditions,2)
else error('Frequency and condition vectors must be same length, or freq must be 1 longer for jitter')
end

nconds = sum(conditions > 0);
fprintf('You entered %01d conditions  (event types) that will each be modeled with a regessor. \n ', nconds);
fprintf('Note that if you enter 0 as a condition number, those events will not be modeled\n (they are assumed to be rest/inter-stimulus interval periods)\n\n');
pause(.5)

% ----------------------------------------------------------------
% * saturation setup
% ----------------------------------------------------------------
if isempty(nonlinthreshold) | strcmp(nonlinthreshold,'none'),dosaturation = 0; nonlinthreshold = []; else dosaturation = 1; end


% ----------------------------------------------------------------
% * contrast setup
% ----------------------------------------------------------------
  
% work out whether to use contrasts.
if isempty(contrasts)
    disp('  ...no contrasts entered; Calculating efficiency of model betas (regression parameters)')
    docontrasts = 0;
else
    csize = size(contrasts);
    fprintf('Contrasts entered. You entered matrix of %01d contrasts, with weights across %01d conditions.\n ', csize);

    docontrasts = 1;
    disp('Contrasts:')
    disp(contrasts)
    
    badconlength = (~(trans2switch || trans2block)) && ~(size(contrasts,2) == nconds);
    badconlength = badconlength | (trans2block && ~(size(contrasts,2) == nconds*2));
    if badconlength
        error(sprintf('The number of columns in your contrast matrix must equal the number of conditions\n(excluding condition number entries of 0)'))
    end

    disp(' ...adding one column to contrast matrix with weights of 0, to model the intercept')

    contrasts(:,size(contrasts,2)+1) = 0;  % add 0s contrasts to account for intercept

    if ~isempty(contrastweights)
         fprintf('You entered a contrast weight vector across %01d contrasts\n ', length(contrastweights));
         if length(contrastweights) ~= size(contrasts, 1)
             error('The length of contrastweights should equal the number of contrasts (rows) in your contrast matrix.');
         end
    end
end

pause(2)



% ----------------------------------------------------------------
% * setup freqConditions and rests
% ---------------------------------------------------------------- 

% normalize freqConditions
%if ~sum(freqConditions) == 1,
%	freqConditions(1:end-1) = (1 - freqConditions(end)) / (size(freqConditions,2)-1);
%	disp(['	...freqConditions does not sum to 1: normalizing to ' num2str(freqConditions)])
%end
if ~sum(freqConditions) > 1, error('freqConditions must sum to 1 or less than 1.'),end
    
% flag for rest length.
	if ~isempty(restevery) &  ~isempty(restlength)
		disp(['	...Using rests of length ' num2str(restlength) ' and resting every ' num2str(restevery)])
		dorests = 1;
	else disp('	...No rests specified.'),dorests = 0;
	end

if ~(mod(scanLength / ISI,1) == 0),disp('Warning: Scan length in s is not an even multiple of ISI!'),end


% ----------------------------------------------------------------
% * initial computation of list lengths and output
% ----------------------------------------------------------------  

fitnessMatrix = zeros(4,sizeGenerations);
numStim = ceil(scanLength / (ISI));
if dorests,
	numRestStim = (ceil(numStim/(mean(restevery)+restlength)) - 1) * restlength;
else
	numRestStim = 0;
end
numStimEachCond = ceil((numStim-numRestStim) * freqConditions);			            % row vector of stim in each cond
numBlanks = numStim - numRestStim - sum(numStimEachCond);
numsamps = ceil(numStim*ISI/TR);
%lowerLimit = round(scanLength / TR * lowerLimit); 
disp('================== Parameters ======================')
disp(['     Total stimuli in scan      : ' num2str(numStim)]) 
disp(['     Fixed rest length in ITIs  : ' num2str(restlength)]) 
disp(['     Fixed Rest stimuli in scan : ' num2str(numRestStim)])
disp(['     Num blank intervals        : ' num2str(numBlanks)])
disp(['     Num of task conds          : ' num2str(sum(conditions > 0))])
disp(['     Num stimuli each cond      : ' num2str(numStimEachCond)])
disp('====================================================')


% ----------------------------------------------------------------
% * get smoothing matrix and autocorrelation matrix
% ----------------------------------------------------------------
if ~isfield(GA,'LPsmooth'),GA.LPsmooth = 1;,end
[S,Vi,svi] = getSmoothing(HPlength,GA.LPsmooth,TR,numsamps,xc);
clear Vi

% ----------------------------------------------------------------
% * HRF GAMMA FUNCTION - spm 99
% ----------------------------------------------------------------

   HRF = spm_hrf(.1);						% SPM HRF sampled at .1 s
   HRF = HRF/ max(HRF);
   
% ----------------------------------------------------------------
% * generate an unsorted list of conditions
% ----------------------------------------------------------------   

disp('	...generating lists of organisms')
unsortedList = [];
for i = 1:size(conditions,2)	
    unsortedList = [unsortedList; conditions(i) * ones(numStimEachCond(i),1)];
end
unsortedList = [unsortedList; zeros(numBlanks,1)];

% ----------------------------------------------------------------
% * transform to switches warnings (and generate unsorted list)
% ----------------------------------------------------------------   

% This is part of the switching hack. uses 2 conditions, then figures out 4 columns from that.
% 5 is the rest condition.
if trans2switch
    if size(conditions,2) > 2
        error('Can''t use trans2switch with other than 2 conditions.')
    end
	disp(['	...USING TRANS2SWITCH > num stim each cond = ' num2str(numStimEachCond)])

end % if trans2switch

% ----------------------------------------------------------------
% * transform to block design - double number of conditions
% ---------------------------------------------------------------- 
if trans2block
	disp(['	...USING TRANS2BLOCK >'])
        freqConditions = [freqConditions./2 freqConditions./2];
        disp(['     freqConditions = ' num2str(freqConditions)])
   
        if dojitter
           maxcond = max(conditions)-1;
           conditions = [conditions(1:maxcond) maxcond+1:2*length(conditions)-1];
           disp(['     CONDITION ' num2str(conditions(end)) ' is blank jitter.'])
	else
           maxcond = max(conditions);
           conditions = [conditions maxcond+1:2*length(conditions)];
        end
        disp(['     conditions = ' num2str(conditions)])
	
	% ----------------------------------------------------------------
	% * setup special first trial
	% ----------------------------------------------------------------
	if isempty(dofirst) 
		dofirst = 0;
    end
    if dofirst
		disp(['	...block design: adding special predictor for first trial in block.'])
		try
			% this is really kludgy, but should give a rough estimate of how many first trials to expect.
			numfirst = numStim ./ mean(restevery);
			proportionfirst = numfirst./numStim;
		catch
			error('restevery not found...must use rest periods with transform2block!')
		end
		freqConditions = freqConditions - (proportionfirst./size(freqConditions,2));
		freqConditions = [freqConditions proportionfirst];
		disp('	...first trial special condition - adjusted expected frequencies:')
		disp(['     freqConditions = ' num2str(freqConditions)])

		disp(['	...Adding extra column to contrasts to account for 1st trial predictor:'])
		contrasts = [contrasts zeros(size(contrasts,1),1)];
		contrasts
	end
end




% ----------------------------------------------------------------
% * signal to user if jitter is used.
% ---------------------------------------------------------------- 
if dojitter
   disp(['REST INTERVALS DETECTED: condition ' num2str(max(conditions))])
else
   disp(['REST INTERVALS: not used (to use, freqCond should be one longer than conditions'])
end




% ----------------------------------------------------------------
% * randomize initial set of organisms
% ---------------------------------------------------------------- 

disp('  ...randomizing organism start state')
for z = 1:sizeGenerations % generate random ordering of x conditions
  	stimList = getRandom(unsortedList);
    listMatrix(:,z) = stimList; % a row for each subject
end




% ----------------------------------------------------------------
% * transform restevery into restMatrix
% ---------------------------------------------------------------- 

%	restMatrix is a matrix with period length in ITIs X list (cols)
%		that specifies how long to go for each period between a rest/probe.
if dorests
	atleast = min(restevery);
	restPeriods = numStim / atleast + 5;	% make this many rows in restMatrix
	restList = [];
	for i = 1:size(restevery,2):restPeriods
		restList = [restList;restevery'];
	end
	for i = 1:sizeGenerations
		restMatrix(:,i) = getRandom(restList);
	end
	% disp('=============== Rest calculation ===================')
	disp(['	...restMatrix is ' num2str(size(restMatrix,1)) ' X ' num2str(size(restMatrix,2))])
	restMatrix(1:5,1:10)




    % ----------------------------------------------------------------
    % * insert rests, if needed, and trim list
    % ----------------------------------------------------------------
	%	There are two listMatrices: one to be tested for fitness, also called rna, and
	%		the other for crossover (called dna).
	%
	%	The first one has the rests in it, and the 2nd just has the stimuli.
	%	#1 is called TESTlistMatrix, and #2 is called listMatrix.
	%	
	%	restMatrix is a matrix with period length in ITIs X list (cols)
	%		that specifies how long to go for each period between a rest/probe.
    %
    %   We need to generate TESTlistMatrix here to make sure it's the right size.
    %   later, we'll use it in the GA.  
    %
	% could also use the function dna2rna, but we need only the rests at this point
	TESTlistMatrix = insert_rests(listMatrix,restMatrix,restlength,numStim);
	
else 
	TESTlistMatrix = listMatrix;
	restMatrix = [];
end


% ----------------------------------------------------------------
% * allow user-entered listmatrix, to use non-random start.
% ----------------------------------------------------------------
if isfield(GA,'listMatrix')
	disp('	...Existing listMatrix detected.  Starting with matrix in GA.listMatrix.')
	try
		listMatrix(:,1:size(GA.listMatrix,2)) = GA.listMatrix;
	catch
		whos listMatrix
		error('Input listMatrix size does not match generated size.')
	end
end
	%while size(listMatrix,2) < sizeGenerations,
	%	listMatrix = [listMatrix listMatrix];
	%end
if size(listMatrix,2) > sizeGenerations,
	listMatrix = listMatrix(:,1:sizeGenerations);
end

% ----------------------------------------------------------------
% * check for other errors, and output warnings
% ----------------------------------------------------------------

% This should never happen if using rests, because insert_rests should adjust list length to numStim if necessary, but...
if size(TESTlistMatrix,1) < numStim
    disp(['Warning: # stim = ' num2str(numStim) '; list length = ' num2str(size(TESTlistMatrix,1)) ' : Padding with zeros.'])
    listMatrix(end+1:numStim,:) = 0;
elseif size(TESTlistMatrix,1) > numStim,disp(['Warning: # stim = ' num2str(numStim) '; list length = ' num2str(size(TESTlistMatrix,1)) ' : Truncating lists.'])
    listMatrix = listMatrix(1:numStim,:);
end

% initialize bestMat to size of final list to be saved (rna)
 bestMat = uint8(zeros(numStim,1));
 
disp('======== Num stimuli, averaged across lists (before instruction/rest stimuli) ========')
for i = 0:size(freqConditions,2)
	num = mean(sum(listMatrix == i));
	freq = num / numStim;
	disp(['		Condition ' num2str(i) ': ' num2str(num) ' stimuli, ' num2str(freq*100) '% of total stimuli'])
end
disp('======================================================================================')

clear TESTlistMatrix
listMatrix = uint8(listMatrix);
restMatrix = uint8(restMatrix);

% ----------------------------------------------------------------
% * criterion measures setup
% ---------------------------------------------------------------- 
if ~isempty(NumStimthresh) | ~isempty(maxCbalDevthresh) | ~isempty(maxFreqDevthresh)
	docriterion = 1;
	if isempty(NumStimthresh),NumStimthresh = 10000; end
 	if isempty(maxCbalDevthresh),maxCbalDevthresh = 10000; end
	if isempty(maxFreqDevthresh),maxFreqDevthresh = 10000; end
else
	docriterion = 0;
end

maxrestthresh = 2;					% max number of rests in a row.

% ----------------------------------------------------------------
% * hox gene setup
% ---------------------------------------------------------------- 
if numhox > 0
    hoxlist = hoxsetup(numhox,hoxrange,sizeGenerations);
end
if numhox > 0, disp('Hox range:'), hoxrange, end


% ----------------------------------------------------------------
% * Set up block contrast, if trans2block
% ----------------------------------------------------------------

if GA.trans2block && isfield(GA, 'blockcontrast') && GA.blockcontrast
    
    a = [ones(GA.restevery, 1); zeros(GA.restlength, 1)]; ab = [a; -a];
    blkstimlist = repmat(ab, ( ceil(2 * size(stimList, 1)) ./ length(ab) ), 1);
    blkmodel = sampleInSeconds(blkstimlist,ISI);
    blkmodel = resample(blkmodel,1,TR*10);
    blkmodel = blkmodel(1:numsamps, :);
    
end

% ----------------------------------------------------------------
% * save initial list matrix
% ----------------------------------------------------------------
if dorests
    save initial_designs listMatrix restMatrix contrasts svi
else
    save initial_designs listMatrix contrasts svi
end

% d-optimality: we need the whitening matrix, inv(svi), rather than svi
% i think...
if dflag, svi = pinv(svi);  end

% -------------------------------------------------------------------------------------------------
% * genetic algorithm
% ---------------------------------------------------------------------------------------------------

%try

for generation = 1:numGenerations+1
	
	% -------------------------------------------------------------------------------------------------
	% * set up rna (ready to model) lists and initialize generation variables
	% -------------------------------------------------------------------------------------------------
	
	gentime = cputime;
	
	rna = dna2rna(listMatrix,restMatrix,restlength,numStim,dorests,trans2switch,trans2block,dofirst);
    
	countnoqualify = 0;
    genMaxNumStim = 0;
    genMaxDev = 0;
    genMaxFreqDev = 0;
    genFreqMat = zeros(size(conditions));
    genmaxrest = 0;
	
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	% * WITHIN A GENERATION
 	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	for z = 1:sizeGenerations % do this for each organism in the generation
		stimList = double(rna(:,z));

        
            % check that no conditions are missing
            if length(unique(stimList)) < nconds   % we have some missing ones; not a valid design
                fitnessMatrix(:, z) = 0;
                
                fprintf('Warning: Some designs are incomplete (too few event types). \nYou may have too many conditions for the length of time you''re using.');
                
                continue
            end
                
		% -------------------------------------------------------------------------------------------------
		% * counterbalancing
	    %  only performs counterbalancing up to length of conditions vector - so leaves out 1st trial in 'dofirst'. 
      	% if (cbalColinPowerWeights(1) > 0)    removed 3/30 to implement criterion rather than weights.
		% -------------------------------------------------------------------------------------------------

		if (cbalColinPowerWeights(1) > 0) | (docriterion & maxCbalDevthresh < 10000)
   			[cBal,dummy,maxDev] = getCounterBal(stimList, maxOrder,conditions,freqConditions);
    		if (cbalColinPowerWeights(1) > 0),fitnessMatrix(1,z) = cBal; end
		else
			maxDev = 0;				% satisfy criterion without testing if this criterion not specified.
		end
   
	  
		% -------------------------------------------------------------------------------------------------
		% * discrepancy from desired frequencies
		% -------------------------------------------------------------------------------------------------
                 
    	if (cbalColinPowerWeights(4) > 0) | docriterion
			[maxFreqDev,fitnessMatrix(4,z),freqMat] = calcFreqDev(stimList,conditions,freqConditions);
		elseif docriterion
			[maxFreqDev,omega,freqMat] = calcFreqDev(stimList,conditions,freqConditions);
		end
	  
	 
		% -------------------------------------------------------------------------------------------------
		% * hard-constraint criteria
		% -------------------------------------------------------------------------------------------------
	
	    go = 1;
	    if docriterion
	  	[maxNumStim,maxrest] = getMaxInARow(stimList,dojitter); 
	  		if maxNumStim > NumStimthresh | maxrest > maxrestthresh | maxDev > maxCbalDevthresh | maxFreqDev > maxFreqDevthresh
		  		go = 0;
		  		countnoqualify = countnoqualify + 1;
	          	genMaxNumStim = genMaxNumStim + maxNumStim;
                genMaxDev = genMaxDev + maxDev;
                genMaxFreqDev = genMaxFreqDev + maxFreqDev;
                genFreqMat = genFreqMat + freqMat;
                genmaxrest = genmaxrest + maxrest;
			end
		end
	
	 
		% -------------------------------------------------------------------------------------------------
		% * efficiency
		% -------------------------------------------------------------------------------------------------
	
    	if (cbalColinPowerWeights(2) > 0) & go   % build predictor set of vectors and convolve with HRF

			model = designvector2model(stimList,ISI,HRF,TR,numsamps,nonlinthreshold,S);
            
            % add Block effect for mixed block/ER
            % Kludgy insertion. tor: 5/6/08
            if GA.trans2block && isfield(GA, 'blockcontrast') && GA.blockcontrast
                testcontrasts = blkdiag(1, contrasts);
                testmodel = [blkmodel model];

                xtxitx = pinv(testmodel);   % a-optimality   % inv(X'S'SX)*(SX)'; pseudoinv of (S*X)
                fitnessMatrix(2,z) = calcEfficiency([1 contrastweights],testcontrasts, xtxitx, svi, dflag);
            else
                % Original code, used in most cases
                if dflag
                    xtxitx = model'*svi*model;  % d-optimality
                    fitnessMatrix(2,z) = calcEfficiency(contrastweights,contrasts,xtxitx,[],dflag);
                else
                    xtxitx = pinv(model);   % a-optimality   % inv(X'S'SX)*(SX)'; pseudoinv of (S*X)
                    fitnessMatrix(2,z) = calcEfficiency(contrastweights,contrasts,xtxitx,svi,dflag);
                end

            end

		elseif 	docriterion & ~go    %(cbalColinPowerWeights(2) > 0 | cbalColinPowerWeights(3) > 0) & ~go  
			fitnessMatrix(2,z) = -1000;
		else
			fitnessMatrix(2,z) = 0;
		end
	
        % -------------------------------------------------------------------------------------------------
		% * HRF shape estimation efficiency
		% -------------------------------------------------------------------------------------------------
	
    	if (cbalColinPowerWeights(3) > 0) & go   % build predictor set of vectors and convolve with HRF

            delta = [];
            for i = 1:max(stimList(:,1))
                delta(:,i) = (stimList == i);
            end
            
            % how much HRF estimation we do (up to 30 s) matters
            % we want at least as long as the expected actual response
			[model] = tor_make_deconv_mtx2(delta,round(30 / TR),TR / ISI);  % hard-coded for 30 s of HRF estimation
            
            % add Block effect for mixed block/ER
            % Kludgy insertion. tor: 5/6/08
            if GA.trans2block && isfield(GA, 'blockcontrast') && GA.blockcontrast
                model = [blkmodel model];
            end
            
            if ~isempty(S), model = S * model; end
            
            if dflag
                xtxitx = model'*svi*model;  % d-optimality
                fitnessMatrix(3,z) = calcEfficiency([],[],xtxitx,[],dflag);
            else
        	    xtxitx = pinv(model);   % a-optimality   % inv(X'S'SX)*(SX)'; pseudoinv of (S*X)
                fitnessMatrix(3,z) = calcEfficiency([],[],xtxitx,svi,dflag);
            end
		   
		elseif 	docriterion && ~go    %(cbalColinPowerWeights(2) > 0 | cbalColinPowerWeights(3) > 0) & ~go  
			fitnessMatrix(3,z) = -1000;
		else
			fitnessMatrix(3,z) = 0;
		end
        
   	end

   	clear model,clear maxNumStim,clear maxDev,clear maxFreqDev,clear cBal,clear dummy,clear stimList,clear go,clear xtxitx
   
   
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	% * AFTER EACH GENERATION
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	[overallFitness,mostFit,f] = getOverallFitness(cbalColinPowerWeights,fitnessMatrix);

   % Determine variability in population - rough measure
   % -------------------------------------------------------------------------------------------------
   popuv = abs(corrcoef(double(listMatrix)));
   popVar(generation) = 1 - mean(mean(popuv));  
   clear popuv
   
   % save summary info
   % -------------------------------------------------------------------------------------------------
   %warning off
   bestCbal(generation) = f(1);
   bestVar(generation) = f(2);
   %warning on
   
   qualifyinglists(generation) = sizeGenerations - countnoqualify;
   
   if size(cbalColinPowerWeights,2) > 3, bestFreq(generation) = f(4);,end
   bestHrf(generation) = f(3);
   clear f;
    
   % print summary of this generation to screen
   % -------------------------------------------------------------------------------------------------
   str = (['best of generation ' num2str(generation)]);
   if (cbalColinPowerWeights(1) > 0),
       str = [str ' / cbal. = ' num2str(bestCbal(generation))];
   end
   if (cbalColinPowerWeights(2) > 0),
        str = [str ' / Wtd. con eff = ' num2str(bestVar(generation))];
   end
   if (cbalColinPowerWeights(3) > 0),
        str = [str ' / Wtd. HRF eff = ' num2str(bestHrf(generation))];
   end
   if docriterion
        str = [str ' / ok lists = ' num2str(sizeGenerations - countnoqualify)];
   end
   str = [str ' / Pop var. = ' num2str(popVar(generation)) ' / time = ' num2str(cputime - gentime)];
   
   disp(str)

   if countnoqualify > sizeGenerations - 11
       disp('Warning: Most designs do not meet your hard constraint criteria. You are not likely to be able to')
       disp('optimize this design without removing some hard constraints!')
       disp(' ')
       fprintf('You specified a max of %01d stim of the same type in a row.  Average in designs: %3.1f', GA.NumStimthresh, genMaxNumStim/sizeGenerations)
       disp(['Avg. deviation from freqs = ' num2str(genMaxFreqDev/sizeGenerations)])
       disp(['Avg. deviation from counterbal = ' num2str(genMaxDev/sizeGenerations)])   
       disp(['Avg. frequencies are = ' num2str(genFreqMat./sizeGenerations)]) 
       disp(['Avg. max cond 5 is = ' num2str(genmaxrest./sizeGenerations)])        
       disp(' ')
       
   end
	 
	% Save best of this generation
	% -------------------------------------------------------------------------------------------------
	if dorests
		myDesign = dna2rna(listMatrix(:,mostFit),restMatrix(:,mostFit),restlength,numStim,dorests,trans2switch,trans2block,dofirst);
	else
		myDesign = dna2rna(listMatrix(:,mostFit),[],restlength,numStim,dorests,trans2switch,trans2block,dofirst);
	end
	bestMat(:,generation) = myDesign(:,1);	

    % -------------------------------------------------------------------------------------------------
   	% * crossbreeding
   	% -------------------------------------------------------------------------------------------------
   	if generation < numGenerations+1 & (cputime - clockStart) < maxTime	     
   		if dorests
		  	[listMatrix,restMatrix] = breedorgs(overallFitness,listMatrix,alph,restMatrix);
	  	else
		  	listMatrix = breedorgs(overallFitness,listMatrix,alph);
	  	end
 	end
    
    
    % ----------------------------------------------------------------
    % * check for zeros in stimlist
    % ----------------------------------------------------------------
   %  nzeros = any(sum(listMatrix == 0));


    % -------------------------------------------------------------------------------------------------
   	% * 10% random burst if pop var is low
   	% -------------------------------------------------------------------------------------------------
    if popVar(generation) < .40
        if trans2block,
            listMatrix = tenPercentRandom(listMatrix,mostFit,conditions(1:floor(length(conditions)./2)));
        else,
            listMatrix = tenPercentRandom(listMatrix,mostFit,conditions);
        end
    end
    
	% Save in-process results for recovery in case of crash
	% -------------------------------------------------------------------------------------------------
	
    if mod(generation,10) == 0,
		save listMat_working
        % try, pack, catch, end
    end

	totalGenTime(generation) = cputime - clockStart;
		 
	
	% Monitor time and break if over
	% -------------------------------------------------------------------------------------------------
	if (cputime - clockStart) > maxTime	
		break
	end
		
	 % just test this to see if contrast variance is the same btwn modelDiagnostics and optimizeGA
	 % remove this later.  it's slow.
	 % --------------------------------------------------------------------------------------------------
	 %test = modelDiagnostics(bestMat(:,generation),'stimList','all',ISI,TR,contrasts,'noplot');
	 %disp(['	///modelDiagnostics: se    is ' num2str(test.sebeta) ' / eff is ' num2str(1./test.sebeta)])
	 %disp(['	///modelDiagnostics: conse is ' num2str(test.consebeta) ' / eff is ' num2str(1./test.consebeta)])
	 %disp(['	///modelDiagnostics: convar is ' num2str(test.consebeta.^2) ' / eff is ' num2str(1./test.consebeta.^2)])
	 %xtxitx = pinv(test.modelatTR);
	 %gamoddiagvar = xtxitx*svi*xtxitx'
	 %[fit,testlistconvarorig,xtxi] = testlist(bestMat(:,generation),GA,HRF)
	 %[fit,testlistconvarafterM,xtxi] = testlist(test.stimlist,GA,HRF)
	 
	 
		 
end  % generations loop - finish ev. algorithm


%catch
%    dbstack
%    disp('Error in GA process.')
%    lasterr
%    keyboard
%end



% AFTER ALL GENERATIONS
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %


disp('saving workspace as GAresults.mat')
save GAresults



M.origlist = listMatrix(:,mostFit);
if dorests,M.restlist = restMatrix(:,mostFit);,end
M.stimlist = myDesign;
M.ga = GA;
M.ga.bestCbal = bestCbal;
M.ga.bestCVar = bestVar;
M.ga.bestHrf = bestHrf;
if size(cbalColinPowerWeights,2) > 3,M.ga.bestFreq = bestFreq;,end
M.ga.popVar = popVar;
M.ga.totalGenTime = totalGenTime;

M.ga.qualifyinglists = qualifyinglists;
M.ga.numStimEachCond = numStimEachCond;
M.ga.numGenerations = numGenerations;
M.ga.sizeGenerations = sizeGenerations;
M.ga.nonlinthreshold = nonlinthreshold;
M.ga.listMatrix = listMatrix;
M.bestLists = bestMat;
date = clock;
M.date = [num2str(date(2)) '-' num2str(date(3)) '-' num2str(date(1))]


try
	if plotFlag
    	M = modelDiagnostics2(M,'screen');
	else
    	M = modelDiagnostics2(M,'noplot');
	end
catch
	disp('Error in modelDiagnostics2')
	lasterr
	keyboard
end


% PLOT additional OUTPUT
% -------------------- %
if plotFlag
   figure
	subplot(5,1,1)
	plot(bestCbal, 'g')
	title('Counterbalancing of best individual in each generation')
	subplot(5,1,2)
	plot(bestVar, 'b')
	title('Max. predictor colinearity of best individual in each generation')
	subplot(5,1,3)
	plot(qualifyinglists, 'r')
     title('Number of lists satisfying criteria in each generation')
   subplot(5,1,4)
	plot(bestFreq, 'k')
   title('Max % discrepancy between actual and specified frequencies')
   subplot(5,1,5)
   plot(popVar, 'm')
   title('Population variability - 1 is uncorrelated columns, 0 is all identical organisms')
   set(gcf,'Position',[232   258   560   420]); % [612    55   665   889]);
   format short g
    format compact
    disp('Elapsed Time for this run')
    elapsedTime = clock - clockStart
end

disp(['optimizeGA done: ' num2str(cputime-clockStart) ' s']) 
return




% ====== Sub-functions =================================================================

function outList = transform2switches(stimList)
% assumes 2 stimtypes, 1 and 2
% classifies them into no switch (1 and 2) or switch (3 and 4)
outList(1,1) = stimList(1,1);
for i = 2:size(stimList,1)
   switch stimList(i-1,1)		% based on previous trial
   case 1
      if stimList(i,1) == 2, outList(i,1) = 4;,else outList(i,1) = stimList(i,1);,end
   case 2
      if stimList(i,1) == 1, outList(i,1) = 3;,else outList(i,1) = stimList(i,1);,end
   case 5
      if i > 2 & stimList(i,1) == 1 & stimList(i-2,1) == 2, outList(i,1) = 3;
      elseif i > 2 & stimList(i,1) == 2 & stimList(i-2,1) == 1, outList(i,1) = 4;
      else outList(i,1) = stimList(i,1);
      end
   otherwise outList(i,1) = stimList(i,1);
   end
end
return



% USE INDEPENDENT FUNCTION TRANSFORM2BLOCK
%function sl = transform2block(sl,rl,restlength)
% sl and rl are stimlist and restlist.
% now is NOT compatible with a separate jitter blank rest interval.

%maxnum = max(sl);
%if doblank, maxnum = maxnum-1;,end

%for i = 2:2:length(rl)
%     start = sum(rl(1:i-1)) + restlength * length(rl(1:i-1)) + 1;
%     stop = min(start + rl(i) - 1,length(sl));
%     sl(start:stop) = sl(start:stop) + maxnum;
%end

%return



function [max,maxrest] = getMaxInARow(stimList,dojitter)
	max = 1; counter = 1;maxrest = 1;counterrest = 1;
        if dojitter, restnum = max(stimList);,else restnum = Inf;,end
	for i = 2:size(stimList,1)
		if stimList(i,1) == stimList(i-1,1)& ~stimList(i,1) == 0,
			counter = counter + 1;
			if counter > max, max = counter;,end
		else counter = 1;
                end
                
                if dojitter
                     if stimList(i,1) == restnum & stimList(i-1,1) == restnum
                        counterrest = counterrest+1;
                        if counterrest > maxrest,maxrest = counterrest;,end
                     else counterrest = 1;
		     end
                end

	end

return
	

