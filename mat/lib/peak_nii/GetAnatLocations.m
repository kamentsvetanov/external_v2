function GetAnatLocations(AnatomicalDistTable,cluster,popup)
 

for ii=1:numel(cluster)
    rind=AnatomicalDistTable.Data(:,1)==cluster(ii);
    cind=find(AnatomicalDistTable.Data(rind,3:end)>0);
    cind=cind+1;
    tmp=AnatomicalDistTable.Data(rind,cind+1)';
    [val ord]=sort(tmp,'descend');
    
    disp(['Cluster ' num2str(cluster(ii)) ':'])
    Message{1}=['Cluster ' num2str(cluster(ii)) ':'];
    for ii=1:numel(ord)
        disp(['     ' num2str(tmp(ord(ii))) '% is in the ' AnatomicalDistTable.ColHeaders{cind(ord(ii))}])
        Message{end+1}=['      ' num2str(tmp(ord(ii))) '% is in the ' AnatomicalDistTable.ColHeaders{cind(ord(ii))}];
    end
    if popup==1;
        msgbox(Message')
    end
    clear Message
    disp(' ')
end
    