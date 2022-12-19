function res=Phi_CGMY(u  , t ,C,G,M,Y)
    tmp=t*C*gamma(-Y).*((M - 1i.*u ).^Y -   M^Y   +  (G + 1i.*u).^Y  -  G^Y );
    res=exp(tmp);
end