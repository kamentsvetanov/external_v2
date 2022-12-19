function res=PhiTempMultS(u,dt,C,G,M,alphat)
res=exp ( dt.*C.*gamma(-alphat).*((M-1i.*u).^(alphat) - M.^(alphat) + (G+1i.*u).^(alphat) - G.^(alphat)) );
end
