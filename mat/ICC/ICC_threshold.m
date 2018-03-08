function [dat]=ICC_threshold()
%function that plots the median value of ICC, within the 
%regions defined by the thresholded regions of spmT_0001, against the 
%thresholds (imput by user). The thresholdidng is continously increased, 
%to check for positive networks, and decresed, to check negative ones.  
%__________________________________________________________________________

global defaults
spm_defaults;


[f_act,sts] =spm_select(1,'image','spmT map...','', pwd,'^spmT.*\.img$');
[sd f ex]=fileparts(f_act);
file1=[sd '/' f '.img'];  


[f,sts] =spm_select(1,'image','ICC map...','', pwd,'^ICC.*\.img$');      
[sd f ex]=fileparts(f);
file2=[sd '/' f '.img'];  


threshold_a=spm_input('activation thresholds',1,'e',[0 1 2 3 4 5],NaN);


da = spm_input('plot deactivation?',2,'b','yes|no',['y' 'n'], 2);

if da=='y'
    threshold_d=spm_input('activation thresholds',3,'e',[-5 -4 -3 -2 -1 0],NaN);
end

th=0;                           %dummy network

net=file1;
[datreg, datregn, datregnn] = ICC_network(th,net, file1, file2);

D1=datreg(:,1);
        D2=datreg(:,2);
        D1=D1(D2~=0);
        D2=D2(D2~=0);
    for i=1:size(threshold_a,2)
        
        %NETWORK        
        D2n=D2(D1>=threshold_a(i));  %define networks from whole volume data
        D1n=D1(D1>=threshold_a(i));

                
        sD2n=sort(D2n);
        medianN1=sD2n(floor((length(D2n)+1)/2));
        N1cci(1)=sD2n(floor((length(D2n)+1)/2  -sqrt(length(D2n))/2*2.575));
        N1cci(2)=sD2n(floor((length(D2n)+1)/2  +sqrt(length(D2n))/2*2.575));
        NetStErr = abs(N1cci(1)-N1cci(2))/2;
        sigmaNet = NetStErr/2.575;
        
        threshold_icc(i)=medianN1./100;
        threshold_err_icc(i)=NetStErr./100;
    end
    
    
        %DEACTIVATED NETWORK        
    if da=='y'
        for i=1:size(threshold_d,2)
            
            D2dn=D2(D1<threshold_d(i));
            D1dn=D1(D1<threshold_d(i));
        
                
            sD2dn=sort(D2dn);
            medianN1=sD2dn(floor((length(D2dn)+1)/2));
            N1cci(1)=sD2dn(floor((length(D2dn)+1)/2  -sqrt(length(D2dn))/2*2.575));
            N1cci(2)=sD2dn(floor((length(D2dn)+1)/2  +sqrt(length(D2dn))/2*2.575));
            NetStErr = abs(N1cci(1)-N1cci(2))/2;
            sigmaNet = NetStErr/2.575;
        
            threshold_iccd(i)=medianN1./100;
            threshold_err_iccd(i)=NetStErr./100;
        end       
    end


figure;
set(gcf, 'color', 'white');
errorbar([threshold_a], [threshold_icc], [threshold_err_icc])
dat=[threshold_a(:) threshold_icc(:) threshold_err_icc(:)];

if da=='y'
    hold on
    errorbar([threshold_d], [threshold_iccd], [threshold_err_iccd], 'color','r')
    legend('acivated network', 'deactivated network', 'Location', 'SouthEastOutside');
    hold off
end
ylabel('median ICC'); xlabel('t-threshold');

fprintf('************** \n')
fprintf('computing done \n')