%cat_vol_laplace3 Volumetric Laplace filter with Dirichlet boundary. 
%  Filter SEG within the intensity range of low and high until the changes
%  are below TH. 
% 
%  L = cat_vol_laplace3(SEG,low,high,TH)
%
%  SEG  .. 3D single input matrix
%  low  .. low boundary threshold
%  high .. high boundary threshold
%  TH   .. threshold to control the number of iterations
%          maximum change of an element after iteration
%
%  See also cat_vol_laplace3R, compile.
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
%  $Id: cat_vol_laplace3.m 1791 2021-04-06 09:15:54Z gaser $
