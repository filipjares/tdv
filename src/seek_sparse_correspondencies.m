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

% addpath wbs/

%% Remove the radial distortion

% load('data/Kcalib.mat', 'rd');
% addpath rd_undistort
% rddirundistort(rd, 'pictures/sb', 'linear_pictures/sb');

%% Read the images and get the descriptors (1)

if( ~exist( 'wbs_default_cfg', 'file' ) )
  error( 'Cannot find WBS matcher. Probably PATH is not set.' );
end

% read images (TODO: add al the images, use my own images instead of these:)
fprintf( 'Reading images ...\n' )
im1=imread('linear_pictures/sb/IMG_5953.JPG');
im2=imread('linear_pictures/sb/IMG_5956.JPG');
im3=imread('linear_pictures/sb/IMG_5957.JPG');

% compute image descriptors
fprintf( 'Computing descriptors ...\n' )
cfg  = wbs_default_cfg;
pts1 = wbs_describe_image(im1, cfg);
pts2 = wbs_describe_image(im2, cfg);
pts3 = wbs_describe_image(im3, cfg);

%% Seek sparse correspondencies (2)

[ pc12 m12 ] = wbs_match_descriptions( pts1, pts2, cfg );
% do it for the others too
[ pc23 m23 ] = wbs_match_descriptions( pts2, pts3, cfg );
[ pc31 m31 ] = wbs_match_descriptions( pts3, pts1, cfg );

%% Visualize the correspondencies for first pair (3)

figure(1)
plot_wbs( im1, im2, pc12(1:2,:), pc12(3:4,:) )

%% For the first three images, find consistent correspondences

% there will not be more results than the length of the shortest mXY array
results = zeros(3, min([size(m12,2) size(m23, 2) size(m31,2)]));
results_count = 0;

for i = 1:size(m12,2)
    col_in_23 = find(m23(1,:) == m12(2,i));
    if (~isempty(col_in_23))
        col_in_31 = find(m31(1,:) == m23(2,col_in_23));
        if (m31(2,col_in_31) == m12(1, i))
            results_count = results_count + 1;
            results(:,results_count) = [m12(1, i) m23(1, col_in_23) m31(1, col_in_31)]';
        end
    end
end

results = results(:,1:results_count);

%% And display them

% different colors
cl = [ 1   0   0; ...
       0 0.8   0; ...
       1   1   0; ...
       0   0   0; ...
       0   0.5 0.5; ...
       0   0   1; ...
       1   0   1; ...
      .5   0   .5; ...
       1   .5  0; ...
     ];

% plot particular images with all consistent matches shown
figure(2)
images = {im1 im2 im3};
points = {pts1 pts2 pts3};
for i = 1:3
    subplot(1,3,i)
    image(images{i});
    axis equal tight;
    hold on;
    pts = points{i};
    for j = 1:results_count
        line(pts(results(i,j)).x, pts(results(i,j)).y, 'markerfacecolor',  cl(mod(j-1, size(cl,1))+1,:), ...
        'markersize', 7, 'marker', 'o', 'color', 'w', 'linewidth', 1);
        %plot_wbs( im1, im2, pc12(1:2,:), pc12(3:4,:) )
    end
    hold off;
end;

