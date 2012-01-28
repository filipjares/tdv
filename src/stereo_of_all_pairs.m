%% All pairs stereo

addpath toolbox/
addpath rectify/
addpath gcs/

load ('../data/glue_cameras-02-output.mat', 'K', 'cameras');
images = initialize_empty_images_structure();
% TODO: add K to cameras

%% prepare table of (vertical and horizontal) camera pairs for stereo

% each row in the pairs table contains one pair (indices of cameras in the pair)
pairs = nan(9+8, 2);
for i = [1 2 3, 5 6 7, 9 10 11]
   pairs(i,:) = [i, i+1]; 
end
for i = 1:8
    pairs(i+11,:) = [i, i+4];
end

%% compute stereo of all the pairs

N = size(pairs,1);  % count of pairs

% prepare variables
XStereo = cell(1,N);
CStereo = cell(1,N);
PosStereo = cell(1, N);
DStereo = cell(1, N);

% process stereo
for i = 1:N
    i1 = pairs(i, 1);
    i2 = pairs(i, 2);
    fprintf('Pair %02u - %02u...\n', i1, i2);
    fprintf('\tloading data\n');
    P1 = diag([0.5 0.5 1])*K*cameras{i1};
    P2 = diag([0.5 0.5 1])*K*cameras{i2};
    im1 = imread(images(i1).filename);
    im2 = imread(images(i2).filename);
    im1 = im1(1:2:end,1:2:end,:);
    im2 = im2(1:2:end,1:2:end,:);
    fprintf('\tcomputing stereo\n');
    [XStereo{i}, CStereo{i}, PosStereo{i}, DStereo{i}] = rectify_and_stereo(i1, i2, P1, P2, im1, im2);
    clear im1 im2;
end
%% vertical pairs

save('../data/stereo_all_pairs.mat');

