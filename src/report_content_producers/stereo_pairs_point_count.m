
% load '../data/stereo_all_pairs.mat'

pair_ix = [1:3 5:7 9:11 12:length(pairs)];

N = length(pair_ix);

sum = 0;
for i = 1:N
    count = size(XStereo{i},2);
    fprintf('pair %2d-%d:\tcount = %7d\n', ...
        pairs(pair_ix(i),1), pairs(pair_ix(i), 2), ...
        count);
    sum = sum + count;
end

fprintf('\ntotal point count = %d\n', sum);