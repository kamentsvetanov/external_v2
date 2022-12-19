function[H,ALPHA,vect_ech1,vect_log1,handlefig,OD]=DWTestim_all(in,time,RegParam,type_ond,siz,Reg,Tol,gamma,FindMax,radius,DeepScale,echelle)%graph,echelle)
% No help found
% Written by Pierrick Legrand, January 2005


% Modified by Pierrick Legrand, June 2011

% FracLab 2.06, Copyright © 1996 - 2011 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

in=in(:);
N=length(in);
n=floor(log2(N));
H=[];

%%%%%%%%%%% Création du filtre %%%%%%%%%%%%
if strcmp(type_ond,'Triangle')==1
    a=in(:,1);
    Na=length(a);
    if log2(Na)==floor(log2(Na))
    else
       n=ceil(log2(N));
       fl_warning('The length of the signal should be a power of 2');
       xxx=ceil(log2(Na));
       dd=zeros(1,2^xxx);
       dd(1:Na)=a;
       in=dd';
    end 

    [qmf,dqmf] = MakeBSFilter(type_ond);
    wc = FWT_SBS(in,1,qmf,dqmf);
    wc=wc';
else    
    q=MakeQMF(type_ond,siz);
    [wt,wti,wtl] =FWT(in,n,q);
end;


    

%%%%%%%%%%% Extraction des coeffs %%%%%%%%%
if strcmp(type_ond,'Triangle')==1
  c=zeros(n,2^(n-1));
  for j=1:1:n
    c(j,1:2^(j-1))=wc(2^(j-1)+1:2^(j));
  end; 
else
    c=zeros(n,-wti(1)+wti(2));
    for j=1:n
       for i=1:-wti(j)+wti(j+1)
          c(n-j+1,i)=wt(wti(j)+i-1);
       end;
    end;
end;    


%%%%%%%%%%%% Estimation du bruit %%%%%%%%%
sigma=(median(abs(c(n,:))))/0.6745;   
   
%%%%%%%%%%% Holder Function %%%%%%%%%%%%%%%%%%%%% 
   
if isempty(time) 

  h_waitbar = fl_waitbar('init');
    
  for point=1:length(in)
     vect_ech1=[];
     vect_log1=[];
     fl_waitbar('view',h_waitbar,point,length(in));
     if strcmp(type_ond,'Triangle')==1
       for j=echelle
         vect_ech1=[vect_ech1 j];
         vect_log1=[vect_log1 log2(abs(c(j,ceil((floor((1+point)/2))/2^(n-j)))))];
       end;
    else
        for j=echelle
         vect_ech1=[vect_ech1 j];
         vect_log1=[vect_log1 log2(abs(c(j,ceil((floor((1+point)/2))/2^(n-j)))))];
       end;
   end; 
     
     %t1=polyfit(vect_ech1,vect_log1,1);
     %alpha1=-0.5-t1(1);
     %ALPHA_ORIG(point)=alpha1;
     
     %vect_ech(:,point)=vect_ech1;
     vect_log(:,point)=vect_log1;
     
     if strcmp(RegParam,'linf')|strcmp(RegParam,'lsup')
        
        if FindMax==1
           [vect_ech1,vect_log1]=rad(c,point,radius,DeepScale);
        end;   
        [a,b]=regression_elimination(vect_ech1,vect_log1,RegParam,gamma,sigma*Tol);% Tol=0 revient à annuler le bruit
        pente=[a,b];
        alpha2=-0.5-pente(1);
        ALPHA(point)=alpha2;    
     elseif strcmp(RegParam,'ls')
         
        if FindMax==1
           [vect_ech1,vect_log1]=rad(c,point,radius,DeepScale);
        end;
        t2=monolr(vect_ech1,vect_log1,RegParam{1});
        ALPHA(point)=-0.5-(t2);
        %ALPHA=ALPHA_ORIG;    
     elseif strcmp(RegParam{1},'wls')
        if FindMax==1
           [vect_ech1,vect_log1]=rad(c,point,radius,DeepScale);
        end;
        RegWeight = RegParam{2}(vect_ech1)./sum(RegParam{2}(vect_ech1)) ;
        t2=monolr(vect_ech1,vect_log1,RegParam{1},RegWeight);
        t2=t2(1);
        ALPHA(point)=-0.5-t2;
     elseif strcmp(RegParam{1},'pls')
        if FindMax==1
           [vect_ech1,vect_log1]=rad(c,point,radius,DeepScale);
        end;
        t2=monolr(vect_ech1,vect_log1,RegParam{1},RegParam{2});
        t2=t2(1);
        ALPHA(point)=-0.5-t2;
     elseif strcmp(RegParam{1},'ml')
        if FindMax==1
           [vect_ech1,vect_log1]=rad(c,point,radius,DeepScale);
        end;
        t2=monolr(vect_ech1,vect_log1,RegParam{1});
        t2=t2(1);
        ALPHA(point)=-0.5-(t2);
     elseif strcmp(RegParam{1},'lapls');
        if FindMax==1
           [vect_ech1,vect_log1]=rad(c,point,radius,DeepScale);
        end;
        t2=monolr(vect_ech1,vect_log1,RegParam{1});
        t2=t2(1);
        ALPHA(point)=-0.5-(t2);   
     end;  
  end;

  
H=ALPHA;
 nb_zones = 10;
 for i=1:length(echelle)
   j=echelle(i);
   OD(i,:) = -vect_log(i,:)/j;
 end
 meanOD = mean(OD(floor(end/2):end,:),1);
 
 moy_ALPHA = fl_tendance(ALPHA,nb_zones);
 moy_meanOD = fl_tendance(meanOD,nb_zones);
	
 %H=meanOD-moy_meanOD+moy_ALPHA;(
  
  
fl_waitbar('close',h_waitbar);
            %%%%%%%%%%%%%%%%%%% Pointwise Holder Exponent %%%%%%%%%%%%

elseif isempty(Reg)|Reg==0 %full range regression
  
   point=time;
   vect_ech1=[];
   vect_log1=[];
   
   if strcmp(type_ond,'Triangle')==1
     for j=2:n
         vect_ech1=[vect_ech1 j];
         vect_log1=[vect_log1 log2(abs(c(j,ceil((floor((1+point)/2))/2^(n-j)))))];
     end;
  else 
      for j=1:n
         vect_ech1=[vect_ech1 j];
         vect_log1=[vect_log1 log2(abs(c(j,ceil((floor((1+point)/2))/2^(n-j)))))];
     end;
 end;
 
 if strcmp(RegParam,'linf')|strcmp(RegParam,'lsup')
   [ALPHA,handlefig]=fl_regression(vect_ech1,vect_log1,'-0.5-a_hat','LocalHolderExponent',2,RegParam{:},gamma,sigma*Tol); % Tol=0 revient à annuler le bruit
 else
   [ALPHA,handlefig]=fl_regression(vect_ech1,vect_log1,'-0.5-a_hat','LocalHolderExponent',2,RegParam{:});
 end

elseif Reg==1 %Specify the range
   point=time;
   vect_ech1=[];
   vect_log1=[];
   for j=1:n
         vect_ech1=[vect_ech1 j];
         vect_log1=[vect_log1 log2(abs(c(j,ceil((floor((1+point)/2))/2^(n-j)))))];
   end;
   if FindMax==1
           [vect_ech1,vect_log1]=rad(c,point,radius,DeepScale);
   end;
   
 if strcmp(RegParam,'linf')|strcmp(RegParam,'lsup')
   [ALPHA,handlefig]=fl_regression(vect_ech1,vect_log1,'-0.5-a_hat','LocalHolderExponent',Reg,RegParam{:},gamma,sigma*Tol); % Tol=0 revient à annuler le bruit
 else
   [ALPHA,handlefig]=fl_regression(vect_ech1,vect_log1,'-0.5-a_hat','LocalHolderExponent',Reg,RegParam{:});
 end
   
end;


if strcmp(type_ond,'Triangle')==1
    ALPHA=ALPHA+0.5;
end    


   

