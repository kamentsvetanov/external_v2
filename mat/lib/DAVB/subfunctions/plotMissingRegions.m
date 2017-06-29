
lo.theta = [1];
lo.sigma = [1e0 1e1 1e2 1e4];
TR = [.5 1 2 4];
N = 20;

comp = 'C';
display = 'F';


for MR = 1:2
    hff(MR) = figure('color',ones(1,3));
    if MR ==1
        str = ' : 1 --> (2) --> 3';
    else
        str = ' : (2) --> 1 and 3';
    end
    set(hff(MR),'name',['missing region: pb #',num2str(MR),str])
    for i=1:length(lo.sigma)
        for j=1:length(TR)
            ha = subplot(4,4,(i-1)*4+j,'parent',hff(MR));
            if isequal(comp,'A')
                if isequal(display,'F')
                    hb = bar(ha,...
                        [real(mr(MR).sAF{i,j})-real(mr(MR).sAF{i,j}),...
                        real(mr(MR).dAF{i,j})-min(real(mr(MR).dAF{i,j}))]);
                else
                    hb = bar(ha,[mr(MR).swon{i,j},mr(MR).dwon{i,j}]);
                end
            else
                if isequal(display,'F')
                    hb = bar(ha,...
                        [real(mr(MR).sCF{i,j})-real(mr(MR).sCF{i,j}),...
                        real(mr(MR).dCF{i,j})]-min(real(mr(MR).dCF{i,j})));
                else
                    hb = bar(ha,[mr(MR).sCwon{i,j},mr(MR).dCwon{i,j}]);
                end
            end
            set(hb(1),'facecolor',[0 0.4980 0])
            set(hb(2),'facecolor',[0.8706 0.4902 0])
            title(ha,...
                ['SNR=',num2str(lo.sigma(i)),...
                ' ; TR=',num2str(TR(j))])
            set(ha,...
                'xlim',[.5 5.5],...
                'xtick',[1:5],...
                'xticklabel',{'1','2','3','4','5'})
            if ~isequal(display,'F')
                set(ha,'ylim',[0 N])
            end
            box(ha,'on')
            grid(ha,'on')
        end
    end
end

