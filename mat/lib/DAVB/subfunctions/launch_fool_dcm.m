% [TBC]



lo.theta = -[4 2 1];
lo.sigma = [1e0 1e1 1e2];
% N = 20;

RandStream.setDefaultStream ... 
     (RandStream('mt19937ar','seed',sum(100*clock)));

fdir = 'D:\MatlabWork\Routinetheque\DAVB\results_sDCM';

for k = 21:100
    
    for i=1:length(lo.sigma)
        
        for j=1:length(lo.theta)
            
            fsave = [fdir,filesep,...
                '0fdcmWhrf_',...
                num2str(i),'_',...
                num2str(j),'_',...
                num2str(k),'.mat'];
            
            disp(' ')
            disp('---------------------------------------------------')
            
            if ~~~exist(fsave,'file')
                save(fsave,'i','j','k')
                disp(['Simulation ',fsave,' ...'])
                [y,post,out,post123,out123] = demo_fool_dcmWhrf(lo,i,j);
                save(fsave,'i','j','k','y','post','out','post123','out123')
            else
                disp(['Skipping ',fsave,' ...'])
            end
            
            
        end
        
    end
    
end