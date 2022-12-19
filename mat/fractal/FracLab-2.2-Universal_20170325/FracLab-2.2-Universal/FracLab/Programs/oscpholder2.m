function  hp =oscpholder2(y,rmin,rmax,time ,voices,varargin)
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
reg=1:pas:Ns ;
i=time;
%u=w(:,i)';
u= w(1:pas:Ns,i)';
  
  %%%%% Suppression des doublons
%   t=1;
%   regtemp(1)=1;
%   utemp=[u(1)];
%   for i=1:length(u)-1
%       if u(i+1)~=u(i)
%           regtemp(t+1)=i+1;
%           utemp=[utemp u(i+1)];
%           t=t+1;
%       end    
%   end;
%   u=utemp;
%   reg=regtemp;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
    %%%%% Suppression des doublons
  t=1;
  regtemp(1)=reg(1);
  utemp=[u(1)];
  for i=1:length(u)-1
      if u(i+1)~=u(i)
          regtemp(t+1)=reg(i+1);
          utemp=[utemp u(i+1)];
          t=t+1;
      end    
  end;
  u=utemp;
  reg=regtemp;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  
  % ar=polyfit( log(s)-log(s(rmax)), log(u/u(rmax)+s/s(rmax)) , 1);
  % am=polyfit( log(s)-log(s(rmax)), log(max(u/u(rmax),s/s(rmax))) , 1);
  switch varargin{1}
    case  'wls'  
      RegWeight = varargin{2}(reg)./sum(varargin{2}(reg)) ;
      %[a_hat,b_hat]=monolr(log(s(reg)),log(u(reg)),varargin{1},RegWeight);
      [a_hat,b_hat]=monolr(log(s(reg)),log(u),varargin{1},RegWeight);
    case  {'linf','lsup'}
       %[a_hat,b_hat]=regression3(log(s(reg)),log(u(reg)));
       %pente=newnewreg(log(s(reg)),log(u(reg)),varargin{1},0);
       [a_hat,b_hat]=regression_elimination(log(s(reg)),log(u),varargin{:});
    %case  'lsup'
       %[a_hat,b_hat]=regression4(log(s(reg)),log(u(reg)));   
    otherwise
      %[a_hat,b_hat]=monolr(log(s(reg)),log(u(reg)),varargin{:});
      [a_hat,b_hat]=monolr(log(s(reg)),log(u),varargin{:});
  end

  hp=a_hat(1);
 % hpr(i)=ar(1);
 % hpm(i)=am(1);
%end;

figure;
%plot(log(s(reg)),log(u(reg)),'ko');hold on;
plot(log(s(reg)),log(u),'ko');hold on;
plot(log(s(reg)),hp*log(s(reg))+b_hat(1),'r');
titre=['Holder Exponent = ',num2str(hp)];
titre=num2str(titre);
title(titre);
%log(s(reg))
%plot(hp*log(s(reg))+b_hat(1)*ones(1,length(log(s(reg)))),'r');