function [mes,fs] = multinom(base,s,vp)
% MULTINOM Generates pre-multifractal deterministic measures related to
%          Multinomial Measure
%
%   MES = MULTINOM(BASE,S,VP) Generates the pre-multifractal measure, MES,
%   using a base of the multinomial, BASE, a number of scales, S and a 
%   (BASE x 1)-vector of weight coefficients, VP. The parameters BASE and S
%   are positive integers superior to 2 and defining the sample size, N, of MES
%   as N = BASE^S, and the parameter VP are positive reals in (0,1) with a number
%   of elements equal to BASE and the sum of the elments must be equal to 1.
% 
%   [MES,fs] = MULTINOM(...) Generates MES and computes its multifractal
%   spectrum, fs. The output fs is a structure that contains the spectrum,
%   fs.spec, and the holder exponents, fs.exp.
%   
%   Example
%
%       %Synthesis of pre-multifractal measure MES
%       b = 2; s = 10; N = b^s; t = linspace(0,1,N);
%       x = multinom(b,s,[0.3;0.7]);
%       figure; plot(t,x);
%       title ('Pre-multifractal MES, deterministic multinomial measure'); xlabel ('time');
%
%   See also multinomstoc
%
%   References
%
%      [1] Carl J. G. Evertsz and Benoit B. MandelBrot, "Multifractal Measures",
%          Chaos and Fractals, New Frontiers of Science, Appendix B,
%          Peitgen, Juergens and Saupe, Springer Verlag, Springer Verlag (1992) 921-953.
%
%      [2] Benoit B. MandelBrot, "A class of Multinomial Multifractal Measures 
%          with negative (latent) values for the 'Dimension' f(alpha)",
%          Fractals' Physical Origins and Properties, Proceeding of the Eric Meeting, 1988 
%          L. Pietronero, Plenum Press, New York (1989) 3-29.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc multinom ">multinom</a>

% Author Christian Choque Cortez, October 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,3);
nargoutchk(1,2);

if ~(base >=2 && base <= 10) , error('The base value must be in (2,10)'); end
if length(vp) ~= base, error(['Weights vector must have ',num2str(base),' elements']); end
if sum(vp) ~= 1, error('The sum of weights must be equal to 1'); end
if nargout > 1, nspec = 'spec'; else nspec = 'nospec'; end

%--------------------------------------------------------------------------
Npoints_spec = 200;
mes = multim1d(base,vp,'meas',s); % calling the mex-file

if strcmp(nspec,'spec')
    [a,f] = multim1d(base,vp,'spec',Npoints_spec); % calling the mex-file
    fs = struct('exp',a,'spec',f);
end
mes = mes';

end