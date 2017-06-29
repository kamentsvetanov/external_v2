%(c) 2012, Ameera X. Patel, University of Cambridge

function [] = compile(outname)

%_______TS NODES ______%

ts=dir('_t*1D');

for i=1:length(ts)
    eval(['load ' ts(i).name ' -ascii'])
end

tsvec=who('-regexp','X_t');

for i=1:length(tsvec)
    tsvar=eval(tsvec{i});

    if isempty(tsvar)==1
       tsvar=zeros(size(tscat(i-1),1),1);
    end

    tscat(:,i)=tsvar(:,1);
end


%_______XYZ NODES ______%

xyz=dir('__xyz*1D');

for i=1:length(xyz)
    eval(['load ' xyz(i).name ' -ascii'])
end

xyzvec=who('-regexp','X__xyz');

for i=1:length(xyzvec)
    xyzvar=eval(xyzvec{i});

    if isempty(xyzvar)==1
       xyzvar=zeros(size(xyzvec(i-1),1),1);
    end
    
    xyzcat(:,i)=xyzvar(:,1);
end


%_______N NODES ______%

n=dir('_n*1D');

for i=1:length(n)
    eval(['load ' n(i).name ' -ascii'])
end

nvec=who('-regexp','X_n');

for i=1:length(nvec)
    nvar=eval(nvec{i});

    if isempty(nvar)==1
       nvar=zeros(size(nvec(i-1),1),1);
    end

    ncat(:,i)=nvar(:,1);
end


dlmwrite(sprintf('%s_ts.txt',outname),tscat,' ')
dlmwrite(sprintf('%s_xyz.txt',outname),xyzcat,' ')
dlmwrite(sprintf('%s_n.txt',outname),ncat,' ')


end
