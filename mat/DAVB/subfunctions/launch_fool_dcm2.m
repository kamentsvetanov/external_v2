% [TBC]

lo.theta = [0.25 0.5 1];
lo.sigma = [1e0 1e1 1e2];
N = 100;

RandStream.setDefaultStream ... 
     (RandStream('mt19937ar','seed',sum(100*clock)));

fdir = 'D:\MatlabWork\Routinetheque\DAVB_new\results_missingRegions';

for k = 1:N
    
    for i=1:length(lo.sigma)
        
        for j=1:length(lo.theta)
            
            fsave = [fdir,filesep,...
                'missingRegion_',...
                num2str(i),'_',...
                num2str(j),'_',...
                num2str(k),'.mat'];
            
            disp(' ')
            disp('---------------------------------------------------')
            
            if ~~~exist(fsave,'file')
                save(fsave,'i','j','k')
                disp(['Simulation ',fsave,' ...'])
                [y,post,out,post12,out12] = demo_missingRegion(lo,i,j);
                save(fsave,'lo','i','j','k','y','post','out','post12','out12')
            else
                disp(['Skipping ',fsave,' ...'])
            end
            
            
        end
        
    end
    
end