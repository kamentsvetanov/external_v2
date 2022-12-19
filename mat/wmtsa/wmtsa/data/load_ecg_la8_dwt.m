function [varname_list] = load_ecg_la8_dwt
% load_ecg_la8_dwt -- Load DWT coefficients (LA8 filter) for ecg times series.

% $Id: load_ecg_la8_dwt.m 612 2005-10-28 21:42:24Z ccornish $ 
  
  [wmtsa_data_path] = fileparts(which('wmtsa/data/load_ecg_la8_dwt'));
  
  WW = load([wmtsa_data_path, filesep, 'DWT', filesep, 'ecg-LA8-DWT.dat']);
  
  W = {WW};
  
  N = length(WW);
  wtf = 'la8';
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

