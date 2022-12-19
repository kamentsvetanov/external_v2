function CV=oscplscv(X,y,A,K,method,nosc)
%+++ K-fold Cross-validation for PLS
%+++ Input:  X: m x n  (Sample matrix)
%            y: m x 1  (measured property)
%            A: The max PC for cross-validation
%            K: fold. when K=m, it is leave-one-out CV
%       method: pretreatment method. Contains: autoscaling,
%               pareto,minmax,center or none.
%+++ Output: Structural data: CV
%+++ Hongdong Li, Oct. 16, 2008.

[y,index]=sort(y);
X=X(index,:);
A=min([size(X) A]);
yytest=[];YR=[];
[Mx,Nx]=size(X);
groups = 1+rem(0:Mx-1,K);
for group=1:K
    testk = find(groups==group);  calk = find(groups~=group);
    Xcal=X(calk,:);ycal=y(calk);
    Xtest=X(testk,:);ytest=y(testk); 
   %+++ OSC  
   [Xcal,RR,PP,TT,Xtest] = dosc(Xcal,ycal,Xtest,nosc);
   %+++ OSC END 
    %   data pretreatment
    if strcmp(method,'autoscaling')
      [xstd,meanx,stderror]=standard(Xcal);[ystd,meany,sigmay]=standard(ycal);xs=xstd;ys=ystd;
    elseif strcmp(method,'center')
      [xcen,meanx]=colcenter(Xcal);[ycen,meany]=colcenter(ycal);xs=xcen;ys=ycen;  
    elseif strcmp(method,'pareto');
      [xpar,meanx,stderror]=pareto(Xcal);[ypar,meany,sigmay]=pareto(ycal);xs=xpar;ys=ypar;
    elseif strcmp(method,'minmax');
      [xpar,minmaxx]=std01(Xcal);[ypar,minmaxy]=std01(ycal);xs=xpar;ys=ypar;
    elseif strcmp(method,'none');
      xs=Xcal;ys=ycal;
    else
      display('Wrong data pretreat method!');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [B,W,T,P,Q]=pls_nipals(xs,ys,A,0);   % no pretreatment.
 
    yp=[];
    for j=1:A
        B=W(:,1:j)/(P(:,1:j)'*W(:,1:j))*Q(1:j);
        %+++ calculate the coefficient linking Xcal and ycal.
        if strcmp(method,'autoscaling')
            C=sigmay*B./stderror';coef=[C;meany-meanx*C;];
        elseif strcmp(method,'center')
            coef=[B;meany-meanx*B];
        elseif strcmp(method,'pareto');
            C=sigmay*B./stderror';coef=[C;meany-meanx*C;];
        elseif strcmp(method,'minmax');
            dx=minmaxx(2,:)-minmaxx(1,:);dy=minmaxy(2)-minmaxy(1);
            C=dy*B./dx';coef=[C;-minmaxx(1,:)*C+minmaxy(1)];  
        elseif strcmp(method,'none');
            coef=B;
        end
        %+++ predict
        Xteste=[Xtest ones(size(Xtest,1),1)];if strcmp(method,'none');Xteste=Xtest;end;
        ytest_p=Xteste*coef;
        yp=[yp ytest_p];
    end
      
    
    YR=[YR;yp];yytest=[yytest;ytest];
    fprintf('The %dth group finished.\n',group);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error=YR-repmat(yytest,1,A);
PRESS=sum(error.^2);
cv=sqrt(PRESS/Mx);
[RMSEP,index]=min(cv);index=index(1);
SST=sumsqr(yytest-mean(yytest));
for i=1:A
  SSE=sumsqr(YR(:,i)-yytest);
  Q2(i)=1-SSE/SST;
end
Ypred=[YR(:,index) yytest];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++ output  %%%%%%%%%%%%%%%%
CV.method=method;
CV.RMSEP=RMSEP;
CV.Q2_all=Q2;
CV.Q2_max=Q2(index);
CV.Ypred=Ypred;
CV.cv=cv;
CV.optPC=index;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%