function [mes,fs] = multinomstoc(base,s,varargin)
% MULTINOMSTOC Generates pre-multifractal stochastic measures related to
%              Multinomial Measure
%
%   MES = MULTINOMSTOC(BASE,S) Generates the pre-multifractal measure, MES,
%   using a base of the multinomial, BASE, and a number of scales, S. 
%   The parameters BASE and S are positive integers superior to 2 and 
%   defining the sample size, N, of MES as N = BASE^S.
%
%   MES = MULTINOMSTOC(...'METHOD') Generates MES using a specific method. The
%   possible METHOD options that can be applied are 'shufmeas' in order to
%   synthesize a shuffled multinomial measure or 'pertmeas' in order to synthesize
%   a perturbated multinomial measure or 'unifmeas' in order to synthesize a
%   multinomial measure with uniformly distributed weights or 'lognmeas' in order
%   to synthesize a multinomial measure with log normaly distributed weights.
%   If METHOD is not specified, the default value is METHOD = UNIFMEAS.
% 
%   [MES,fs] = MULTINOMSTOC(...) Generates MES and computes its multifractal
%   spectrum, fs. The output fs is a structure that contains the spectrum,
%   fs.spec, and the holder exponents, fs.exp.
%   
%   Example
%
%       %Synthesis of pre-multifractal stochastic measure MES
%       b = 2; s = 10; N = b^s; t = linspace(0,1,N);
%       x = multinomstoc(b,s);
%       figure; plot(t,x);
%       title ('Pre-multifractal MES, stochastic multinomial measure'); xlabel ('time');
%
%   See also multinom
%
%   References
%
%      [1] Carl J. G. Evertsz and Benoit B. MandelBrot, "Multifractal Measures",
%          Chaos and Fractals, New Frontiers of Science, Appendix B,
%          Peitgen, Juergens and Saupe, Springer Verlag, Springer Verlag (1992) 921-953.
%
%      [2] Benoit B. MandelBrot, "A class of Multinomial Multifractal Measures 
%          with negative (latent) values for the "Dimension" f(alpha)",
%          Fractals' Physical Origins and Properties, Proceeding of the Eric Meeting, 1988 
%          L. Pietronero, Plenum Press, New York (1989) 3-29.
%
%      [3] Benoit B. MandelBrot, "Limit Lognormal Multifractal Measures",
%          Frontiers of Physics, Landau Memorial Conference, Proceeding of Tel-Aviv Meeting, 1988
%          Errol Asher Gotsman, Yuval Ne'eman and Alexander Voronoi, New York Pergamon (1990) 309-340.
%
%
% Reference page in Help browser
%     <a href="matlab:fl_doc multinomstoc ">multinomstoc</a>

% Author Christian Choque Cortez, October 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
        
narginchk(2,4);
nargoutchk(1,2);

if ~(base >=2 && base <= 10) , error('The base value must be in (2,10)'); end
if nargin > 2
    arguments = varargin;
    list1 = {'pertmeas'}; % with second argument, cell with weight vector and perturbation
    list2 = {'shufmeas','lognmeas'}; % with second argument, weight vector or variance
    list3 = {'unifmeas'}; % no argument needed
    
    [method, arguments] = checkforargument(arguments,list1,'unifmeas','wo');
    if strcmp(method{1},'unifmeas')
        [method, arguments] = checkforargument(arguments,list2,'unifmeas','wo');
    end
    if strcmp(method{1},'unifmeas')
        [method, arguments] = checkforargument(arguments,list3,'unifmeas');
    end
    if strcmp(method{1},'lognmeas') || strcmp(method{1},'shufmeas') || strcmp(method{1},'pertmeas')
        if length(method) ~= 2, error('Invalid use of method property'); end
        switch(method{1})
            case 'lognmeas'
                if ~isscalar(method{2}), error('Invalid use of method property'); end
                if method{2} <= 0, error('Invalid use of method property'); end
            case 'shufmeas'
                if ~isnumeric(method{2}), error('Invalid use of method property'); end
                vp = method{2};
                if length(vp) ~= base, error(['Weights vector must have ',num2str(base),' elements']); end
                if sum(vp) ~= 1, error('The sum of weights must be equal to 1'); end
            case 'pertmeas'
                if ~iscell(method{2}) || length(method{2}) ~= 2, error('Invalid use of method property'); end
                parameters = method{2};
                if ~isnumeric(parameters{1}) || ~isnumeric(parameters{2}), error('Invalid use of method property'); end
                vp = parameters{1};
                if length(vp) ~= base, error(['Weights vector must have ',num2str(base),' elements']); end
                if sum(vp) ~= 1, error('The sum of weights must be equal to 1'); end
                if parameters{2} >= min(vp), error('Perturbation parameter must be inferior to the smaller weight'); end
        end
    end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    method = {'unifmeas'};
end
if nargout > 1, nspec = 'spec'; else nspec = 'nospec'; end

%--------------------------------------------------------------------------
Npoints_spec = 200;

if length(method) == 2
    switch(method{1})
        case 'lognmeas'
            variance = method{2};
            mes = smultim1d(base,method{1},s,variance); % calling the mex-file
            if strcmp(nspec,'spec')
                [a,f] = smultim1d(base,'lognspec',Npoints_spec,variance); % calling the mex-file
                fs = struct('exp',a,'spec',f);
            end
            
        case 'shufmeas'
            mes = multim1d(base,vp,method{1},s); % calling the mex-file
            if strcmp(nspec,'spec')
                [a,f] = multim1d(base,vp,'spec',Npoints_spec); % calling the mex-file
                fs = struct('exp',a,'spec',f);
            end
            
        case 'pertmeas'
            perturbation = parameters{2};
            mes = multim1d(base,vp,method{1},s,perturbation); % calling the mex-file
            if strcmp(nspec,'spec')
                [a,f] = multim1d(base,vp,'spec',Npoints_spec); % calling the mex-file
                fs = struct('exp',a,'spec',f);
            end
    end
else
    mes = smultim1d(base,method{1},s); % calling the mex-file
    if strcmp(nspec,'spec')
        [a,f] = sbinom('unifspec',Npoints_spec); % calling the mex-file
        fs = struct('exp',a,'spec',f);
    end
end
mes = mes';

end