function [o] = evaluateVB(lo2,Laplace)

try
    Laplace;
catch
    Laplace = 1;
end

% Scores stochastic DCM for the missing region problem

simul = lo2.simul;
post = lo2.post;
out = lo2.out;
post12 = lo2.post12;
out12 = lo2.out12;

%--------- 1- evaluate input noise estimation
en = simul.eta(out.options.inF.n5,:);
enHat = out.suffStat.dx(out.options.inF.n5,:);
C = corrcoef(en(:),enHat(:));
o.en.corr = C(1,2);
o.en.asse = sum((en(:)-enHat(:)).^2);
o.en.rsse = sum((en(:)-enHat(:)).^2./(en(:).^2+eps));

%---------- 2- evaluate path coefficients estimation
theta = [simul.theta.*ones(2,1)];%;exp(.1)*ones(simul.MR,1)];
indAC = [out.options.inF.indA(:)];%;out.options.inF.indC(:)];
% sDCM:
sthetaHat = post.muTheta(indAC);
sV = post.SigmaTheta(indAC,indAC);
o.theta.sDCM.v = trace(sV);
o.theta.sDCM.asse = sum((theta-sthetaHat).^2);
o.theta.sDCM.rsse = sum((theta-sthetaHat).^2./(theta.^2+eps));
% dDCM:
dthetaHat = out.options.init.posterior.muTheta(indAC);
dV = out.options.init.posterior.SigmaTheta(indAC,indAC);
o.theta.dDCM.v = trace(dV);
o.theta.dDCM.asse = sum((theta-dthetaHat).^2);
o.theta.dDCM.rsse = sum((theta-dthetaHat).^2./(theta.^2+eps));

%---------- 3- missing region problem
for i=1:5
    for j = 1:4
        if Laplace
            sF(i,j) = out12{i,j}.F;
            dF(i,j) = out12{i,j}.options.init.out.F;
        else
            sF(i,j) = getF(post12{i,j},out12{i,j},0);
            dF(i,j) = getF(...
                out12{i,j}.options.init.posterior,...
                out12{i,j}.options.init.out,...
                0);
            [DCM] = exportDCMfromVBNLSS(post12{i,j},out12{i,j},[],lo2.simul.TR);
            spm_dcm_explore(DCM)
            pause
        end        
    end
end
o.MR.sDCM.F = sF;
o.MR.dDCM.F = dF;
sF1 = sum(sF,2);
dF1 = sum(dF,2);
sF2 = sum(sF,1);
dF2 = sum(dF,1);
o.MR.sDCM.won = find(sF1>=max(sF1)-3);
o.MR.dDCM.won = find(dF1>=max(dF1)-3);
o.MR.sDCM.Cwon = find(sF2>=max(sF2)-3);
o.MR.dDCM.Cwon = find(dF2>=max(dF2)-3);

if isequal(simul.MR,1) % 1 -> 2 -> 3
    o.MR.win = 1; % 1 -> 3
else %  2 -> 1 and 3
    o.MR.win = [4;5]; % 1 | 3
end
o.MR.sDCM.err = GraphDist(o.MR.win,o.MR.sDCM.won);
o.MR.dDCM.err = GraphDist(o.MR.win,o.MR.dDCM.won);

function err = GraphDist(win,won)
if isequal(win,1)
    if any(ismember(won,1))
        err(1) = 0;
    else
        err(1) = Inf;
    end
    if any(ismember(won,[3 4 5]))
        err(2) = 1;
    else
        err(2) = Inf;
    end
    if any(ismember(won,2))
        err(3) = 2;
    else
        err(3) = Inf;
    end
    err = min(err);
else
    if any(ismember(won,[4 5]))
        err(1) = 0;
    else
        err(1) = Inf;
    end
    if any(ismember(won,[1 2]))
        err(2) = 1;
    else
        err(2) = Inf;
    end
    if any(ismember(won,3))
        err(3) = 2;
    else
        err(3) = Inf;
    end
    err = min(err);
end
    
    
    