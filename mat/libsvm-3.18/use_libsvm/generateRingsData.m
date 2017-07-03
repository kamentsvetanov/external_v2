% Generate non-linear-boundary decision data set
N1 = 80;
d1 = generateCircularData2D(2,3,1,N1);
N2 = 80;
d2 = generateCircularData2D(4,6,0.5,N2);
N3 = 80;
d3 = generateCircularData2D(7,8,1,N3);
N4 = 80;
d4 = generateCircularData2D(9,10,1,N4);

data = [d1;d2;d3;d4];
label = [1*ones(N1,1); 2*ones(N2,1); 3*ones(N3,1); 4*ones(N4,1)];

figure; 
scatter(data(:,1),data(:,2),30,label,'o','filled');

save('ring_4Class_train','data','label');