function [varname_list] = load_ecg_haar_dwt
% load_ecg_haar_dwt -- Load DWT coefficients (Haar filter) for ecg times series.

% $Id: load_ecg_haar_dwt.m 612 2005-10-28 21:42:24Z ccornish $ 
  
  [wmtsa_data_path] = fileparts(which('wmtsa/data/load_ecg_haar_dwt'));
  
  WW = load([wmtsa_data_path, filesep, 'DWT', filesep, 'ecg-Haar-DWT.dat']);
  
  W = {WW};
  
  N = length(WW);
  wtf = 'haar';
  J0 = 6;
  boundary = 'periodic';
  
  att.Transform = 'DWT';
  att.WTF = wtf;
  att.N = N;
  att.NW = N;
  att.J0 = J0;
  att.NChan = 1;
  att.Boundary = boundary;
  att.Aligned = 0;
  att.RetainVJ = 0;
  
  assignin('caller', 'ecg_W', W);
  assignin('caller', 'ecg_w_att', att);

  varname_list = {'ecg_W', 'ecg_w_att'};
  
return

