
addpath toolbox/

% load('../data/Kcalib.mat', 'K');

% load('../data/pairs/stereo_all_pairs.mat');

Xv = Xvert{2};
ppos = pos{13};
%%
filtered_ix = find(filter_points(Xv, ppos, cameras));

X = nan(size(im1));

for i = 1:size(filtered_ix,2)
    X(ppos(2,i), ppos(1,i), :) = p2e(Xv(:,i));
end