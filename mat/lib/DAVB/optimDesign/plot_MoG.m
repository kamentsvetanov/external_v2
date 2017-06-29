function plot_MoG(Phi)

% plots 1D mixture of Gaussian densities

try
    gri = in.gri;
catch
    gri = -10:1e-2:10;
end
gri = gri(:);

mu = 2*sigm(Phi(2));
s = exp(Phi(3));

p1 = exp(-0.5*(gri-mu).^2./s);
p1 = (1./sqrt(2*pi))*(1./sqrt(s)).*p1;

p2 = exp(-0.5*(gri+mu).^2./s);
p2 = (1./sqrt(2*pi))*(1./sqrt(s)).*p2;

p3 = exp(-0.5*(gri).^2./s);
p3 = (1./sqrt(2*pi))*(1./sqrt(s)).*p3;

q = 0.5*sigm(Phi(1));

mgp = q.*p1 + q.*p2 + (1-2*q).*p3;

gx = exp(-0.5*(gri).^2);
gx = (1./sqrt(2*pi)).*gx;

try
    hf = findobj('tag','plotMoG');
catch
    hf = figure('tag','plotMoG');
end
set(hf,...
    'name',[...
    'q=',num2str(q,'%4.3e'),...
    ',mu=',num2str(mu,'%4.3e'),...
    's=',num2str(s,'%4.3e')]);
ha = axes('parent',hf);
set(ha,'nextplot','add');
plot(ha,gri,q*p1,'b');
plot(ha,gri,q*p2,'g');
plot(ha,gri,(1-2*q).*p3,'r');
plot(ha,gri,mgp,'k');
plot(ha,gri,gx,'k--');
legend({'wp1','wp2','wp3','mog','gaussian'})
