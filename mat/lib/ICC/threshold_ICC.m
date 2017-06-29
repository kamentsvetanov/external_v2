%script that calulates plots the median value of ICC_2A_con, within the 
%regions defined by the thresholded regions of spmT_0001, against the 
%thresholds (imput by user). The thresholdidng is continously increased, 
% to check for positive networks, and decresed, to check negative ones.  
%__________________________________________________________________________
clear all
global defaults
spm_defaults;

sel1=['']; 
    
[root,sts1] = spm_select(Inf,'dir','Select working directory...',sel1, ...
                         pwd,'.*',[]);
cd(root); 


threshold=spm_input('thresholds',2,'e',0,NaN);

th=0;                           %dummy network
net=[pwd,'/spmT_0001.img'];
file1=[pwd,'/spmT_0001.img'];       
%file2=[pwd,'/ICC_2A_con.img'];


%net=[pwd,'/con_0001.img'];
%file1=[pwd,'/sigmar.img'];       
file2=[pwd,'/corr_spmT_0001.img'];

[datreg, datregn, datregnn] = network(th,net, file1, file2);

D1=datreg(:,1);
        D2=datreg(:,2);
        D1=D1(D2~=0);
        D2=D2(D2~=0);
    for i=1:size(threshold,2)
        
        %NETWORK        
        D2n=D2(D1>=threshold(i));  %define networks from whole volume data
        D1n=D1(D1>=threshold(i));

                
        sD2n=sort(D2n);
        medianN1=sD2n(floor((length(D2n)+1)/2));
        N1cci(1)=sD2n(floor((length(D2n)+1)/2  -sqrt(length(D2n))/2*2.575));
        N1cci(2)=sD2n(floor((length(D2n)+1)/2  +sqrt(length(D2n))/2*2.575));
        NetStErr = abs(N1cci(1)-N1cci(2))/2;
        sigmaNet = NetStErr/2.575;
        
        threshold_icc(i)=medianN1./100;
        threshold_err_icc(i)=NetStErr./100;
               
        
        %NETWORK        
        D2dn=D2(D1<-threshold(i));
        D1dn=D1(D1<-threshold(i));
        
                
        sD2dn=sort(D2dn);
        medianN1=sD2dn(floor((length(D2dn)+1)/2));
        N1cci(1)=sD2dn(floor((length(D2dn)+1)/2  -sqrt(length(D2dn))/2*2.575));
        N1cci(2)=sD2dn(floor((length(D2dn)+1)/2  +sqrt(length(D2dn))/2*2.575));
        NetStErr = abs(N1cci(1)-N1cci(2))/2;
        sigmaNet = NetStErr/2.575;
        
        threshold_iccd(i)=medianN1./100;
        threshold_err_iccd(i)=NetStErr./100;
               
end;

figure;
errorbar([-threshold], [threshold_iccd], [threshold_err_iccd])
hold on
errorbar([threshold], [threshold_icc], [threshold_err_icc])
hold off
ylabel('Median ICC'); xlabel('t-threshold');