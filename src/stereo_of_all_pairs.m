%% All pairs stereo

% addpath toolbox/
% addpath rectify/
% addpath gcs/

load ('../data/glue_cameras-02-output.mat', 'K', 'cameras');
images = initialize_empty_images_structure();
% TODO: add K to cameras

Xhoriz = cell(1,8);
Choriz = cell(1,8);

% horizontal pairs
for i = 1:11
    i1 = i;
    i2 = i+1;
    fprintf('Pair %02u - %02u...\n', i1, i2);
    fprintf('\tloading data\n');
    P1 = K*cameras{i1};
    P2 = K*cameras{i2};
    im1 = imread(images(i1).filename);
    im2 = imread(images(i2).filename);
    fprintf('\tcomputing stereo\n');
    [Xhoriz{i}, Choriz{i}] = rectify_and_stereo(i1, i2, P1, P2, im1, im2);
    clear im1 im2;
end

Xvert = cell(1,8);
Cvert = cell(1,8);

% vertical pairs
for i = 1:8
    i1 = i;
    i2 = i + 4;
    fprintf('Pair %02u - %02u...\n', i1, i2);
    fprintf('\tloading data\n');
    P1 = K*cameras{i1};
    P2 = K*cameras{i2};
    im1 = imread(images(i1).filename);
    im2 = imread(images(i2).filename);
    fprintf('\tcomputing stereo\n');
    [Xhoriz{i}, Choriz{i}] = rectify_and_stereo(i1, i2, P1, P2, im1, im2);
    clear im1 im2;
end

save('../data/stereo_all_pairs.mat');

% X = []; c = [];
% for i = 1:11
%     X = [X, Xhoriz{i}];
%     c = [c, Choriz{i}];
% end
% for i = 1:8
%     X = [X, Xvert{i}];
%     c = [c, Cvert{i}];
% end;
% export_to_vrml('../data/stereo_all_pairs.wrl', cameras, X, c/255);
