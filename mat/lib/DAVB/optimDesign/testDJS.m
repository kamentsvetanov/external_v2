% text script for Jensen-Shannon divergence

function testDJS

alpha1 = 2;
alpha2 = 0.5:0.5:4;
ps = 0.5*ones(2,1);

gri = -10:0.01:10;
col = repmat('rgbcmy',1,1e2);

n = 1;
In = eye(n);

mus{1} = zeros(n,1);
Qs{1} = alpha1.*In;
tmp = mus{1}-gri;
p1 = exp(-0.5*tmp.^2./Qs{1});
p1 = p1./sum(p1);

hf = figure;
ha = gca;
set(ha,'nextplot','add');

for i = 1:length(alpha2)

    
    mus{2} = zeros(n,1);
    Qs{2} = alpha2(i).*In;
    
    tmp = mus{2}-gri;
    p2 = exp(-0.5*tmp.^2./Qs{2});
    p2 = p2./sum(p2);
    
    plot(ha,gri,p2,'color',col(i+1));
    str{i} = ['model 2: v=',num2str(alpha2(i))];
    legend(str)
    
    [DJS(i),b(i)] = JensenShannon(mus,Qs,ps);
    [pe(i)] = ProbError(mus,Qs,ps);
    
    
end
plot(ha,gri,p1,'k--');
str{end+1} = 'model 1';
legend(str)

hf2 = figure;
ha2 = gca;
set(ha2,'nextplot','add')
plot(ha2,-DJS,'b')
plot(ha2,b,'r')
plot(ha2,b.^2,'r--')
plot(ha2,pe,'g')
legend({'r(u)','b(u)','b(u)^2','p(e=1|u)'})

