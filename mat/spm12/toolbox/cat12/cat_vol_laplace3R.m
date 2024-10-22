%cat_vol_laplace3R Volumetric Laplace filter with Dirichlet boundary. 
%  Filter SEG within the intensity range of low and high until the changes
%  are below TH. 
% 
%  L = cat_vol_laplace3(SEG,R,TH)
%
%  SEG  .. 3D single input matrix
%  R    .. 3D boolean volume to describe the filter area
%  TH   .. threshold to control the number of iterations
%          maximum change of an element after iteration
%
%  See also cat_vol_laplace3, compile.
% ______________________________________________________________________
%
% Christian Gaser, Robert Dahnke
% Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
% Departments of Neurology and Psychiatry
% Jena University Hospital
% ______________________________________________________________________
%  $Id: cat_vol_laplace3R.m 1791 2021-04-06 09:15:54Z gaser $
