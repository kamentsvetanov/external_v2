function mes = multinomstoc2d(base,s,varargin)
% MULTINOMSTOC2D Generates pre-multifractal 2D stochastic measures related to
%              Multinomial Measure
%
%   MES = MULTINOMSTOC2D(BASE,S) Generates the pre-multifractal measure, MES,
%   using a base of the multinomial, BASE, and a number of scales, S. 
%   The parameters BASE and S are positive integers superior to 2 and defining
%   the sample size, N, of MES as N = BASE^S.
%
%   MES = MULTINOMSTOC(...'METHOD') Generates MES using a specific method. The
%   possible METHOD options that can be applied are 'shufmeas' in order to
%   synthesize a shuffled multinomial measure or 'pertmeas' in order to synthesize
%   a perturbated multinomial measure or 'unifmeas' in order to synthesize a
%   multinomial measure with uniformly distributed weights or 'lognmeas' in order
%   to synthesize a multinomial measure with log normaly distributed weights.
%   If METHOD is not specified, the default value is METHOD = UNIFMEAS.
%   
%   Example
%
%       %Synthesis of pre-multifractal stochastic measure MES
%       b = [2 2]; s = 9;
%       x = multinomstoc2d(b,s);
%       figure; imagesc(x);
%       title ('Pre-multifractal 2D MES, uniform law multinomial measure');
%
%   See also multinom2d
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
% Reference page in Help browser
%     <a href="matlab:fl_doc multinomstoc ">multinomstoc</a>

% Author Christian Choque Cortez, October 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
        
narginchk(2,4);
nargoutchk(1,1);

if length(base) ~= 2, error('The base parameter must be 2 elements vector'); end
if ~((base(1) >=2 || base(2) >=2) && (base(1) <= 10 || base(2) <= 10)), error('The base value must be in (2,10)'); end
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
                if numel(vp) ~= prod(base), error(['Weights vector must have ',num2str(prod(base)),' elements']); end
                if size(vp,1) ~= base(1) || size(vp,2) ~= base(2), error(['Weights vector must be a ',num2str(base(1)),'x',num2str(base(2)),' vector']); end
                if sum(sum(vp)) ~= 1, error('The sum of weights must be equal to 1'); end
            case 'pertmeas'
                if ~iscell(method{2}) || length(method{2}) ~= 2, error('Invalid use of method property'); end
                parameters = method{2};
                if ~isnumeric(parameters{1}) || ~isnumeric(parameters{2}), error('Invalid use of method property'); end
                vp = parameters{1};
                if numel(vp) ~= prod(base), error(['Weights vector must have ',num2str(prod(base)),' elements']); end
                if size(vp,1) ~= base(1) || size(vp,2) ~= base(2), error(['Weights vector must be a ',num2str(base(1)),'x',num2str(base(2)),' vector']); end
                if sum(sum(vp)) ~= 1, error('The sum of weights must be equal to 1'); end
                if parameters{2} >= min(vp(:)), error('Perturbation parameter must be inferior to the smaller weight'); end
        end
    end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    method = {'unifmeas'};
end

%--------------------------------------------------------------------------
if length(method) == 2
    switch(method{1})
        case 'lognmeas'
            variance = method{2};
            mes = smultim2d(base(1),base(2),method{1},s,variance); % calling the mex-file
            
        case 'shufmeas'
            vp = vp';
            mes = multim2d(base(1),base(2),vp,method{1},s); % calling the mex-file
            
        case 'pertmeas'
            vp = vp';
            perturbation = parameters{2};
            mes = multim2d(base(1),base(2),vp,method{1},s,perturbation); % calling the mex-file
    end
else
    mes = smultim2d(base(1),base(2),method{1},s); % calling the mex-file
end
mes = mes';

end