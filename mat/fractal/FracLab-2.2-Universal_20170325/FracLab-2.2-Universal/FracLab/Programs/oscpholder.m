function  hp =oscpholder(y,rmin,rmax,voices, varargin)
% hp =oscpholder(y,rmin,rmax, varargin)
% y : signal
% rmin smallest oscillation scale
% rmax greatest oscillation scale

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N=max(length(y));

hp=zeros([1,N]);
hl=zeros([1,N]);
hll=hl;
Ns=(rmax-rmin+1);
[wsup s]=cmptsup(y,rmin, rmax, Ns);
winf=cmptinf(y,rmin, rmax, Ns);
w=wsup-winf;
% choose the regression points
pas=floor((Ns-1)/(voices-1));
%reg=1:pas:Ns ;


for i=1:N
  clear reg;clear u;clear utemp;clear regtemp;
  u=w(:,i)';
 
  reg=1:pas:Ns; 
  %%%%% Suppression des doublons
  t=1;
  regtemp(1)=reg(1);
  utemp=[u(1)];
  for ii=1:length(u)-1
      if u(ii+1)~=u(ii)
          regtemp(t+1)=reg(ii+1);
          utemp=[utemp u(ii+1)];
          t=t+1;
      end    
  end;
%   if length(regtemp)>length(utemp)
%      regtemp=regtemp(1:end-1); 
%   end    
  u=utemp;
  reg=regtemp;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  % ar=polyfit( log(s)-log(s(rmax)), log(u/u(rmax)+s/s(rmax)) , 1);
  % am=polyfit( log(s)-log(s(rmax)), log(max(u/u(rmax),s/s(rmax))) , 1);
  switch varargin{1}
    case  'wls'  
      RegWeight = varargin{2}(reg)./sum(varargin{2}(reg)) ;
      [a_hat,b_hat]=monolr(log(s(reg)),log(u),varargin{1},RegWeight);
    case  {'linf','lsup'}
       %[a_hat,b_hat]=regression3(log(s(reg)),log(u(reg)));
       [a_hat,b_hat]=regression_elimination(log(s(reg)),log(u),varargin{:});
    %case  'lsup'
       %[a_hat,b_hat]=regression4(log(s(reg)),log(u(reg)));   
    otherwise
      %[a_hat,b_hat]=monolr(log(s(reg)),log(u(reg)),varargin{:});
      s(reg);log(u);
      [a_hat,b_hat]=monolr(log(s(reg)),log(u),varargin{:});
  end

  hp(i)=a_hat(1);
 % hpr(i)=ar(1);
 % hpm(i)=am(1);
end;


