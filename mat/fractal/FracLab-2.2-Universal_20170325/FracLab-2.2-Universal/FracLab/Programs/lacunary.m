function lac = lacunary(N,H,L,QMF)
% LACUNARY Generates a process using a Lacunary discret Wavelet transform
%
%   LAC = LACUNARY(N,H,L,QMF) Generates the process, LAC, using a sample
%   size, N, a Holder exponent, H, a Lacunarity coefficient, L, and a
%   quadrature mirror filter QMF. The parameter N is a positive integer,
%   and the parameters H and L are reals in (0,1).
%
%   Example
%
%       N = 1024; H = 0.5; L = 0.9; t = linspace(0,1,N);
%       QMF = MakeQMF('daubechies',2);
%       x = lacunary(N,H,L,QMF);
%       figure; plot(t,x);
%       title('Process with Lacunary Wavelet H = 0.5, L = 0.9 and 2-daubechies filter');
%       xlabel('time');
%
%   See also wave1f, MAKEQMF, FWT, IWT
%
% Reference page in Help browser
%     <a href="matlab:fl_doc lacunary ">lacunary</a>

%   Author Paulo Goncalves, October 1998
% Modified by Christian Choque Cortez, October 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(4,4);
nargoutchk(1,1);

%--------------------------------------------------------------------------
noctaves = floor(log2(N));
xinit = zeros(1,N);
[wt,wti,wtl] = FWT(xinit,noctaves,QMF);

for j = 1 : noctaves
  ncoef = round(2^((noctaves-j)*L));
  % determination aleatoire des positions lacunaires sans remise
  if ncoef <= 2^(noctaves-j-1) % selection des ncoef coefficients non nuls
      Pos = floor(rand(1,ncoef) .* wtl(j));
      [PosSort,PosIdx] = sort(Pos);
      ii = find(diff(PosSort) == 0);
      Multi = ~isempty(ii);
      while Multi
          Pos(PosIdx(ii+1)) = floor(rand(size(ii)) .* wtl(j));
          [PosSort,PosIdx] = sort(Pos);
          ii = find(diff(PosSort) == 0);
          Multi = ~isempty(ii);
      end
  elseif ncoef > 2^(noctaves-j-1) % selection des (2^(J-j)-ncoef) coefficients nuls
      PosZero = floor(rand(1,2^(noctaves-j)-ncoef) .* wtl(j));
      [PosZeroSort,PosZeroIdx] = sort(PosZero);
      ii = find(diff(PosZeroSort) == 0);
      Multi = ~isempty(ii);
      while Multi
          PosZero(PosZeroIdx(ii+1)) = floor (rand(size(ii)) .* wtl(j));
          [PosZeroSort,PosZeroIdx] = sort(PosZero);
          ii = find(diff(PosZeroSort) == 0);
          Multi = ~isempty(ii);
      end
      Pos = ones(1,2^(noctaves-j));
      Pos(PosZero+1) = zeros(size(PosZero));
      Pos = find(Pos) - 1;
  end
  wt(wti(j) + Pos) = ones(1,ncoef) .* 2^(H*j);  
  % for a L-Infty normalization:
  wt(wti(j) + Pos) = wt(wti(j) + Pos) .* 2^(j/2); 
end

lac = IWT(wt) ;