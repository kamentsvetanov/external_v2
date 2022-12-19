function x = IWT2_SBS(wc,L,qmf,dqmf)
% IWT2_SBS -- Inverse 2d Wavelet Transform
%            (symmetric extention, bi-orthogonal)
%  Usage
%    x = IWT2_SBS(wc,L,qmf,dqmf)
%  Inputs
%      wc    2-d wavelet transform [n by n array, n arbitrary]
%      L     coarse level
%      qmf   low-pass quadrature mirror filter
%      dqmf  high-pas dual quadrature mirror filter
%  Outputs
%      x     2-d signal reconstructed from wc
%  Description
%      If wc is the result of a forward 2d wavelet transform, with
%           wc = FWT2_SBS(x,L,qmf,dqmf)
%      then x = IWT2_SBS(wc,L,qmf,dqmf) reconstructs x exactly if qmf is a nice
%      quadrature mirror filter, e.g. one made by MakeBioFilter
%  See Also:
%    FWT2_SBS, MakeBioFilter

% Author Thomas P.Y. Yu, 1996
% Part of WaveLab Version 802

% FracLab 2.05 Beta, Copyright � 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

        [m,J] = dyadlength(wc(:,1));
        [n,K] = dyadlength(wc(1,:));
	% assume m==n, J==K

	x = wc;
	
	dpm = dyadpartition(m);
	
	for jscal=L:J-1,
	  bot = 1:dpm(jscal+1);
	  top = (dpm(jscal+1)+1):dpm(jscal+2); 
	  all = [bot top];
	  
	  nc = length(all);
	  
	  for iy=1:nc,
	    x(all,iy) =  UpDyad_SBS(x(bot,iy)', x(top,iy)', qmf, dqmf)';
	  end
	  for ix=1:nc,
	    x(ix,all) = UpDyad_SBS(x(ix,bot), x(ix,top), qmf, dqmf);
	  end
	end
    
