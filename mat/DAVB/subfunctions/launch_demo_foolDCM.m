% routine for simulation series of DCMs with missing regions

% launch_demo_foolDCM

lo = load('params_fool.mat');

I = length(lo.alpha);
J = length(lo.sigma);
K = length(lo.theta);

ns = 0;
n1 = 0;
n2 = 0;

bm1 = zeros(I,J,K);
bm2 = zeros(I,J,K);
d1 = bm1;
d2 = bm2;
err1 = d1;
err2 = d2;
for i=1:I
    for j=1:J
        for k=1:K
            
            ns = ns+1;
            
            fname = [pwd,filesep,'fooldcm_',...
                num2str(i),'_',...
                num2str(j),'_',...
                num2str(k),'.mat']
            
%             close all
%             demo_fool_dcm
%             save(fname)
            
            lo2 = load(fname);
            
            for ii=1:length(lo2.out123)
                F(1,ii) = lo2.out123{ii}.F;
                F(2,ii) = lo2.out123{ii}.Fns;
            end
            [mf,im] = max(F,[],2);
            
            bm1(i,j,k) = im(1);
            bm2(i,j,k) = im(2);
            
            [d1(i,j,k),err1(i,j,k)] = distDCM(im(1));
            [d2(i,j,k),err2(i,j,k)] = distDCM(im(2));
            
            
            if im(1) == 1;
                n1 = n1+1;
            end
            if im(2) == 1;
                n2 = n2+1;
            end
            
            
%             hf = figure;
%             ha = gca;
%             plot(ha,F')
%             set(ha,'nextplot','add')
%             plot(im,mf,'ro')
%             str = ['alpha=',num2str(lo2.alpha),...
%                 ' ,sigma=',num2str(lo2.sigma),...
%                 ' ,theta=',num2str(lo2.theta(6))];
%             set(hf,'name',str)
%             pause
            
        end
    end
end
            
            