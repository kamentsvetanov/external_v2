function mes = multinom2d(base,s,vp)
% MULTINOM2D Generates pre-multifractal 2D deterministic measures related to
%            Multinomial Measure
%
%   MES = MULTINOM2D(BASE,S,VP) Generates the pre-multifractal measure, MES,
%   using a base of the multinomial, BASE, a number of scales, S and a 
%   (BASE x 1)-vector of weight coefficients, VP. The parameters BASE and S
%   are positive integers superior to 2 and defining the sample size, N, of
%   MES as N = BASE^S, and the parameter VP are positive reals in (0,1) with
%   a number of elements equal to BASE and the sum of the elments must be equal to 1.
%   
%   Example
%
%       %Synthesis of pre-multifractal measure MES
%       b = [2 2]; s = 9;
%       x = multinom2d(b,s,[0.1 0.2;0.3 0.4]);
%       figure; imagesc(x);
%       title ('Pre-multifractal 2D MES, deterministic multinomial measure');
%
%   See also multinomstoc2d
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
% Reference page in Help browser
%     <a href="matlab:fl_doc multinom2d ">multinom2d</a>

% Author Christian Choque Cortez, October 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(3,3);
nargoutchk(1,1);

if length(base) ~= 2, error('The base parameter must be 2 elements vector'); end
if ~((base(1) >=2 || base(2) >=2) && (base(1) <= 10 || base(2) <= 10)), error('The base value must be in (2,10)'); end
if numel(vp) ~= prod(base), error(['Weights vector must have ',num2str(prod(base)),' elements']); end
if size(vp,1) ~= base(1) || size(vp,2) ~= base(2), error(['Weights vector must be a ',num2str(base(1)),'x',num2str(base(2)),' vector']); end
if sum(sum(vp)) ~= 1, error('The sum of weights must be equal to 1'); end

%--------------------------------------------------------------------------
vp = vp';
mes = multim2d(base(1),base(2),vp,'meas',s); % calling the mex-file

mes = mes';

end