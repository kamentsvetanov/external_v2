
% run Monte-Carlo simulations for the missing region problem

lo.theta = [1];
lo.sigma = [1e0 1e1 1e2 1e4];
TR = [0.5 1 2 4];
N = 20;
try
    RandStream.setDefaultStream ...
        (RandStream('mt19937ar','seed',sum(100*clock)));
catch
    randn('seed',sum(100*clock))
end

fdir = 'D:\MatlabWork\Routinetheque\davb\results_sDCM2';

for k = 1:N
    
    for i=1:length(lo.sigma)
        
        for j=1:length(TR)
            
            for MR = 1:2
                
                if TR(j) >= 1
                    sTR = num2str(TR(j));
                else
                    sTR = '05';
                end
                fsave = [fdir,filesep,...
                    'result_sigma',num2str(lo.sigma(i)),...
                    '_TR',sTR,...
                    'MR',num2str(MR),...
                    '_',num2str(k),'.mat'];
                
                disp(' ')
                disp('---------------------------------------------------')
                
                if ~~~exist(fsave,'file')
                    save(fsave,'i','j','k')
                    disp(['Simulation ',fsave,' ...'])
                    [y,simul,post,out,post12,out12] = demo_missingRegion(lo,i,1,MR,TR(j));
%                     [y,simul,post,out,post12,out12] = demo_missingRegion2(lo,i,1,MR,TR(j));
                    save(fsave,'lo','i','j','k','y','simul','post','out','post12','out12')
                else
                    disp(['Skipping ',fsave,' ...'])
                end
                
            end
            
        end
        
    end
    
end