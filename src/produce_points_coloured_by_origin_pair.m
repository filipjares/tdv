
% pairs containing useful stereo data (omitting garbage)
pairs = [
    1,  2;
    1,  5;
    2,  6;
    3,  7;
    6,  7;
    6,  10;
    7,  11;
    8,  12;
    9,  10;
    %10, 11;
    ];

N = size(pairs,1);
X = cell(1,N);
total_points_count = 0;
all_pairs_str = [];

for i = 1:N
    i1 = pairs(i,1);
    i2 = pairs(i,2);
    pair_str = [num2str(i1, '%02u') '-' num2str(i2, '%02u')];
    all_pairs_str = [all_pairs_str, '.', pair_str];
    load(['../data/points_from_stereo_pair_', pair_str, '.mat'], 'XX');
    X{i} = p2e(XX);
    total_points_count = total_points_count + size(XX,2);
end
%%

clear XX;
XX = zeros(3,total_points_count);
cc = zeros(3,total_points_count);
last = 0;
for i = 1:N
    count = size(X{i},2);
    ix = (last+1):(last+count);
    XX(:, ix) = X{i};
    cc(:, ix) = color_hash(i)'*ones(1,count);
    last = last + count;
end

load(['../data/points_from_stereo_pair_01-02.mat'], 'P1');
export_filename_base = ['../data/points_coloured_by_origin_pair-pairs' all_pairs_str];
export_to_vrml([export_filename_base '.wrl'], {P1}, XX, cc);

%%

% plot legend:
leg = cell(1, N);
figure(1);
for i = 1:N
    i1 = pairs(i,1);
    i2 = pairs(i,2);
    pair_str = [num2str(i1, '%02u') '-' num2str(i2, '%02u')];
    plot(i, 0, 'o', 'MarkerSize', 20, 'MarkerFaceColor', color_hash(i), 'color', color_hash(i));
    if (i == 1) hold on; end;
    leg{i} = pair_str;
end
hold off;
legend(leg)

print(1, [export_filename_base '.png'], '-dpng');

