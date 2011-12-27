%function rectify_and_stereo(i1, i2)
i1 = 2;
i2 = 6;
addpath toolbox/
addpath rectify/
addpath gcs/

fprintf('Loading data from previous steps ...\n');
load ('../data/glue_cameras-02-output.mat', 'K', 'cameras', 'X');
images = initialize_empty_images_structure();

P1 = K*cameras{i1};
P2 = K*cameras{i2};

fprintf('Loading images %s) and %s).\n', images(i1).figId, images(i2).figId);
images(i1).img=imread(images(i1).filename);
images(i2).img=imread(images(i2).filename);

F = cameras2F(P1,P2);

fprintf('Computing rectifying homographies and rectifying images...\n');
[H1, H2, im1r, im2r] = rectify(F, images(i1).img, images(i2).img);

im1r = im1r(1:2:end, 1:2:end);
im2r = im2r(1:2:end, 1:2:end);

H1 = diag([0.5 0.5 1])*H1;
H2 = diag([0.5 0.5 1])*H2;

fprintf('Computing disparity map of the pair...\n');
D = gcs(im1r, im2r, []);
P1r = H1*P1;
P2r = H2*P2;

%%

fprintf('Saving intermediate results...\n');
pair_str = [num2str(i1, '%02u') '-' num2str(i2, '%02u')];
save(['../data/rectify_and_stereo_pair-', pair_str, '.mat']);

%% 

fprintf('Computing image point coordinates and colors...\n');

% Size of border used to avoid reconstructing near-border artifacts
BORDER = 40;
HEIGHT = size(images(i1).img, 1);
WIDTH = size(images(i1).img, 2);

ok = ~isnan(D);     % valid disparities

% prepare arrays for points and their colors
u1 = ones(3,sum(sum(ok)));  % point coordinates in the first (rectified) picture
u2 = ones(3,sum(sum(ok)));  % point coordinates in the second (rectified) picture
c = zeros(3,sum(sum(ok)));  % colors of these points

n = 0;
for i = 1:size(im1r, 1)
    pts_in_row = sum(ok(i,:));  % valid disparities count in current row
    if (pts_in_row == 0)
        continue;
    end
    
    col_ix = find(ok(i,:));     % indices of points with valid disparities
    
    % coordinates of points in current row in 1st pic (having valid disparities)
    u1_in_row = [col_ix; i*ones(1,pts_in_row); ones(1,pts_in_row)];
    
    % coordinates of these points in original picture (before rectification)
    u1_orig = round(p2e(H1\u1_in_row));
    % indices of points with valid disparities having sufficient distance from the border
    inside_border = find(u1_orig(1,:) > BORDER & u1_orig(1,:) < WIDTH - BORDER ...
            & u1_orig(2,:) > BORDER & u1_orig(2,:) < HEIGHT - BORDER);
    
    ok_pts_in_row = size(inside_border,2);  % useful points count
    
    if (ok_pts_in_row == 0)
        continue;
    end
    
    new_points_ix = (n+1):(n+ok_pts_in_row); % indices of useful points
	
    % coordinates
    u1(:, new_points_ix) = u1_in_row(:, inside_border);
    u2(1:2, new_points_ix) = [col_ix(inside_border) - D(i,col_ix(inside_border)); i*ones(1,ok_pts_in_row)];
    
    % colors
    for j = 1:ok_pts_in_row
        c(:,new_points_ix(j)) = images(i1).img(u1_orig(2,inside_border(j)), u1_orig(1,inside_border(j)), :);
    end    
	n = n + ok_pts_in_row;
end

u1 = u1(:,1:n);
u2 = u2(:,1:n);
c  =  c(:,1:n);

%%

fprintf('Computing space points (reprojections)...\n');

tic;
X2 = Pu2X(P1r, P2r, u1, u2);
XX = X2(:,1:10:end);
toc
%%
% save(['../data/points_from_stereo_pair_', pair_str, '.mat'], 'XX', 'P1r', 'P2r', 'H1', 'H2', 'P1', 'P2', 'F', 'i1', 'i2');
% export_to_vrml(['../data/points_from_stereo_pair_', pair_str, '.wrl'], {P1, P2}, XX);

% export_to_vrml(['../data/points_from_stereo_pair_', pair_str, '-both_results.wrl'], {P1, P2}, [X, XX], [ [1 0 0]'*ones(1,size(X,2)), [0 1 0]'*ones(1,size(XX,2)) ]);

export_to_vrml(['../data/points_from_stereo_pair_', pair_str, '-color.wrl'], {P1, P2}, X2, c/255);

save('../data/rectify_and_stereo-output.mat');

%% Display rectified images

% figure(1); imshow(im1r);
% figure(2); imshow(im2r);
% 
% assert(size(im1r,1) == size(im2r,1));
% umax = max(size(im1r,2), size(im2r,2));
% 
% j = 1000;
% figure(1); h1 = line([1, umax], [j, j]);
% figure(2); h2 = line([1, umax], [j, j]);


%end