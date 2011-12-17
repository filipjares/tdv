%
% Task 2-1 assignment
%
% 1. Pre-compute (and save) interest point descriptors for all the input
%    images.
% 2. Estimate (and save) pairwise correspondences in all pairs between
%    input images (so e.g. for 12 input images there is 66 pairs).
% 3. Visualize correspondences for a chosen pair, e.g., as in figure1 .
% 4. Choose a triple of images and select and visualize correspondences
%    that links all the images and are consistent, as in figure3 . 

%% Add wbs to path if neccessary

addpath wbs/
addpath corresp/

%% Remove the radial distortion

% load('../data/Kcalib.mat', 'rd');
% addpath rd_undistort
% rddirundistort(rd, 'pictures/sb', 'linear_pictures/sb');

%% Read the images and compute the descriptors (1)

if( ~exist( 'wbs_default_cfg', 'file' ) )
  error( 'Cannot find WBS matcher. Probably PATH is not set.' );
end

images = initialize_empty_images_structure();

n_cam = length(images);

fprintf('Reading images ...\n');
for i = 1:n_cam
    fprintf('    image %u (%s)\n', i, images(i).filename);
    images(i).img = imread(images(i).filename);
end

fprintf('\nComputing descriptors ...\n');
cfg  = wbs_default_cfg;
for i = 1:n_cam
    fprintf('    for image %u\n', i);
    images(i).pts = wbs_describe_image(images(i).img, cfg);
end

%% Seek sparse correspondencies (2)

% Init arrays to store results of the WBS matcher in
m  = cell(n_cam, n_cam);
pc = cell(n_cam, n_cam);
combinations = nchoosek([1:n_cam], 2);

fprintf('\nSeeking correspondences for all image pairs ...\n');
for i = 1:size(combinations, 1)
    i1 = combinations(i,1);
    i2 = combinations(i,2);
    fprintf('    for image pair (%u, %u)\n', i1, i2);
    [pc{i1,i2}, m{i1,i2}] = wbs_match_descriptions( ...
                                    images(i1).pts, images(i2).pts, cfg);
end

%% Save the data found

save('../data/images_and_sparse_correspondences.mat', 'images', 'm', 'pc');

%% Visualize the correspondencies for first pair (3)

figure(1);
plot_wbs(images(1).img, images(2).img, pc{1,2}(1:2,:), pc{1,2}(3:4,:));

%% For the first three images, find consistent correspondences

% there will not be more results than the length of the shortest mXY array
results = zeros(3, min([size(m{1,2},2) size(m{2,3}, 2) size(m{1,3},2)]));
results_count = 0;

for i = 1:size(m{1,2},2)
    col_in_23 = find(m{2,3}(1,:) == m{1,2}(2,i));
    if (~isempty(col_in_23))
        col_in_13 = find(m{1,3}(2,:) == m{2,3}(2,col_in_23));
        if (m{1,3}(1,col_in_13) == m{1,2}(1, i))
            results_count = results_count + 1;
            results(:,results_count) = [m{1,2}(1, i) m{2,3}(1, col_in_23) m{1,3}(2, col_in_13)]';
        end
    end
end

results = results(:,1:results_count);

%% And display them

% plot particular images with all consistent matches shown
figure(2)
for i = 1:3
    subplot(1,3,i)
    image(images(i).img);
    axis equal tight;
    hold on;
    pts = images(i).pts;
    for j = 1:results_count
        line(pts(results(i,j)).x, pts(results(i,j)).y, 'markerfacecolor', color_hash(j), ...
        'markersize', 7, 'marker', 'o', 'color', 'w', 'linewidth', 1);
        %plot_wbs( im1, im2, pc{1,2}(1:2,:), pc{1,2}(3:4,:) )
    end
    hold off;
end;

