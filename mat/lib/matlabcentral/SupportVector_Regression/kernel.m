function ker=kernel(x,xi,k)

if k=='g'
    for i=1:length(x)
        ker(i)=exp(-norm(x(i,:)-xi)); %gaussian Kernel
    end
elseif k=='l'
    for i=1:length(x)
        ker(i)=x(i,:)*xi'; %linear Kernel
    end
elseif k=='p'
    for i=1:length(x)
        ker(i)=(x(i,:)*xi').^3; %poly3 Kernel
    end
end

end