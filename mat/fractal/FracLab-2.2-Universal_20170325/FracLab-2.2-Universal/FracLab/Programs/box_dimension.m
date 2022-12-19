function [boxdim,Nboites,taille,handlefig,bounds]=box_dimension(input_sig,Nmin,Nmax,varargin);
%   Estimates the box dimension of a 1d sample.
%
%   Computes the box dimension of the graph of a 1d sampled function.  
%   1.  Usage
%
%   o  Matlab :
%      [dim,nb,taille,handlefig]=box_dimension(input_sig,Nmin,Nmax,reg,RegParam);
%
%   1.1.  Input parameters
%
%   o  input_sig : 1d: Real vector [1,nt] 
%      Time samples of the signal to be analyzed.
%
%   o  Nmin : Integer in  [1,log2(2*floor(N/2))-1]
%      Lower size bound (lower length) of the boxes. When not
%      specified, this parameter is set to 1.
%
%   o  Nmax : Integer in  [Nmin,log2(2*floor(N/2))]
%      Upper size bound (upper length) of the boxes. When not
%      specified, this parameter is set to 5.
%
%   o  reg : 1 if you want to choose the bounds manually, 
%            0 if you want to use the full range.
%            See the help on fl_regression for more information 
%            and other possible values.
%
%   o  RegParam : Integer
%      specifies the type of regression to be used.
%
%   1.2.  Output parameters
%
%   o  dim : Real
%      estimated box dimension
%
%   o  nb :  Integer vector 
%      gives the number of non-empty boxes for each size of the box
%      from Nmin to Nmax
%   
%   o  handlefig (for Matlab only): Integer vector
%      Handles of the figures opened during the procedure.
%
%
%   2.  See also:
%
%   cwttrack, cwtspec.

% Author Ina Taralova, January 2001

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

signal1=input_sig*(1/(2*norm(input_sig,inf)));
signal1(:)=signal1(:)+0.5;
taille=2.^(-[Nmin:Nmax]);
[boxdim,Nboites,handlefig,bounds]=boxdim_classique(signal1,taille,[],[],0,varargin{:});
