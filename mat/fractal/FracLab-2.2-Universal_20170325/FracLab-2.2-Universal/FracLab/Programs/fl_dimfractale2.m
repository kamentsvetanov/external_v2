function [dim,handlefig]=fl_dimfractale2(f,Nepsilonmin,Nepsilonmax,a,b,reg,RegParam)
% FL_DIMFRACTALE2 estimates the box dimension of a 1D signal using the
%   variation method.
%
%   [DIM, FIG] = fl_dimfractale2(F, MINSCALE, MAXSCALE, 0, 1, REGRANGE, REGPARAM)
%   estimates the box dimension of the 1D signal F, which is returned in DIM in REG = 0. 
%   If REG = 1, the function displays a figure on which the user can
%   manually define the range used for the regression. Otherwise, this
%   range is chosen automatically.
%   Parameters MINSCALE and MAXSCALE define the minimum and maximum scales
%   used in the variation method. 
%   The parameter REGPARAM defines the type of regression used. See the help of monolr 
%   for more informations.
%   
%   Example
%
%       N = 1024 ; H = 0.8 ; t = linspace(0,1,N);
%       x = fbmwoodchan(N,H) ;
%       dim = fl_dimfractale2(x,4,2^8,0,1,0,'ls');
%
%   See also regdim1d, boxdim_classique, boxdim_listepoints,
%   boxdim_binaire, lacunarity
%   
%   References
%       [1] Dubuc, B, Quiniou, J. F., Roques-Carmes, C.,Tricot, C. and Zucker, S. W.
%           "Evaluating the fractal dimension of profiles",
%           Phys. Rev. A,39 (3),p.1500-1512, Feb. 1989
%
% Reference page in Help browser
%     <a href="matlab:fl_doc fl_dimfractale2 ">fl_dimfractale2</a>

% Modified by Paul Balanca, June 2011

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------


s=size(f);
N=s(1);

pas=(b-a)/N;

%epsilonend=(b-a)/N
%V=zeros(nbpoints,1);

V=zeros(Nepsilonmax,2);
oscillation=fl_oscillation2(f,Nepsilonmax,a,b);

%pas=abs(epsilonend-epsilonstart)/nbpoints;

h_waitbar = fl_waitbar('init');
for(i=1:Nepsilonmax)
    fl_waitbar('view',h_waitbar,i,Nepsilonmax);
    epsilon=i*pas;
    V(i,1)=log(1/epsilon);
    V(i,2)=log((1/(epsilon*epsilon))*fl_variations(f,i,oscillation,a,b));
end
fl_waitbar('close',h_waitbar);
 

%figure; plot(V(Nepsilonmin:Nepsilonmax,1),V(Nepsilonmin:Nepsilonmax,2));

%dim=regression(V(Nepsilonmin:Nepsilonmax,2),V(Nepsilonmin:Nepsilonmax,1));
[dim,handlefig]=fl_regression(V(Nepsilonmin:Nepsilonmax,1)',V(Nepsilonmin:Nepsilonmax,2)','a_hat','BoxDimension',reg,RegParam);
