function visures(sig,sigsynt,marks)
%   Plots the the original signal and the synthetic one with the segmenta-
%   tion marks.
%
%   1.  Usage
%
%   h = visures(sig,sigsynt,marks)
%
%   1.1.  Input parameters
%
%   o  sig : Real matrix
%      Contains the original signal
%
%   o  sigsynt : Real matrix
%      Contains the synthetic signal
%
%   o  marks : Real vector
%      Contains the segmentation marks.
%
%   1.2.  Output parameters
%
%   o  h : Real scalar
%      A handle to a figure object
%
%   2.  See also:
%
%   hist, wave2gifs.
%
%   3.  Example:

% Auhtor Khalid Daoudi, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

M = sigsynt(marks) ;
N = length(sig);
%sizesig = size(sig);
%if(sizesig(1) ~= 1)
%	sig=sig';
%end
t = (1:N);
figure('Tag','graph_segment')
% figure;
plot(t,sig,'b',t,sigsynt,'g',marks,M,'r+');
	
