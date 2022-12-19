function [alpha, cfc, var_a, var_b, cov_ab] = calc_alpha_exponent(x, diagnosticPlot, order, onset)
% This program uses Discrete Wavelet Decomposition to estimate
% the scaling exponent alpha from the power-law behaviour: E(d_x(j)^2) = 2^(j*alpha)*c_f*c;
%
% x: data vector, for example, the sequence of offspring numbers;
% diagnosticPlot: if 1 then a plot of j against the estimated log E(d_x(j)^2)
% order: the order of wavelet filter coefficients, h = 4:2:20;
% onset: the lower bound of scaling region. If you don't specify
%        this input parameter, the program plots log2(E(d_x(j)^2)) against j; 
% cfc = c_f*c;
% var_a: variance of the estimator a which is defined by cfc = 2^a; 
% var_b: variance of the estimator alpha;
% cov_ab: covariance between the estimators alpha and a;
%
% This procedure is proposed by Veitch and Abry;

% Author Y. Shen, December 2002
% Modified by W. Arroum, December 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

h = dau(order);
n = length(h);  
h0 = fliplr(h);   
h1 = h;  
h1(1:2:n) = -h1(1:2:n); 

l = length(x);
nj = floor(log2(l)); 

c = x(:)';  
j = [];
y_j = [];
n_j = [];
for k = 1:nj
    l = length(c);
    c = [c(mod((-(n-1):-1),l)+1) c];   
    d = conv(c,h1);   
    d = d(n:2:(n+l-2));  
    c = conv(c,h0);  
    c = c(n:2:(n+l-2));
    j = [j;k];
    n_j = [n_j;length(d)];
    if sum(d.^2)~=0
        y_j = [y_j;log2(sum(d.^2)/length(d))];
    else
        y_j=[y_j;0];
    end
end;

g_j = -1./n_j/log(2); % asymptotic approximation
mean_y_j = y_j - g_j; 
var_y_j = 2./n_j/log(2)/log(2); % asymptotic approximation


index = find(n_j>=8);
if ~isempty(index)
    if diagnosticPlot == 1
       errorbar(j,mean_y_j,2*sqrt(var_y_j));
       hold on;
       plot(j,mean_y_j,'o');
       hold off;
    end
    j_min = onset;
    S = sum(1./var_y_j(j_min:index(end)));
    S_x = sum(j(j_min:index(end))./var_y_j(j_min:index(end)));
    S_xx = sum(j(j_min:index(end)).*j(j_min:index(end))./var_y_j(j_min:index(end)));
    if S*S_xx-S_x*S_x~=0
        var_b = S/(S*S_xx-S_x*S_x);
        var_a = S_xx/(S*S_xx-S_x*S_x);
        cov_ab = -1*S_x/(S*S_xx-S_x*S_x);

        w_j = (S*j-S_x)./var_y_j/(S*S_xx-S_x*S_x);
        v_j = (S_xx-S_x*j)./var_y_j/(S*S_xx-S_x*S_x);

        b = sum(w_j(j_min:index(end)).*mean_y_j(j_min:index(end)));
        a = sum(v_j(j_min:index(end)).*mean_y_j(j_min:index(end)));

        alpha = b;
        cfc = 2^a;
    else
        alpha=NaN;
        cfc=NaN;
        var_a=NaN;
        var_b=NaN;
        cov_ab=NaN;
    end
else
    alpha=NaN;
    cfc=NaN;
    var_a=NaN;
    var_b=NaN;
    cov_ab=NaN;
end


function h = dau(order)
if order == 4
	h = [0.4829629131445341
	0.8365163037378079
	0.2241438680420134
	-0.1294095225512604];
elseif order == 6
	h = [0.3326705529500825
	0.8068915093110924
	0.4598775021184914
	-0.1350110200102546
	-0.0854412738820267
	0.0352262918857095];
elseif order == 8
	h = [0.2303778133088964
	0.7148465705529154
	0.6308807679398587
	-0.0279837694168599
	-0.1870348117190931
	0.0308413818355607
	0.0328830116668852
	-0.0105974017850690];
elseif order == 10
	h = [0.16010239797419231755   
	0.60382926979718765104   
	0.72430852843777138172   
	0.13842814590132229702  
	-0.24229488706637955509  
	-0.03224486958463790298   
	0.07757149384004533021  
	-0.00624149021279823274  
	-0.01258075199908191381   
	0.00333572528547376171];
elseif order == 12
	h = [0.11154074335010408237
	0.49462389039843135397
	0.75113390802107049549
	0.31525035170920534533
	-0.22626469396540713208 
	-0.12976686756724714611
	0.09750160558731878202
	0.02752286553030498448
	-0.03158203931748377463 
	0.00055384220116140592 
	0.00477725751094519764
	-0.00107730108530840587];
elseif order == 14
	h = [0.07785205408501189028
	0.39653931948193121837
	0.72913209084625985046
	0.46978228740520439066
	-0.14390600392858410306
	-0.22403618499390165475
	0.07130921926682094736
	0.08061260915108464653
	-0.03802993693501364320
	-0.01657454163066688843
	0.01255099855610011805
	0.00042957797292139123
	-0.00180164070404753161
	0.00035371379997452691];
elseif order == 16
	h = [0.0544158422431072
	0.3128715909143166
	0.6756307362973195
	0.5853546836542159
	-0.0158291052563823
	-0.2840155429615824
	0.0004724845739124
	0.1287474266204893
	-0.0173693010018090
	-0.0440882539307971
	0.0139810279174001
	0.0087460940474065
	-0.0048703529934520
	-0.0003917403733770
	0.0006754494064506
	-0.0001174767841248];
elseif order == 18
	h = [0.0380779473638778
	0.2438346746125858
	0.6048231236900955
	0.6572880780512736
	0.1331973858249883
	-0.2932737832791663
	-0.0968407832229492
	0.1485407493381256
	0.0307256814793385
	-0.0676328290613279
	0.0002509471148340
	0.0223616621236798
	-0.0047232047577518
	-0.0042815036824635
	0.0018476468830563
	0.0002303857635232
	-0.0002519631889427
	0.0000393473203163];
elseif order == 20
	h = [0.0266700579005473
	0.1881768000776347
	0.5272011889315757
	0.6884590394534363
	0.2811723436605715
	-0.2498464243271598
	-0.1959462743772862
	0.1273693403357541
	0.0930573646035547
	-0.0713941471663501
	-0.0294575368218399
	0.0332126740593612
	0.0036065535669870
	-0.0107331754833007
	0.0013953517470688
	0.0019924052951925
	-0.0006858566949564
	-0.0001164668551285
	0.0000935886703202
	-0.0000132642028945];
end
