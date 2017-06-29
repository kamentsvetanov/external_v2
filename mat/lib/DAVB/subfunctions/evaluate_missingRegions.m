
% Loops over Monte-Carlo simulations (missing region problem)

% lo.theta = [1];
% lo.sigma = [1e0 1e1 1e2];
% TR = [.5 1 2 4];
% N = 100;

lo.theta = [1];
lo.sigma = [1e0 1e1 1e2 1e4];
TR = [.5 1 2 4];
N = 19;

% fdir = 'D:\MatlabWork\Routinetheque\DAVB_new\results_TR';
fdir = 'D:\MatlabWork\Routinetheque\davb\results_sDCM';
% Laplace = 0;

ff = zeros(4,4);
ff0 = zeros(4,4);

en.corr = zeros(length(lo.sigma),length(TR));
en.asse = en.corr;
en.rsse = en.corr;

theta.sDCM.v = en.corr;
theta.sDCM.asse = en.corr;
theta.sDCM.rsse = en.corr;
theta.dDCM = theta.sDCM;


for i=1:length(lo.sigma)
    for j=1:length(TR)
        for MR = 1:2
            mr(MR).sDCM{i,j} = zeros(3,1);
            mr(MR).dDCM{i,j} = zeros(3,1);
            mr(MR).swon{i,j} = zeros(5,1);
            mr(MR).dwon{i,j} = zeros(5,1);
            mr(MR).sCwon{i,j} = zeros(4,1);
            mr(MR).dCwon{i,j} = zeros(4,1);
            mr(MR).sAF{i,j} = zeros(5,1);
            mr(MR).dAF{i,j} = zeros(5,1);
            mr(MR).sCF{i,j} = zeros(4,1);
            mr(MR).dCF{i,j} = zeros(4,1);
        end
    end
end




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
                disp(['Loading ',fsave,' ...'])
                
                try
                    
                    lo2 = load(fsave);
                    
                    try
                        
                        % get evaluation measures
                        [o] = evaluateVB(lo2,Laplace);
                        
                        % average input noise estimation evaluation measures
                        en.corr(i,j) = ((k-1)*en.corr(i,j) + o.en.corr)./k;
                        en.asse(i,j) = ((k-1)*en.asse(i,j) + o.en.asse)./k;
                        en.rsse(i,j) = ((k-1)*en.rsse(i,j) + o.en.rsse)./k;
                        
                        % average network path coefficients evaluation measures
                        theta.sDCM.v(i,j) = ...
                            ((k-1)*theta.sDCM.v(i,j) + o.theta.sDCM.v)./k;
                        theta.sDCM.asse(i,j) = ...
                            ((k-1)*theta.sDCM.asse(i,j) + o.theta.sDCM.asse)./k;
                        theta.sDCM.rsse(i,j) = ...
                            ((k-1)*theta.sDCM.rsse(i,j) + o.theta.sDCM.rsse)./k;
                        theta.dDCM.v(i,j) = ...
                            ((k-1)*theta.dDCM.v(i,j) + o.theta.dDCM.v)./k;
                        theta.dDCM.asse(i,j) = ...
                            ((k-1)*theta.dDCM.asse(i,j) + o.theta.dDCM.asse)./k;
                        theta.dDCM.rsse(i,j) = ...
                            ((k-1)*theta.dDCM.rsse(i,j) + o.theta.dDCM.rsse)./k;
                        
                        % average missing region BMS indices
                        stmp = mr(MR).sDCM{i,j}(o.MR.sDCM.err+1);
                        dtmp = mr(MR).dDCM{i,j}(o.MR.dDCM.err+1);
                        mr(MR).sDCM{i,j}(o.MR.sDCM.err+1) = stmp +1;
                        mr(MR).dDCM{i,j}(o.MR.dDCM.err+1) = dtmp +1;
                        
                        % get winning connectivity structure and group F
                        stmp = mr(MR).swon{i,j}(o.MR.sDCM.won);
                        dtmp = mr(MR).dwon{i,j}(o.MR.dDCM.won);
                        mr(MR).swon{i,j}(o.MR.sDCM.won) = stmp +1;
                        mr(MR).dwon{i,j}(o.MR.dDCM.won) = dtmp +1;
                        mr(MR).sAF{i,j} = mr(MR).sAF{i,j} ...
                            + sum(o.MR.sDCM.F,2);
                        mr(MR).dAF{i,j} = mr(MR).dAF{i,j}...
                            + sum(o.MR.dDCM.F,2);
                            
                        
                        % get winning input driving effect and group F
                        stmp = mr(MR).swon{i,j}(o.MR.sDCM.Cwon);
                        dtmp = mr(MR).dwon{i,j}(o.MR.dDCM.Cwon);
                        mr(MR).sCwon{i,j}(o.MR.sDCM.Cwon) = stmp +1;
                        mr(MR).dCwon{i,j}(o.MR.dDCM.Cwon) = dtmp +1;
                        mr(MR).sCF{i,j} = mr(MR).sCF{i,j} ...
                            + sum(o.MR.sDCM.F,1)';
                        mr(MR).dCF{i,j} = mr(MR).dCF{i,j}...
                            + sum(o.MR.dDCM.F,1)';

                        
                    catch
                        
                        disp(['nothing in ',fsave,' ...'])
                        break
                        
                    end
                    
                catch
                    
                    disp(['no file named ',fsave,' ...'])
                    break
                    
                end
                
                
            end
            
        end
        
    end
    
end



