
addpath toolbox/

% load('../data/Kcalib.mat', 'K');

% load('../data/stereo_all_pairs.mat');

%%
X = cell(1,8);

for i = 1:8
    
    i1 = i;
    i2 = i + 4;
    P1 = diag([0.5 0.5 1])*K*cameras{i1};
    P2 = diag([0.5 0.5 1])*K*cameras{i2};
    im1 = imread(images(i1).filename);
    im2 = imread(images(i2).filename);
    im1 = im1(1:2:end,1:2:end,:);
    im2 = im2(1:2:end,1:2:end,:);
    
    ppos = pos{11+i};
    filtered_ix = find(filter_points(Xvert{i}, Xvert{2}, pos{13}, cameras));
    X{i} = nan(size(im1));

    for j = filtered_ix
        X{i}(ppos(2,j), ppos(1,j), :) = p2e(Xvert{i}(:,j));
    end
end

%%

psr(X);

