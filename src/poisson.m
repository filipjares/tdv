
addpath toolbox/
addpath psr/

% load('../data/Kcalib.mat', 'K');

% load('../data/stereo_all_pairs.mat');

%%

% pair       1st cam  2nd cam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 01               1        2
% 02               2        3
% 03               3        4
% 04               4        5
% 05               5        6
% 06               6        7
% 07               7        8
% 08               8        9
% 09               9       10
% 10              10       11
% 11              11       12
% 12               1        5
% 13               2        6
% 14               3        7
% 15               4        8
% 16               5        9
% 17               6       10
% 18               7       11
% 19               8       12

% indices of camera pairs that will be used for surface reconstruction
% (and that contain useful stereo data, omitting garbage)
pair_ixs = [
         1, ...         %    1        2
         6, ...         %    6        7
         9, ...         %    9       10
        10, ...         %   10       11
        12, ...         %    1        5
        13, ...         %    2        6
        14, ...         %    3        7
        17, ...         %    6       10
        18, ...         %    7       11
        19  ...         %    8       12
    ];
N = length(pair_ixs);  % count of pairs

X = cell(1,N);

disp('Camera pairs used for surface reconstruction are:');
for i = 1:N
    pair_index = pair_ixs(i);
    
    i1 = pairs(pair_index, 1);
    i2 = pairs(pair_index, 2);
    disp([num2str(i1, '%02u') '-' num2str(i2, '%02u')]);
    im1 = imread(images(i1).filename);
    im1 = im1(1:2:end,1:2:end,:);
    
    ppos = PosStereo{pair_index};
    filtered_ix = find(filter_points(XStereo{i}, XStereo{13}, PosStereo{13}, cameras));
    X{i} = nan(size(im1));

    for j = filtered_ix
        X{i}(ppos(2,j), ppos(1,j), :) = p2e(XStereo{i}(:,j));
    end
end

%%

psr(X);

