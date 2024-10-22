function Yg = cat_vol_grad(Ym,vx_vol,noabs)
% ----------------------------------------------------------------------
% gradient map for edge description
%
% Yg = cat_vol_grad(Ym,vx_vol,noabs)
%
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
% $Id: cat_vol_grad.m 1791 2021-04-06 09:15:54Z gaser $

  if ~exist('vx_vol','var'), vx_vol=ones(1,3); end
  Ym = single(Ym); 
  Ynan = isnan(Ym); 
  [D,I] = cat_vbdist(single(~Ynan),cat_vol_morph(~Ynan,'d',1)); Ym(D<2) = Ym(I(D<2)); % replace nan
  clear D I; 
  [gx,gy,gz] = cat_vol_gradient3(single(Ym)); 
  if exist('noabs','var') && noabs
    Yg = gx./vx_vol(1) + gy./vx_vol(2) + gz./vx_vol(3); 
  else
    Yg = abs(gx./vx_vol(1)) + abs(gy./vx_vol(2)) + abs(gz./vx_vol(3)); 
  end
  Yg(Ynan) = 0; % restore nan?
  %Yg = Yg ./ (Ym+eps);
return
