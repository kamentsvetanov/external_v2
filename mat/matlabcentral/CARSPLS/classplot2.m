function classplot2(X,y,flag)
%+++ flag: 0 No marker;
%          1 using clorstr
%          2 using class number;          

colorstr={'rd';'bo';'k*';'gp';'cs';'g>';'c.';};
nclass=unique(y);
iter=1;
for i=1:length(nclass)
   index_i=find(y==nclass(i));
   Xsub=X(index_i,:);
   if flag==0
     plot(Xsub(:,1),Xsub(:,2),colorstr{i});   
   elseif flag==1;
     plot(Xsub(:,1),Xsub(:,2),colorstr{i});
     text(Xsub(:,1),Xsub(:,2),num2str(iter));
   elseif flag==2;    
     plot(Xsub(:,1),Xsub(:,2),colorstr{i},'marker','none');  
     text(Xsub(:,1),Xsub(:,2),num2str(iter));  
   elseif flag==3     
     plot(Xsub(:,1),Xsub(:,2),colorstr{i});
     text(Xsub(:,1),Xsub(:,2),num2str([index_i]));    
   elseif flag==4     
     plot(Xsub(:,1),Xsub(:,2),colorstr{i});
     text(Xsub(:,1),Xsub(:,2),num2str([1:size(Xsub,1)]')); 
   end
   hold on;   
   iter=iter+1;
end







    

