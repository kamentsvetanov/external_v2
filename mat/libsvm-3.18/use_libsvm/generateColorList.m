function rgbList = generateColorList(n,option)
N = n+1;
h = linspace(0,1,N)'; % H components
s = ones(N,1); % S components
v = ones(N,1); % V component
hsv = [h s v];
hsv = hsv(1:end-1,:);
rgbList = hsv2rgb(hsv);

if nargin > 1
    if strcmp(lower(option.order),'shuffle')
        augmentedIndex = [1:n; n:-1:1];
        augmentedIndex = augmentedIndex(:);
        permutedIndex = augmentedIndex(1:n)';
        rgbList = rgbList(permutedIndex,:);
    end
    
    if option.display == 1
        figure; scatter(1:n,1:n,30,rgbList,'s','filled');
    end
end